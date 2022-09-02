# GOlang

## 第1章：golang基础

### 1.1 语言特性

#### 1.1.1 自动垃圾回收

​	系统会自动帮我们判断，并在合适的时候（比如CPU 相对空闲的时候）进行自动垃圾收集工作

#### 1.1.2 更丰富的内置类型

1. 除了几乎所有语言都支持的简单内置类型
2. 数组切片（Slice）:一种可动态增 长的数组
3. 字典类型（map）

#### 1.1.3 函数多返回值

#### 1.1.4 错误处理

1. defer、
2. panic
3. recover

#### 1.1.5匿名函数和闭包

​	所有的函数也是值类型，可以作为参数传递

#### 1.1.6 类型和接口

1. 类型定义非常接近于C语言中的结构（struct），甚至直接沿用了struct关键字

2. 只是支持了最基本的类型组合功能

3. “非侵入式” 接口（接口的修改不会影响到所有改该接口的类型）

   实现了接口的全部方法，就可以直接转换

   ```
   type Bird struct {
    ...
   }
   func (b *Bird) Fly() {
    // 以鸟的方式飞行
   } 
   
   另外一个包
   type IFly interface {
    Fly()
   }
   
   func main() {
    var fly IFly = new(Bird)
    fly.Fly()
   }
   ```

#### 1.1.7 并发编程

1. 使用goroutine而不是裸用 操作系统的并发机制，
2. Go语言实现了CSP（通信顺序进程，Communicating Sequential Process）模型来作为goroutine 间的推荐通信方式

#### 1.1.8 反射

- **反射**是指在**程序运行期**对程序本身进行访问和修改的能力，程序在编译时变量被转换为内存地址，变量名不会被编译器写入到可执行部分，在运行程序时程序无法获取自身的信息。

- Go语言提供了 reflect 包来访问程序的反射信息

- 对象的序列化（serialization，有时候也叫Marshal & Unmarshal）（Go语言标准库的encoding/json、encoding/xml、encoding/gob、encoding/binary等包就大量 依赖于反射功能）

```
reflect.ValueOf(sparrow).Elem()  # 相当于对类型*操作
```



#### 1.1.9 语言交互性

1. go中，可以按Cgo的特定语法混合编写C语言代码，然后Cgo工具可以将这些混合的C 代码提取并生成对于C功能的调用包装代码

### 1.2 Go 程序

#### 1.2.1 代码解读

1. Go文件的开头package声明，表示Go代码所属的包
2. 包是Go语言里最基本的分发单位，也是工程管理中依赖关系的体现
3. 生成Go可执行程序，必须建立一个名 字为main的包，并且在该包中包含一个叫main()的函数（该函数是Go可执行程序的执行起点）
4. import语句，导入该程序所依赖的包
5. 不得包含在源代码文件中没有用到的包
6. 所有Go函数以关键字func开头
7. 在函数返回时没有被明确赋值的返回值都会被设置为默认值，比如result会被设为0.0，err会被设为nil
8. /* 块注释 */    // 行注释

#### 1.1.2 编译环境准备

```
# golang文件安装在/usr/local/
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
```

## 第2章：顺序编程

#### 2.1 变量

#### 2.2 类型

##### 2.2.1 布尔类型：bool

1. 布尔类型不能接受其他类型的赋值，不支持自动或强制的类型转换

##### 2.2.2 整型

1. int8、byte、int16、int、uint、uintptr等
2. int和int32在Go语言里被认为是两种不同的类型
3. value1 := 64 // value1将会被自动推导为int类型
4. 做**强制类型转换**时，需要注意**数据长度**被**截短**而发生的**数据精度损失**（比如 将浮点数强制转为整数）和**值溢出**（值超过转换的目标类型的值范围时）问题。
5. 两个不同类型的整型数不能直接比较，但是都可以直接与字面常量（literal）进行比较

##### 2.2.3 浮点类型：

1. float32、float64 类型

2. 浮点类型 采用IEEE-754标准的表达方式

3. fvalue2 := 12.0      // 如果加小数点，fvalue2->float64

