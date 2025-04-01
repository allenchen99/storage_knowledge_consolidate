# CAW and CAS 
## Compare and Write
VAAI supports atomic-test-and-set (ATS). In SCSI, this is a compare-and-write operations (CAW). It is used as a replacement lock mechanism for SCSI reservations on VMFS volumes when doing metadata updates. Basically ATS locks can be considered as a mechanism to modify a disk sector, which when successful, allow an ESXi host to do a metadata update on a VMFS. This includes allocating space to a VMDK during provisioning, as certain characteristics would need to be updated in the metadata to reflect the new size of the file. Interestingly enough, in the initial VAAI release, the ATS primitives had to be implemented differently on each storage array, so you had a different ATS opcode depending on the vendor. ATS is now a standard T10 and uses opcode 0x89 (COMPARE AND WRITE).

## Compare and Swap
1. Atomic Test and Set (ATS): ATS is a VAAI primitive that allows a host to atomically test and set a lock on a specific storage block. CAS operations are typically used to implement the atomicity of the test and set operation, ensuring that multiple hosts can concurrently access the same storage block without conflicts.
Hardware Assisted Locking (HBA): HBA is another VAAI primitive that offloads the locking operations for virtual machine disk files to the storage array. CAS operations are used to coordinate and manage the lock state of the shared storage blocks accessed by virtual machines.![image](https://github.com/user-attachments/assets/940d4ba1-9f7c-40fc-b7f9-2db1d1b1db3c)

# Docker Cheat image


# KVM
![image](https://github.com/user-attachments/assets/a11d874d-1b03-4f8e-8db9-af9188ecd5d9)
