
# SSD 功能测试清单（WA / WL / FTL / Cache Management）

## 1. 写放大（Write Amplification, WA）测试

- **目的**：评估实际写入量与主机写入量的比值
- **测试步骤**：
  - 使用 `fio` 工具生成顺序写入、随机写入负载
  - 使用 `smartctl -a /dev/sdX` 读取 SMART 属性：
    - Total NAND Writes
    - Host Writes
  - 计算 WA：  
    `WA = NAND 写入量 / 主机写入量`
- **评估指标**：
  - WA 接近 1（理想）
  - 随机写下 WA 显著上升则表示有优化空间

---

## 2. 磨损均衡（Wear Leveling, WL）测试

- **目的**：检测擦写次数分布是否均匀
- **测试步骤**：
  - 构造热数据（频繁写）+冷数据（长期不写）混合写入场景
  - 使用厂商工具或 SSD 模拟器（如 MQSim）查看每个块的擦写次数
- **评估指标**：
  - 块擦写次数标准差（Std Dev）
  - 最大擦写次数 - 最小擦写次数
  - SMART 属性中的“Wear Leveling Count”变化趋势

---

## 3. 地址映射（FTL）测试

- **目的**：评估 FTL 的映射效率与 GC 策略
- **测试步骤**：
  - 顺序写入：验证是否性能稳定，GC少
  - 小块随机写：检查是否频繁触发 GC
  - 写满盘 → 删除部分 → 重写：评估映射更新与GC反应
- **工具建议**：
  - `fio`, `blktrace`, `nvme-cli`
  - SSD 模拟器（如 DiskSim+SSD extension）
- **评估指标**：
  - GC触发频率
  - WA变化
  - 映射延迟（需模拟器或控制器日志支持）

---

## 4. 缓存管理（Cache Management）测试

- **目的**：验证 DRAM/SLC 缓存的性能提升与掉电风险
- **测试步骤**：
  - 写入突发大数据（超出缓存大小）→ 检查掉速点
  - 小块连续写入 → 验证缓存命中率高时的吞吐
  - 禁用缓存（如支持，如 `hdparm -W0`）对比测试
  - 掉电测试：模拟断电后验证缓存数据持久性（高端平台支持）
- **评估指标**：
  - 吞吐曲线（缓存溢出前后对比）
  - 写入延迟变化
  - 掉电数据一致性

---

## 常用工具列表

| 工具名      | 功能                             |
|-------------|----------------------------------|
| `fio`       | 构造各种 IO 负载（顺序/随机）   |
| `smartctl`  | 查看 SMART 指标（WA/WL）        |
| `nvme-cli`  | 查看 NVMe SSD 日志、健康状态    |
| `blktrace`  | 跟踪 Linux 块层 IO 行为         |
| `hdparm`    | 控制写缓存（部分SATA盘支持）    |
| MQSim/DiskSim | SSD FTL/Garbage Collection 模拟 |

---