4. 浮点数不是一种精确的表达方式，不能直接“==”比较大小

   ```go
   //比较浮点数
   import "math"
   // p为用户自定义的比较精度，比如0.00001
   func IsEqual(f1, f2, p float64) bool {
    return math.Fdim(f1, f2) < p
   } 
   ```

##### 2.2.4 复数类型

1. 两个实数（在计算机中用浮点数表示）构成，一个表示实部（real），一个表示 虚部（imag）。
2. complex64、complex128
3. 复数z = complex(x, y)，就可以通过Go语言内置函数real(z)获得该复数的实 部，也就是x，通过imag(z)获得该复数的虚部

##### 2.2.5 字符串：string

1. 字符串的内容不能在初始化后被修改，

字符类型：rune

错误类型：error

##### 2.2.6 复合类型

指针（pointer）

##### 2.2.7 数组：array

1. 数组是值类型， 每次传递都将产生一份**副本**
2. 数组的长度在定义之后无法再次修改

##### 2.2.8 数组切片：slice

1. 数据结构：

   1. 一个指向原生数组的指针
   2. 数组切片中的元素个数
   3. 数组切片已分配的存储空间。

2. 创建数组切片

   1. 基于数组

      ```go
      // 先定义一个数组
       var myArray [10]int = [10]int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
       // 基于数组创建一个数组切片
       var mySlice []int = myArray[:5]
      ```

   2. 直接创建

      ```go
      //创建一个初始元素个数为5的数组切片，元素初始值为0：
      mySlice1 := make([]int, 5)
      //创建一个初始元素个数为5的数组切片，元素初始值为0，并预留10个元素的存储空间：
      mySlice2 := make([]int, 5, 10)
      //直接创建并初始化包含5个元素的数组切片：
      mySlice3 := []int{1, 2, 3, 4, 5} 
      ```

3.  元素遍历

   ```go
   //传统的元素遍历方法如下:
   for i := 0; i <len(mySlice); i++ {
    fmt.Println("mySlice[", i, "] =", mySlice[i])
   }
   //使用range关键字可以让遍历代码显得更整洁。range表达式有两个返回值，第一个是索引，第二个是元素的值：
   for i, v := range mySlice {
    fmt.Println("mySlice[", i, "] =", v)
   } 
   ```

4. 动态增减元素

   1. cap()函数：数组切片分配的空间大小

   2. len()函数：数组切片中当前所存储的元素个数

   3. append

      ```go
      mySlice2 := []int{8, 9, 10}
      //从尾端给mySlice加上3个元素,从而生成一个新的数组切片
      mySlice = append(mySlice, 1, 2, 3)
      
      // 给mySlice后面添加另一个数组切片
      mySlice = append(mySlice, mySlice2...) 
      ```

      1. append()的语义，从第二个参数起的所有参数都是待附加的 元素。
      2. mySlice中的元素类型为int，所以直接传递mySlice2是行不通的。加上省略号相 当于把mySlice2包含的所有元素打散后传入

5. 基于数组切片创建数组切片

   ```go
   oldSlice := []int{1, 2, 3, 4, 5}
   newSlice := oldSlice[:3] // 基于oldSlice的前3个元素构建新数组切片
   ```

6. 内容复制

   copy()，用于将内容从一个数组切片复制到另一个 数组切片。如果加入的两个数组切片不一样大，就会按其中较小的那个数组切片的元素个数进行 复制

   ```go
   slice1 := []int{1, 2, 3, 4, 5}
   slice2 := []int{5, 4, 3}
   copy(slice2, slice1) // 只会复制slice1的前3个元素到slice2中
   copy(slice1, slice2) // 只会复制slice2的3个元素到slice1的前3个位置
   ```

##### 2.2.9 字典（map）

