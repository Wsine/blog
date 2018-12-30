# C++实现禁忌搜索解决TSP问题

使用的搜索方法是Tabu Search（禁忌搜索）

![frame](http://images0.cnblogs.com/blog2015/701997/201507/252337482038376.png)

### 程序设计

1)	文件读入坐标点计算距离矩阵/读入距离矩阵

```
for(int i = 0; i < CityNum; i++){
	fin >> x[i] >> y[i];
}
for(int i = 0; i < CityNum - 1; i++){
	Distance[i][i] = 0;
	for(int j = i + 1; j < CityNum; j++){
		double Rij = sqrt(pow(x[i] - x[j], 2) + pow(y[i] - y[j], 2));
		Distance[i][j] = Distance[j][i] = (int)(Rij + 0.5);//四舍五入
	}
}
Distance[CityNum - 1][CityNum - 1] = 0;

for(int i = 0; i < CityNum; i++){
	for(int j = 0; j < CityNum; j++){
		fin >> Distance[i][j];
	}
}
```

2)	初始化旅行商路径

`initGroup()//初始化路径编码`

3)	初始化最佳路径为初始化路径

```
// 假设为最优，如有更优则更新
memcpy(bestGh, Ghh, sizeof(int)*CityNum);
bestEvaluation = evaluate(Ghh);
```

4)	[有限次数迭代]，如达到搜索次数上限则结束搜索

```
// 有限次数迭代
int nn;
while(t < MAX_GEN){
	// TSP solve
}
```

5)	[有限次数邻域交换]，随机交换两个路径点，如达次数转（7）

```
while(nn < NeighborNum){
	changeneighbor(Ghh, tempGhh);// 得到当前编码Ghh的邻域编码tempGhh
```

6)	禁忌表中不存在且路径更优，则更新当代路径，转（5）

```
if(!in_TabuList(tempGhh)){// 禁忌表中不存在
	tempEvaluation = evaluate(tempGhh);
	if(tempEvaluation < localEvaluation){// 局部更新
		memcpy(LocalGhh, tempGhh, sizeof(int)*CityNum);
		localEvaluation = tempEvaluation;
	}
	nn++;
}
```

7)	如路径比最佳路径更优则更新最优路径

```
if(localEvaluation < bestEvaluation){// 最优更新
	bestT = t;
	memcpy(bestGh, LocalGhh, sizeof(int)*CityNum);
	bestEvaluation = localEvaluation;
}
```

8)	更新当代最优路径到当前路径（必定执行，可能更差）

`memcpy(Ghh, LocalGhh, sizeof(int)*CityNum);// 可能更差，但同样更新`

9)	当前路径加入禁忌表，转（4）

```
pushTabuList(LocalGhh);// 加入禁忌表
t++;
```

程序加入了时间计算

```
start = clock();
solve();
finish = clock();
double run_time = (double)(finish - start) / CLOCKS_PER_SEC;
```

### 运行效果样例

默认搜索代数为10000

