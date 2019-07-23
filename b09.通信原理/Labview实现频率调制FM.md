# Labview实现频率调制（FM）

频率调制的原理：

![1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image74.png)

自己的实现为三角函数分解

![2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image75.png)

根据这个公式在Labview中连线则可以得到最终的波形输出

### 实现效果

![3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image76.png)

![4](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image77.png)

![5](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image78.png)

从频域图中可以看出，载波信号的频率被调制，原本为双峰的余弦信号，现在经过了调制为多个峰值并且其中一个峰会和基带信号的频率一致。也就会出现正弦信号为低峰的时候，调制后信号频率低间隔比较稀疏的结果

### 后端实现

![6](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image79.png)

基本上根据三角函数变化公式来实现后端。选择的信号都是余弦信号