1. map是一堆键值对的未排序集合

   ```
   // PersonInfo是一个包含个人详细信息的类型
   type PersonInfo struct {
   	ID      string
   	Name    string
   	Address string
   }
   func main() {
   	var personDB map[string]PersonInfo
   	personDB = make(map[string]PersonInfo)
   	// 往这个map里插入几条数据
   	personDB["12345"] = PersonInfo{"12345", "Tom", "Room 203,..."}
   	personDB["1"] = PersonInfo{"1", "Jack", "Room 101,..."}
   	// 从这个map查找键为"1234"的信息
   	person, ok := personDB["12345"]
   	// ok是一个返回的bool型，返回true表示找到了对应的数据
   	if ok {
   		fmt.Println("Found person", person.Name, "with ID 1234.")
   	} else {
   		fmt.Println("Did not find person with ID 1234.")
   	}
   }
   ```

2. 变量声明

   ```go
   var myMap map[string] PersonInfo
   ```

3. 创建

   ```go
   myMap = make(map[string] PersonInfo) 
   
   //创建了一个初始存储能力为100的map:
   myMap = make(map[string] PersonInfo, 100) 
   //创建并初始化map的代码如下：
   myMap = map[string] PersonInfo{
    "1234": PersonInfo{"1", "Jack", "Room 101,..."},
   } 
   ```

4. 元素赋值

   ```go
   myMap["1234"] = PersonInfo{"1", "Jack", "Room 101,..."}	
   ```

5. 元素删除

   ```go
   delete(myMap, "1234") 
   ```

6. 元素查找

   ```
   value, ok := myMap["1234"]
   if ok { // 找到了
    // 处理找到的value
   } 
   ```

##### 2.2.10 通道（chan）

##### 2.2.11 结构体（struct）

##### 2.2.12 接口（interface）



#### 2.3 流程控制

##### 2.3.1 条件语句

##### 2.3.2 选择语句

```go
	switch i {
	case 0:
		fmt.Printf("0")
	case 2:
		fallthrough
	case 3:
		fmt.Printf("3")
	case 4, 5, 6:
		fmt.Printf("4, 5, 6")
	default:
		fmt.Printf("Default")
	}
```

Go里面switch默认相当于每个case最后带有break，匹配成功后不会自动向下执行其他case，而是跳出整个switch, 但是可以使用**fallthrough强制执行后面的一个case代码**

##### 2.3.3 循环语句

1. go循环语句只支持for关键字

#### 2.4 函数

函数的基本组成为：关键字func、函数名、 参数列表、返回值、函数体和返回语句

##### 2.4.1 函数定义

```go
func Add(a, b int)(ret int, err error) {
 // ...
} 
```

##### 2.4.2 函数调用

```go
import "mymath"// 假设Add被放在一个叫mymath的包中
 // ...
c := mymath.Add(1, 2)
```

##### 2.4.3 不定参数

1. 不定参数类型

   ```go
   func myfunc(args ...int) {
    	for _, arg := range args {
   	 	fmt.Println(arg)
    	}
   }
   //这段代码的意思是，函数myfunc()接受不定数量的参数，这些参数的类型全部是int，所以它可以用如下方式调用：
   myfunc(2, 3, 4)
   myfunc(1, 3, 7, 13) 
   ```

2. 不定参数的传递

   ```go
   // 按原样传递
    myfunc3(args...)
    // 传递片段，实际上任意的int slice都可以传进去
    myfunc3(args[1:]...) 
   ```

3. 任意类型的不定参数

   ```go
   func Printf(format string, args ...interface{}) {
    // ...
   } 
   ```

##### 2.4.4 多返回值

##### 2.4.5 匿名函数与闭包

1. 匿名函数

   ```go
   //不带函数名的函数声明和函数体
   func(a, b int, z float64) bool {
    return a*b <int(z)
   } 
   ```

   ```go
   capture := func(ctx context.Context, signal types.Signal) {
   	defer cwg.Done()
   	c.camera.Capture(ctx, signal.GetIndex())
   }
   
   capture(ctx, signal)
   ```

2. 闭包

​		闭包是可以包含自由（未绑定到特定对象）变量的代码块，这些变量不在这个代码块内或者 任何全局上下文中定义，而是在定义代码块的环境中定义。

```go
var j = 5
	a := func() func() {
		var i = 10
		return func() {
			fmt.Printf("i, j: %d, %d\n", i, j)
		}
	}()
	a()
	j *= 2
	a()
	
//在变量a指向的闭包函数中，只有内部的匿名函数才能访问变量i，而无法通过其他途径访问到，因此保证了i的安全性
```

