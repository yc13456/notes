## Git基本使用

### Git工作流程

1. 克隆 Git 资源作为工作目录。
2. 在克隆的资源上添加或修改文件
3. 如果其他人修改了，你可以更新资源。
4. 在提交前查看修改。
5. 提交修改。
6. 修改完成后，如果发现错误，可以撤回提交并再次修改并提交。

![img](https://www.runoob.com/wp-content/uploads/2015/02/git-process.png)

### Git 工作区、暂存区和版本库

#### 概念

1. **工作区：**在电脑里能看到的目录。
2. **暂存区：**英文叫 stage 或 index。一般存放在 **.git** 目录下的 index 文件（.git/index）中，所以我们把暂存区有时也叫作索引（index）。
3. **版本库：**工作区有一个隐藏目录 **.git**，这个不算工作区，而是 Git 的版本库。

![img](https://www.runoob.com/wp-content/uploads/2015/02/1352126739_7909.jpg)

Git指令

```shell
#打标签：
git tag -a 标签名 -m 标签描述
git push 本地branch名 标签名
#删除本地标签
git tag -d 标签名
#删除远程仓库tag
git push origin :refs/tags/标签名
#建立本地ssh密钥
ssh-keygen -t rsa -C "yc_13456@163.com"
#验证是否能连接github
ssh -T git@github.com
#获取云端有，本地没有的数据
git fetch [alias]
#将服务器上的任何更新（假设有人这时候推送到服务器了）合并到你的当前分支。
git merge [alias]/[branch]
```

获取远程分支到本地

```shell
git fetch origin remote仓库
git checkout remote仓库
git pull
```
pk:(10万一个)
mac:1-500000
did:1-500000

40万次请求（第一次缓存，第一次读）
10 个客户端（5个。5个）

### go get 访问私有仓库的问题

- 给仓库打 tag，这样仓库地址可以被识别
- export GOPRIVATE=git@github.com；go build 时，系统不会用 GOPROXY 以及校验 SUM
- 调整 git https 为 ssh

```
git config --global url."git@gitlab.gizwits.com:".insteadof "https://gitlab.gizwits.com/"
```

### 删除add 缓存区文件

```
rm .git/index
```

### 撤销commit文件

```
git reset --soft HEAD^ #撤销最后一次
git reset --soft HEAD~2 # 撤销最后二次
```

### 提交本地代码到远程仓库 

```
git remote add origin https://github.com/yc13456/device-control
git remote -v 
git add .
git commit -m "init"
git push --set-upstream origin master
```

```
[Unit]
Description=Edge QCR4F
After=network-online.target
Requires=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/edgeqcr4f --config /etc/edgerobot/config.json
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
```

```
[Unit]
Description=Edge FRPC
After=network-online.target
Requires=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc --config /etc/edgerobot/frpc.ini
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target

```

```
[common]
server_addr = 159.75.234.92
server_port = 7000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 8000
remote_port = 31999

```

```
[Unit]
Description=Edge QRC4T service
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=simple
WorkingDirectory=/usr/local/lib
ExecStart=taskset -c 0,1,2,3 /usr/local/bin/edgeqcr4t --logtostderr=false --log_file=/data/logs/edgeqcr4t.log --log_file_max_size=1024
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
```

0.5s执行保存操作,执行20次.容量5s更新加1.正确应保存3张图片

0.5s执行保存操作,执行100次.容量5s更新加1.规定时间内容量为60.正确应保存64张图片之后,容量被消耗,等待下一次容量补充

ffmpeg encode产生mkv

ffmpeg Decode解压mkv成图片

将目标时间范围内文件上传到cos

