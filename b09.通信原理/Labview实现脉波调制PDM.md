# Labview实现脉波调制( PDM )

根据定义为脉冲宽度调制
生成一个正弦信号，得到其幅值输入给一个方波信号的占空比
由于方波信号的占空比里面含有正弦信号的信息
因此通过滤出方波信号的占空比信息则可以恢复波形

### 实现效果

![1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image66.png)

![2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image67.png)

PDM输出图2：

![3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image68.png)

对比分析两次的PDM图形，方波信号的占空比一直在持续变化，变化的根据就是正弦信号的幅值。
结果图中，正弦信号恢复准确

### 后端实现

![4](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image69.png)