#### 2.5 错误处理

##### 2.5.1 error接口

1. error接口：错误处理的标准模式（最后一个defer语句将最先被执行）

##### 2.5.2 defer

1. defer语句的调用：**先进后出**的原则

##### 2.5.3 panic()和recover()

1. **调用panic()函数**时，正常的**函数**执行流程将**立即终止**，但函数中之前使用**defer**关键字延迟执行的**语句**将**正常展开执行**。之后该函数将返回到调用函数，并导致逐层向上执行panic流程，直至所属的goroutine中所有正在执行的函数被终止。错误信息将被报告，包括在调用panic()函数时传入的参数，这个过程称为错误处理流程
2. recover：防止程序崩溃。可以让进入**宕机流程**中的 goroutine **恢复**过来，recover **仅在**延迟函数 **defer 中有效**，在正常的执行过程中，**调用 recover** 会**返回 nil** 并且没有其他任何效果，如果当前的 goroutine **陷入恐慌**，调用 recover 可以**捕获到 panic 的输入值**，并且**恢复正常**的执行

## 第3章：面向对象编程

### 3.1 类型系统

类型系统是指一个语言的类型体系结构。一个典型的类型系统通常包含如下基本 内容：

1. 基础类型，如byte、int、bool、float等
2. 复合类型，如数组、结构体、指针等
3. 可以指向任意对象的类型（Any类型--interface{}）
4. 值语义和引用语义
5. 面向对象，即所有具备面向对象特征（比如成员方法）的类型
6. 接口

#### 3.1.1 为类型添加方法

```go
//定义了一个新类型Integer，它和int没有本质不同，只是它为内置的int类型增加了个新方法Less()
type Integer int
func (a Integer) Less(b Integer) bool {
	return a < b
}
func main() {
	var a Integer = 1
	if a.Less(2) {
		fmt.Println(a, "Less 2")
	}
}
```

#### 3.1.2 值语义和引用语义

值语义和引用语义的差别在于赋值；Go语言中的大多数类型都基于值语义

```go
b = a
b.Modify()
// 如果b的修改不会影响a的值，那么此类型属于值类型。如果会影响a的值，那么此类型是引用类型
```



### 辨析

```
'{'不能单独放在一行,'}'可以单独放一行
```

```
声明变量的一般形式是使用 var 关键字：
```

```
单纯地给 a 赋值也是不够的，这个值必须被使用()

全局变量是允许声明但不使用的。 同一类型的多个变量可以声明在同一行
```

```
常量是一个简单值的标识符，在程序运行时，不会被修改的量。
```

```
在数组上使用range将传入index和值两个变量：
nums := []int{2, 3, 4}
```

```
被defer标记的d函数中的程序“立即执行”，而d函数返回的函数则在测试方法结束后 按照“后进先出”的顺序执行（栈的形式）
```

```
User:结构体
map[string]User 	//定义一个集合，'key':string类型；value:'User'结构体类型
make[map[string]User]	//定义一个切片，元素是map集合
```

```
1.go总是先从GOROOT出先搜索，再从GOPATH列出的路径顺序中搜索，只要一搜索到合适的包就理解停止。当搜索完了仍搜索不到包时，将报错。
2.搜索路径都是放在src下面
```

#### nil与NULL的区别

|          |               nil                |                   NULL                   |
| :------: | :------------------------------: | :--------------------------------------: |
| 初始化值 |               nil                |                    0                     |
| 真假判断 | 只有nil与false表示假，其余均为真 |                                          |
| 赋值对象 |       nil一般赋值给空对象        |       NULL一般赋值给nil之外的空值        |
| 空值情况 |      nil是一个对象指针为空       | NULL是一个类指针为空，其基本数据类型为空 |



##### 修改go语言环境配置

当你安装的GO的语言版本大于1.13的时候，那么就不用这么麻烦了，直接使用go env -w命令就行了

```
例如：
go env -w GOPROXY=https://goproxy.io,direct
# Set environment variable allow bypassing the proxy for selected modules
go env -w GOPRIVATE=*.corp.example.com
go env -w GO111MODULE=on
```

