## Django

### 查询命令

#### 查询django版本

```shell
python -m django --version
```

#### 查询包版本

```python
import scrapy
scrapy.__version__
```

### 获取数据

```python
#是一个Python字典，包含了所有本次HTTP请求的Header信息
request.META 
```

## python

### 动态参数

```python
*args
#一个星号表示接收任意个参数。调用时，会将实际参数打包成一个元组传入形式参数。如果参数是个列表，会将整个列表当做一个参数传入
**kwargs
#工作原理和*args有点类似，但不是接收位置参数，而是接收关键字(keyword)参数(也叫被命名的参数)

# *操作符告诉print()首先将list解包
my_list = [1, 2, 3]
print(*my_list)
```

修饰符

```python
#修饰符对应的函数不需要实例化，不需要 self 参数，但第一个参数需要是表示自身类的 cls 参数，可以来调用类的属性，类的方法，实例化对象等。
```

### 函数

#### setattr() 

```python
#函数指定对象的指定属性的值
class Person:
  name = "John"
  age = 36
  country = "Norway"
setattr(Person, 'age', 40)
```

#### getattr() 

```python
#getattr() 函数获取某个类实例对象中指定属性的值
class CLanguage:
    def __init__ (self):
        self.name = "C语言中文网"
        self.add = "http://c.biancheng.net"
    def say(self):
        print("我正在学Python")

clangs = CLanguage()
print(getattr(clangs,"name"))
print(getattr(clangs,"add"))
print(getattr(clangs,"say"))
print(getattr(clangs,"display",'nodisplay'))
```