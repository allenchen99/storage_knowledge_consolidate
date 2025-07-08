
# 应用程序 I/O Pattern 分析方法（由浅入深）

## 1. 使用系统级工具采集 I/O 行为

### 🧰 Linux 工具：

| 工具               | 功能说明                               |
|--------------------|--------------------------------------|
| `iostat`           | 查看设备 IOPS、吞吐、队列深度（`-x` 参数更详细） |
| `vmstat`           | 查看系统 I/O 等待情况（`wa` 列）          |
| `pidstat -d`       | 查看每个进程的磁盘 I/O                    |
| `iotop`            | 实时查看哪些进程在做大量 I/O               |
| `dstat`            | 实时监控多维度 I/O 指标                    |
| `blktrace` / `btt` | 内核级块设备 I/O 跟踪，输出请求类型、大小、时间等 |
| `strace -e read,write` | 追踪某程序的 I/O 系统调用（粗略，但能看 syscall 级别行为） |

### 示例：

```bash
iostat -x 1
iotop -aoP   # 累计 I/O 排序
pidstat -d -p <PID> 1

## 2. 使用 fio job replay 或 workload capture 工具
如果你能控制或模拟应用，可在生产或测试环境使用工具重现并分析实际 I/O pattern。

### 🔧 方法 A：fio job trace
使用 fio 的 --write_iolog 和 --read_iolog 功能：

bash
Copy
Edit
fio --filename=/path/to/file --rw=randrw --bs=4k --runtime=60 --write_iolog=trace.log
然后可用 --read_iolog 回放、分析。

### 🔧 方法 B：replay io trace from real apps（例如 Vdbench trace 或 blktrace）
使用专业工具捕获真实应用 I/O trace

通过工具转换或自定义脚本实现重放