#### GOLang匿名函数

```
#Go 语言支持匿名函数，可作为闭包。匿名函数是一个"内联"语句或表达式。匿名函数的优越性在于可以直接使用函数内的变量
#	开发一个形式方法名或者参数，做为该函数构建入口。
#	如：
func getSequence() func() int {
   i:=0
   return func() int {
      i+=1
     return i  
   }
}

func main(){
   /* nextNumber 为一个函数，函数 i 为 0 */
   nextNumber := getSequence()  
   /* 调用 nextNumber 函数，i 变量自增 1 并返回 */
   fmt.Println(nextNumber())
   fmt.Println(nextNumber())
}
#匿名函数返回一个函数时，使用该函数的时候，函数里面的变量会保存下来，下次可以收到该该改变。
```



## 示例程序

#### 1、iota实例

```
#iota：常量自动生成器
package main

import "fmt"
const (
    i=1<<iota
    j=3<<iota
    k
    l
)

func main() {
    fmt.Println("i=",i)
    fmt.Println("j=",j)
    fmt.Println("k=",k)
    fmt.Println("l=",l)
}
#结果：
i= 1
j= 6
k= 12
l= 24
#赋常量，出现一行有常量没有赋初值，系统会按照上一行的数据格式赋予初值
```

#### 2、位运算符号

```go
var c int
c=4
c <<=  2
fmt.Printf("第 6行  - <<= 运算符实例，c 值为 = %d\n", c )
c >>=  2
fmt.Printf("第 7 行 - >>= 运算符实例，c 值为 = %d\n", c )
结果:
第 6行  - <<= 运算符实例，c 值为 = 16
第 7 行 - >>= 运算符实例，c 值为 = 4
#十进制int整形数据，右移后赋值，位数不够的，保持原状？
```

#### 3、go语言函数闭包

```
package main
import "fmt"

func getSequence() func() int {
   i:=0
   return func() int {
      i+=1
     return i  
   }
}

func main(){
   /* nextNumber 为一个函数，函数 i 为 0 */
   nextNumber := getSequence()  

   /* 调用 nextNumber 函数，i 变量自增 1 并返回 */
   fmt.Println(nextNumber())
   fmt.Println(nextNumber())
   fmt.Println(nextNumber())
   
   /* 创建新的函数 nextNumber1，并查看结果 */
   nextNumber1 := getSequence()  
   fmt.Println(nextNumber1())
   fmt.Println(nextNumber1())
}
#执行结果：
1
2
3
1
2

#为什么数据会在执行nextNumber1()函数之后，i会一直保存叠加？
#匿名函数返回一个函数时，使用该函数的时候，函数里面的变量会保存下来，下次可以收到该该改变。
```

#### 4、for循环切片

```
func main() {
	//这是我们使用range去求一个slice的和。使用数组跟这个很类似
	nums := []int{2, 3, 4}
	sum := 0
	for _, num := range nums {
		sum += num
	}
	fmt.Println("sum:", sum)
}
#结果：9
#但是如下图，结果是3
#大概是固定搭配，切片状态，使用for循环需要使用给两个返回值。map
```

![3](C:\Users\yc\Pictures\3.png)

#### 5、go实现接口

```
package main
import (
    "fmt"
)

type Phone interface {
    call()
}

type NokiaPhone struct {
}
#实现接口的nokiaPhone方法
func (nokiaPhone NokiaPhone) call() {
    fmt.Println("I am Nokia, I can call you!")
}

type IPhone struct {
}
#实现接口的iPhone方法
func (iPhone IPhone) call() {
    fmt.Println("I am iPhone, I can call you!")
}

func main() {
    var phone Phone
    phone = new(NokiaPhone)
    #这儿new的是结构体？还是实现接口的方法？
    phone.call()
   
    phone = new(IPhone)
    phone.call()

}
#接口实现的方式不太清晰？
#方法名前面定义的部分，代表方法需要哪些结构。所以上述给一个结构体之后，便拥有了该方法的全部实现方法
```

