---
  title: linux
date: 2022-02-16 12:53:55
tags:
---

# linux笔记



## 基本操作

### 查看服务

```
 systemctl status 服务名
```

### 配置CentOS7网络

```
vi /etc/sysconfig/network-scripts/ifcfg-ens33
#这一项改为YES（ONBOOT=yes）
#重启网卡:
sudo service network restart
```

```
echo "字符串"：换行打印；
echo -n "字符串" 不换行打印';
echo -e选项输出转义字符
```

### nc测试网路请求

```
nc -lp 9999 #以本机作为服务端，监听9999端口
nc 192.168.153.130 9999 #客户端机器使用netcat 和ip地址进行连接。
```

### 进程阻塞与非阻塞

```
同步阻塞：当A调用B的时候，A需要一直在等待，直到B返回结果，期间A不可以做任何事情。
同步非阻塞：当A调用B的时候，A需要等待B返回结果，但是期间可以去做别的事情，但是A需要时不时的确认B是否返回结果。
异步阻塞：当A调用B的时候，B立即返回结果，A不需要等待，到结果返回时B会通知A，但是期间A不可以做别的事情。
异步非阻塞：当A调用B的时候，B立即返回结果，A不需要等待，到结果返回时B会通知A，而且期间A还可以做别的事情。
```

### 服务器内存使用情况：free

```
free -m --查看内存，不带单位
free -h --查看内存使用情况，带单位，显示查看结果
total：总计物理内存的大小
used：已使用内存
free：可用内存
Shared：多个进程共享的内存总额
Buffers/cached：磁盘缓存的大小  缓存是可以清除的
```

### 缓存清除

```
如果cached过大接近total数就需要清除缓存了，缓存清除命令：
echo 1 > /proc/sys/vm/drop_caches --释放网页缓存
echo 2 > /proc/sys/vm/drop_caches --释放目录项和索引
echo 3 > /proc/sys/vm/drop_caches --释放网页缓存，目录项和索引
```

### 本地和远程服务器文件传输包

```
apt-get install lrzsz
rz:上传
sz:下载
```

### 统计ssh在线人数

```shell
w	#显示目前登入系统的用户信息。
w | grep pts |wc -l
```

### 查看系统中所有的用户

```
grep bash /etc/passwd
```

### 查看所有用户密码

```
sudo vim /etc/passwd
#结果
khadas:x:1000:1000::/home/khadas:/bin/bash
从左到右依次为（用冒号分隔）：
	登录用户名
	经过加密的口令或者口令占位符
	UID（用户ID）
	默认的GID（组ID）
	GECOS信息：全名，办公室，手机号，座机号，其它（上结果无该信息）
	主目录
	登录的shell
```

### /bin/bash-posix与/bin/sh区别

```shell
1./bin/bash–posix与/bin/sh的执行结果相同。总结起来，sh跟bash的区别，实际上是bash有没开启posix模式的区别。遵守posix规范，可能包括，”当某行代码出错时，不继续往下执行。“
2.每个脚本开头都使用"#!"，它是指定一个文件类型的特殊标记，代表该文件就是一个可执行的脚本。在#!之后，接一个路径名，这个路径名指定了一个解释脚本命令的程序，这个程序可以是shell，程序语言或者任意一个通用程序。
```

### 分组操作

```shell
#添加分组
groupadd -g id 组名
参数说明：
-g：指定新建工作组的 id；
-r：创建系统工作组，系统工作组的组ID小于 500；
-K：覆盖配置文件 "/ect/login.defs"；
-o：允许添加组 ID 号不唯一的工作组。
-f,--force: 如果指定的组已经存在，此选项将失明了仅以成功状态退出。当与 -g 一起使用，并且指定的GID_MIN已经存在时，选择另一个唯一的GID（即-g关闭）。

#查看分组
cat /etc/group
#删除分组:
sudo groupdel 组名
```

### 递归创建目录

```shell
mkdir -p
#递归创建目录，即使上级目录不存在，会按目录层级自动创建目录。一次可以创建多级文件夹
```

### 添加用户到用户组

