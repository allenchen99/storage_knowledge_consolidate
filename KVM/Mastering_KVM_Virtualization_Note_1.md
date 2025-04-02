	##全书内容：
		1. Understanding Virtualization
		2. KVM Internal
		3. Setting Up Standalone KVM Virtualization
		4. Getting Start with libvirt and Creating Your First Virtual Machine
		5. Network and Storage
		6. Virtual Machine Lifecycle Management (理解增删查改，on/off, snapshot管理，migrate）
		7. Templates and Snapshots
		8. An HTML5-Based Management Tool for KVM libvirt
		9. Software-Defined Networking for KVM Virtualization
		10. Installing and Configurating the Virtual 
		11. Start Your First Virtual Machine in oVirt
		
		
	#1. Understanding Virtualization
	Advantages of virtualization:
		○ Server Consolidation
		○ Service Isolation
		○ Faster Server Provisioning
		○ Disaster Recovery
		○ Dynamic Load Balancing
		○ Faster development and test environment
		○ Improved system reliability and security
		○ OS independence or a reduced hardware vender lock-in
	VMware 通常了解的Virtualization:
		○ Network Virtualization
		○ Storage Virtualization
		○ Computing Virtualization
	但是此处增加了如下一些维度:
		○ Application Virtualization
		○ Software Virtualization
			§ Full (ESXi)
			§ Para Virtualization (Guest OS like HyperV and VirtualBox)
			§ Hardware Assisted (Intel VT, AMD V)
OS Virtualization/Partitioning (Solaris Container, Parellel's OpenVZ)![image](https://github.com/user-attachments/assets/8724adf8-c8e0-436d-9e23-5ece6c33bcea)
	接下来介绍现代OS对Ring 0 -3 的使用机制
		Ring 0以上是unprotected, HyperVisor在访问CPU,Memory, I/O devices时需要privileged ring, 所以Intel/AMD给VMM添加了一个Rin1. 如果没有Hardware Virtulization技术的支持， Hypervisor 基本会占用ring-0,
![image](https://github.com/user-attachments/assets/d6e860b3-4bd4-4680-ab24-8a5946d17c66)
![image](https://github.com/user-attachments/assets/0a5c7cd5-7c10-4aaa-97a7-517b552489ab)
	KVM介绍，代表最新得现代得虚拟化技术
QEMU可以虚拟磁盘，网络，VGA, PCI, USB， serial/parrallel ports![image](https://github.com/user-attachments/assets/9192072e-2434-4463-9e8b-172c39482c43)