#### 5、通道(chan)实现

```
1.通道有一个默认缓冲区，可以保存输送到管道的数据。
2.管道内部数据被拿出打印或者其他操作，就看作缓冲区数据被消费一个
```

#### 6、defer延迟执行

```
func GetCount() int {
    // 锁定
    countGuard.Lock()
    // 在函数退出时解除锁定
    defer countGuard.Unlock()
    return count
}
func SetCount(c int) {
    countGuard.Lock()
    count = c
    countGuard.Unlock()
}
//使用defer延迟执行有意义吗？
//都是等待函数执行结束，只不过defer“先进后出”
```

#### 7、golang中.([]byte)和 []byte()

```
.([]byte)
value, ok := var.([]byte)
//这是标准的golang类型断言(Type Assertion)。这里的var一般是一个interface{}类型的变量。这句的字面含义是“我认为var这个interface{}类型变量的underlying type是[]byte，如果是，请将其值赋给变量value，并且ok =true，如果不是ok = false。

[]byte() 
value, ok := []byte(var) 
//这是标准的golang显式转型，将变量var转换成[]byte类型，并赋值给value
```





#### 8、Golang 函数和方法的区别

|          | 函数                                                         | 方法                                                   |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| 含义     | 函数function是⼀段具有独⽴功能的代码，可以被反复多次调⽤，从⽽实现代码复⽤ | ⽅法method是⼀个类的⾏为功能，只有该类的对象才能调⽤。 |
| 接收者   | 函数⽆接受者                                                 | ⽅法有接受者                                           |
| 作用对象 | 没有作⽤对象                                                 | 具有作⽤对象                                           |
| 命名     | 函数不可以重名                                               | ⽅法可以重名                                           |
| 调用方式 | 函数是直接调用                                               | 方法由struct对象通过.点号调用                          |

```
1.Go语⾔，同时有函数和⽅法，⽅法的本质是函数，但是⽅法和函数⼜具有不同点。
2.⼀个⽅法就是⼀个包含了接受者的函数；
3.Go语⾔中， 接受者的类型可以是任何类型，不仅仅是结构体， 也可以是struct类型外的其他任何类型
```

#### 9、net标准库

```
listen, err := net.Listen("tcp", "192.168.79.1:8080")	//监听ip和端口
con, err := listen.Accept()		//监听客户端连接，返回socket连接句柄
data := make([]byte, 1000)	//接受客户端数据缓冲区
n, err := con.Read(data)	//读取数据
```

```
//简单的TCP服务器
package main

import(
	"fmt"
	"net"
)
func Read(con net.Conn){
	data := make([]byte, 1000)
	for{
		n, err := con.Read(data)
		if err != nil{
			fmt.Println(err)
			break
		}
		fmt.Println(string(data[0:n]))
	}
}
func main(){
	listen, err := net.Listen("tcp", "192.168.79.1:8080")
	if err != nil{
		fmt.Println(err)
		return
	}
	for{
		con, err := listen.Accept()
		if err != nil{
			fmt.Println(err)
			continue
		}
		go Read(con)
	}
}
//客户端（linux系统安装NC服务）直接用：
nc 192.168.79.1 8080
//服务端会监听本机ip中的8080端口，然后接受客户端的连接请求，连接成功之后，读取来自客户端的数据，并打印出来。
```

```
//简单的HTTP服务
package main

import(
	"fmt"
	"net/http"
)

func HandleIndex(w http.ResponseWriter, r *http.Request){
	r.ParseForm()
	fmt.Println("PATH: ", r.URL.Path)
	fmt.Println("SCHEME: ", r.URL.Scheme)
	fmt.Println("METHOD: ", r.Method)
	fmt.Println()
	fmt.Fprintf(w,  "<h1>Index Page</h1>")
	fmt.Println(w)
}

func main(){
	fmt.Println("Start")
	http.HandleFunc("/", HandleIndex)
	err := http.ListenAndServe(":8000", nil)
	if err != nil{
		fmt.Println(err)
	}
}

```

#### 10、go语言err异常处理要放在正确返回值后面

