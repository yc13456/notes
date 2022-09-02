# Kubeenetes

### Kubernetes 集群

```shell
1、Kubernetes 协调一个高可用计算机集群，每个计算机作为独立单元互相连接工作。
2、Kubernetes 中的抽象允许将容器化的应用部署到集群，而无需将它们绑定到某个特定的独立计算机。
3、为了使用这种新的部署模型，应用需要以将应用与单个主机分离的方式打包：它们需要被容器化。
4、与过去的那种应用直接以包的方式深度与主机集成的部署模型相比，容器化应用更灵活、更可用。 
5、Kubernetes 以更高效的方式跨集群自动分发和调度应用容器。
6、Kubernetes 是一个开源平台，并且可应用于生产环境。
```

Kubernetes 集群包含两种类型的资源:

```
Master 调度整个集群
Nodes 负责运行应用
```

![image-20210720152904623](../../../Pictures/typora_Images/image-20210720152904623.png)

1、**Master 负责管理整个集群。** Master 协调集群中的所有活动，例如调度应用、维护应用的所需状态、应用扩容以及推出新的更新。

2、**Node 是一个虚拟机或者物理机，它在 Kubernetes 集群中充当工作机器的角色**。每个Node都有 Kubelet , 它管理 Node 而且是 Node 与 Master 通信的代理。

问题：

```
1、sshd三个安全设置没有问题，
2、在板子上面烧录镜像，运行初始化脚本，数据连接不上云端。kebuedge初始化脚本对二次使用的vim3连接云端，有bug。

3、在云端将该节点重构之后，云端会存在pending，开发板也接受不到云端部署的容器。
4、昨天和前天没有烧录，新的开发板没有问题。运行脚本可以直接连上。
```

容器服务 Kubernetes 知识图谱



2

|                    | Kubernetes功能                                               |
| ------------------ | ------------------------------------------------------------ |
| 服务发现和负载均衡 | k8s可以使用DNS和ip地址公开，检测到容器流量很大,k8s会负载均衡并分配网络流量 |
| 存储编排           | 允许你自动挂载你选择的存储系统（本地存储、公共云提供商等）   |
| 自动部署和回滚     | k8s可以自动化为部署创建新容器， 删除现有容器并将它们的所有资源用于新容器 |
| 自动完成装箱计算   | 允许指定每个容器所需 CPU 和内存（RAM）                       |
| 自我修复           | 重新启动失败的容器、替换容器、杀死不响应用户定义的 运行状况检查的容器，**并且在准备好服务之前不将其通告给客户端** |

