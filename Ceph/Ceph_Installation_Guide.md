# 1. Prepare - NTP and  Config SSH
---------------------
## Stop firewall
systemctl stop firewalld && systemctl disable firewalld


##config ssh (后面如果docker不成功则需要再ceph docker里面执行)
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id root@10.229.96.115
ssh-copy-id root@10.229.96.116

# 2. Install cephadm
---------------------
##Install cephadm on 10.229.96.114
curl --silent --remote-name --location https://download.ceph.com/releases/17.2.6/rpm/el8/noarch/cephadm
chmod +x cephadm
mv cephadm /usr/local/bin/


## run this on all nodes
cephadm add-repo --release quincy
cephadm install ceph-common

# 3. Initialize Ceph Cluster
---------------------
##Intitialize on 10.229.96.114
cephadm bootstrap --mon-ip 10.229.96.114
reinstall:(cephadm bootstrap --mon-ip 10.229.96.114 --allow-overwrite)


        URL: https://cftvml096114:8443/
        User: admin
        Password: Password123!

##CEPH CLI
ssh $(hostname) "cephadm shell"
ceph -s

# 4. Add additional nodes
---------------------
sudo ceph orch daemon add mon cftvml9096115 10.229.96.115
sudo ceph orch daemon add mon cftvml9096116 10.229.96.116

## Add additional nodes:
cftvml9096115
cftvml9096116

->此时如果名字不能解析则需要/etc/hosts ==>然后运行systemctl restart systemd-hostnamed


ceph orch host ls

# 5. Deploy OSD
to list available disk
lsblk
##Add dis to OSD
ceph orch apply osd --all-available-devices
or add disk manually
ceph orch apply osd --host cftvml9096114 --device /dev/sdb
ceph orch apply osd --host cftvml9096115 --device /dev/sdb
ceph orch apply osd --host cftvml9096116 --device /dev/sdb

check osd status
ceph osd tree



# 6. Config Pool

Create pool with pg_num and pgp_num
ceph osd pool create mypool 128 128

ceph osd pool ls detail


 Config Block
 Enable rbd and list rbd
 ceph osd pool application enable mypool rbd
 ceph osd pool application get mypool

ceph osd pool create rbd 8
pool 'rbd' created

rbd create myrbd --size 10G --pool mypool

 rbd ls mypool
 specific default pool/etc/ceph/ceph.conf
    osd_pool_default = rbd
    osd_pool_default_size = 3
    osd_pool_default_min_size = 1

 Config File
 Create metadata pool and data pool
ceph osd pool create mymetadata 32 32
ceph osd pool create mydata 32 32

ceph fs new mycephfs mymetadata mydata

ceph fs ls

Config RGW
ceph orch apply rgw myrgw
radosgw-admin user create --uid="testuser" --display-name="Test User"


 Verify Status
ceph osd stat
ceph pg stat
ceph df
ceph auth get-key client.admin

# 7. Diagnostics
ceph fs status
ceph status
ceph mds stat
ceph orch ps |grep mds

Start MDS if there no 
ceph orch apply mds mycephfs --placement=1

if MDS not activate:
ceph mds fail mycephfs:0

# 8. iSCSI install
 zypper in tcumu-runner ceph-iscsi
 Config /etc/ceph/iscsi-gateway.cfg
  Sample:
   [config]
	|# Name of the Ceph storage cluster. A suitable Ceph configuration file allowing
	|# access to the Ceph storage cluster from the gateway node is required, if not
	|# colocated on an OSD node.
	cluster_name = ceph

	|# Place a copy of the ceph cluster's admin keyring in the gateway's /etc/ceph
	|# directory and reference the filename here
	gateway_keyring = ceph.client.admin.keyring


	|# API settings.
	|# The API supports a number of options that allow you to tailor it to your
	|# local environment. If you want to run the API under https, you will need to
	|# create cert/key files that are compatible for each iSCSI gateway node, that is
	|# not locked to a specific node. SSL cert and key files *must* be called
	|# 'iscsi-gateway.crt' and 'iscsi-gateway.key' and placed in the '/etc/ceph/' directory
	|# on *each* gateway node. With the SSL files in place, you can use 'api_secure = true'
	|# to switch to https mode.

	|# To support the API, the bare minimum settings are:
	api_secure = false

	|# Additional API configuration options are as follows, defaults shown.
	|# api_user = admin
	|# api_password = admin
	|# api_port = 5001
	|# trusted_ip_list = 192.168.0.10,192.168.0.11
 systemctl enable --now rbd-target-gw rbd-target-api

 gwcli
	/> cd /iscsi-targets
	/iscsi-targets>  create iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw
	ok

	> /iscsi-targets> cd iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw/gateways
	> /iscsi-target...-igw/gateways>  create ceph-gw-1 10.229.96.114
	
	
	> /iscsi-targets> cd iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw/gateways
	> /iscsi-target...-igw/gateways>  create ceph-gw-1 10.229.96.114 skipchecks=true
									   create ceph-gw-2 10.229.96.115 skipchecks=true
										create ceph-gw-3 10.229.96.116 skipchecks=true									   

Notes: enable iscsi-gateway on other node,
	1. install: zypper in tcumu-runner ceph-iscsi
	2. copy /etc/ceph/ceph.conf from primary node
		chown ceph:ceph /etc/ceph/ceph.conf
		chmod 600 /etc/ceph/ceph.conf
	3. kerying : ls -l /etc/ceph/ceph.client.admin.keyring
		scp /etc/ceph/ceph.client.admin.keyring 10.229.96.115:/etc/ceph/
		then chown and permission
			chown ceph:ceph /etc/ceph/ceph.client.admin.keyring
			chmod 600 /etc/ceph/ceph.client.admin.keyring	

add additional iscsigateway: /> iscsi-targets/iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw/gateways create 10.229.96.114 10.229.96.115 10.229.96.116
