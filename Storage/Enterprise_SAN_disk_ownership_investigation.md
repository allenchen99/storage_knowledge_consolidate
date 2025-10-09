# Storage System Architectures

Industry designs fall into two broad classes, depending on how tightly coupled the controllers are:

- **Share-everything**
- **Share-nothing**

---

## Architecture Comparison

| Architecture | Example Systems | Disk Ownership Model | I/O Handling | Metadata Consistency |
|--------------|----------------|-------------------|-------------|-------------------|
| Shared-Disk Active-Active | Dell EMC Unity / PowerStore, HPE 3PAR, Huawei OceanStor, Pure Storage FlashArray | All controllers have simultaneous access to the same disk set; metadata determines which SP handles which block/LUN. | Any SP can service any LUN; usually one SP is “primary” for each LUN or extent. | Metadata locks, mirrored write cache, distributed journaling. |
| Node-Owned (Shared-Nothing within HA Pair) | NetApp ONTAP, IBM Storwize/SVC | Each disk (aggregate or mdisk) has an owning controller; peer can take over during failover. | Only the owning node writes normally; peer uses takeover logic on failover. | NVRAM mirrored between nodes for durability. |

---

## Why Shared-Disk Became the Industry Trend

**Key reasons:**

- Better capacity utilization – No need to pre-partition disks to controllers.
- Simpler load balancing – Any SP can service workloads dynamically.
- Faster failover – No physical ownership handoff; only metadata role change.
- Lower rebuild risk – Both controllers can assist in RAID rebuilds or scrubbing.

> This requires very careful metadata management (often distributed or journal-based), but modern interconnects (PCIe/NVLink/NVMe fabrics) make this practical.

---

## Public Paper Support

### Dell EMC Unity / PowerStore

**Evidence:** Dell whitepaper *“Dell EMC Unity: Introduction to the Platform”* (2022)  
> “All drives are shared between both Storage Processors. Each SP can access and manage any drive in the system. LUN ownership is logical and can move between SPs.”

**Patent:**  – *Managing ownership of resources in a distributed storage system (EMC)*  
Describes metadata ownership granularity at the extent or region level.

### HPE 3PAR / Primera

**Evidence:** HPE 3PAR StoreServ Architecture Technical White Paper  
> “All nodes have access to all drives in the system. Each logical region (chunklet) may be mastered by one node, but physical disks are visible to all.”

### Huawei OceanStor

**Evidence:** Huawei OceanStor V5 Architecture White Paper  
> “All controllers share the same backend disk pool. Logical disk metadata determines ownership. Write data is mirrored through the PCIe backplane.”

### Pure Storage FlashArray

**Evidence:** Pure Storage Architecture Guide  
> “All controllers can read and write any SSD through shared NVMe fabric. Active-active controllers coordinate through metadata locks and mirrored NVRAM.”

### NetApp ONTAP (Contrast Case)

**Evidence:** NetApp ONTAP 9 High Availability Technical Report (TR-4067)  
> “Each aggregate is owned by a single node in an HA pair. Partner node can take over ownership if the owner fails.”

---

## Hybrid or Evolving Models

Modern distributed systems (e.g., PowerStore X or OceanStor Dorado) use fine-grained metadata ownership:

- Disks are shared.
- Extents (e.g., 1MB or 4MB slices) have internal ownership assignments for caching and scheduling.
- Ownership metadata is journaled and synchronized via internal RDMA or PCIe links.
- Sometimes described in patents as “dynamic region ownership” or “metadata lease model”.

---

## Rebuild Coordination

| Architecture | Disk Ownership | Rebuild Coordinator | Peer SP Role |
|--------------|---------------|------------------|-------------|
| Unity | Shared | Pool owner SP | Assist I/O, takeover on fail |
| PowerStore | Shared (extent-level ownership) | Extent owner SP | Assist via internal fabric |
| 3PAR | Shared | Chunklet master node | Parallel I/O assistance |
| OceanStor | Shared | Pool owner SP | I/O mirror & assist |
| NetApp ONTAP | Node-owned | Owning node | None unless takeover |

---

## Detailed System Notes

### 1. Dell EMC Unity

- Uses shared-disk active-active architecture.
- Each pool or RAID group has an owning SP for control-plane operations.
- Disk failure handling:
  - Owning SP initiates rebuild (allocates spare, updates metadata).
  - Rebuild I/O is distributed between SPs.
  - Peer SP takes over if owning SP fails mid-rebuild.

📘 **Evidence:** *Dell EMC Unity: Introduction to the Platform*  
> “Each Storage Pool is managed by one SP at a time. The peer SP has access to all drives and can assume ownership in case of failure.”

### 2. Dell EMC PowerStore

- Fully distributed shared-disk system.
- Each RAID protection group (“Extent Group”) is managed by one SP (metadata owner).
- Rebuild handled by that SP’s software thread; I/O may come from both SPs.
- Ownership may migrate dynamically for load balancing.

📘 **Patent Reference:** US11080142B2  
> Describes rebuilding RAID regions owned by a controller, while other controllers assist through shared disk access.

### 3. NetApp ONTAP

- Node-owned disks: each aggregate belongs to one controller.
- Only owning node performs rebuild (“reconstruction” or “copyback”).
- Partner node stands by for takeover.

📘 **Evidence:** TR-4067  
> “During normal operation, only the owner node reconstructs failed disks in its aggregates.”

### 4. HPE 3PAR / Primera

- Shared-disk system.
- Each chunklet region has a logical “master node.”
- Node orchestrates rebuild; all nodes participate in I/O.
- Rebuild manager balances workloads across controllers.

📘 **Evidence:** *HPE 3PAR StoreServ Architecture White Paper*  
> “Each logical region is mastered by one node, which coordinates reconstruction of failed drives. All nodes contribute I/O to speed rebuild.”

### 5. Huawei OceanStor

- Shared-disk active-active design.
- Pool owner coordinates RAID rebuild.
- Peer controller mirrors metadata updates and assists with I/O.
- Rebuild I/O dynamically balanced via PCIe fabric.

📘 **Evidence:** *Huawei OceanStor V5 Series Technical White Paper*  
> “When a member disk fails, the owning controller reconstructs data using spare space, while peer controllers participate in I/O forwarding.”
