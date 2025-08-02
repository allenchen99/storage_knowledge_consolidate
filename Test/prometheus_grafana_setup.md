
# Prometheus + Grafana Monitoring Setup (on WSL2 with Docker)

## 1. Make Docker Ready

```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

---
如果是国内安装可能会出错，添加国内registry-mirrors
```
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub.geekery.cn"
  ]
```
## 2. 配置 `docker-compose.yml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  node-exporter:
    image: prom/node-exporter
    container_name: node-exporter
    ports:
      - "9100:9100"
    pid: "host"
    restart: unless-stopped

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
    restart: unless-stopped

volumes:
  grafana-storage:
```

---

## 3. 配置 `prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["node-exporter:9100"]
```

---

## 4. 启动服务

```bash
docker-compose up -d
```

然后确认服务是否正常运行：

```bash
docker ps
```

- Prometheus: http://localhost:9090  
- Grafana: http://localhost:3000  
  - 默认账号密码：admin / admin  
  - 登录后添加 Prometheus 数据源：http://prometheus:9090  
  - 导入 Dashboard（如：Node Exporter Full → ID `1860`）

---

## 📌 如果遇到网络变动导致错误

```bash
docker-compose down
docker network rm monitoring_default
docker-compose up -d --no-build
```

---

## Configuration 小结

配置好 `prometheus.yml` 之后重启 Prometheus：

```bash
docker-compose restart prometheus
# 或
docker restart prometheus
```

Grafana 添加数据源：

1. 打开 Grafana → `Add Data Source`
2. 类型选择 Prometheus
3. URL 设置为：`http://host.docker.internal:9090`
4. 测试成功后 → Dashboard → Import → 输入 Dashboard ID（如 `1860`）→ Load → 数据源选择 Prometheus → Import

---

## ✨ 多个主机监控（多个 node_exporter）

如果有多个远程主机运行 node_exporter，可这样修改 `prometheus.yml`：

```yaml
scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["192.168.1.10:9100"]
        labels:
          instance: "host-A"
      - targets: ["192.168.1.11:9100"]
        labels:
          instance: "host-B"
      - targets: ["192.168.1.12:9100"]
        labels:
          instance: "host-C"
```

---

## 查看容器 IP 地址

列出所有容器 IP：

```bash
docker inspect -f '{{ .Name }} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
```

示例输出：

```
/prometheus - 172.18.0.4
/grafana - 172.18.0.3
/node-exporter - 172.18.0.2
```

---

## Docker 信息查询命令

```bash
docker ps -q
docker inspect <container_id>
```

示例：

```bash
docker ps -q
# 输出:
1e1422c1997e
eb33c243c07c
17298d5fe863

docker inspect 1e1422c1997e
```

---

> 本文档适用于本地监控环境，基于 Docker Compose，支持多主机扩展和自定义 Dashboard。
