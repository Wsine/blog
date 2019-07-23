# Labview实现单边带信号调制（SSB）[滤波法]

首先用信号仿真器得到一个被调制信号m(t)，以及载波信号，该实验选择正弦信号作为载波信号。
根据调制器模型

![1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image49.png)

得到一个结果信号。
其中，H(w)的选择是低通滤波器，实验中得到的是理想的低通滤波器，阶数为10。
输出结果为载波信号的时域图像、调制信号的频域图像和结果信号的频域图像。

### 实现效果

![2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image50.png)

载波频率对原信号的调制作用使得双峰频率偏移的载波频率大小的位置。经过低通滤波器的作用后，剩下小于截止频率的部分

### 后端实现

![3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image51.png)