vSS
Scenario	Load Balancing Policy	Requires Switch LACP	Network Failure Detection	优缺点
Default/General Scenario	Route based on originating virtual port ID	❌ No	Link Status Only	简单，兼容好，但是不能充分利用多条NIC
Switch does not support LACP, optimize bandwidth	Route based on source MAC hash	❌ No	Beacon Probing	比virtual port ID稍微均衡，但是不能动态调整
Switch supports LACP, maximize bandwidth	Route based on IP hash	✅ Yes	Beacon Probing	实现真正的负载均衡，Switch LACP支持，需要至少三块NIC
(source IP+Dest IP 计算hash)
Failover only, no load balancing needed	Use explicit failover order	❌ No	Beacon Probing	仅关注HA，不许负载均衡
![image](https://github.com/user-attachments/assets/26d61d91-ee6b-42a5-84aa-f4d88da146f5)

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

vDS
Discovery protocol
- CDP
- LLDP
Uplinks: incoming nic ports
Distributed Port group: load balance增加了Route based on NIC load，无需额外配置LACP，但是需要vDS
