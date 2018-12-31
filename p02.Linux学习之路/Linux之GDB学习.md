# Linux之GDB学习

GDB是一款优秀的调试工具，懂的人自然懂，一直以来用它都没有好好整理过使用方法，我用的也是皮毛，目前先整理一下皮毛，日后再更新

### 使用方法

**编译C++**

从编译的角度上来说，需要在编译的时候加上`-g`参数，生成调试信息，否则GDB无法对该程序进行Debug

`$ gcc -g main.cc `



**启动GDB**

`$ gdb /your/program`即可

**设置命令行参数**

> set args 给args变量赋值

`(gdb) set args -a -b`或`$ gdb /your/program -a -b`

查看当前的参数使用`(gdb) show args`

python程序的调试也可以使用`$ gdb python main.py`



**装载程序**

> file FILE 装载指定的可执行文件进行调试

如果只是打开了gdb程序没有初始化装载程序，可以通过file命令装载可执行文件

> cd directory 改变当前工作目录
>
> pwd 显示当前工作目录

装载可执行文件的时候也有工作目录的说法，可以通过cd命令切换



**浏览程序**

> list linenum 显示当前源文件的指定行数
>
> list function 显示当前源文件的指定函数
>
> list filename 显示指定的源文件
>
> list filename:linenum 显示指定的源文件的指定行数，函数同理
>
> list 显示下一个listsize大小的源代码，可以通过set/show命令修改大小，默认10行
>
> list - 显示最后一次list的前面listsize的源代码

浏览源代码对于定位core dump发生的原因，定位设断点的位置都特别有帮助



**设置断点**

breakpoints：

> break linenum 在当前源文件的指定行数设置断点
>
> break function 在当前源文件的指定函数设置断点
>
> break filename:linenum 在指定源文件的指定行数设置断点，函数同理
>
> break something if condition 条件断点，符合条件的时候断点才会触发

watchpoints：

> watch expr 当应用程序写expr，修改其值时触发
>
> rwatch expr 当应用程序读expr的值时触发
>
> awatch expr 当应用程序读取或写入expr的值时触发

catchpoints：

> catct event 在发生某种事件的时候触发
>
> tcatch event 同上，但只停一次，生效后自动删除
>
> 事件一般类型为：throw、catch、exec、fork、load、syscall等

断点是调试的中间过程的记录，在循环的地方多使用条件断点，可以减少很多的人工操作

断点管理：

> info breakpoint 查看断点
>
> delete breakpoint num 删除断点
>
> disable breakpoint num 禁用断点
>
> enable breakpoint num 启用断点

删除或禁用一些断点有利于程序的快速执行，比如一个断点已经测试几次都没运行崩溃，说明这个断点没问题，可以不要了



**运行程序**

> run 运行装载的可执行程序
>
> step 运行下一行代码，遇到函数时进入函数
>
> next 运行下一行代码，遇到函数时运行整个函数
>
> continue 断点触发后，继续执行
>
> call function 调用和执行特定的函数

一般情况下，我也只使用这些，目前也够用了，call命令可以多次测试一个函数在不同参数下的运行情况



**查看变量**

> print variable 打印一个变量
>
> whatis variable 打印一个变量的类型
>
> ptype variable 打印一个struct或class的定义
>
> backtrace 打印程序中的当前位置和表示如何到达当前位置的栈跟踪

set variable 可以修改一个变量的值，但一般情况下不建议人为地去修改这些变量的值

backtrace是一个好命令，遇到core dump的时候使用很方便



**万能的命令**

> help COMMAND 显示指定命令的帮助信息

### 缩写映射表

```
b -> break
c -> continue
d -> delete
i -> info
l -> list
n -> next
p -> print
r -> run
s -> step
u -> until
bt -> backtrace
aw -> awatch
rw -> rwatch
wa -> watch
```

初期使用GDB的时候不建议记忆和使用缩写，后期你自然就会因为懒得写多两个字母而自然而然地使用缩写了