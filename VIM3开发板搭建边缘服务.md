## VIM3开发板连接云端并初始化

### 1、使用烧录工具把vim3-ubuntu镜像烧录进VIM3开发板

```shell
#点击vim3中间按键三下，进入烧录模式
#使用烧录工具把镜像（VIM3_Ubuntu-server镜像）烧录到系统中
1、新机器第一次运行脚本即可成功接入系统
2、若是vim3开发板已经注册过了，第二次接入系统，会导致边缘节点接入失败。但是数据第一次接入过程，
```



### 2、配置PC使用串口通信工具，配置VIM3板的网络，并以ssh远程登陆

### 3、拷贝文件到开发板。

```sheLl
git clone https://gitlab.gizwits.com/cloud-edge-collaboration/kubeedge-deploy
#期间需要验证公司仓库账号
```

### 4、切换到root用户下

```
/home/khadas/kubeedge-deploy/arch/arm64
```

### 5、执行脚本 vim3-deploy.sh

```shell
bash vim3-deploy.sh		#经过测试，用bash不会报错
```

### #6、在云端重构该VIM3边缘节点，VIM开发板会收到新的docker镜像文件。

​	k8s_edge-frpc_edge-monitor、k8s_edge-monitor_edge-monitor、k8s_prometheus-node-exporter_edge-monitor、k8s_POD_edge-monitor

### 7、遇到问题

1、docker 镜像无法下载，可选择

```
sudo rm /var/lib/apt/lists/* -vf
#删除apt包下载锁
```

2、若出现:line 59: /tmp/edgecore-install.log: Permission denied：需要删除该临时文件，然后重新执行脚本
3、其余可能情况：

```shell
keadm reset(重新注册边缘节点)#或者systemctl stop edgecore
```

4、systemctl stop edgecore

rm /var/lib/kubeedge/edgecore.db

mv /etc/docker/key.json /etc/docker/key.json.bak

reboot

curl -L "https://qcr4t-raw-1251025085.cos.ap-guangzhou.myqcloud.com/vim3-deploy.sh" -o vim3-deploy.sh

### 8、KubeEdge部署脚本 vim3-deploy.sh

```shell
#!/bin/bash
chmod +x $(echo $0)
echo "更新系统用户安全信息"
echo "  - 添加gizwits分组"
echo "  - 添加gizwits用户"
if ! id -u gizwits >/dev/null 2>&1; then
	groupadd -g 2021 gizwits
    mkdir -p /home/gizwits
	useradd -g 2021 -u 2021 -c 'Gizwits Manager' -s /bin/bash gizwits
	echo gizwits:go4gizwits | chpasswd
	echo "  - 授权gizwits用户"
	cat /etc/group | grep ':khadas' | awk -F ':' '{print $1}' | xargs -I {} usermod -aG {} gizwits
fi

echo "  - 配置sshd安全环境"
userdel khadas >/dev/null 2>&1
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
if ["$(grep 'port 1621' /etc/ssh/sshd_config)" == ''] >/dev/null 2>&1;then echo "port 1621" >> /etc/ssh/sshd_config; fi
sudo service ssh restart

echo "  - 更新时区为中国上海"
timedatectl set-timezone Asia/Shanghai

echo "  - 启动看门狗"
sudo systemctl enable watchdog.service  >/dev/null 2>&1
sudo systemctl start watchdog.service  >/dev/null 2>&1


echo "挂载sd卡（请确保sd卡已格式化为ext4，并只有一个分区）"
if ! cat /etc/fstab | grep /dev/mmcblk1p1 > /dev/null; then
	echo "/dev/mmcblk1p1    /data    ext4    defaults,noatime,nodiratime    0    0">>/etc/fstab
fi
sudo mkdir -p /data
sudo mount -a

echo "安装和配置Docker"
echo "  - 更新Docker源"
apt-get update >/dev/null 2>&1
apt-get install -y apt-transport-https ca-certificates curl software-properties-common >/dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - >/dev/null 2>&1
add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null 2>&1
apt-get update >/dev/null 2>&1
echo "  - 安装Docker"
apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
systemctl enable docker >/dev/null 2>&1
systemctl restart docker
echo "  - 授权Docker分组用户"
usermod -aG docker gizwits

echo "安装和配置KubeEdge"
if [ ! -f "/tmp/package.tar.gz" ];then
	echo "  - 下载KubeEdge"
	curl -L "https://gwapi-1251025085.cos.ap-guangzhou.myqcloud.com/gems/kubeedge-for-gizwits/kubeedge-for-gizwits-v1.7.0-linux-arm64.tar.gz" -o /tmp/package.tar.gz >/dev/null 2>&1
fi

echo "  - 部署KubeEdge"
tar -vxf /tmp/package.tar.gz -C / >/dev/null 2>&1
KUBEEDGE_CONFIG=/etc/kubeedge/config/edgecore.yaml
cp ${KUBEEDGE_CONFIG} ${KUBEEDGE_CONFIG}.bak
MACHINE_ID=$(ifconfig eth0 | grep 'ether' | awk -F ' ' '{print $2}' | sed 's/://g')
ARCH=$(hostnamectl status | grep 'Architecture' | awk -F ': ' '{print $2}')
EDGENODE_NAME=${MACHINE_ID}-${ARCH}-vim3
echo "  - 注册边缘节点 ${EDGENODE_NAME}"
echo ${EDGENODE_NAME} > /etc/hostname
keadm join --kubeedge-version=1.7.0 --cloudcore-ipport=kube.gizwitsapi.com:10000 --edgenode-name=${EDGENODE_NAME} >/tmp/edgecore-install.log
systemctl stop edgecore
echo "  - 更新配置信息"
echo "port 10883" > /etc/mosquitto/conf.d/port.conf
systemctl enable mosquitto >/dev/null 2>&1
systemctl restart mosquitto
mv ${KUBEEDGE_CONFIG}.bak ${KUBEEDGE_CONFIG}
sed -i -e "s/@hostname@/${EDGENODE_NAME}/g" /etc/kubeedge/config/edgecore.yaml
systemctl enable edgecore >/dev/null 2>&1
systemctl restart edgecore

echo "系统重启"
sudo reboot
```

