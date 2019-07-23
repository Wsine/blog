# verilog简易实现CPU的Cache设计

该文是基于博主之前一篇博客[http://www.cnblogs.com/wsine/p/4661147.html](http://www.cnblogs.com/wsine/p/4661147.html)所增加的Cache，相同的内容就不重复写了，可点击链接查看之前的博客。

### Cache结构

![struct](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image196.png)

采用的是2-way，循环5遍的测试方式，和书本上一致，4个set

### Cache设计

首先在PCPU模块里面增加寄存器

![1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image197.png)

在流水线MEM那一阶段如果是STROE或者LOAD指令更新cache

![2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image198.png)

采取的替换策略是FIFO策略，在cache上面增加了一个位U

整个cache的控制部分如下：

![3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image199.png)
![4](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image200.png)

如果读取时没有hit，则会成memory中取值并存到cache里面

![5](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image201.png)
![6](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image202.png)

书本和ppt上的样例，初始化了datamemory的值

### 仿真结果

从仿真器可以比较容易观察数据的变化，特别是hit0和hit1的变化

![7](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image203.png)
![8](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image204.png)
![9](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image205.png)

从仿真文本来看，gr1和gr2的load结果也是成功的。没有出现不能错误读取的xxxx结果

传送门：

- CPU2_Cache

点击[这里](http://pan.baidu.com/s/1i3pMzLN)