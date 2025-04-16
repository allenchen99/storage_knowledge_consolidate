# SRE Responsibilities

## Availablility
## Latency
## Performance
## Efficiency
## Change management
## Monitoring
## Emergency response
## Capacity palnning (scalability).
Effective capacity planning in SRE ensures system reliability and scalability by proactively provisioning resources based on actual demand and anticipated growth.
> Capacity planning is not about maximizing hardware utilization — it's about **ensuring stability, scalability, and reliability**.
---

### 🖥️ 1. Compute

- **Key Metrics**:
  - CPU usage
  - Memory usage

- **Planning Tips**:
  - Understand service resource patterns (CPU-intensive vs memory-intensive)
  - Set upper limits (e.g., keep CPU/memory usage below 70%)
  - Enable auto-scaling (e.g., Kubernetes HPA)

---

### 🌐 2. Network

- **Key Metrics**:
  - Bandwidth
  - IOPS (especially for storage/network equipment)
  - Latency

- **Planning Tips**:
  - Distinguish north-south (user traffic) and east-west (service-to-service) flows
  - Monitor packet loss and latency spikes
  - Ensure headroom to prevent network bottlenecks

---

### 📦 3. Storage

- **Key Metrics**:
  - Bandwidth
  - IOPS (read/write operations per second)
  - Latency

- **Planning Tips**:
  - Consider read/write patterns and their impact on performance
  - Reserve space for snapshots, backups, and logs
  - Plan for burst write performance

---

### ✅ Use the following approach:

| Aspect                 | Practice                                                                 |
|------------------------|--------------------------------------------------------------------------|
| Peak usage             | Plan based on **historical peak**, not average                          |
| Future demand          | Account for business growth (e.g., +20% user growth → +20% resource need)|
| Buffer (Headroom)      | Reserve **20–30%** buffer to handle spikes or failover                  |
| Thresholds             | Set alerts at ~70–80%, and plan service deployments at ~60–70% usage    |
| Performance testing    | Periodically run load tests to validate assumptions                     |

---

### 🧮 Example Calculation:

If current CPU peak usage = 60%  
Expected growth = 20%  
Then plan for: `60% × 1.2 = 72%`  
Add buffer: `72% × 1.25 = 90%`  
→ Your infrastructure should support up to 90% usage comfortably.

---

### ✅ General Strategies

- Reserve **30% headroom** to avoid resource exhaustion
- Continuous **monitoring and alerting** (e.g., Prometheus + Grafana)
- Use **historical trend analysis** for future projection
- Perform **regular load testing**
- Include capacity planning in **change management processes**

---

### 🔁 Optional Enhancements

- High availability considerations for all resource dimensions
- Cost-performance trade-offs
- Priority-based resource allocation by service importance
- Design for horizontal scalability

---

> Use this guide for SRE daily ops, system reviews, pre-deployment checks, and budget planning.