|                                                              | Kubernetes选择性和灵活性                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 不限制支持的应用程序类型                                     | 支持极其多种多样的工作负载（如果应用程序可以在容器中运行，那么它应该可以在 Kubernetes 上很好地运行） |
| 部署源代码，也不构建你的应用程序                             | 持续集成(CI)、交付和部署（CI/CD）工作流取决于技术要求（团队技术偏好） |
| 不提供应用程序级别的服务作为内置服务                         | 中间件、数据处理框架、数据库、缓存、集群存储系统等。这些组件可以在k8s上面运行，并且可以由运行在 k8s上的应用程序通过可移植机制（例如， [开放服务代理](https://openservicebrokerapi.org/)）来访问 |
| 不要求日志记录、监视或警报解决方案                           | 它提供了一些集成作为概念证明，并提供了收集和导出指标的机制   |
| 不提供或不要求配置语言/系统                                  |                                                              |
| 不提供也不采用任何全面的机器配置、维护、管理或自我修复系统   |                                                              |
| Kubernetes 包含一组独立的、可组合的控制过程， 这些过程连续地将当前状态驱动到所提供的所需状态 |                                                              |

###  Kubernetes组件

#### 1、控制平面组件（Control Plane Components）：

控制平面的组件对集群做出全局决策(比如调度)，以及检测和响应集群事件

|                          |                                                              |
| ------------------------ | ------------------------------------------------------------ |
| kube-apiserver           | API 服务器是 Kubernetes [控制面](https://kubernetes.io/zh/docs/reference/glossary/?all=true#term-control-plane)的组件， 该组件公开了 Kubernetes API。 API 服务器是 Kubernetes 控制面的**前端** |
| etcd                     | 是兼具一致性和高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库 |
| kube-scheduler           | 控制平面组件，负责监视新创建的、未指定运行[节点（node）](https://kubernetes.io/zh/docs/concepts/architecture/nodes/)的 [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)，选择节点让 Pod 在上面运行 |
| kube-controller-manager  | 运行[控制器](https://kubernetes.io/zh/docs/concepts/architecture/controller/)进程的控制平面组件。<br />Node Controller（节点控制器）：负责在节点出现故障时进行通知和响应<br />Job controller（任务）： 监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成<br />Endpoints Controller（端点）：填充端点(Endpoints)对象(即加入 Service 与 Pod)<br />服务帐户和令牌控制器（Service Account & Token Controllers）：为新的命名空间创建默认帐户和 API 访问令牌 |
| cloud-controller-manager | 云控制器管理器是指嵌入特定云的控制逻辑的 [控制平面](https://kubernetes.io/zh/docs/reference/glossary/?all=true#term-control-plane)组件 |

#### 2、Node 组件：

节点组件在每个节点上运行，维护运行的 Pod 并提供 Kubernetes 运行环境

|                   |                                                              |
| ----------------- | ------------------------------------------------------------ |
| kubelet           | 一个在集群中每个[节点（node）](https://kubernetes.io/zh/docs/concepts/architecture/nodes/)上运行的代理。 它保证[容器（containers）](https://kubernetes.io/zh/docs/concepts/overview/what-is-kubernetes/#why-containers)都 运行在 [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 中。 |
| kube-proxy        | 集群中每个节点上运行的网络代理，维护节点上的网络规则         |
| Container Runtime | 负责运行容器的软件                                           |

#### 3、插件

插件使用 Kubernetes 资源（[DaemonSet](https://kubernetes.io/zh/docs/concepts/workloads/controllers/daemonset/)、 [Deployment](https://kubernetes.io/zh/docs/concepts/workloads/controllers/deployment/)等）实现集群功能，插件中命名空间域的资源属于 `kube-system` 命名空间

|                                               |                                                              |
| --------------------------------------------- | ------------------------------------------------------------ |
| DNS                                           | 集群 DNS 是一个 DNS 服务器，和环境中的其他 DNS 服务器一起工作，它为 Kubernetes 服务提供 DNS 记录 |
| Web 界面（Dashboard）                         | [Dashboard](https://kubernetes.io/zh/docs/tasks/access-application-cluster/web-ui-dashboard/) 是 Kubernetes 集群的通用的、基于 Web 的用户界面（管理运行应用程序及集群本身故障排除） |
| 容器资源监控（Container Resource Monitoring） | 将关于容器的一些常见的时间序列度量值保存到一个集中的数据库中，**并提供用于浏览这些数据的界面** |
| Cluster-level Logging                         | 将容器的日志数据 保存到一个集中的日志存储中，该存储能够提供搜索和浏览接口 |

#### 4、辨析

|       |                                                              |
| ----- | ------------------------------------------------------------ |
| pods  | 一个或多个共享存储、网络的容器。Pod 中的内容总是并置（colocated）的并且一同调度，在共享的上下文中运行。 |
| nodes | 一台逻辑或者物理主机（可包含多个pods）                       |



### 安装k8s环境

#### 1、设置hostname

```shell
hostnamectl set-hostname kubemaster
vim /etc/hosts
    192.168.56.142 kubemaster
    192.168.56.144 kubenode1
```



#### 2、修改docker cgroup

```json
vim /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

#### 3、禁止掉swap分区

```shell
swapoff -a 	#临时
vi /etc/fstab  # 注释掉swap那行，持久化生效
```

#### 4、确保时区和时间正确

```shell
timedatectl set-timezone Asia/Shanghai
systemctl restart rsyslog 
```

#### 5、设置iptables可以看到bridged traffic

```shell
lsmod | grep br_netfilter # 确认Linux内核加载了br_netfilter模块

#确保sysctl配置中net.bridge.bridge-nf-call-iptables的值设置为了
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

#### 6、关闭防火墙

```shell
ufw disable #关闭
ufw status #查看状态
```

#### 7、安装kubeadm kubeadm kubectl

```shell
sudo apt-get update && sudo apt-get install -y ca-certificates curl software-properties-common apt-transport-https curl
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF 
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

#### 8、init部署

```shell
# 使用了非默认的CIDR
kubeadm init --pod-network-cidr 172.16.0.0/16 --service-cidr=10.96.0.0/12  --image-repository=registry.aliyuncs.com/google_containers --v=5

#返回
# kubeadm join 192.168.23.128:6443 --token 49lvq0.lcfgo9wnpy4q2b4f --discovery-token-ca-cert-hash sha256:f72e1638d6e0c73cea6fa87a3a8211dc0234af6be83c7cd80de9247bd3daa15a
```

#### 9、配置kubectl执行

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 10、安装calico网络插件

```shell
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
# 安装 Tigera Calico 运算符和自定义资源定义。
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml

# 通过创建必要的自定义资源来安装 Calico。
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
```

#### 11、k8s集群重新初始化

```shell
# https://blog.csdn.net/one2threexm/article/details/107735228
```

#### 12、node节点信息重置

```
kubeadm reset
systemctl stop kubelet
systemctl stop docker
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
rm -rf /etc/cni/
##重启kubelet
systemctl restart kubelet
##重启docker
systemctl restart docker
```



### 命令行

#### kubeadm 

```shell
# 创建token
kubeadm token create
```

#### kubectl

```shell
# 获取集群节点
kubectl get node
kubectl get nodes -o wide

# 所有命名空间中的Pod、deployment
kubectl get pods -A
kubectl get pod -A |grep -v kube-system #

# 
kubectl get no -o wide --show-labels
```