```shell
useradd [-mMnr][-c <备注>][-d <登入目录>][-e <有效期限>][-f <缓冲天数>][-g <群组>][-G <群组>][-s <shell>][-u <uid>][用户帐号]
```

### 文本文件的语言--AWK

```shell
awk [选项参数] 'script' var=value file(s)
#或
awk [选项参数] -f scriptfile var=value file(s)
选项参数:
-F fs or --field-separator fs
指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。(默认空格分割，取值$1，$2依次取出第一和第二个分割后的元素)
-v var=value or --asign var=value
赋值一个用户定义变量。
-f scripfile or --file scriptfile
从脚本文件中读取awk命令。
-mf nnn and -mr nnn
对nnn值设置内在限制，-mf选项限制分配给nnn的最大块数目；-mr选项限制记录的最大数目。这两个功能是Bell实验室版awk的扩展功能，在标准awk中不适用。
-W compact or --compat, -W traditional or --traditional
在兼容模式下运行awk。所以gawk的行为和标准的awk完全一样，所有的awk扩展都被忽略。
-W copyleft or --copyleft, -W copyright or --copyright
打印简短的版权信息。
-W help or --help, -W usage or --usage
打印全部awk选项和每个选项的简短说明。
-W lint or --lint
打印不能向传统unix平台移植的结构的警告。
-W lint-old or --lint-old
打印关于不能向传统unix平台移植的结构的警告。
-W posix
打开兼容模式。但有以下限制，不识别：/x、函数关键字、func、换码序列以及当fs是一个空格时，将新行作为一个域分隔符；操作符**和**=不能代替^和^=；fflush无效。
-W re-interval or --re-inerval
允许间隔正则表达式的使用，参考(grep中的Posix字符类)，如括号表达式[[:alpha:]]。
-W source program-text or --source program-text
使用program-text作为源代码，可与-f命令混用。
-W version or --version
打印bug报告信息的版本。
```

### xargs 工具

```shell
#xargs（英文全拼： eXtended ARGuments）是给命令传递参数的一个过滤器，也是组合多个命令的一个工具。
#xargs 可以将管道或标准输入（stdin）数据转换成命令行参数，也能够从文件的输出中读取数据。
#xargs 也可以将单行或多行文本输入转换为其他格式，例如多行变单行，单行变多行。
#xargs 默认的命令是 echo，这意味着通过管道传递给 xargs 的输入将会包含换行和空白，不过通过 #xargs 的处理，换行和空白将被空格取代。
#xargs 是一个强有力的命令，它能够捕获一个命令的输出，然后传递给另外一个命令。
#之所以能用到这个命令，关键是由于很多命令不支持|管道来传递参数，而日常工作中有有这个必要，所以就有了 xargs 命令，例如：
find /sbin -perm +700 |ls -l       #这个命令是错误的
find /sbin -perm +700 |xargs ls -l   #这样才是正确的

#命令格式
somecommand |xargs -item  command
-a file 从文件中读入作为 stdin
-e flag ，注意有的时候可能会是-E，flag必须是一个以空格分隔的标志，当xargs分析到含有flag这个标志的时候就停止。
-p 当每次执行一个argument的时候询问一次用户。
-n num 后面加次数，表示命令在执行的时候一次用的argument的个数，默认是用所有的。
-t 表示先打印命令，然后再执行。
-i 或者是-I，这得看linux支持了，将xargs的每项名称，一般是一行一行赋值给 {}，可以用 {} 代替。
-r no-run-if-empty 当xargs的输入为空的时候则停止xargs，不用再去执行了。
-s num 命令行的最大字符数，指的是 xargs 后面那个命令的最大命令行字符数。
-L num 从标准输入一次读取 num 行送给 command 命令。
-l 同 -L。
-d delim 分隔符，默认的xargs分隔符是回车，argument的分隔符是空格，这里修改的是xargs的分隔符。
-x exit的意思，主要是配合-s使用。。
-P 修改最大的进程数，默认是1，为0时候为as many as it can ，这个例子我没有想到，应该平时都用不到的吧。
```

### 修改用户信息

