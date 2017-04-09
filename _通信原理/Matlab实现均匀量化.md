#Matlab实现均匀量化

首先读入一个音频文件的前200个点，如果音频通道大于1则只取一个通道，滤掉其余的
得到音频文件的最大值和最小值，最大值和最小值的差除以2的4次方即16得到量化电平的端点间隔。
从最小值开始每次加量化电平端点间隔进行量化，最大值之上补一个边界，方便判断。

1. Mid Riserd 量化方法
	遍历量化区间，如满足某一区间，则取其区间的中点进行量化，并进行下一个点
2. Mid Tread量化方法
	遍历量化电平正负半个端点间隔，如满足该区间，则取该量化端点

输出两者和原来信号进行对比分析。

###实现效果

运行效果图：
红色的是原始声音信号的波形
蓝色的是4 bits量化后的波形

![1](http://images0.cnblogs.com/blog2015/701997/201507/231454496935859.png)

![2](http://images0.cnblogs.com/blog2015/701997/201507/231454562711483.png)

###代码实现

```matlab
clear all
clc
% 量化位数
n_bits = 4;
% 读入原始文件的左声道前200个点
WAV = wavread('road.wav', 200);
WAV = WAV( : ,1);
figure;
plot(WAV, 'r');hold on
% 设置量化电平参数
MAX_VALUE = max(WAV);
MIN_VALUE = min(WAV);
MID_VALUE = (MAX_VALUE - MIN_VALUE) / 2^n_bits;
for i = 1 : 2^n_bits + 1
   m(i) = MIN_VALUE + MID_VALUE * (i - 1); 
end
%% Mid Riser的量化方法
WAV1 = WAV;
for i = 1 : 200
   for j = 1 : 2^n_bits
      % 取分界点的中点
      if WAV1(i) >= m(j) && WAV1(i) <= m(j+1)
         WAV1(i) = (m(j) + m(j+1)) / 2;
         break
      end
   end
end
plot(WAV1, 'b');hold off % 输出并对比
title('Mid Riser');
%% Mid Tread的量化方法
figure;
plot(WAV, 'r');hold on
WAV2 = WAV;
for i = 1 : 200
   for j = 1 : 2^n_bits
      % 取某一分界点
      if WAV2(i) >= (m(j) - 1/2 * MID_VALUE) && WAV2(i) <= (m(j) + 1/2 * MID_VALUE)
         WAV2(i) = m(j);
         break
      end
   end
end
plot(WAV2, 'b');hold off % 输出并对比
title('Mid Tread');
```