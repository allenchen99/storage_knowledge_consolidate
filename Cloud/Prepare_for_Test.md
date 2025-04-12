# AWS Certified Solutions Architect – Professional 备考知识点

## 一、核心 AWS 服务和概念的深入理解：

* **计算 (Compute):**
    * **EC2 (Elastic Compute Cloud):**
        * 实例类型、定价模型（On-Demand, Reserved, Spot, Savings Plans, Dedicated Hosts/Instances）、存储选项（EBS, Instance Store）、网络（ENI, ENA, EFA）、安全组、IAM 角色、启动模板/配置、Auto Scaling、负载均衡（ELB - Application Load Balancer, Network Load Balancer, Classic Load Balancer）、容器服务 (ECS, EKS, Fargate)、Serverless 计算 (Lambda)。
    * **Lambda:**
        * 事件驱动模型、执行环境、配置、版本控制、别名、部署包、监控和日志记录、集成其他 AWS 服务。
    * **容器服务 (ECS, EKS, Fargate):**
        * Docker 基础、编排概念、任务定义、服务、集群管理、网络模型、安全考量。
* **存储 (Storage):**
    * **S3 (Simple Storage Service):**
        * 存储类（Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant Retrieval, Glacier Flexible Retrieval, Glacier Deep Archive）、生命周期策略、版本控制、访问控制（ACLs, Bucket Policies, IAM Policies）、加密（SSE-S3, SSE-KMS, SSE-C）、静态网站托管、事件通知、S3 Select/Glacier Select/Athena。
    * **EBS (Elastic Block Store):**
        * 卷类型 (gp2/gp3, io1/io2, st1, sc1)、快照、生命周期管理器、加密。
    * **EFS (Elastic File System):**
        * 性能模式、吞吐模式、加密、访问控制。
    * **Storage Gateway:**
        * 文件网关、卷网关、磁带网关及其使用场景。
    * **DataSync:**
        * 数据迁移和同步服务。
* **数据库 (Database):**
    * **RDS (Relational Database Service):**
        * 支持的引擎 (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server)、实例类型、存储类型、备份和恢复、高可用性（Multi-AZ）、只读副本、安全性（加密、VPC 安全组、IAM 认证）、性能优化。
    * **DynamoDB:**
        * NoSQL 数据库概念、分区键和排序键、全局二级索引和本地二级索引、读/写容量单元、On-Demand 和 Provisioned 模式、DAX 缓存、Global Tables、Streams、安全性。
    * **Aurora:**
        * MySQL 和 PostgreSQL 兼容版本、存储自动扩展、高性能和高可用性特性。
    * **Redshift:**
        * 数据仓库概念、列式存储、数据加载和卸载、性能优化。
    * **ElastiCache (Redis, Memcached):**
        * 缓存策略、使用场景、安全性。
* **网络 (Networking):**
    * **VPC (Virtual Private Cloud):**
        * 子网、路由表、网络 ACLs、安全组、NAT Gateway、Internet Gateway、VPC Peering、Transit Gateway、PrivateLink、Direct Connect、VPN。
    * **Route 53:**
        * DNS 服务、路由策略（Simple, Failover, Geolocation, Geoproximity, Latency, Weighted, Multivalue Answer）、健康检查、域名注册。
    * **CloudFront:**
        * 内容分发网络 (CDN)、缓存策略、源服务器配置、安全（WAF 集成、Signed URLs/Cookies）。
    * **API Gateway:**
        * API 创建、管理、监控和安全、RESTful 和 WebSocket API、Throttling、CORS。
    * **Load Balancing (ELB):**
        * Application Load Balancer (HTTP/HTTPS)、Network Load Balancer (TCP/UDP/TLS)、Classic Load Balancer。
* **安全 (Security):**
    * **IAM (Identity and Access Management):**
        * 用户、组、角色、策略、权限边界、多因素身份验证 (MFA)。
    * **KMS (Key Management Service):**
        * 密钥管理、加密和解密、信封加密。
    * **Secrets Manager:**
        * 安全地存储和检索密码、API 密钥和其他敏感信息。
    * **Certificate Manager (ACM):**
        * SSL/TLS 证书的预置、管理和部署。
    * **WAF (Web Application Firewall):**
        * 保护 Web 应用程序免受常见 Web 攻击。
    * **GuardDuty:**
        * 智能威胁检测服务。
    * **Inspector:**
        * 自动化安全漏洞评估服务。
    * **Shield:**
        * DDoS 防护服务。
    * **Cognito:**
        * 用户身份验证和授权服务。