```shell
#usermod 命令就是用来调整使用 useradd 命令添加的用户信息
usermod [选项] 用户名
选项：
-c 用户说明：修改用户的说明信息，即修改 /etc/passwd 文件目标用户信息的第 5 个字段；
-d 主目录：修改用户的主目录，即修改 /etc/passwd 文件中目标用户信息的第 6 个字段，需要注意的是，主目录必须写绝对路径；
-e 日期：修改用户的失效曰期，格式为 "YYYY-MM-DD"，即修改 /etc/shadow 文件目标用户密码信息的第 8 个字段；
-g 组名：修改用户的初始组，即修改 /etc/passwd 文件目标用户信息的第 4 个字段（GID）；
-u UID：修改用户的UID，即修改 /etc/passwd 文件目标用户信息的第 3 个字段（UID）；
-G 组名：修改用户的附加组，其实就是把用户加入其他用户组，即修改 /etc/group 文件；
-l 用户名：修改用户名称；
-L：临时锁定用户（Lock）；
-U：解锁用户（Unlock），和 -L 对应；
-s shell：修改用户的登录 Shell，默认是 /bin/bash。
```

### 列出系统的所有sudo用户

```
getent group sudo 
```

### 查看linux用户密码（需要linux密码）

```shell
#用户名在/etc/passwd这个文件中；
#密码在/etc/shadow中
cat /etc/passwd
#结果
gizwits:x:2021:2021:Gizwits Manager:/home/gizwits:/bin/bash
#格式解释

{用户名}：{加密密码}：{口令最后修改时间距原点(1970-1-1)的天数}：{口令最小修改间隔(防止修改口令，如果时限未到，将恢复至旧口令)：{口令最大修改间隔}：{口令失效前的警告天数}：{账户不活动天数}：{账号失效天数}：{保留}

#为了安全，系统将明文密码进行了加密。查看加密方式
authconfig --test | grep hashing
```

### 删除用户

```shell
userdel -r 用户名
#用户相关文件也会删除。
```

### 用户得到权限

```shell
sudo -i 完全取得root的权限和root的工作环境。(只需要验证当前用户账号密码；进程的实际用户ID和有效用户ID都变成了root，主目录也切换为root的主目录)
su root 仅仅取得root权限，工作环境不变，（需要验证root密码；su root和su一样:表示与root建立一个链接，通过root执行命令，其实就是进程的有效用户ID变成了root）
```

### 结果黑洞

```shell
/dev/null
#脚本没有必要打印或者打印信息过多，减小性能和内存消耗，所以把信息丢到结果黑洞里面
```

### 查看系统版本

```shell
lsb_release -a
uname -a
cat /proc/version
uname -r
```

### 容器内部下载包

```shell
apk install 包名
```

### 传输超大文件

```shell
# 推送(https://www.cnblogs.com/coolops/p/12843436.html)
rsync -auvzP -e "ssh -p22" mssh.tar.gz root@192.168.176.11:/data/
# 拉取
rsync -auvzP -e "ssh -p22" root@192.168.176.11:/data/mssh.tar.gz .
```

### 压缩文件

```shell
# 压缩为*.gz
tar -zcvf test.tar.gz test.txt
# gz解压缩
tar -zxvf /usr/local/test.tar.gz
```

### 更换ubuntu源

1. ```shell
   1. 确定系统版本
   2. 找到源list
   3. 打开vi /etc/apt/sources.list
   4. apt update
   5. apt upgrade
   ```

### ubuntu20.04 图形界面开启与关闭

```
# 关闭图形界面
sudo systemctl set-default multi-user.target
# 开启图形界面
sudo systemctl set-default graphical.target
```

### centos7命令行安装wmvare tools

