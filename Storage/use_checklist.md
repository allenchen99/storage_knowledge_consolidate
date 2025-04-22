# USE Method Monitoring Checklist

> For each hardware or system resource, monitor **Utilization**, **Saturation**, and **Errors**.

---

## 🧠 CPU

- **Utilization**
  - CPU 使用率（user, system, idle）
  - 每核/线程使用情况

- **Saturation**
  - 运行队列长度（run queue length）
  - 平均负载（load average）

- **Errors**
  - 中断错误（interrupt errors）
  - 上下文切换异常

---

## 🧠 Memory

- **Utilization**
  - 总内存、已用内存、剩余内存
  - 缓存和 buffer 占用
  - Swap 使用率

- **Saturation**
  - 缺页率（page faults per sec）
  - Swap 活动频率
  - 内存碎片情况（fragmentation）

- **Errors**
  - 内存分配失败（malloc fail）
  - OOM（Out Of Memory）记录

---

## 💽 Disk I/O

- **Utilization**
  - 每秒读写次数（IOPS）
  - 磁盘带宽（MB/s）
  - %util（磁盘使用时间占比）

- **Saturation**
  - I/O 队列长度（avgqu-sz）
  - 平均响应时间（await）

- **Errors**
  - I/O 错误次数
  - 磁盘重试事件
  - 磁盘 SMART 告警

---

## 🌐 Network

- **Utilization**
  - 入站/出站流量（bytes/sec）
  - 网络带宽使用率

- **Saturation**
  - TCP 连接等待（SYN_RECV）
  - 套接字使用率

- **Errors**
  - 丢包率（packet loss）
  - CRC 错误、重传数
  - 网络接口错误（rx/tx errors）

---

## 🔒 Kernel Locks / Mutex

- **Utilization**
  - 锁使用次数
  - 锁持有时间

- **Saturation**
  - 等待锁的线程数
  - 锁等待时间

- **Errors**
  - 死锁检测（deadlock）
  - 超时未释放锁

---

## 💡 GPU（如有）

- **Utilization**
  - GPU 使用率
  - 显存使用情况

- **Saturation**
  - CUDA 等待队列
  - 显存分配等待

- **Errors**
  - 驱动错误
  - 显存溢出
  - 过热告警

---

## 🔗 Database Connection Pool

- **Utilization**
  - 活跃连接数
  - 最大连接使用率

- **Saturation**
  - 连接等待时间
  - 请求排队数量

- **Errors**
  - 连接失败次数
  - 查询超时次数
  - 数据库错误日志（如 deadlock）

---

## 🔍 参考

- Brendan Gregg: [USE Method](http://www.brendangregg.com/usemethod.html)
- 推荐工具：
  - `vmstat`, `iostat`, `top`, `sar`, `perf`
  - `Grafana + Prometheus`, `Netdata`, `Zabbix`