* **监控与管理 (Monitoring and Management):**
    * **CloudWatch:**
        * 指标、告警、日志、仪表盘、事件。
    * **CloudTrail:**
        * API 调用审计日志。
    * **Config:**
        * 资源配置跟踪和合规性审计。
    * **Trusted Advisor:**
        * 成本优化、安全性、容错能力、性能和配额方面的建议。
    * **Systems Manager:**
        * 自动化管理、配置管理、补丁管理、会话管理器等。
    * **Service Catalog:**
        * 创建和管理已批准的 IT 服务目录。
    * **Organizations:**
        * 多账户管理和治理。
    * **Cost Explorer & Billing:**
        * 成本分析和管理。
* **Serverless 服务:**
    * **Lambda、API Gateway、DynamoDB、S3、SNS、SQS、EventBridge、Step Functions、AppSync。** 理解 Serverless 架构的优势和适用场景。
* **消息队列与通知 (Messaging and Notification):**
    * **SNS (Simple Notification Service):**
        * 发布/订阅模型、主题、订阅、消息传递协议。
    * **SQS (Simple Queue Service):**
        * 消息队列、标准队列和 FIFO 队列、消息可见性、死信队列。
    * **Kinesis:**
        * 数据流、数据 Firehose、数据 Analytics。
    * **EventBridge:**
        * 事件总线、事件模式、规则、目标。
* **混合云 (Hybrid Cloud):**
    * **Direct Connect、VPN、Storage Gateway、Outposts。** 理解混合云架构的模式和挑战。
* **迁移与现代化 (Migration & Modernization):**
    * **AWS Migration Hub、Application Discovery Service、Database Migration Service (DMS)、Server Migration Service (SMS)。** 了解不同的迁移策略（Rehost, Replatform, Repurchase, Refactor, Retire, Retain）。

## 二、架构设计原则和最佳实践：

* **高可用性 (High Availability):**
    * 消除单点故障、多可用区部署、弹性伸缩、故障转移机制。
* **容错性 (Fault Tolerance):**
    * 冗余、备份和恢复策略、自动恢复机制。
* **可扩展性 (Scalability):**
    * 水平扩展和垂直扩展、弹性伸缩、无状态应用程序设计。
* **安全性 (Security):**
    * 纵深防御、最小权限原则、数据加密、网络安全、身份和访问管理。
* **成本优化 (Cost Optimization):**
    * 选择合适的实例类型和存储类、弹性伸缩、预留实例和 Savings Plans、无服务器架构、数据生命周期管理、监控和分析成本。
* **性能效率 (Performance Efficiency):**
    * 选择合适的计算和存储服务、缓存策略、数据库优化、网络优化、无服务器架构。
* **卓越运营 (Operational Excellence):**
    * 自动化、监控和告警、基础设施即代码 (IaC)、灾难恢复计划。

## 三、解决实际问题的能力：

* 能够根据业务需求设计满足高可用性、可扩展性、安全性和成本效益的 AWS 解决方案。
* 能够诊断和解决 AWS 环境中的问题。
* 能够评估现有架构并提出改进建议。
* 能够根据不同的场景选择合适的服务和架构模式。
* 了解不同 AWS 服务的限制和权衡。

## 四、考试准备建议：

* **深入学习 AWS 文档和白皮书：** 这是最权威的学习资源。
* **动手实践：** 通过 AWS 控制台、CLI 和 SDK 进行实际操作。
* **参加培训课程：** AWS 官方培训或第三方培训机构的课程可以帮助您系统地学习。
* **阅读案例研究：** 了解其他公司如何使用 AWS 解决实际问题。
* **做模拟题：** 熟悉考试题型和节奏。
* **参与社区讨论：** 与其他备考者交流经验和知识。
* **关注 AWS 的最新动态：** AWS 服务更新频繁，需要及时了解。

## 五、重要白皮书建议阅读：

* AWS Well-Architected Framework
* Architecting for the Cloud: AWS Best Practices
* Building Scalable and Highly Available Applications on AWS
* Cost Optimization Pillar - AWS Well-Architected Framework
* Security Pillar - AWS Well-Architected Framework
* Performance Efficiency Pillar - AWS Well-Architected Framework
* Operational Excellence Pillar - AWS Well-Architected Framework
* Reliability Pillar - AWS Well-Architected Framework

**记住，AWS Certified Solutions Architect – Professional 考试不仅仅考察您对单个服务的了解，更重要的是考察您如何将这些服务组合起来构建健壮、可扩展和经济高效的解决方案的能力。**

祝您考试顺利！
