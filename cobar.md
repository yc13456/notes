## CoBar

### go get安装一个单独项目

```
go get -u github.com/spf13/cobra
//注意本地GO安装目录需要开放访问权限，否则cobra安装不了
```

### 添加go mod

```
go mod init c/Users/yc/Documents/goDemo/newApp
//注意，该mod需要在main.go同级目录下面
```

### 下载项目和依赖

```
go get -u -d +github包路径	//github包下载
go mod tidy		//下载整个项目依赖包（系统只下载只用了的包，import但未使用的包不会下载）
go mod vendor		//加载依赖包
```

### cobra参数说明：

```
cmd目录，整个项目的Command,其中root.go是最高级的Command
main.go整个项目的入口。初始化Cobra
vendor：项目依赖包的存放地方
pkg：package包所在，包含各种服务函数和方法
build:可以使用dockerFile抓取镜像
go.main：可以完成数据依赖下载、加载等操作
```

### 新建一个cobra项目

```go
cobra脚手架需要提前 go mod init
//1 新建一个project ，新建bin、src、pkg文件夹
//2 进入src文件夹，运行Cobra初始化	命令
	cobra init --pkg-name github.com/spf13/newApp
//3 安装初始化mod.go
	go mod init
//4 获取Cobra Github文件
	go get -u github.com/spf13/cobra
//5 下载Cobra项目依赖包
	go mod tidy
//6 加载依赖包
	go mod vendor
```

数据配置

```go
//	#Bind Flags with Config
var author string
func init() {
  rootCmd.PersistentFlags().StringVar(&author, "author", "YOUR NAME", "Author name for copyright attribution")
  viper.BindPFlag("author", rootCmd.PersistentFlags().Lookup("author"))
}

//1 rootCmd.PersistentFlags().StringVar获取控制台命令行参数。如上：得到命令行里面‘author’参数值并赋给本地author变量。

//2 还是viper主要是对配置文件进行操作。如read get bind 

//3 一个go脚本能够定义多个命令，使用方式：go run main.go +[use名]

```

Cobra框架运行流程

```go
1 当rootCmd绑定子Command之后，Init函数才会运行。单独运行go run main.go指挥显示usage和子命令参数提示
2
```

```
package main

import "fmt"

func main() {
   fmt.Println("22")
}
```

Edgetool工具使用

```
1、git clone 源码
2、go mod tidy
3、go mod vendor
4、go build main.go
```

