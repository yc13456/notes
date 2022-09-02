# 服务安装部署

## 一、安装docker，配置下载源

```shell
cd /etc/docker
vim daemon.json

{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://ghcr.io",
    "https://mirror.baidubce.com"
  ]
}

service docker restart
```



## 二、rabbitmq

### 1、安装rabbitmq

```shell
docker search rabbitmq:management #有web管理界面
#运行rabbitmq服务
docker run -d -p 15672:15672  -p  5672:5672  -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin --name rabbitmq --hostname=rabbitmqhostone  rabbitmq:management

#访问rabbitmq
#默认账号密码：guest/guest
http://ip:15672/
```

### 2、rabbitmq鉴权

1. RabbitMQ鉴权:rabbitmq节点会查看它的权限并授权访问相应的资源，如虚拟主机，队列，交换机等等

2. 鉴权方式：一种是利用内置数据库鉴权。另一种是rabbitmq-auth-backend-http鉴权插件来实现后端鉴权。

3. ```
   Configure regexp：对queue或exchange新建和配置的权限。
   Write regexp：对一个queue或exchange写消息的权限,以及queue与exchange绑定权限
   Read regexp：对一个queue或exchange读消息的权限。
   
   .* 表示对所有queue和exchange有此权限。
   
   ^$ 表示对所有的queue和exchage没有此权限。
   
   ^(hello.*)$ 表示只有以hello开头的queue或exchage的权限
   
   ^(hello.*|team.*)$ 表示有以hello和team开头的queue或exchange的权限。
   ```


### 3、通信过程

![img](https://images2018.cnblogs.com/blog/787798/201803/787798-20180328174112195-1114311375.png)

1. P1生产消息，发送给服务器端的Exchange

2. Exchange收到消息，根据ROUTINKEY，将消息转发给匹配的Queue1

3. Queue1收到消息，将消息发送给订阅者C1

4. C1收到消息，发送ACK给队列确认收到消息

5. Queue1收到ACK，删除队列中缓存的此条消息

### 4、参考文档

```
https://www.cnblogs.com/quan-coder/p/8663747.html
https://segon.cn/rabbitmq-authentication-authorisation-access-control.html
```



## 问题

![image-20220328182720372](C:/Users/yc/Pictures/typora_Images/image-20220328182720372.png)

1. 限制用户只能进行“读”操作，通过限制用户绑定的topic exchange“只读”
2. 一个用户一个exchange，交换机名称不能重复是个问题。



## 三、Kafka

### 1、安装配置

1、安装运行Zookeeper

```shell
docker run -d --name zookeeper -p 2181:2181  wurstmeister/zookeeper
```

2、安装运行Kafka

```shell
docker run -d --name kafka -p 9092:9092 -e KAFKA_BROKER_ID=0 -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --link zookeeper -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -t wurstmeister/kafka
```

```shell
docker run -d --name kafka -p 9092:9092 -e KAFKA_BROKER_ID=0 -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --link zookeeper -e KAFKA_ADVERTISED_LISTENERS="INTERNAL://kafka:29092,EXTERNAL://localhost:9092" -e KAFKA_LISTENERS="INTERNAL://:29092,EXTERNAL://:9092" -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP "INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT" -e KAFKA_INTER_BROKER_LISTENER_NAME="INTERNAL" -t wurstmeister/kafka
```

3、创建测试topic

```
 bin/kafka-topics.sh --create --zookeeper 172.17.0.3:2181 --replication-factor 1 --partitions 1 --topic test01
```

4、消费者开启消费

```shell
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test01 --from-beginning
```

5、生产者发布消息

```
kafka-console-producer.sh --broker-list localhost:9092 --topic test01
```

```
https://www.jianshu.com/p/09129c9f4c80
```

全日至启动kafka

```
bin/kafka-server-start.sh config/server.properties
```



SCRAM创建过程

```shell
bin/kafka-configs.sh --zookeeper 172.17.0.3:2181 --alter --add-config 'SCRAM-SHA-256=[iterations=8192,password=alice-secret],SCRAM-SHA-512=[password=alice-secret]' --entity-type users --entity-name alice

Warning: --zookeeper is deprecated and will be removed in a future version of Kafka.
Use --bootstrap-server instead to specify a broker to connect to.
Completed updating config for entity: user-principal 'alice'.

bin/kafka-configs.sh --zookeeper 172.17.0.3:2181 --alter --add-config 'SCRAM-SHA-256=[password=admin-secret],SCRAM-SHA-512=[password=admin-secret]' --entity-type users --entity-name admin
Warning: --zookeeper is deprecated and will be removed in a future version of Kafka.
Use --bootstrap-server instead to specify a broker to connect to.
Completed updating config for entity: user-principal 'admin'.
```

#### 

添加user 权限在topic层面 的写权限

```
kafka-acls.sh --authorizer-properties zookeeper.connect=172.17.0.3:2181 --add --allow-principal User:"alice" --producer --bash-5.1# bin/kafka-acls.sh --authorizer-properties zookeeper.connect=172.17.0.3:2181 --add --allow-principal User:"alice" --operation Write  --topic 'test007'


Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test007, patternType=LITERAL)`: 
 	(principal=User:alice, host=*, operation=WRITE, permissionType=ALLOW) 
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test007, patternType=LITERAL)`: 
 	(principal=User:alice, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:alice, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:alice, host=*, operation=DESCRIBE, permissionType=ALLOW) 

```



