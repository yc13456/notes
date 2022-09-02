## Containerd

#### 1、简介

- containerd是一个工业级标准的高级容器运行时，它强调**简单性**、健壮性和**可移植性**。
- containerd可以在宿主机中管理完整的**容器生命周期**，包括
  - 容器镜像的传输和存储
  - 容器的执行和管理、存储和网络等。

#### 2、与Docker关系

- 使用Docker作为K8S容器运行时的话，**Docker没有CRI组件**，kubelet需要先要通过**dockershim**去调用Docker，再通过Docker去调用containerd。

  ![preview](https://pic1.zhimg.com/v2-a33f47493cfe8214d910367353851ef8_r.jpg)

- 使用containerd作为K8S容器运行时的话，由于containerd内置了**CRI（Container Runtime Interface）**插件，kubelet可以直接调用containerd。

![preview](https://pic2.zhimg.com/v2-55b30b651d8ed158ef08b254b11590b5_r.jpg)

#### 3、架构示意图

https://blog.frognew.com/2021/05/relearning-container-08.html

![containerd-architecture.png](https://blog.frognew.com/images/2021/05/containerd-architecture.png)

C/S架构

1. 服务端包含（Subsystems）：

   - Bundle：bundle服务允许用户从磁盘镜像中提取和打包bundles

   - Runtime：运行时服务支持运行bundles，包括运行时容器的创建

2. 外部通过GRPC API与服务进行交互

3. 客户端组件(Distribution)

   - 为了灵活性，一些组件是在客户端实现的:   
     - Distribution: 提供镜像的拉取和推送上传功能

4. containerd创建bundle的数据流

   - containerd在架构上被设计为主要是协调bundles的创建和执行

   - bundles是指被Runtime使用的配置、元数据、rootfs数据

   - 一个bundle就是一个运行时的容器在磁盘上的表现形式，简化为文件系统中的一个目录。
     ![containerd创建bundle的数据流图](https://blog.frognew.com/images/2021/05/containerd-data-flow.png) 

     1. 指示Distribution Controller去拉取一个具体的镜像，Distribution将镜像分层内容存储到内容存储中(content store)，将镜像名和root manifest pointers注册到元数据存储中(metadata store)。

     1. 一旦镜像拉取完成，**用户可以指示**Bundle Controller将镜像分解包到一个bundle中。从内容存储中消费后，图像中的层被解压缩到快照组件中。

     1. 当容器的rootfs的快照准备好时，Bundle Controller控制器可以使用image manifest和配置来准备执行配置。其中一部分是将挂载从snapshot模块输入到执行配置中。

     1. 将准备好的bundle给Runtime子系统以执行, Runtime子系统将读取bundle配置来创建一个运行的容器。

   - 对应containerd的数据根目录下的各个子目录:

## runc

- Runc是一个基于OCI标准实现的一个轻量级容器运行工具，用来创建和运行容器。

- Containerd是用来维持通过runc创建的容器的运行状态。

- **runc用来创建和运行容器**，**containerd作为常驻进程用来管理容器**。


![img](https://res.cloudinary.com/dqxtn0ick/image/upload/v1631847625/article/kubernetes/containerd/container-ecosystem.drawio.png)