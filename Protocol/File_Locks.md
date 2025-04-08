# 📂 文件锁机制对比：NFSv3、NFSv4 与 SMB

本表格对比了三种主流文件共享协议在文件锁机制方面的设计与实现差异，适用于分布式存储、虚拟化环境与文件服务器等场景的调研与选型。

---

## 📊 文件锁机制对比表

| 特性/协议                   | NFSv3                             | NFSv4                                          | SMB (CIFS/SMB2/SMB3)                                  |
|----------------------------|-----------------------------------|------------------------------------------------|--------------------------------------------------------|
| 协议状态性                 | 无状态（Stateless）              | 有状态（Stateful）                              | 有状态（Stateful）                                    |
| 锁管理方式                 | 外部协议 NLM + NSM               | 内建 LOCK/OPEN 操作 + stateid 管理             | 内建锁管理 + 租约 (Lease) / Oplock                    |
| 锁类型                     | 共享/排它锁                      | 共享/排它锁，强制锁（可选）                     | 共享/排它锁，Oplock/Lease 支持                        |
| 委托机制（缓存优化）       | 无                               | Delegation 支持客户端缓存                        | Oplock / Lease 提供缓存能力                           |
| 锁持久性                   | 客户端或服务器宕机后锁可能丢失   | 客户端可 RECLAIM 恢复锁                         | SMB3 支持 Persistent Handle（锁重连恢复）             |
| 锁恢复机制                 | 依赖 NSM 检测客户端状态          | 租约过期、客户端 RECLAIM                        | Oplock Break 通知 + Persistent Handle                 |
| 客户端锁检测方式           | 客户端自行判断                   | 服务器检查并统一判断冲突                        | 服务器端管理并主动通知冲突                            |
| 防火墙友好性               | 差（使用动态端口）               | 好（标准 TCP 2049）                             | 好（标准 TCP 445）                                    |
| 多客户端一致性保障         | 弱，可能锁不一致                 | 强，所有访问基于 stateid 控制                    | 强，通过租约 / Oplock 控制                            |
| 与数据库类应用兼容性       | 差（建议禁用）                   | 好（可启用强制锁）                              | 视 Oplock 配置而定，建议禁用缓存                       |
| 重连后的锁恢复能力         | 无                               | 需要在 grace period 内 RECLAIM                  | SMB3 可自动恢复（persistent handle）                  |
| 常用调试命令工具           | `rpcinfo`, `rpcdebug`, `statd`    | `rpcdebug`, `lslocks`, `showmount`              | `smbstatus`, Event Viewer, `oplocktest.exe`            |
| 常见问题                   | 锁丢失、端口封锁、锁死           | grace period 设置不当导致锁恢复失败             | Oplock break 失败可能造成锁死                         |

---

## 📝 锁恢复机制情景对比

| 场景             | NFSv3             | NFSv4                    | SMB2+（带 Lease）                     |
|------------------|-------------------|---------------------------|---------------------------------------|
| 服务器重启       | 锁丢失，需 NSM 介入 | 客户端 RECLAIM 恢复锁     | 锁可能失效，依赖租约和 Persistent Handle |
| 客户端宕机       | 锁遗留，需 NSM 清理 | 服务器定时清理失联租约   | Oplock Break 清理，避免冲突            |
| 网络闪断         | 锁易丢失           | TCP 长连接保活状态        | 租约保持 + Persistent Handle 可恢复    |

---

## ✅ 总结建议

- ✅ 推荐使用 **NFSv4 或 SMB2+** 替代 NFSv3，以获得更好的锁一致性与恢复能力。
- 🔐 SMB3 支持 persistent handle，在虚拟机存储和数据库场景下表现更优。
- ⚠️ NFSv3 使用时要格外注意锁状态同步、NLM/NSM 的状态检查和防火墙配置。


# 🔒 文件锁机制 Python 模拟实现：NFSv3、NFSv4、SMB

本文使用 Python 脚本模拟三种常见文件共享协议的文件锁机制，包括 NFSv3、NFSv4 和 SMB，用于学习文件锁行为的实现方式和差异。

---

## 📁 1. NFSv3 模拟（Stateless + 文件锁）

NFSv3 是无状态协议，文件锁功能通过 NLM（Network Lock Manager）来实现。锁机制可能丢失或因 crash 而失效。

**特点：**  
- 无状态（Stateless） 
- 依赖外部锁守护进程（如 lockd） 
- 锁不可恢复 

**Python 实现：**  

```python
# NFSv3 文件锁模拟：基于 fcntl（Unix 系统支持）
import fcntl

def nfsv3_lock(filepath):
    with open(filepath, 'r+') as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
            print("NFSv3: Lock acquired.")
            f.write("NFSv3 lock test.\n")
            input("Press Enter to release lock...")
        except BlockingIOError:
            print("NFSv3: Lock already held by another process.")
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)
            print("NFSv3: Lock released.")

# 示例调用
nfsv3_lock('/tmp/testfile.txt')
```

## 📁 NFSv4 模拟（Stateful + 可恢复锁）
NFSv4 内置文件锁支持，所有锁操作基于状态（stateid）进行管理，客户端 crash 后可重连并恢复锁。

**特点：**  
有状态（Stateful）  
支持锁恢复（crash recovery）  
支持 byte-range 锁  

**Python 实现：**
```python
# NFSv4 状态锁模拟
import threading
import time

class NFSv4Lock:
    def __init__(self):
        self.lock = threading.Lock()
        self.client_state = {}

    def acquire(self, client_id):
        if self.lock.acquire(timeout=3):
            self.client_state[client_id] = "LOCKED"
            print(f"NFSv4: Lock acquired by client {client_id}")
        else:
            print(f"NFSv4: Client {client_id} failed to acquire lock")

    def release(self, client_id):
        if self.client_state.get(client_id) == "LOCKED":
            self.client_state[client_id] = "UNLOCKED"
            self.lock.release()
            print(f"NFSv4: Lock released by client {client_id}")
        else:
            print(f"NFSv4: Client {client_id} had no lock")

# 示例调用
lock = NFSv4Lock()
lock.acquire("client-123")
time.sleep(2)
lock.release("client-123")
```

## 📁 3. SMB 模拟（带租约和 Oplock）
SMB 使用租约（Lease）和机会锁（Oplock）实现高效的客户端缓存和锁管理。客户端 crash 或断开时，服务器可回收租约。

**特点：**  
有状态（Stateful）  
支持租约机制（Lease）  
支持缓存一致性管理（Oplock）  

**Python 实现：**

```python

# SMB 租约锁模拟
import threading
import time

class SMBLeaseLock:
    def __init__(self):
        self.lock = threading.Lock()
        self.lease_timeout = 5
        self.lease_timer = None

    def acquire(self, client_id):
        if self.lock.acquire(timeout=2):
            print(f"SMB: {client_id} acquired lock with lease.")
            self.lease_timer = threading.Timer(self.lease_timeout, self.lease_expired, [client_id])
            self.lease_timer.start()
        else:
            print(f"SMB: {client_id} failed to acquire lock.")

    def lease_expired(self, client_id):
        print(f"SMB: Lease expired for {client_id}. Releasing lock.")
        self.lock.release()

    def release(self, client_id):
        if self.lease_timer:
            self.lease_timer.cancel()
        self.lock.release()
        print(f"SMB: {client_id} manually released lock.")

# 示例调用
lease_lock = SMBLeaseLock()
lease_lock.acquire("client-A")
time.sleep(3)
lease_lock.release("client-A")
```

