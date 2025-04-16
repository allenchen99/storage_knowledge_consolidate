vSS
Scenario	Load Balancing Policy	Requires Switch LACP	Network Failure Detection	优缺点
Default/General Scenario	Route based on originating virtual port ID	❌ No	Link Status Only	简单，兼容好，但是不能充分利用多条NIC
Switch does not support LACP, optimize bandwidth	Route based on source MAC hash	❌ No	Beacon Probing	比virtual port ID稍微均衡，但是不能动态调整
Switch supports LACP, maximize bandwidth	Route based on IP hash	✅ Yes	Beacon Probing	实现真正的负载均衡，Switch LACP支持，需要至少三块NIC
(source IP+Dest IP 计算hash)
Failover only, no load balancing needed	Use explicit failover order	❌ No	Beacon Probing	仅关注HA，不许负载均衡
# vSS vs vDS 对比（VMware 虚拟交换机）

| 特性/功能                 | vSS（Standard vSwitch）                            | vDS（Distributed vSwitch）                             |
|--------------------------|----------------------------------------------------|--------------------------------------------------------|
| **配置位置**              | 每台 ESXi 主机本地配置                             | vCenter 集中统一配置                                   |
| **可管理性**              | 主机间配置分离，维护成本高                         | 集中管理，多主机环境中易于统一操作                     |
| **依赖 vCenter**          | 无需依赖                                           | 强依赖 vCenter（管理/配置需要）                        |
| **配置一致性**            | 需人工确保一致，容易出错                           | 配置集中，策略一致性高                                 |
| **vMotion 支持**          | 支持，但目标主机必须配置完全一致                   | 原生支持，不需手动配置目标主机                         |
| **VLAN 支持**             | 支持                                               | 支持                                                    |
| **LACP（链路聚合）支持** | 不支持                                             | 支持（需要物理交换机端口也配置 LACP）                 |
| **NIC Teaming（网卡绑定）** | 支持，支持基于 IP Hash、源 MAC、虚拟端口等策略   | 支持所有 vSS 策略 + LACP                               |
| **Failover（故障转移）策略** | 支持多种故障检测与切换策略，如 Beacon probing    | 支持高级的故障转移与流量分布策略                        |
| **Port Mirroring（端口镜像）** | 不支持                                        | 支持                                                    |
| **NetFlow 支持**         | 不支持                                             | 支持，可用于流量分析                                    |
| **NIOC（网络资源控制）** | 不支持                                             | 支持基于流量类型的优先级策略                            |
| **备份与恢复网络配置**    | 不方便，需逐台配置                                 | 支持通过 vCenter 快速导入导出配置                      |
| **许可要求**              | 所有版本支持                                       | 需要 Enterprise Plus 许可                              |
| **适用场景**              | 小型实验室、小规模部署、独立主机环境               | 中大型数据中心、大规模虚拟化平台、私有云或混合云       |

---

## ✅ 应用场景对比

### 🔹 vSS 适用场景
- 小型环境或实验室环境
- 主机数量较少，不依赖集中管理
- 不需要高级网络特性，如 NetFlow、Port Mirroring、LACP
- 希望降低许可成本的场景

### 🔸 vDS 适用场景
- 企业级部署，ESXi 主机数量多
- 需要统一网络策略管理和配置一致性
- 高可用要求较高（如自动故障转移、链路聚合）
- 需要网络监控、流量控制等高级功能
- 对 DevOps、自动化部署友好（如配合 vSphere with Tanzu/Kubernetes）

---
### 总结
所以主要是取决于有没有LACP，如果有LACP则可以使用IP 哈希 （负载均衡和HA最好），如果简单网络配置routed based on originating virtual port ID就可以了
安全配置中 （一般情况下配置reject）
Promiscuous Mode：
	- Accept可以接受所有流量，适用于抓包分析 IDS/IPS(入侵检测），镜像流量
	- Reject只能收到发给自己的流量，保护VM之间的隔离性，适用于绝大多数场景
Mac Address Change:
	- Accept: 允许VM修改自己Mac Address
	- Rejet: VM修改自己点至网络通信会被阻断
Forged Transmits（伪造传输）
	- Accept （适用于HA 方案、虚拟路由器、网络负载均衡（NLB）、VRRP/CARP 等。）
	- Reject （源MAC地址与vSwitch记录的MAC地址不匹配）

### vDS
Discovery protocol
- CDP
- LLDP
Uplinks: incoming nic ports
Distributed Port group: load balance增加了Route based on NIC load，无需额外配置LACP，但是需要vDS
