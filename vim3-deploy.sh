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