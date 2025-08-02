# 块设备（iSCSI / FC）端到端性能问题分析指南

## 1. 明确端到端路径

### iSCSI 路径：

```
[应用层] 
[OS IO调度层] 
[iSCSI Initiator 驱动层] 
[网络层 TCP/IP] 
[交换网络 or SAN网络]
[iSCSI Target] 
[后端块存储/RAID] 
[磁盘]
```

### FC 路径：

```
[应用层]
[OS IO栈] 
[HBA 驱动层] 
[光纤 SAN 网络] 
[FC Target] 
[后端块存储] 
[磁盘]
```

---

## 2. 分阶段分析可能瓶颈点

| 阶段                | 可能瓶颈                         | 分析手段                                    |
| ----------------- | ---------------------------- | --------------------------------------- |
| 应用层               | 小块写入、频繁 flush、顺序/随机 IO       | `strace`, `iostat`, 应用日志                |
| 块设备层              | IO 调度器（none/cfq）、bio 处理慢     | `iostat -x`, `blktrace`, `bpftrace`     |
| iSCSI Initiator 层 | 登录状态、Queue 满、session timeout | `iscsiadm`, `/proc/net/iscsi`, `dmesg`  |
| HBA层（FC）          | Queue 深度不够、驱动问题、中断瓶颈         | `systool`, `ql-dump`, `lpfc_logverbose` |
| SAN网络 / IP 网络     | 拥塞、端口错误、路径故障                 | `porterrshow`, SAN监控、ping、iperf3        |
| 多路径层              | I/O 负载不均衡、路径丢失               | `multipath -ll`, `dmsetup`, `udevadm`   |

---

## 3. 推荐工具

| 目的        | 工具/命令                                              |
| --------- | -------------------------------------------------- |
| 块设备监控     | `iostat -x 1`, `blktrace`, `bpftrace`, `fio`       |
| iSCSI 状态  | `iscsiadm -m session`, `/proc/net/iscsi`           |
| FC HBA 状态 | `systool -c fc_host -v`, `sanlun fcp show adapter` |
| 网络调优      | `ethtool -S`, `ifconfig`, `iperf`, `tcpdump`       |
| 多路径状态     | `multipath -ll`, `lsblk`, `dmsetup info`           |
| IO队列分析    | `/sys/block/sdX/queue/`, `iostat -x`               |
| Trace 分析  | `perf`, `systemtap`, `bpftrace`, `flamegraph`      |

---

## 4. 实战案例举例

### 示例 1：iSCSI 写入吞吐低

* 观察 `iostat -x 1`，发现 `await` 高达 200ms
* `tcpdump` 抓包发现未启用 Jumbo Frame，MTU 为 1500
* 修改为 `mtu=9000`，吞吐提升 40%
* 同时增加 Target 端的 queue depth，从 32 提升至 128

### 示例 2：FC 读取性能不一致

* `multipath -ll` 显示某路径 degraded
* `systool -c fc_host -v` 显示 CRC 错误
* 更换 FC 光模块，性能恢复正常

---

## 5. 总结

块设备的端到端性能分析需要从应用层、操作系统、传输协议到存储设备整体串联思考，结合工具定位瓶颈，必要时进行网络和存储协同优化，才能找到根因并进行有效调优。

---

## 附加加分点

* iSCSI 参数：`max_recv_data_segment_length`, `ImmediateData` 优化
* FC Queue Depth 调优：如 `lpfc_hba_queue_depth`, `ql2xmaxqdepth`
* 多路径策略：round-robin 与 failover 的区别
* Async IO / Direct IO / AIO 的性能差异
* iSCSI / FC 协议延迟与吞吐对比

---

# NFS 端到端性能问题分析指南

## 1. 明确端到端路径

### NFS 路径：

```
[应用层] | IO大小顺序，flush 机制，r/w cache, user类型
[VFS/NFS 客户端] | async/sync mount, mount r/w size, buffer size, file lock
[内核 TCP/IP 协议栈]
[网络] |最简单就是通过ping来检查，如果要知道具体原因就是tcpdump,
[NFS 服务端] | NAS Server， 主要通过nas server的log，已经服务器端的网络TCP/IP session等等
[本地文件系统] |nfsstat -s, 服务端的nfs thread, dead lock
[块存储] | slice allocation, 碎片整理，RAID rebuild， thread count
[磁盘] |磁盘的IOPS/Bandwidth/Latency: NLSAS/SAS/SAS Flash/NVMe Flash
```

---

## 2. 分阶段分析可能瓶颈点

| 阶段             | 可能瓶颈                                 | 分析手段                                               |
| -------------- | ------------------------------------ | -------------------------------------------------- |
| 应用层            | 小块写入、频繁 flush、顺序/随机 IO               | `strace`, `iostat`, 应用日志                           |
| OS 文件系统层 (NFS) | async vs sync mount、读写 buffer 大小、文件锁 | `nfsstat`, `nfsiostat`, `mount` 参数分析               |
| NFS 客户端        | rsize/wsize 配置、缓存一致性机制               | `nfsiostat`, `mount`, `cat /proc/fs/nfsfs/volumes` |
| 网络栈层           | 丢包、重传、NIC 瓶颈、MTU、TSO/LRO             | `ethtool`, `ss`, `netstat`, `tcpdump`              |
| 存储服务端          | NFS 服务配置、线程数、文件系统瓶颈、RAID 重建          | `nfsstat -s`, `nfsdcltrack`, 存储监控工具                |

---

## 3. 推荐工具

| 目的        | 工具/命令                                         |
| --------- | --------------------------------------------- |
| NFS 客户端状态 | `nfsiostat`, `nfsstat -c`, `mount` 参数         |
| NFS 服务端状态 | `nfsstat -s`, `systemctl status nfs-server`   |
| 网络调优      | `ethtool -S`, `ifconfig`, `iperf`, `tcpdump`  |
| Trace 分析  | `perf`, `systemtap`, `bpftrace`, `flamegraph` |

---

## 4. 实战案例

### 示例：NFS 写入延迟高

* 应用反映写入缓慢，用 `nfsiostat` 发现写延迟 >100ms
* `mount` 显示为 `sync` 挂载，导致每次写都落盘
* 更换为 `async` + 调整 `rsize/wsize=1M` 后大幅改善吞吐
* `nfsstat -s` 显示服务端 backlog 高，调大 `nfsd` 线程数

---

## 5. 总结

NFS 性能分析的关键在于客户端挂载参数、服务端配置、文件系统特性和网络链路健康状况的综合评估，善用工具组合分析具体延迟来源，往往能快速发现瓶颈并对症下药。

---

## 附加加分点

* NFS 优化参数：`async` vs `sync`, `rsize/wsize`, `noatime`
* 文件系统选择对 NFS 性能的影响（如 ext4 vs xfs）
* NFS v3 vs v4 性能对比
* 服务端 `nfsd` 线程配置与瓶颈
* NFS over RDMA 的探索与实践