### VIM3 开启蓝牙服务

```
sudo systemctl restart bluetooth-power-fixup.service
```

蓝牙串口通信测试

```shell
#0、开启蓝牙服务 
sudo hciconfig hci0 up
#1、安装
sudo apt-get install pulseaudio-module-bluetooth
#2、本地配置蓝牙spp连接服务(下图)
#3、重启蓝牙服务
systemctl restart bluetooth 
```

![img](https://i0.hdslb.com/bfs/article/0d0707fa880f2308f9456250a19dabd5b558b82a.png@828w_686h_progressive.webp)

2021.7.22-7.27

Go-BlueTooth蓝牙串口通信

```shell
#启动容器
docker exec -it 1ef2773476e3 bash
#2 想让蓝牙能被连接需要开启耳机模式。
pulseaudio --start

#问题：遇到一直连接不上的问题，需要重启buletooth服务，重启脚本
#添加sp：sdptool add SP    - 添加SPP:
#sdptool add SP    - 添加SPP:
#hciconfig hci0 up	- 开启蓝牙服务
#蓝牙串口程序销毁串口软件进程之后，需要重启服务端蓝牙服务
```

出现问题

```
1、开机之后，先测试bluetoothctl ，并成功连接上。
2、再去运行脚本

问题：
1 出现bluez有问题，则bluetoothctl reset,然后重新进行蓝牙连接
2 进行数据读取的时候，因为服务端响应时间问题，导致客户端数据会超时读取失败。
3 程序每次CTRL+Z/C,并不会结束程序问题
4 只有重启蓝牙服务，才能保证下次连接不会一直出错
```

2021.7.27任务：

```
完成蓝牙串口通信，服务端主动向客户端发送消息。
通信事件，都是由客户端发起，然后由服务端完成。（不需要实现，服务端没有必要主动给而客户端发送消息）
```

配置蓝牙串口通信流程

```sheLl
#1 安装音频媒体包：
sudo apt-get install pulseaudio-module-bluetooth
sudo killall pulseaudio 
sudo pulseaudio --start
#2 启动容器
docker run --privileged -itd -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket --net=host 镜像名 /bin/bash
#3 进入项目目录
cd /go/src/github.com/muka/go-bluetooth/_examples
#4 修改server 脚本
cd /go/src/github.com/muka/go-bluetooth/examples/service
vim server.go

#5 添加write.go脚本
	package service_example
	import ("fmt")
	func write() []byte {
         var dataStr string
         fmt.Print("please input dataString")
         fmt.Scanf("%s",&dataStr)
         byte_data := []byte(dataStr)
         return byte_data
     }

#6 运行脚本，启动蓝牙连接
go run main.go service agent
#7 手机打开蓝牙，连接蓝牙
#8 手机使用"BLE调试宝"进行串口调试
```

```
1 服务端监听客户端请求。
客户端执行write的同时，执行read。
服务端写入数据，然后把图片传回来。
2 服务端主动发送内容。
```

```
蓝牙数据连接过程中
1、蓝牙开启
	使用本地dbus服务配置一个蓝牙终端设备连接agent
```



```
sudo apt-get install pulseaudio-module-bluetooth
sudo killall pulseaudio 
 
sudo pulseaudio --start
sudo systemctl restart bluetooth
```

```
sudo btmgmt -i 0 power off
sudo btmgmt- -i 0 name "my go app"
sudo btmgmt -i 0 le on
sudo btmgmt -i 0 connectable on
sudo btmgmt -i 0 advertising on
sudo btmgmt -i 0 power on
```

### 调试

```
1、设置安全连接：使用pin码形式（配对方式）
```

VIM3引脚参数

![image-20211103171251965](C:/Users/yc/Pictures/typora_Images/image-20211103171251965.png)

