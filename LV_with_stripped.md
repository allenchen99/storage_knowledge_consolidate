# Step to simulate storage poolized
## 1. Create 4 LUNs and attach to Linux
ls /dev/mapper/3600601600d4051001*
/dev/mapper/3600601600d4051001d87eb671856b050  /dev/mapper/3600601600d4051001e87eb67733df03d  /dev/mapper/3600601600d4051001e87eb67a940b4bb  /dev/mapper/3600601600d4051001e87eb67d2a709b7
sles15-chena18-dev-01:~ # ls -al /dev/mapper/3600601600d4051001*
lrwxrwxrwx 1 root root 7 Apr  1 02:31 /dev/mapper/3600601600d4051001d87eb671856b050 -> ../dm-2
lrwxrwxrwx 1 root root 7 Apr  1 02:31 /dev/mapper/3600601600d4051001e87eb67733df03d -> ../dm-5
lrwxrwxrwx 1 root root 7 Apr  1 02:31 /dev/mapper/3600601600d4051001e87eb67a940b4bb -> ../dm-3
lrwxrwxrwx 1 root root 7 Apr  1 02:31 /dev/mapper/3600601600d4051001e87eb67d2a709b7 -> ../dm-4
sles15-chena18-dev-01:~ # multipath -ll |grep DGC
3600601600d4051001e87eb67733df03d dm-5 DGC,VRAID
3600601600d4051001e87eb67a940b4bb dm-3 DGC,VRAID
3600601600d4051001e87eb67d2a709b7 dm-4 DGC,VRAID
3600601600d4051001d87eb671856b050 dm-2 DGC,VRAID
## 2. Create a Volume Group with the 4 physical volumes
sles15-chena18-dev-01:~ # vgcreate vg_striped /dev/mapper/3600601600d4051001d87eb671856b050 /dev/mapper/3600601600d4051001e87eb67733df03d /dev/mapper/3600601600d4051001e87eb67a940b4bb /dev/mapper/3600601600d4051001e87eb67d2a709b7
  Physical volume "/dev/mapper/3600601600d4051001d87eb671856b050" successfully created.
  Physical volume "/dev/mapper/3600601600d4051001e87eb67733df03d" successfully created.
  Physical volume "/dev/mapper/3600601600d4051001e87eb67a940b4bb" successfully created.
  Physical volume "/dev/mapper/3600601600d4051001e87eb67d2a709b7" successfully created.
  Volume group "vg_striped" successfully created
 
## 3. Create LV on top of LV, the slice is 256M from the 4 physical volume
sles15-chena18-dev-01:~ # lvcreate -L 400G -i 4 -I 256M -n lv_striped vg_striped
  Reducing requested stripe size 256.00 MiB to maximum, physical extent size 4.00 MiB.
  Logical volume "lv_striped" created.
 
## 4. Format LV as ext4
sles15-chena18-dev-01:~ # mkfs.ext4 /dev/vg_striped/lv_striped
mke2fs 1.43.8 (1-Jan-2018)
Discarding device blocks: done
Creating filesystem with 104857600 4k blocks and 26214400 inodes
Filesystem UUID: 2aedd338-a2f3-4217-a39e-8c19102f8e12
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000
 
Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done
 
sles15-chena18-dev-01:~ # mkdir /mnt/striped_lv
sles15-chena18-dev-01:~ # mount /dev/vg_striped/lv_striped /mnt/striped_lv
sles15-chena18-dev-01:~ # df -h /mnt/striped_lv/
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/vg_striped-lv_striped  393G   73M  373G   1% /mnt/striped_lv
 
## Next step is Create a file on the pool, format as a FS export to use (this is LUN) 
## Format it as a UFS, mount them on VDM and export to user as CIFS/nfs
