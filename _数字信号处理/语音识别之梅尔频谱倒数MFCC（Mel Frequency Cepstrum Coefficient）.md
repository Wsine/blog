#语音识别之梅尔频谱倒数MFCC（Mel Frequency Cepstrum Coefficient）

###原理
1. 梅尔频率倒谱系数：一定程度上模拟了人耳对语音的处理特点
2. 预加重：在语音信号中，高频部分的能量一般比较低，信号不利于处理，提高高频部分的能量能更好的处理
3. 分帧：在比较短的时间内，语音信号不会发生突变，利于处理
4. 加窗：帧内信号在后序FFT变换的时候不会出现端点突变的情况，较好地得到频谱
5. 补零：FFT的要求输入数据需要满足2^k个点
6. 计算能量谱：对语音信号最好的分析在其功率谱
7. 计算梅尔频谱：梅尔频谱体现人耳对语音的特点
8. 离散余弦变换：计算梅尔倒谱，易于观察
9. 归一化：易于纵观整个语音信号的特点

###过程
流程图：
从 人声的模拟信号 得到 MFCC的梅尔倒谱
![流程图](http://images0.cnblogs.com/blog2015/701997/201507/101332557838865.jpg)


- 录音得到人声音频信号，保存到本地

```
%%
% r = audiorecorder(16000, 16, 1);
% record(r); % servel seconds
% stop(r);
% mySpeech = getaudiodata(r);
% figure;plot(mySpeech);title('mySpeech');
%%
mySpeech = wavread('mySpeech.wav', 'native');
figure;plot(mySpeech);title('mySpeech');
SizeOfmySpeech = size(mySpeech, 1);
for i = 2 : SizeOfmySpeech
   mySpeech(i) = mySpeech(i) - 0.95 * mySpeech(i-1);
end
figure;plot(mySpeech);title('mySpeech_fix');
```
录音的要求是采用率为16000Hz，量化为16bit
- 读取本地语音文件

```
ret_value temp;
short waveData2[60000];

int main()
{
	load_wave_file("mySpeech.wav", &temp, waveData2);
	return 0;
}
```

总共有60000个采样点

- 设置窗函数（海明窗、汉宁窗、布拉克曼窗）

![窗函数](http://images0.cnblogs.com/blog2015/701997/201507/101333353778036.jpg)


```
void setHammingWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.54 - 0.46*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1));
	}
}

void setHanningWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.5 - 0.5*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1));
	}
}

void setBlackManWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.42 - 0.5*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1)) 
									+ 0.08*cos(4 * PI*i / (FRAMES_PER_BUFFER - 1));
	}
}
```

此次选取的是海明窗

- 分帧加窗操作

![分帧](http://images0.cnblogs.com/blog2015/701997/201507/101334133145981.jpg)


```
// 加窗操作
int seg_shift = (i - 1) * NOT_OVERLAP;
for(j = 0; j < FRAMES_PER_BUFFER && (seg_shift + j) < numSamples; j++){
	afterWin[j] = spreemp[seg_shift + j] * frameWindow[j];
}
```

每次分帧，数据点变为400个点

- 补零操作

```
// 满足FFT为2^n个点，补零操作
for(int k = j - 1; k < LEN_SPECTRUM; k++){
	afterWin[k] = 0;
}
```

满足fft操作需要，补零至512个点

- 计算能量谱

```
void FFT_Power(float* in, float* energySpectrum){
	fftwf_complex* out = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex)*LEN_SPECTRUM);
	fftwf_plan p = fftwf_plan_dft_r2c_1d(LEN_SPECTRUM, in, out, FFTW_ESTIMATE);
	fftwf_execute(p);
	for(int i = 0; i < LEN_SPECTRUM; i++){
		energySpectrum[i] = out[i][0] * out[i][0] + out[i][1] * out[i][1];
	}
	fftwf_destroy_plan(p);
	fftwf_free(out);
}
```

这里用到了MIT大学的开源FFT变换库fftw3.h，快速计算能量谱(可以搜索下载根据自己的IDE配置)

- 计算梅尔谱

![梅尔谱1](http://images0.cnblogs.com/blog2015/701997/201507/101334530808164.jpg)


```
void computeMel(float* mel, int sampleRate, const float* energySpectrum){
	int fmax = sampleRate / 2;
	float maxMelFreq = 1125 * log(1 + fmax / 700);
```

![梅尔谱2](http://images0.cnblogs.com/blog2015/701997/201507/101335125801807.jpg)


```
// 计算频谱到梅尔谱的映射关系
for(int i = 0; i < NUM_FILTER + 2; i++){
	m[i] = i*delta;
	h[i] = 700 * (exp(m[i] / 1125) - 1);
	f[i] = floor((256 + 1)*h[i] / sampleRate);
}
```

![梅尔谱3](http://images0.cnblogs.com/blog2015/701997/201507/101335496437652.jpg)


```
// 梅尔滤波
for(int i = 0; i < NUM_FILTER; i++){
	for(int j = 0; j < 256; j++){
		if(j >= melFilters[i][0] && j <= melFilters[i][1]){
			mel[i] += ((j - melFilters[i][0]) / (melFilters[i][1] - melFilters[i][0]))*energySpectrum[j];
		}
		else if(j > melFilters[i][1] && j <= melFilters[i][2]){
			mel[i] += ((melFilters[i][2] - j) / (melFilters[i][2] - melFilters[i][1]))*energySpectrum[j];
		}
	}
}
```

一共选择了40个三角滤波器，最后的梅尔谱也是40个点
- 计算梅尔倒谱
![梅尔倒谱1](http://images0.cnblogs.com/blog2015/701997/201507/101336176748587.jpg)
![梅尔倒谱2](http://images0.cnblogs.com/blog2015/701997/201507/101336408465342.jpg)



```
void DCT(const float* mel, float* melRec){
	for(int i = 0; i < LEN_MELREC; i++){
		for(int j = 0; j < NUM_FILTER; j++){
			if(mel[j] <= -0.0001 || mel[j] >= 0.0001){
				melRec[i] += log(mel[j])*cos(PI*i / (2 * NUM_FILTER)*(2 * j + 1));
			}
		}
	}
}
```

把40个点的梅尔谱映射到13维的倒谱上。取对数做离散余弦变换
- 归一化处理
![归一化1](http://images0.cnblogs.com/blog2015/701997/201507/101337097527377.jpg)
![归一化2](http://images0.cnblogs.com/blog2015/701997/201507/101337306437262.jpg)


```
// 归一化处理
for(int i = 0; i < LEN_MELREC; i++){
	sumMelRec[i] = sqrt(sumMelRec[i] / numFrames);
}
fstream fout("All_MelRec.txt", ios::out);
fstream fout2("All_MelRec_Bef.txt", ios::out);
for(int i = 0; i < numFrames; i++){
	for(int j = 0; j < LEN_MELREC; j++){
		fout2 << mulMelRec[i][j] << " ";
		mulMelRec[i][j] /= sumMelRec[j];
		fout << mulMelRec[i][j] << " ";
	}
	fout << endl;
	fout2 << endl;
}
```

使得最终的结果数据聚拢，易于观察

- 绘图输出结果（以原始数据为例，和最终结果为例）

```
%% 读取原始音频文件
fidin = fopen('wavData.txt', 'r');
len_waveData = fscanf(fidin, '%d', 1);
waveData = zeros(len_waveData, 1);
for i = 1 : 1 : len_waveData
   waveData(i) = fscanf(fidin, '%d', 1);
end
fclose(fidin);
subplot(2, 3, 1); plot(1:len_waveData, waveData);
axis([0 400 -2 2]);
title('原始音频文件');
```

```
%% 梅尔倒谱的色域
A = load('All_MelRec_Bef.txt');
figure;
imagesc(A'); hold on
colorbar;
title('梅尔倒谱的色域');
%% 梅尔倒谱的色域（归一化）
B = load('All_MelRec.txt');
figure;
imagesc(B'); hold on
colorbar;
title('梅尔倒谱的色域（归一化）');
```

其余输出操作是相同的，操作见最后的完整代码

###结果
**录音后的原始音频信号**
![原始音频](http://images0.cnblogs.com/blog2015/701997/201507/101338048462880.jpg)
总共有6000个采样点，量化为16bit，因此数据量级能达到10^4

**MFCC操作中，第五帧的结果流程**
![流程](http://images0.cnblogs.com/blog2015/701997/201507/101338369869626.jpg)

原始音频分帧后，每一帧是400的点，从结果来看，在一帧的时间长度里面，数据变化不大，幅值维持在 [-1  1] 之间浮动。（如选取其他帧可以看到变化比较明显，看看原始音频就知道了）
加窗操作后，端点值被明显收敛到0，因此不会对能量谱的计算产生突变的情况。
能量谱和梅尔谱可以看出，与我们已知的人声特点相关。
**归一化之前的梅尔倒谱**
![输出1](http://images0.cnblogs.com/blog2015/701997/201507/101339010188952.jpg)
高频能量集中在较低的维度，和能量谱的显示吻合
**归一化的梅尔倒谱**
![输出2](http://images0.cnblogs.com/blog2015/701997/201507/101339260497404.jpg)
归一化之后，相比未归一化的图，较高维度的能量能够较好地被分辨出来，易于分析

至此，梅尔倒谱工作完成。

###完整代码

matlab录音文件 main.m

```
clear all
close all
clc
%%
% r = audiorecorder(16000, 16, 1);
% record(r); % servel seconds
% stop(r);
% mySpeech = getaudiodata(r);
% figure;plot(mySpeech);title('mySpeech');
%%
mySpeech = wavread('mySpeech.wav', 'native');
figure;plot(mySpeech);title('mySpeech');
SizeOfmySpeech = size(mySpeech, 1);
for i = 2 : SizeOfmySpeech
   mySpeech(i) = mySpeech(i) - 0.95 * mySpeech(i-1);
end
figure;plot(mySpeech);title('mySpeech_fix');
```
C++主函数文件 main.cpp
```
#include<iostream>
#include "fftw3.h"
#include"MFCC.h"
#include"wav.h"
using namespace std;

int wavLen;
double waveData[60000];

ret_value temp;
short waveData2[60000];

int main()
{
	/*wavLen = wavread("mySpeech.txt", waveData);
	if(wavLen == -1)
		exit(0);*/
	load_wave_file("mySpeech.wav", &temp, waveData2);
	MFCC(waveData2, 60000, 16000);
	system("pause");
	return 0;
}
```

C++音频定义头文件 wav.h
​     
```
#ifndef _WAV_H
#define _WAV_H

#define MAXDATA (512*400)  //一般采样数据大小,语音文件的数据不能大于该数据
#define SFREMQ (16000)   //采样数据的采样频率8khz
#define NBIT 16

typedef struct WaveStruck{//wav数据结构
	//data head
	struct HEAD{
		char cRiffFlag[4];
		int nFileLen;
		char cWaveFlag[4];//WAV文件标志
		char cFmtFlag[4];
		int cTransition;
		short nFormatTag;
		short nChannels;
		int nSamplesPerSec;//采样频率,mfcc为8khz
		int nAvgBytesperSec;
		short nBlockAlign;
		short nBitNumPerSample;//样本数据位数，mfcc为12bit
	} head;

	//data block
	struct BLOCK{
		char cDataFlag[4];//数据标志符(data)
		int nAudioLength;//采样数据总数
	} block;
} WAVE;

int wavread(char* filename, double* destination);

struct ret_value
{
	char *data;
	unsigned long size;
	ret_value()
	{
		data = 0;
		size = 0;
	}
};

void load_wave_file(char *fname, struct ret_value *ret, short* waveData2);

#endif
```

C++音频实现文件 wav.cpp
​      
```
#include"wav.h"
#include<cstdio>
#include<cstring>
#include<malloc.h>

int wavread(char* filename, double* destination){
	WAVE wave[1];
	FILE * f;
	f = fopen(filename, "rb");
	if(!f)
	{
		printf("Cannot open %s for reading\n", filename);
		return -1;
	}

	//读取wav文件头并且分析
	fread(wave, 1, sizeof(wave), f);

	if(wave[0].head.cWaveFlag[0] == 'W'&&wave[0].head.cWaveFlag[1] == 'A'
		&&wave[0].head.cWaveFlag[2] == 'V'&&wave[0].head.cWaveFlag[3] == 'E')//判断是否是wav文件
	{
		printf("It's not .wav file\n");
		return -1;
	}
	if(wave[0].head.nSamplesPerSec != SFREMQ || wave[1].head.nBitNumPerSample != NBIT)//判断是否采样频率是16khz,16bit量化
	{
		printf("It's not 16khz and 16 bit\n");
		return -1;
	}

	if(wave[0].block.nAudioLength>MAXDATA / 2)//wav文件不能太大,为sample长度的一半
	{
		printf("wav file is to long\n");
		return -1;
	}

	//读取采样数据 
	fread(destination, sizeof(char), wave[0].block.nAudioLength, f);
	fclose(f);

	return wave[0].block.nAudioLength;
}

void load_wave_file(char *fname, struct ret_value *ret, short* waveData2)
{
	FILE *fp;
	fp = fopen(fname, "rb");
	if(fp)
	{
		char id[5];          // 5个字节存储空间存储'RIFF'和'\0'，这个是为方便利用strcmp
		unsigned long size;  // 存储文件大小
		short format_tag, channels, block_align, bits_per_sample;    // 16位数据
		unsigned long format_length, sample_rate, avg_bytes_sec, data_size; // 32位数据
		fread(id, sizeof(char), 4, fp); // 读取'RIFF'
		id[4] = '\0';

		if(!strcmp(id, "RIFF"))
		{
			fread(&size, sizeof(unsigned long), 1, fp); // 读取文件大小
			fread(id, sizeof(char), 4, fp);         // 读取'WAVE'
			id[4] = '\0';
			if(!strcmp(id, "WAVE"))
			{
				fread(id, sizeof(char), 4, fp);     // 读取4字节 "fmt ";
				fread(&format_length, sizeof(unsigned long), 1, fp);
				fread(&format_tag, sizeof(short), 1, fp); // 读取文件tag
				fread(&channels, sizeof(short), 1, fp);    // 读取通道数目
				fread(&sample_rate, sizeof(unsigned long), 1, fp);   // 读取采样率大小
				fread(&avg_bytes_sec, sizeof(unsigned long), 1, fp); // 读取每秒数据量
				fread(&block_align, sizeof(short), 1, fp);     // 读取块对齐
				fread(&bits_per_sample, sizeof(short), 1, fp);       // 读取每一样本大小
				fread(id, sizeof(char), 4, fp);                      // 读入'data'
				fread(&data_size, sizeof(unsigned long), 1, fp);     // 读取数据大小
				ret->size = data_size;
				ret->data = (char*)malloc(sizeof(char)*data_size); // 申请内存空间
				//fread(ret->data, sizeof(char), data_size, fp);       // 读取数据
				fread(waveData2, sizeof(short), data_size, fp); // my fix
			}
			else
			{
				printf("Error: RIFF file but not a wave file\n");
			}
		}
		else
		{
			printf("Error: not a RIFF file\n");
		}
	}
}
```

C++实现MFCC.h
​     
```
#ifndef _MFCC_H
#define _MFCC_H

#define FRAMES_PER_BUFFER 400
#define NOT_OVERLAP 200
#define NUM_FILTER 40
#define PI 3.1415926
#define LEN_SPECTRUM 512
#define LEN_MELREC 13

void MFCC(const short* waveData, int numSamples, int sampleRate);
void preEmphasizing(const short* waveData, float* spreemp, int numSamples, float heavyFactor);
void setHammingWindow(float* frameWindow);
void setHanningWindow(float* frameWindow);
void setBlackManWindow(float* frameWindow);
void FFT_Power(float* in, float* energySpectrum);
void computeMel(float* mel, int sampleRate, const float* energySpectrum);
void DCT(const float* mel, float* melRec);

#endif
```

C++实现MFCC.cpp
​     
```
#include"MFCC.h"
#include"fftw3.h"
#include<cmath>
#include<cstring>
#include<fstream>
#include<string>
using namespace std;

template<class T> void print_Array(T* arr, int len, string filename);
#define TORPINT true
#define PRINT_FRAME 100

float mulMelRec[500][LEN_MELREC];

void MFCC(const short* waveData, int numSamples, int sampleRate){
	if(TORPINT)	print_Array(waveData, 60000, "wavDataAll.txt");
	// 预加重
	float* spreemp = new float[numSamples];
	preEmphasizing(waveData, spreemp, numSamples, -0.95);
	if(TORPINT) print_Array(waveData, 60000, "spreempAll.txt");
	// 计算帧的数量
	int numFrames = ceil((numSamples - FRAMES_PER_BUFFER) / NOT_OVERLAP) + 1;
	// 申请内存
	float* frameWindow = new float[FRAMES_PER_BUFFER];
	float* afterWin = new float[LEN_SPECTRUM];
	float* energySpectrum = new float[LEN_SPECTRUM];
	float* mel = new float[NUM_FILTER];
	float* melRec = new float[LEN_MELREC];
	/*float** mulMelRec = new float*[numFrames + 200];
	for(int i = 0; i < numFrames; i++){
		mulMelRec[i] = new float[LEN_MELREC];
	}*/
	float* sumMelRec = new float[LEN_MELREC];
	memset(sumMelRec, 0, sizeof(float)*LEN_MELREC);
	memset(mulMelRec, 0, sizeof(float)*numFrames*LEN_MELREC);
	// 设置窗参数
	setHammingWindow(frameWindow);
	//setHanningWindow(frameWindow);
	//setBlackManWindow(frameWindow);
	// 帧操作
	for(int i = 0; i < numFrames; i++){
		if(TORPINT && i == PRINT_FRAME)	print_Array(waveData, FRAMES_PER_BUFFER, "wavData.txt");
		if(TORPINT && i == PRINT_FRAME)	print_Array(waveData, FRAMES_PER_BUFFER, "spreemp.txt");
		int j;
		// 加窗操作
		int seg_shift = (i - 1) * NOT_OVERLAP;
		for(j = 0; j < FRAMES_PER_BUFFER && (seg_shift + j) < numSamples; j++){
			afterWin[j] = spreemp[seg_shift + j] * frameWindow[j];
		}
		// 满足FFT为2^n个点，补零操作
		for(int k = j - 1; k < LEN_SPECTRUM; k++){
			afterWin[k] = 0;
		}
		if(TORPINT && i == PRINT_FRAME)
			print_Array(afterWin, LEN_SPECTRUM, "After.txt");
		// 计算能量谱
		FFT_Power(afterWin, energySpectrum);
		if(TORPINT && i == PRINT_FRAME)
			print_Array(energySpectrum, LEN_SPECTRUM, "energySpectrum.txt");
		// 计算梅尔谱
		memset(mel, 0, sizeof(float)*NUM_FILTER);
		computeMel(mel, sampleRate, energySpectrum);
		if(TORPINT && i == PRINT_FRAME)
			print_Array(mel, NUM_FILTER, "mel.txt");
		// 计算离散余弦变换
		memset(melRec, 0, sizeof(float)*LEN_MELREC);
		DCT(mel, melRec);
		if(TORPINT && i == PRINT_FRAME)
			print_Array(melRec, LEN_MELREC, "melRec.txt");
		// 累计总值
		for(int p = 0; p < LEN_MELREC; p++){
			mulMelRec[i][p] = melRec[p];
			sumMelRec[p] += melRec[p] * melRec[p];
		}
	}
	// 归一化处理
	for(int i = 0; i < LEN_MELREC; i++){
		sumMelRec[i] = sqrt(sumMelRec[i] / numFrames);
	}
	fstream fout("All_MelRec.txt", ios::out);
	fstream fout2("All_MelRec_Bef.txt", ios::out);
	for(int i = 0; i < numFrames; i++){
		for(int j = 0; j < LEN_MELREC; j++){
			fout2 << mulMelRec[i][j] << " ";
			mulMelRec[i][j] /= sumMelRec[j];
			fout << mulMelRec[i][j] << " ";
		}
		fout << endl;
		fout2 << endl;
	}
	fout.close();
	fout2.close();

	// 释放内存
	delete[] spreemp;
	delete[] frameWindow;
	delete[] afterWin;
	delete[] energySpectrum;
	delete[] mel;
	delete[] melRec;
	delete[] sumMelRec;
	/*for(int i = 0; i < LEN_MELREC; i++){
		delete[] mulMelRec[i];
	}
	delete[] mulMelRec;*/
}

void preEmphasizing(const short* waveData, float* spreemp, int numSamples, float heavyFactor){
	spreemp[0] = (float)waveData[0];
	for(int i = 1; i < numSamples; i++){
		spreemp[i] = waveData[i] + heavyFactor * waveData[i - 1];
	}
}

void setHammingWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.54 - 0.46*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1));
	}
}

void setHanningWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.5 - 0.5*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1));
	}
}

void setBlackManWindow(float* frameWindow){
	for(int i = 0; i < FRAMES_PER_BUFFER; i++){
		frameWindow[i] = 0.42 - 0.5*cos(2 * PI * i / (FRAMES_PER_BUFFER - 1)) 
									+ 0.08*cos(4 * PI*i / (FRAMES_PER_BUFFER - 1));
	}
}

void FFT_Power(float* in, float* energySpectrum){
	fftwf_complex* out = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex)*LEN_SPECTRUM);
	fftwf_plan p = fftwf_plan_dft_r2c_1d(LEN_SPECTRUM, in, out, FFTW_ESTIMATE);
	fftwf_execute(p);
	for(int i = 0; i < LEN_SPECTRUM; i++){
		energySpectrum[i] = out[i][0] * out[i][0] + out[i][1] * out[i][1];
	}
	fftwf_destroy_plan(p);
	fftwf_free(out);
}

void computeMel(float* mel, int sampleRate, const float* energySpectrum){
	int fmax = sampleRate / 2;
	float maxMelFreq = 1125 * log(1 + fmax / 700);
	int delta = (int)(maxMelFreq / (NUM_FILTER + 1));
	// 申请空间
	float** melFilters = new float*[NUM_FILTER];
	for(int i = 0; i < NUM_FILTER; i++){
		melFilters[i] = new float[3];
	}
	float* m = new float[NUM_FILTER + 2];
	float* h = new float[NUM_FILTER + 2];
	float* f = new float[NUM_FILTER + 2];
	// 计算频谱到梅尔谱的映射关系
	for(int i = 0; i < NUM_FILTER + 2; i++){
		m[i] = i*delta;
		h[i] = 700 * (exp(m[i] / 1125) - 1);
		f[i] = floor((256 + 1)*h[i] / sampleRate);
	}
	// 计算梅尔滤波参数
	for(int i = 0; i < NUM_FILTER; i++){
		for(int j = 0; j < 3; j++){
			melFilters[i][j] = f[i + j];
		}
	}
	// 梅尔滤波
	for(int i = 0; i < NUM_FILTER; i++){
		for(int j = 0; j < 256; j++){
			if(j >= melFilters[i][0] && j <= melFilters[i][1]){
				mel[i] += ((j - melFilters[i][0]) / (melFilters[i][1] - melFilters[i][0]))*energySpectrum[j];
			}
			else if(j > melFilters[i][1] && j <= melFilters[i][2]){
				mel[i] += ((melFilters[i][2] - j) / (melFilters[i][2] - melFilters[i][1]))*energySpectrum[j];
			}
		}
	}
	// 释放内存
	for(int i = 0; i < 3; i++){
		delete[] melFilters[i];
	}
	delete[] melFilters;
	delete[] m;
	delete[] h;
	delete[] f;
}

void DCT(const float* mel, float* melRec){
	for(int i = 0; i < LEN_MELREC; i++){
		for(int j = 0; j < NUM_FILTER; j++){
			if(mel[j] <= -0.0001 || mel[j] >= 0.0001){
				melRec[i] += log(mel[j])*cos(PI*i / (2 * NUM_FILTER)*(2 * j + 1));
			}
		}
	}
}

template<class T> 
void print_Array(T* arr, int len, string filename){
	fstream fout(filename, ios::out);
	fout << len << endl;
	for(int i = 0; i < len; i++){
		fout << arr[i] << " ";
	}
	fout << endl;
	fout.close();
	return;
}
```

Matlab实现输出观察文件 Matlab_print.m
​     
```
clear all
close all
clc
%% 原始音频所有
fidin = fopen('wavDataAll.txt', 'r');
len_waveData = fscanf(fidin, '%d', 1);
waveData = zeros(len_waveData, 1);
for i = 1 : 1 : len_waveData
   waveData(i) = fscanf(fidin, '%d', 1);
end
fclose(fidin);
subplot(2, 3, 1); plot(1:len_waveData, waveData);
title('原始音频文件');
fidin = fopen('spreempAll.txt', 'r');
len_spreemp = fscanf(fidin, '%d', 1);
spreemp = zeros(len_spreemp, 1);
for i = 1 : 1 : len_spreemp
   spreemp(i) = fscanf(fidin, '%d', 1);
end
fclose(fidin);
subplot(2, 3, 2); plot(1:len_spreemp, waveData);
title('预加重音频文件');
figure;
%% 读取原始音频文件
fidin = fopen('wavData.txt', 'r');
len_waveData = fscanf(fidin, '%d', 1);
waveData = zeros(len_waveData, 1);
for i = 1 : 1 : len_waveData
   waveData(i) = fscanf(fidin, '%d', 1);
end
fclose(fidin);
subplot(2, 3, 1); plot(1:len_waveData, waveData);
axis([0 400 -2 2]);
title('原始音频文件');
%% 读取预加重的音频
fidin = fopen('spreemp.txt', 'r');
len_spreemp = fscanf(fidin, '%d', 1);
spreemp = zeros(len_spreemp, 1);
for i = 1 : 1 : len_spreemp
   spreemp(i) = fscanf(fidin, '%d', 1);
end
fclose(fidin);
subplot(2, 3, 2); plot(1:len_spreemp, waveData);
axis([0 400 -2 2]);
title('预加重音频文件');
%% 加窗操作
fidin = fopen('After.txt', 'r');
len_AfterWin = fscanf(fidin, '%d', 1);
AfterWin = zeros(len_AfterWin, 1);
for i = 1 : 1 : len_AfterWin
   AfterWin(i) = fscanf(fidin, '%f', 1);
end
fclose(fidin);
subplot(2, 3, 3); plot(1:len_AfterWin, AfterWin); grid on
title('加窗操作');
%% 能量谱
fidin = fopen('energySpectrum.txt', 'r');
len_energySpectrum = fscanf(fidin, '%d', 1);
energySpectrum = zeros(len_energySpectrum, 1);
for i = 1 : 1 : len_energySpectrum
   energySpectrum(i) = fscanf(fidin, '%f', 1);
end
fclose(fidin);
subplot(2, 3, 4); plot(1:len_energySpectrum, energySpectrum); grid on
title('能量谱');
%% 梅尔谱
fidin = fopen('mel.txt', 'r');
len_mel = fscanf(fidin, '%d', 1);
mel = zeros(len_mel, 1);
for i = 1 : 1 : len_mel
   mel(i) = fscanf(fidin, '%f', 1);
end
fclose(fidin);
subplot(2, 3, 5); plot(1:len_mel, mel); grid on
title('梅尔谱');
%% 梅尔倒谱
fidin = fopen('melRec.txt', 'r');
len_melRec = fscanf(fidin, '%d', 1);
melRec = zeros(len_melRec, 1);
for i = 1 : 1 : len_melRec
   melRec(i) = fscanf(fidin, '%f', 1);
end
fclose(fidin);
subplot(2, 3, 6); stem(1:len_melRec, melRec); grid on
title('梅尔倒谱');
%% 梅尔倒谱的色域
A = load('All_MelRec_Bef.txt');
figure;
imagesc(A'); hold on
colorbar;
title('梅尔倒谱的色域');
%% 梅尔倒谱的色域（归一化）
B = load('All_MelRec.txt');
figure;
imagesc(B'); hold on
colorbar;
title('梅尔倒谱的色域（归一化）');
```