![TEST](http://images0.cnblogs.com/blog2015/701997/201507/252338175152354.png)

修改搜索代数可以线性控制搜索时间，但是搜索效果也会相应地改变，自行斟酌

### 完整代码

```
#include<iostream>
#include<string>
#include<fstream>
#include<cmath>
#include<ctime>
#include<cstdlib>
using namespace std;

int MAX_GEN;//迭代次数
int NeighborNum;//邻居数目
int TabuLen;//禁忌长度
int CityNum;//城市数量

int** Distance;//距离矩阵
int bestT;//最佳出现代数

int* Ghh;//初始路径编码
int* bestGh;//最好路径编码
int bestEvaluation;//最好路径长度
int* LocalGhh;//当代最好路径编码
int localEvaluation;//当代最后路径长度
int* tempGhh;//临时编码
int tempEvaluation;//临时路径长度

int** TabuList;//禁忌表
int t;//当前代数

string filename;

int DEBUG = 0;// for debug

void init(int argc, char** argv);
void solve();
void initGroup();
int evaluate(int* arr);
void changeneighbor(int* Gh, int*tempGh);
bool in_TabuList(int* tempGh);
void pushTabuList(int* arr);
void printResult();
void printDebug(int* arr, string message = "");

int main(int argc, char** argv)
{
	init(argc, argv);
	clock_t start, finish;
	start = clock();
	solve();
	finish = clock();
	double run_time = (double)(finish - start) / CLOCKS_PER_SEC;
	printResult();
	cout << "Runtime: " << run_time << " seconds" << endl;
	system("pause");
	return 0;
}

// 初始化各种参数
void init(int argc, char** argv){
	// CMD大法好，CMD大法妙，CMD大法呱呱叫
	filename = (argc >= 2) ? (string)(argv[1]) : "burma14.tsp";
	int InputMode = (argc >= 3) ? atoi(argv[2]) : 0;
	MAX_GEN = (argc >= 4) ? atoi(argv[3]) : 1000;
	NeighborNum = (argc >= 5) ? atoi(argv[4]) : 200;
	TabuLen = (argc >= 6) ? atoi(argv[5]) : 20;
	// 打开文件
	fstream fin(filename, ios::in);
	if(!fin.is_open()){
		cout << "Can not open the file " << filename << endl;
		exit(0);
	}
	fin >> CityNum;
	// 申请空间
	Distance = new int* [CityNum];
	for(int i = 0; i < CityNum; i++){
		Distance[i] = new int[CityNum];
	}
	// 读入点坐标 计算距离矩阵
	if(InputMode == 0){
		double *x, *y;
		x = new double[CityNum];
		y = new double[CityNum];

		for(int i = 0; i < CityNum; i++){
			fin >> x[i] >> y[i];
		}
		for(int i = 0; i < CityNum - 1; i++){
			Distance[i][i] = 0;
			for(int j = i + 1; j < CityNum; j++){
				double Rij = sqrt(pow(x[i] - x[j], 2) + pow(y[i] - y[j], 2));
				Distance[i][j] = Distance[j][i] = (int)(Rij + 0.5);//四舍五入
			}
		}
		Distance[CityNum - 1][CityNum - 1] = 0;

		delete[] x;
		delete[] y;
	}
	// 读入距离矩阵
	else{
		for(int i = 0; i < CityNum; i++){
			for(int j = 0; j < CityNum; j++){
				fin >> Distance[i][j];
			}
		}
	}
	// 申请空间 最佳路径无穷大
	Ghh = new int[CityNum];
	bestGh = new int[CityNum];
	bestEvaluation = INT_MAX;
	LocalGhh = new int[CityNum];
	localEvaluation = INT_MAX;
	tempGhh = new int[CityNum];
	tempEvaluation = INT_MAX;
	// 申请空间 迭代次数初始化0
	TabuList = new int*[TabuLen];
	for(int i = 0; i < TabuLen; i++){
		TabuList[i] = new int[CityNum];
	}
	bestT = t = 0;
	// 设置随机数种子
	srand((unsigned int)time(0));
}

// 求解TSP问题
void solve(){
	initGroup();//初始化路径编码

	// 假设为最优，如有更优则更新
	memcpy(bestGh, Ghh, sizeof(int)*CityNum);
	bestEvaluation = evaluate(Ghh);

	// 有限次数迭代
	int nn;
	while(t < MAX_GEN){
		nn = 0;
		localEvaluation = INT_MAX;// 初始化无穷大
		while(nn < NeighborNum){
			changeneighbor(Ghh, tempGhh);// 得到当前编码Ghh的邻域编码tempGhh
			//if(++DEBUG < 10)printDebug(tempGhh, "after_change");
			if(!in_TabuList(tempGhh)){// 禁忌表中不存在
				tempEvaluation = evaluate(tempGhh);
				if(tempEvaluation < localEvaluation){// 局部更新
					memcpy(LocalGhh, tempGhh, sizeof(int)*CityNum);
					localEvaluation = tempEvaluation;
				}
				nn++;
			}
		}
		if(localEvaluation < bestEvaluation){// 最优更新
			bestT = t;
			memcpy(bestGh, LocalGhh, sizeof(int)*CityNum);
			bestEvaluation = localEvaluation;
		}
		memcpy(Ghh, LocalGhh, sizeof(int)*CityNum);// 可能更差，但同样更新

		pushTabuList(LocalGhh);// 加入禁忌表
		t++;
	}

	//printResult();// 输出结果
}

// 初始化编码Ghh
void initGroup(){
	// 默认从0号城市开始
	for(int i = 0; i < CityNum; i++){
		Ghh[i] = i;
	}
	//printDebug(Ghh, "init_Ghh");
}

// 计算路径距离
int evaluate(int* arr){
	int len = 0;
	for(int i = 1; i < CityNum; i++){
		len += Distance[arr[i - 1]][arr[i]];
	}
	len += Distance[arr[CityNum - 1]][arr[0]];
	return len;
}

// 得到当前编码Ghh的邻域编码tempGhh
void changeneighbor(int* Gh, int* tempGh){

	int ran1 = rand() % CityNum;
	while(ran1 == 0){
		ran1 = rand() % CityNum;
	}
	int ran2 = rand() % CityNum;
	while(ran1 == ran2 || ran2 == 0){
		ran2 = rand() % CityNum;
	}

	int ran3 = rand() % 3;
	// 随机交换一个数
	if(ran3 == 0){
		memcpy(tempGh, Gh, sizeof(int)*CityNum);
		swap(tempGh[ran1], tempGh[ran2]);
	}
	// 随机交换中间一段距离
	else if(ran3 == 1){
		if(ran1 > ran2){
			swap(ran1, ran2);
		}
		int Tsum = ran1 + ran2;
		for(int i = 0; i < CityNum; i++){
			if(i >= ran1&&i <= ran2){
				tempGh[i] = Gh[Tsum - i];
			}
			else{
				tempGh[i] = Gh[i];
			}
		}
	}
	// 随机交换一段距离
	else if(ran3 == 2){
		if(ran1 > ran2){
			swap(ran1, ran2);
		}
		int index = 0;
		for(int i = 0; i < ran1; i++){
			tempGh[index++] = Gh[i];
		}
		for(int i = ran2 + 1; i < CityNum; i++){
			tempGh[index++] = Gh[i];
		}
		for(int i = ran1; i <= ran2; i++){
			tempGh[index++] = Gh[i];
		}
	}
}

// 判读编码是否在禁忌表中
bool in_TabuList(int* tempGh){
	int i;
	int flag = 0;
	for(i = 0; i < TabuLen; i++){
		flag = 0;
		for(int j = 0; j < CityNum; j++){
			if(tempGh[j] != TabuList[i][j]){
				flag = 1;
				break;
			}
		}
		if(flag == 0)	
			break;
	}
	return !(i == TabuLen);
}

// 加入禁忌表
void pushTabuList(int* arr){
	// 删除队列第一个编码
	for(int i = 0; i < TabuLen - 1; i++){
		for(int j = 0; j < CityNum; j++){
			TabuList[i][j] = TabuList[i + 1][j];
		}
	}
	// 加入队列尾部
	for(int k = 0; k < CityNum; k++){
		TabuList[TabuLen - 1][k] = arr[k];
	}
}

// 输出结果
void printResult(){
	fstream fout("TSP_AnswerOut.txt", ios::out);
	fout << filename << " result:" << endl;
	cout << "最佳长度出现代数：" << bestT << endl;
	fout << "最佳长度出现代数：" << bestT << endl;
	cout << "最佳路径长度： " << bestEvaluation << endl;
	fout << "最佳路径长度： " << bestEvaluation << endl;
	cout << "最佳路径：" << endl;
	fout << "最佳路径：" << endl;
	for(int i = 0; i < CityNum; i++){
		cout << bestGh[i] << "->";
		fout << bestGh[i] << "->";
	}
	cout << 0 << endl;
	fout << 0 << endl;
	fout.close();
}

// Only for Debug
void printDebug(int* arr, string message){
	cout << message << ": ";
	for(int i = 0; i < CityNum; i++){
		cout << arr[i] << " ";
	}
	cout << endl;
}
```

### 测试样例

读入坐标

```
TabuSearch_TSP.exe burma14.tsp 0 10000 200 20

TabuSearch_TSP.exe ulysses16.tsp 0 1000 200 20

TabuSearch_TSP.exe ulysses22.tsp 0 1000 200 25

TabuSearch_TSP.exe eil51.tsp 0 1000 200 55

TabuSearch_TSP.exe dantzig42.tsp 0 1000 200 45

TabuSearch_TSP.exe att48.tsp 0 1000 200 50

TabuSearch_TSP.exe berlin52.tsp 0 1000 200 55
```

读入距离矩阵

```
TabuSearch_TSP.exe gr17.tsp 1 10000 500 20

TabuSearch_TSP.exe gr21.tsp 1 10000 500 25

TabuSearch_TSP.exe gr24.tsp 1 10000 500 25

TabuSearch_TSP.exe fri26.tsp 1 10000 500 30

TabuSearch_TSP.exe bayg29.tsp 1 10000 500 30

TabuSearch_TSP.exe bays29.tsp 1 10000 500 30

TabuSearch_TSP.exe swiss42.tsp 1 10000 500 45

TabuSearch_TSP.exe gr48.tsp 1 10000 500 50

TabuSearch_TSP.exe hk48.tsp 1 10000 500 50

TabuSearch_TSP.exe brazil58.tsp 1 10000 500 60
```

测试样例及完整代码：

[传送门](http://pan.baidu.com/s/1pJIGNnd)