# AWS Solutionons Architection Professional 2022
## SLAs
1. EC2 99.99%, less than 4 mours per month.
2. S3 99.9%
3. RDS 99.5% support multiple DBs
## General Architecture
1. Regions (US, Euro, Asia, South American ...)
2. Multiple AZ (Availablity Zone under each Region)
3. Edge node (CDN) under in each AZ
4. AWS network, support private and public network
5. AWS Direct Connect, direct connect to private cloud which is private and cross zone
6. AWS Services
    1. Amazon Route 53：AWS的DNS服务，提供全球分布的DNS查询服务，帮助用户将流量引导到最佳的AWS资源。
    2. Amazon CloudFront：全球内容分发网络（CDN），将静态和动态内容缓存到边缘位置，以提高用户访问速度。
    3. AWS Global Accelerator：通过全球AWS网络优化应用程序的全球可用性和性能。
    4. AWS IAM（Identity and Access Management）：跨区域的用户身份和访问管理服务，允许对AWS资源的全局访问控制。
7. 跨区域复制和灾难恢复
    1. S3 Copy
    4. RDS Copy
8. 数据合规和法务
## VPS (Virtual Private Clouds) and Subnet
1. IPV4 CIDR block
2. IPV6 CIDR block
3. VPC Create
    1. GUI
    2. CLI
    3. Powershell