[Linux(CentOS 7)命令行模式安装VMware Tools 详解 - 阳光666 - 博客园 (cnblogs.com)](https://www.cnblogs.com/yblafxw/p/9272330.html)

### grep查看文件内容

```shell
grep [options]
[options]主要参数：
－c：只输出匹配行的计数。
－I：不区分大 小写(只适用于单字符)。
－h：查询多文件时不显示文件名。
－l：查询多文件时只输出包含匹配字符的文件名。
－n：显示匹配行及 行号。
－s：不显示不存在或无匹配文本的错误信息。
－v：显示不包含匹配文本的所有行。

# 查看有内容的文件夹下
grep 内容 -nr 文件夹
# 忽略大小写，文件夹查找内容
grep -i cgroup -nr ./
```



## 文件操作

> linux文件操作

### **Linux文件和目录的权限**

```shell
#文件或目录的权限可以分为3种:
r:4 读
w:2 写
x:1  执行(运行)
-：对应数值0
数字 4 、2 和 1表示读、写、执行权限
rwx = 4 + 2 + 1 = 7 (可读写运行）
rw = 4 + 2 = 6 （可读写不可运行）
rx = 4 +1 = 5 （可读可运行不可写）
#比如：最高权限777：（4+2+1）（4+2+1）（4+2+1）
第一个7:表示当前文件的拥有者的权限,7=4+2+1 可读可写可执行权限
第二个7:表示当前文件的所属组（同组用户）权限,7=4+2+1 可读可写可执行权限
第三个7:表示当前文件的组外权限,7=4+2+1 可读可写可执行权限
```

### 查看文件权限

```
ls -l 
ls ll 
ls -al
结果分为7列
    第一列：文件类型，1-代表普通文件 d-代表目录
　　第二列：文件节点数（node）
　　第三列：表示文件拥有者root用户
　　第四列：表示文件所属组root用户组
　　第五列：显示文件大小，默认是字节byte，可以通过命令 ls -lh 更人性化地查看文件大小
　　第六列：文件最后修改时间
　　第七咧：文件或目录的名称

```

### 设置文件权限

```shell
 #格式：chomd 755 文件名
	chown  xww  test       \\将test文件的属主改为xww用户
	chown  xww.xww  test      \\将test文件的属主改为xww用户，属组改为xww组
	chown  -R  xww:xww test   \\将test及其下的所有目录和文件的属主改为xww用户，属组改为xww组。参数-R有递归作用
```

### 查看文件夹大小

```shell
du -h --max-depth=1 文件夹名
```

### 查看指定数量文件

```shell
ls | more -1000
ls -lh|head -n 1000
```

### 文件大小排序查看

```shell
ls -Sl -hl	#降序
ls -Slr -hl #升序
```

### 创建软连接

```shell
ln -s   /tmp/aaa.sh /home/link    //在home下创建一个名为link的软链接，指向/tmp/aaa.sh
```

### ubuntu建立NFS服务

```shell
# 服务端
apt install nfs-server

# 挂载目录： /data/testspace
vi /etc/exports

# 共享文件夹挂载配置,设置数据集成内容
/data/testspace *(rw,sync,no_root_squash,no_subtree_check)
# 设置只读，固定IP能挂载
/data/testspace ip(ro,sync,no_root_squash,no_subtree_check)

# 权限
chmod 777 -R /data/testspace
# 更新配置,重新读取/etc/exports
exportfs -r 
showmount -e

#启用配置
/etc/init.d/nfs-kernel-server restart

# 客户端(也可使用其他客户端服务)
apt-get install nfs-common

#挂载
mount -t nfs -o nolock ip:/data/testspace /mnt

# 卸载挂载点
umount /mnt
```

#### NFS配置

```shell
【NFS共享的常用参数】
ro 只读访问
rw 读写访问
sync 同步写入硬盘
async 暂存内存
secure NFS通过1024以下的安全TCP/IP端口发送
insecure NFS通过1024以上的端口发送
wdelay 多个用户对共享目录进行写操作时，则按组写入数据（默认）
no_wdelay
多个用户对共享目录进行写操作时，则立即写入数据
hide 不共享其子目录
no_hide 共享其子目录
subtree_check 强制NFS检查父目录的权限
no_subtree_check 不检查父目录权限
all_squash 任何访问者，都转为 匿名yong
root_squash root用户访问此目录， 映射成如anonymous用户一样的权限（默认）
no_root_squash root用户访问此目录，具有root操作权限
```



## 系统属性

> linux 系统属性

### 查看系统cpu使用情况

```shell
top	#查看当前cpu使用情况。
#1 其中以id结尾的就是当前系统的cpu空闲率
#2 其中load average 三个数字代表1 5 15分钟前到现在的系统负载平均值
```

### 查看内核版本

```shell
cat /proc/version
uname -a
uname -r
```

### 查看linux版本信息

```
lsb_release -a
cat /etc/issue
```

### shell环境变量

```shell
#查看shell环境变量
export
echo $变量名
#添加环境变量
export 变量名=变量值
#环境变量可以在其进程的子进程中继续有效，而自定义变量则无效
```

### 查看硬盘内存大小

```shell
df -h
# 查看磁盘剩余空间信息
df -hl
```

### 关闭防火墙

```
ubuntu
ufw status
ufw disable
ufw enable
```

### 查看端口占用情况

```shell
lsof -i:端口号
netstat -tunlp | grep 端口号
netstat -ntlp   //查看当前所有tcp端口
netstat -ntulp | grep 80   //查看所有80端口使用情况
netstat -ntulp | grep 3306   //查看所有3306端口使用情况
```

### 杀死进程

```shell
kill -9 PID
```

### 查看全部进程

```shell
 ps aux | less	# 显示所有运行中的进程：
 pstree
 top
 ps -e			# 查看系统中的每个进程。
ps -U root -u root -N		# 查看非root运行的进程
ps -u vivek					# 查看用户vivek运行的进程

```

### 重启网卡

```
1、service network restart
2、ifconfig eth0 down / ifconfig eth0 up
3、ifdown eth0 / ifup eth0
```

```
systemctl list-unit-files
systemd-analyze plot > boot.svg
```



## 网络

> linux网络

### 虚拟机外部访问

​	设置成桥接模式，外部网络可以访问。NAT模式只是共享主机IP,外部一般无法访问

### nmcli

```shell
# 连接wifi
nmcli d wifi connect gizwits-云计算 password go4gizwits
# 扫描wifi
nmcli d wifi list
# 查看连接的wifi
nmcli c
# 删除wifi
nmcli c del UUID
```

### Netplan

```yaml
# 连接eth0、wifi
network:
    version: 2
    renderer: networkd
    ethernets:
        eth0:
            dhcp4: true
    wifis:                                                                      
        wlan0:                                                                  
            access-points:                                                      
              gizwits-云计算:                                                           
                auth:                                                           
                  key-management: psk                                           
                  password: "go4gizwits"                                          
            dhcp4: yes      
            optional: true                                                 
```



## 疑难杂症

> linux 操作系统出现的奇怪问题

### 系统盘变为只读文件的修复

```shell
# centos7
df -Th
# 找到centos-root
	#如：/dev/mapper/centos-root xfs 34G 1.3G 32G 4% /
# 重新挂载
mount -o rw,remount /dev/mapper/centos-root /
```



### 软件编译

> linux操作系统软件编译

#### 包下载地址

```shell
# ffmpeg
http://ffmpeg.org/releases/
```

#### 编译器

##### gcc

- -I ( i 的大写) ：指定头文件路径（相对路径或绝对路径，建议相对路径）
- -i ：指定头文件名字 (一般不使用，而是直接放在**.c 文件中通过#include<***.h> 添加)
- -L ：指定连接的动态库或者静态库路径（相对路径或绝对路径，建议相对路径）
  -l (L的小写)：指定需要链接的库的名字（链接 libc.a : -lc 链接动态库：libc.so : -lc）。 注意：-l后面可以直接添加库名省去“lib”和“.so”或“.a”。 -l(L的小写)链接的到底是动态库还是静态库，如果链接路径下同时有 .so 和 .a 那优先链接 .so 

#### 工具命令

##### ldd

- ldd 命令查看生成的目标文件链接的库

- 库文件编译的搜索路径
  - 先搜索-L指定的目录
  - gcc的环境变量LIBRARY_PATH；
  - 系统目录：/lib和/lib64、/usr/lib 和/usr/lib64、/usr/local/lib和/usr/local/lib64