```
		n, err := con.Read(data)
		fmt.Println("n",n)
		//退出
		if n == 0 {
			quit1(&newuser ,con)
			//下线广播
			msginfo := fmt.Sprintf("id:%s,name:%s 下线了...\n", newuser.id, newuser.name)
			message <- msginfo
		}
		if err != nil{
			fmt.Println(err)
			break
		}
```

#### 11、Channel读写

```
读或者写一个nil的channel的操作会永远阻塞。
读一个关闭的channel会立刻返回一个channel元索类型的零值。
写一个关闭的channel会导致panic。
map也是指针，实际数据在堆中，未初始化的值是nil。
```

## 网络处理库

#### pprof

是 Go 语言中分析程序运行性能的工具，它能提供各种性能数据

```
m.Handle("/debug/pprof/cmdline", http.HandlerFunc(pprof.Cmdline))
```

![pprof 采集的信息类型](https://user-images.githubusercontent.com/7698088/68523507-3ce36500-02f5-11ea-8e8f-438c9ef2b9f8.png)

## 额外语法

### struct{}

```go
stopflag := make(chan struct{})
stopflag <- struct{}{} //写
<-stopflag			//读
"struct{}{}"，第一个"{}"对表示类型，第二个"{}"对表示一个类型对象实例。
```

#### type

- 类型定义：定义了一种新的类型

  ```go
  type Student struct {
    name String
    age int
  }
  
  type I int
  ```

- 类型别名：给现有的类型取了一个别名alias

  ```
  type Sdt = Student
  type I = int
  ```

## go下载git项目

```shell
1、git clone 源码
2、go mod tidy
3、go mod vendor
4、go build main.go
# 例子下载gitlab.gizwits.com项目
1.安装go
2、配置go env 
GONOPROXY="*.gizwits.com"
GONOSUMDB="*.gizwits.com"
GOPROXY="https://goproxy.cn,direct"	
GO111MODULE=off #关闭go mod

#注意：Go get报错 fatal: could not read Username for 'https://xxx': terminal prompts disabled
git config --global --add url."git@gitlab.gizwits.com:".insteadOf "https://github.com/"

```

运行环境

```shell
export GOROOT=~/go
export PATH=$PATH:$GOROOT/bin
```



## 小工具代码

### 读取yaml文件

```yaml
parameter:
  originPk: "36b62c8efa114d8aafe338aaca84f171"
  originPs: "7a54dc0200564c7aa3eae7fdb83cb38d"
  targetPk: "104be435e6e04486ace3da9563e07677"
  targetPs: "319514c872dd49aeb4106023a9b93e65"
  # OTA设备数量
  totalCount: 1000
  # 接口错误重试数
  retryCount: 300
  # openAPI地址
  url: "https://api2.iotsdk.com"
m2m:
  apiPort: 8082
  m2mToken: "Z2l6d2l0c19tMm0gcm9ja3M="
```

```go
type Config struct {
	Parameter struct {
		OriginPk   string `yaml:"originPk"`
		OriginPs   string `yaml:"originPs"`
		TargetPk   string `yaml:"targetPk"`
		TargetPs   string `yaml:"targetPs"`
		TotalCount int    `yaml:"totalCount"`
		RetryCount int    `yaml:"retryCount"`
		URL        string `yaml:"url"`
	}
}

func ParseConfig(configFile string, config *Config) (Config, error) {
	data, err := ioutil.ReadFile(configFile)
	fmt.Println(string(data))
	if err != nil {
		fmt.Println("failed to read config file %s: %v", configFile, err)
		return *config, nil
	}
	err = yaml.Unmarshal(data, config)
	if err != nil {
		fmt.Println("failed to unmarshal config file %s: %v", configFile, err)
		return *config, nil
	}
	return *config, nil
}

func main() {
	var config Config
	var err error
	str, _ := os.Getwd()	#注意不同系统，返回不同，在命令行下面使用
	config, err = ParseConfig(path.Join(str, ConfigFile), &config)		#path.join会兼容大部分系统文件分隔符
	if err != nil {
		fmt.Println("config.yaml load error")
	}
	fmt.Println("config:", config)
}
```

