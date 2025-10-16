**1.Warp⼯具简介**

warp 是⼀款开源的S3基准测试⼯具，开源S3项⽬minio下的⼀个⼦项⽬，可以对兼容S3语义的服务进⾏基准测试。

**2.Warp主要功能及配置**

常⽤功能有mixed，put，get，analyze等；

mixed：是混合读写模式，可以指定put、get、delete、stat类型的请求的不同⽐例。

put：只进⾏上传请求。

get：先上传部分数据进⾏预热，然后只进⾏下载请求。

analyze：将其他模式的输出结果进⾏分析，warp数据取样间隔5s

例：mixed 混合读写1：9

warp mixed --put-distrib=90 --get-distrib=10 --stat-distrib=0 --delete-distrib=0 --host=www.s3.com -- bucket=bucket-test-4k --access-key=key@123 --secretkey=key@123 --obj.size=4KiB -- duration=10m --concurrent=40 --benchdata=warpdata -q --disable-multipart -- nocleaer

其中：

--put-distrib：put请求百分比

--get-distrib：get请求百分比

--stat-distrib：stat请求百分比

--delete-distrib：delete请求百分⽐，要求必须⼩于put请求百分⽐

--host：访问的s3域名

--bucket：指定bucket名称，若该桶不存在则会先创建，默认为warp-benchmark-bucket

--access-key：用户ak

--secret-key：用户sk

--obj.size：对象大⼩

--duration：请求持续时间

--concurrent：并发线程数

--benchdata：⽣成的⽂件前缀，后缀为csv.zst，⽤于数据分析

--disable-multipart：不使⽤分段上传

--noclear：请求结束不清理对象
If your server is incompatible with [AWS v4 signatures](https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html) the older v2 signatures can be used with `--signature=S3V2`

其他参数可使⽤warp mixed --help命令查询.

另外，可以使⽤环境变量指定某些参数，例如WARP\_HOST 、 WARP\_ACCESS\_KEY 、WARP\_SECRET\_KEY 等。

put、get请求与mixed类似，将关键字改为put或者get，不携带--xxx-distrib参数即可。

**3.Warp具体使⽤**

warp⽀持单机模式和分布式模式。

1.单机模式：

a.下载并安装warp，地址https://github.com/minio/warp

b.启动warp服务，warp默认端⼝为7761

nohup warp client 10.24.169.8:7761 &

c.直接执⾏warp命令即可

2.分布式模式：

在不同服务器上安装warp，并启动warp服务，在其中1台上执⾏命令即可，注意执⾏时需要指定所有的warp客⼾端

warp put --warp-client=192.168.16.61:7761,192.168.16.111:7761 --host=192.168.16.112:9000 --bucket=warp-multi-write-1000m --access-key=key@123 --secretkey=key@123 --obj.size=1000MiB --duration=5m --concurrent=16 --benchdata=1000M-multi16-write -q --disable-multipart --noclear

3.分析数据

warp analyze --analyze.v --analyze.out=filename.csv 100M-multi16-write
