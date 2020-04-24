# Matlab实现单(双)极性(不)归零码

### 内容大纲

- Matlab实现单极性不归零波形（NRZ），0 1 幅值
- Matlab实现单极性归零波形（RZ），0 1 幅值
- Matlab实现双极性不归零波形，-1 1 幅值
- Matlab实现双极性归零波形， -1 1 幅值

### 设计

首先需要确定单个码元信号，以一秒为一个码元周期，每次采样128个点得到两个码元信号，分别是RZ信号和NRZ信号

```
%% 生成单个码元
Ts = 1; % 码元周期
N_sample = 128; % 单个码元抽样点数
dt = Ts / N_sample; % 抽样时间间隔
N = 100; % 码元数
t = 0 : dt : (N * N_sample - 1) * dt; % 序列传输时间
gt1 = ones(1, N_sample); % NRZ
gt2 = [ones(1, N_sample / 2), zeros(1, N_sample / 2)]; % RZ
```

然后根据码元数生成N个0 1 的随机序列，然后根据随机序列在1时取一个码元信号，随机序列为0时取一个零信号

```
%% 生成随机序列
RAN = round(rand(1, N)); % 随机0 1序列
se1 = [];
se2 = [];
for i = 1 : N % 生成序列
   if RAN(i)==1
       se1 = [se1 gt1];
       se2 = [se2 gt2];
   else
       se1 = [se1 zeros(1, N_sample)];
       se2 = [se2 zeros(1, N_sample)];
   end
end
```

然后观察波形看是否正确

```
%% 绘制出结果
subplot(2, 1, 1);plot(t, se1);grid on;axis([0 20 0 2]);title('NRZ');
subplot(2, 1, 2);plot(t, se2);grid on;axis([0 20 0 2]);title('RZ');
```

求信号的功率谱，功率谱 = 信号的频率的绝对平方 / 传输序列的持续时间， 求得的功率谱进行单位换算以dB值表示

![4](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image100.png)

```
%% 功率谱密度计算
fft_se1 = fftshift(fft(se1)); % 求序列的频谱
fft_se2 = fftshift(fft(se2));
PE1 = 10 * log10(abs(fft_se1) .^ 2 / (N * Ts)); % 公式法求概率谱密度
PE2 = 10 * log10(abs(fft_se2) .^ 2 / (N * Ts));
PEL1 = (-length(fft_se1) / 2 : length(fft_se1) / 2 - 1) / 10; % 求区间长度
PEL2 = (-length(fft_se2) / 2 : length(fft_se2) / 2 - 1) / 10;
```

注意：这里使最终观察的波形易于观察，需要使用fftshift函数使0频率响应移到频域中心，而频域较宽，因此只观察整个频域的1/10，取中心部位观察

观察功率谱是否正确

```
%% 绘制出结果
subplot(2, 2, 1);plot(t, se1);grid on;axis([0 20 -1.5 1.5]);title('DBNRZ');
subplot(2, 2, 2);plot(t, se2);grid on;axis([0 20 -1.5 1.5]);title('DBRZ');
```

把单极性转化为双极性观察：此处与单极性不同的地方在于，生成序列的时候，随机序列为0时取单个码元信号的乘以-1，而不是取0信号

此处以附上双极性的全部代码（与单极性差别不大）

```
clear all
close all
clc
%% 生成单个码元
Ts = 1; % 码元周期
N_sample = 128; % 单个码元抽样点数
dt = Ts / N_sample; % 抽样时间间隔
N = 100; % 码元数
t = 0 : dt : (N * N_sample - 1) * dt; % 序列传输时间
gt1 = ones(1, N_sample); % NRZ
gt2 = [ones(1, N_sample / 2), zeros(1, N_sample / 2)]; % RZ
%% 生成随机序列
RAN = round(rand(1, N)); % 随机0 1序列
se1 = [];
se2 = [];
for i = 1 : N % 生成序列
   if RAN(i)==1
       se1 = [se1 gt1];
       se2 = [se2 gt2];
   else
       se1 = [se1 -1*gt1];
       se2 = [se2 -1*gt2];
   end
end
%% 绘制出结果
subplot(2, 2, 1);plot(t, se1);grid on;axis([0 20 -1.5 1.5]);title('DBNRZ');
subplot(2, 2, 2);plot(t, se2);grid on;axis([0 20 -1.5 1.5]);title('DBRZ');
%% 功率谱密度计算
fft_se1 = fftshift(fft(se1)); % 求序列的频谱
fft_se2 = fftshift(fft(se2));
PE1 = 10 * log10(abs(fft_se1) .^ 2 / (N * Ts)); % 公式法求概率谱密度
PE2 = 10 * log10(abs(fft_se2) .^ 2 / (N * Ts));
PEL1 = (-length(fft_se1) / 2 : length(fft_se1) / 2 - 1) / 10; % 求区间长度
PEL2 = (-length(fft_se2) / 2 : length(fft_se2) / 2 - 1) / 10;
%% 绘制出结果
subplot(2, 2, 3);plot(PEL1, PE1); grid on; axis([-50 50 -50 50]); title('density-DBNRZ');
subplot(2, 2, 4);plot(PEL2, PE1); grid on; axis([-50 50 -50 50]); title('density-DBRZ');
```

### 运行效果

单极性归零信号和单极性不归零信号及其功率谱密度：

![re1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image101.png)

分析：单个码元信号的周期是1，图中很坐标以2显示一个点，实际为1。占空比的设置为50%。以0~1时间段为例，图一的信号一直都是1，这是不归零的信号，图二在0~0.5时为1，0.5~1时为0，也就是在下一个码元来临前回归零，这是归零信号的特性。而两者信号的功率谱密度显示，在0频率处能量最集中，各个平垫的能量分布较为均衡，向两极逐渐递减，这适应于一个随机信号的特性



双极性归零信号和单极性不归零信号及其功率谱密度：

![re2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image102.png)

分析：双极性信号不归零信号只有1 -1 两种幅值，而归零信号则多一个0幅值。由于与单极性信号相比，只是幅值上面有所差异，对于频域的没有太大的影响，因而其功率谱密度也是十分相似的

### 后记

关于单(双)极性(不)归零编码的应用看了网上一篇博客：多路复用技术、频分多路复用、时分多路复用、波分多路复用、码分多址、空分多址，讲得还不错。贴网址：

http://blog.csdn.net/sunnyboy_cia/article/details/6382573