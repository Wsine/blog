#Ubuntu系统安装配置 Pintos 和 Bochs

###安装过程
首先是UEFI启动模式下Win8.1安装Ubuntu14.04双系统，由于篇幅过长，就不在这里详写。可见博主的另一篇博客[http://www.cnblogs.com/wsine/p/4297580.html](http://www.cnblogs.com/wsine/p/4297580.html)

本身已安装过其它软件，所以之前就安装好了一些必备的依赖库。
安装方法都是`sudo apt-get stall xxx`比较简单
![1](http://images0.cnblogs.com/blog2015/701997/201507/212207453812915.png)
![2](http://images0.cnblogs.com/blog2015/701997/201507/212207590994290.png)

接着就是解压两个软件到本地中，我选择的目录是`~/Software/OS_Concepts`
![3](http://images0.cnblogs.com/blog2015/701997/201507/212208398814531.png)

初始化bochs的配置，命令行完成，然后打开configure文件却不知道该如何查看，截图这个以示完成（我用的文本编辑器是sublime）
![4](http://images0.cnblogs.com/blog2015/701997/201507/212209023819657.png)

接着是修改ubuntu的环境变量，添加pintos进去，并运行试试
![5](http://images0.cnblogs.com/blog2015/701997/201507/212209409903528.png)
![6](http://images0.cnblogs.com/blog2015/701997/201507/212210007714384.png)

更改pintos下src/utils文件夹下面的Makefile文件
![7](http://images0.cnblogs.com/blog2015/701997/201507/212210238341639.png)

然后make命令执行之后，进行make check操作后截图可见
![8](http://images0.cnblogs.com/blog2015/701997/201507/212210393491200.png)

###后记

首先是大家看不懂教程的`$PINTOS`所代表的意思，我的理解就像是C++语言里面的`#define`宏定义语句。也就是要直接替换教程中所看到的这个字符为自己pintos的路径。

第二个是类似与`CC = gcc -m32`这样子的命令。没有接触过linux终端的可能不清楚，这是Terminal下面通用的格式，-m32这个是一个参数设置，多见于 **-** 这个字符之后都是参数设置。常见的错误是缺少空格或者-写在了前面之类的。

第三个是vim这个软件，一般的linux系统都是非自带的。而教程把这个写在了gedit前面，所以很多人在这步进行不下去就是因为没装vim这个高级程序员专用的代码编辑神器。

第四个是Terminal下面常用的是Tab键。写错了`pintos/src/utils`为`pintos/src/util`。这是因为没有使用Tab键补全命令或者到文件管理器查看文件夹名称所造成的。

后续会有Pintos的开源学习。详细请看本博客后续的文章。以及github上面的开源：[https://github.com/Wsine/pintos-ubuntu](https://github.com/Wsine/pintos-ubuntu)