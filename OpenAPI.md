## OpenAPI系统

### 系统配置

```shell
#(获取镜像仓库源权限)
docker login -u 100005252109 -p gizwits2018 ccr.ccs.tencentyun.com 
#运行Dockerfile构建gizwits_platform
docker build -t gizwits_platform:0.1 .
```

运行docker images

配置信息

```shell
export CONSUL_HTTP_ADDR=192.168.56.135:8500
export CONSUL_KV_DOMAIN=OpenAPI
environment=CONSUL_HTTP_ADDR=192.168.56.133:8500,CONSUL_KV_DOMAIN=OpenAPI
```

### Consul

#### 下载容器

```shell
docker pull consul
```

#### 运行容器

```shell
docker run  -it --name consul1 -p 8500:8500 consul agent -server -bootstrap-expect 1 -data-dir=/home/consul -node=n1 -bind=127.0.0.1 -client=0.0.0.0 -ui
```

发现server IP地址

```shell
dicker exec consul1 consul members
```

运行Consul client

```
docker run \
   --name=fox \
   consul agent -node=client-1 -join=172.17.0.2
```

注册服务

```shell
#安装容器
docker pull hashicorp/counting-service:0.0.2
#运行
docker run \
   -p 9001:9001 \
   -d \
   --name=weasel \
   hashicorp/counting-service:0.0.2
#写入配置文件
docker exec fox /bin/sh -c "echo '{\"service\": {\"name\": \"counting\", \"tags\": [\"go\"], \"port\": 9001}}' >> /consul/config/counting.json"
#reload 配置变化
docker exec fox consul reload
```

安装Mysql

```
 docker run -itd -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql：
```



## 模块

### proto

数据交换的序列结构化数据格式,具有跨平台、跨语言、可扩展特性,类型于常用的XML及JSON

