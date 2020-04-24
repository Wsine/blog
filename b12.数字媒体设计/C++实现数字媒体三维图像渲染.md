# C++实现数字媒体三维图像渲染

### 必备环境
- glut.h 头文件
- glut32.lib 对象文件库
- glut32.dll 动态连接库

### 程序说明
C++实现了用glut画物体对象的功能。并附带放大缩小，旋转，平移和在不同视角观察的功能。渲染方式的选择是Gouraud的渲染方法。程序开始的宏定义可以设置是否输出矩阵信息，用于调试，调试完毕后可以关闭输出信息，大大提高程序的运行速度。

### 操作说明
#### 重要说明
**define MAX_MODEL 20**
程序最多支持创建20个对象，如需要创建更多的对象，请调高这个参数
**define MAX_MODEL_NUM 4000**
程序最多支持对象拥有4000个点和4000个面，如需要读入更复杂的对象，请调高这个参数
**define MAX_POINT_IN_FACE 10**
程序最多支持对象一个面中包含10个点，如需要更多的点，请调高这个参数（一般一个面采用3个点或4个点）
**define MAX_LIGHT 4**
程序最多支持设置4个点光源的设置，如需更多的点光源，请调高这个参数
**define MAX_WIN_SIZE 1000**
程序最多支持1000*1000的分辨率，如需更高的分辨率支持，请调高这个参数（默认正方矩阵）

#### 指令说明
- reset ：把变换矩阵重置为单位矩阵
- scale ：把变换矩阵进行相应的放大缩小
- rotate ： 把变换矩阵进行相应的旋转
- translate ： 把变换矩阵进行相应的平移
- object ： 根据变换矩阵创建一个对象
- obverser ： 设置摄像机的位置和对焦的焦点
- viewport ： 设置投影区域的变换矩阵
- display ： 显示所有的对象
- clearData ：清空所有的对象数据
- clearScreen ：清空屏幕
- ambient ： 设置ambient的Ka系数
- background ： 设置窗口的背景颜色
- light ： 设置一个点光源
- end ： 结束程序

### 函数说明

**void initial()**
输出程序信息，并提示如何输入

**void scale(float sx, float sy, float sz)**
改变变换矩阵进行相应放大缩小

**void rotate(float Xdegree, float Ydegree, float Zdegree)**
改变变换矩阵进行相应的角度旋转

**void translate(float tx, float ty, float tz)**
改变变换矩阵进行相应的平移变换

**void reset()**
重置变换矩阵为单位矩阵

**void viewport(float vxl, float vxr, float vyb, float vyt)**
根据参数设置投影区域的变化矩阵WVM

**void clearData()**
清除全部对象的数据

**void clearScreen()**
清空整个视窗屏幕

**void displayFunc(void)**
视窗初始化和恢复的时候调用的函数

**void ReadInput(bool& IsExit)**
从标准输入输出中读取指令

**void Matrix_Multi_Matrix(float a[][CTM_SIZE], float b[][CTM_SIZE], float c[][CTM_SIZE])**
矩阵乘法，c = a * b

**template<class T> void update_Matrix(T resource[][MTM_SIZE], T destination[][MTM_SIZE])**
更新矩阵

**void drawDot(int x, int y)**
在视窗坐标系中绘制一个点

**void DrawLine(int x0, int x1, int y0, int y1)**
各个方向均可使用，绘制一条直线

**void drawLine0(int x0, int x1, int y0, int y1)**
绘制直线函数，决定调用哪一个直线函数

**void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange)**
绘制一号区域和五号区域的直线

**void drawLine2(int x0, int x1, int y0, int y1, bool xy_interchange)**
绘制二号区域和六号区域的直线

**void drawLine3(int x0, int x1, int y0, int y1, bool xy_interchange)**
绘制三号区域和七号区域的直线

**void drawLine4(int x0, int x1, int y0, int y1, bool xy_interchange)**
绘制四号区域和八号区域的直线

**void ReadFile(bool& IsExit)**
从文件中批量读取指令

**void redraw()**
重绘整个视窗，恢复显示的时候调用

**template<class T> void printMatrix(T* matrix, int row, int col, string str)**
打印矩阵函数，debug时使用

**void object(string objectname)**
创建从文件中一个对象并存储

**void observer(float PX, float PY, float PZ, float CX, float CY, float CZ, float Tilt, float zNear, float zFar, float hFOV);**
设置摄像机的位置和观察的焦点

**void Eye_Transform(float PX, float PY, float PZ, float CX, float CY, float CZ, float Tilt)**
设置从World_Space到Eye_Space的变化矩阵EM

**void Project_Transform(float zNear, float zFar, float hFOV)**
设置从Eye_Space到Project_Space的变化矩阵PM

**void Cross_Multi(float destination[], float a[], float b[])**
三维向量的叉乘运算

**void UnitizeVector(float vector[])**
单位化一个向量

**void setWinSize(int winWidth, int winHeight)**
设置程序窗口的大小

**void setAmbient(float value)**
设置Ambient的Ka系数

**void setBackground(float _background_r, float _background_g, float _background_b)**
设置程序窗口的背景颜色

**void setLight(int _ID, float _Ip, float _X, float _Y, float _Z)**
设置一个点光源

**float getColor(int objectIndex, int faceIndex, int pointIndex, char whichColor)**
计算并返回一个对象中某一个面的一个点的颜色
现在为未完成版本，是简易版，完整版应当如同注释中的所写，只是关键参数未知。

**void getNormalVector(float* destination, int objectIndex, int faceIndex)**
计算得到一个对象中一个面的法向量

**float AbsDot_Multi(float a[], float b[])**
两个三维向量的点乘，返回其绝对值

**void drawFace(const vector<PointWithColor>& colorPointVector, int min_y, int max_y)**
绘制一个面

**float interpolation(float p1, float p2, float q1, float q2, float q)**
插值运算

**void drawColorDot(int x, int y, float c_r, float c_g, float c_b)**
屏幕绘制一个特定颜色的点

**bool is_onLine(int x, int y, int x1, int y1, int x2, int y2)**
判断一个点是否在一条线上

**void sortColorPointVector(vector<PointWithColor>& colorPointVector)**
对一个容量为3的点容器进行排序，分为top，left，right三个点

**void wordsToTA()**
特定环境下所需要的函数

### 程序截图

![123](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image223.png)

![456](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image224.png)

![789](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image225.png)

### 完整代码

```
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <cmath>
#include <string>
#include <vector>
#include <queue>
#include <algorithm>
#include <iomanip>
#include "glut.h"
using namespace std;

#pragma region Data

#define PRINT 0
#define PRINT_VERTEX 0

typedef float wvmtype;
#define MTM_SIZE 4
#define PI 3.14159265
#define MAX_MODEL 20
#define MAX_MODEL_NUM 4000
#define MAX_LINE 100
#define MAX_POINT_IN_FACE 10
#define MAX_LIGHT 4
#define MAX_WIN_SIZE 1000
#define INF_FAR 999.0

struct ASCModel_struct{
	int num_vertex;
	int num_face;
	float vertex[MAX_MODEL_NUM][MTM_SIZE];
	int face[MAX_MODEL_NUM][MAX_POINT_IN_FACE];
	float R, G, B;
	float Kd, Ks, N;
}ASCModel[MAX_MODEL];

struct Light_struct{
	bool enable;
	float Ip;
	float X, Y, Z;
	Light_struct(){
		enable = false;
	}
}Light[MAX_LIGHT];

struct line_data{
	int x, y;
	line_data* next;
	line_data(int _x = -1, int _y = -1){
		x = _x;
		y = _y;
		next = NULL;
	}
};

struct PointWithColor{
	int y;
	float x,z;
	float r, g, b;
	PointWithColor() :x(-1), y(-1){}
	friend bool operator<(const PointWithColor& p1, const PointWithColor& p2){
		return (p1.x > p2.x);
	}
};

struct Buffer_struct{
	float z;
	float r, g, b;
	Buffer_struct(){}
	Buffer_struct(float _z, float _r, float _g, float _b){
		z = _z;
		r = _r;
		g = _g;
		b = _b;
	}
}Buffer[MAX_WIN_SIZE][MAX_WIN_SIZE];

struct line_structure{
	int x0, x1, y0, y1;
};
enum scanLineState{none, odd, even};

float ModelingTransformMatrix[MTM_SIZE][MTM_SIZE] 
	= { { 1, 0, 0, 0 }, 
		{ 0, 1, 0, 0 }, 
		{ 0, 0, 1, 0 }, 
		{ 0, 0, 0, 1 } };
float Eye_Matirx[MTM_SIZE][MTM_SIZE];
float Project_Matrix[MTM_SIZE][MTM_SIZE];
float EyeX, EyeY, EyeZ;
float WzNear, WzFar, WhFOV;
wvmtype WVM[MTM_SIZE][MTM_SIZE];

line_structure line[MAX_LINE];
line_data line_start[MAX_LINE];
line_data* lcp;
line_data* temp;
int num_ASCModel = 0;
int num_line = 0;

float ambient_Ka = 0.0;
float ambient_Ia = 1.0;
float background_r = 0.0;
float background_g = 0.0;
float background_b = 0.0;
float r = 0.0;
float g = 1.0;
float b = 1.0;
const float alpha = 0.0;

ifstream fin;
bool IsExit = false;
string Inputfile;
int height, width;

#pragma endregion

#pragma region FunctionDefinition

void initial();
void displayFunc(void);
void ReadFile(bool& IsExit);
template<class T> void printMatrix(T* matrix, int row, int col, string str);
void Matrix_Multi_Matrix(float a[][MTM_SIZE], float b[][MTM_SIZE], float c[][MTM_SIZE]);
template<class T> void update_Matrix(T resource[][MTM_SIZE], T destination[][MTM_SIZE]);
void redraw();
void clearData();
void clearScreen();
void object(string objectname, float _R, float _G, float _B, float _Kd, float _Ks, float _N);
void reset();
void scale(float sx, float sy, float sz);
void rotate(float Xdegree, float Ydegree, float Zdegree);
void translate(float tx, float ty, float tz);
void observer(float PX, float PY, float PZ, float CX, float CY, float CZ, 
			  float Tilt, float zNear, float zFar, float hFOV);
void Eye_Transform(float PX, float PY, float PZ, float CX, float CY, float CZ, float Tilt);
void Project_Transform(float zNear, float zFar, float hFOV);
void viewport(float vxl, float vxr, float vyb, float vyt);
void display();
void Cross_Multi(float destination[], float a[], float b[]);
void UnitizeVector(float vector[]);
void drawDot(int x, int y);
void DrawLine(int x0, int x1, int y0, int y1);
void drawLine0(int x0, int x1, int y0, int y1);
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine2(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine3(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine4(int x0, int x1, int y0, int y1, bool xy_interchange);
void setWinSize(int winWidth, int winHeight);
void setAmbient(float value);
void setBackground(float _background_r, float _background_g, float _background_b);
void setLight(int _ID, float _Ip, float _X, float _Y, float _Z);
float getColor(int objectIndex, int faceIndex, int pointIndex, char whichColor);
void getNormalVector(float* destination, int objectIndex, int faceIndex);
float AbsDot_Multi(float a[], float b[]);
void drawFace(const vector<PointWithColor>& colorPointVector, int min_y, int max_y);
float interpolation(float p1, float p2, float q1, float q2, float q);
void drawColorDot(int x, int y, float c_r, float c_g, float c_b);
bool is_onLine(int x, int y, int x1, int y1, int x2, int y2);
void sortColorPointVector(vector<PointWithColor>& colorPointVector);
void wordsToTA();

#pragma endregion

#pragma region FunctionImplement

// Print a Matrix
template<class T>
void printMatrix(T* matrix, int row, int col, string str){
	cout << endl;
	cout << "Matrix <<< " << str << " >>> = " << endl;
	for(int i = 0; i < row; i++){
		cout << "\t[";
		for(int j = 0; j < col; j++){
			cout.setf(ios::fixed);
			cout << setw(5) << setprecision(2) << matrix[i][j] << ", ";
		}
		cout << " ]" << endl;
	}
}

// Two 4 * 4 Matrixs Multiplication
void Matrix_Multi_Matrix(float a[][MTM_SIZE], float b[][MTM_SIZE], float c[][MTM_SIZE]){
	float temp[MTM_SIZE][MTM_SIZE];
	
	float multi_sum = 0;
	for(int i = 0; i < MTM_SIZE; i++){
		for(int j = 0; j < MTM_SIZE; j++){
			multi_sum = 0;
			for(int k = 0; k < MTM_SIZE; k++){
				multi_sum += b[k][j] * a[i][k];
			}
			temp[i][j] = multi_sum;
		}
	}

	// Fix to avoid input of Matrix_A is input of Matrix C
	for(int i = 0; i < MTM_SIZE; i++){
		for(int j = 0; j < MTM_SIZE; j++){
			c[i][j] = temp[i][j];
		}
	}
}

// update the current_matrix
template<class T> 
void update_Matrix(T resource[][MTM_SIZE], T destination[][MTM_SIZE]){
	for(int i = 0; i < MTM_SIZE; i++){
		for(int j = 0; j < MTM_SIZE; j++){
			destination[i][j] = resource[i][j];
		}
	}
}

// draw a dot at location with integer coordinates (x,y)
void drawDot(int x, int y){
	glBegin(GL_POINTS);
	// set the color of dot
	glColor3f(r, g, b);
	// invert height because the opengl origin is at top-left instead of bottom-left
	//glVertex2i(x, height - y);
	glVertex2i(x, y);

	glEnd();
}

// Draw a line in any direction
void DrawLine(int x0, int x1, int y0, int y1) {
	int max_dis = abs(x1 - x0);
	max_dis = max_dis > abs(y0 - y1) ? max_dis : abs(y0 - y1);
	//lcp = temp;
	if(max_dis != 0) {
		for(int i = 0; i < max_dis; ++i) {
			int new_p_x = x0 + i * (x1 - x0) / max_dis;
			int new_p_y = y0 + i * (y1 - y0) / max_dis;
			drawDot(new_p_x, new_p_y);
			//lcp->next = new line_data(new_p_x, new_p_y);
			//lcp = lcp->next;
		}
	}
	glFlush();
	return;
}

// Judge to call which drawLine function to draw a line
void drawLine0(int x0, int x1, int y0, int y1){
	int dx = x1 - x0;
	int dy = y1 - y0;
	if(dx >= 0 && dy > 0 && abs(dx) < abs(dy)){
		drawLine1(x0, x1, y0, y1, false);
	}
	else if(dx > 0 && dy >= 0 && abs(dx) >= abs(dy)){
		drawLine2(x0, x1, y0, y1, false);
	}
	else if(dx > 0 && dy <= 0 && abs(dx) > abs(dy)){
		drawLine3(x0, x1, y0, y1, false);
	}
	else if(dx >= 0 && dy < 0 && abs(dx) <= abs(dy)){
		drawLine4(x0, x1, y0, y1, false);
	}
	else if(dx <= 0 && dy < 0 && abs(dx) < abs(dy)){
		drawLine1(x0, x1, y0, y1, true);
	}
	else if(dx < 0 && dy <= 0 && abs(dx) >= abs(dy)){
		drawLine2(x0, x1, y0, y1, true);
	}
	else if(dx < 0 && dy >= 0 && abs(dx) > abs(dy)){
		drawLine3(x0, x1, y0, y1, true);
	}
	else{
		drawLine4(x0, x1, y0, y1, true);
	}
	//num_line++;
}

// Draw line for dx>0 and dy>0
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange){
	if(xy_interchange){
		int change = x0;	x0 = x1;	x1 = change;
		change = y0;	y0 = y1;	y1 = change;
	}
	int x = x1;
	int y = y1;
	int a = y1 - y0;
	int b = -(x1 - x0);
	int d = -a - 2 * b;
	int IncE = -2 * b;
	int IncNE = -2 * a - 2 * b;
	//line_start[num_line] = line_data(x, y);
	//lcp = &line_start[num_line];
	while(y >= y0){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if(d <= 0){
			y--;
			d += IncE;
		}
		else{
			x--;
			y--;
			d += IncNE;
		}
	}
	glFlush();
	return;
}

// Draw line for dx>0 and dy<0
void drawLine2(int x0, int x1, int y0, int y1, bool xy_interchange){
	if(xy_interchange){
		int change = x0;	x0 = x1;	x1 = change;
		change = y0;	y0 = y1;	y1 = change;
	}
	int x = x0;
	int y = y0;
	int a = y1 - y0;
	int b = -(x1 - x0);
	int d = 2 * a + b;
	int IncE = 2 * a;
	int IncNE = 2 * a + 2 * b;
	//line_start[num_line] = line_data(x, y);
	//lcp = &line_start[num_line];
	while(x <= x1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if(d <= 0){
			x++;
			d += IncE;
		}
		else{
			x++;
			y++;
			d += IncNE;
		}
	}
	glFlush();
	return;
}

// Draw line for dx<0 and dy>0
void drawLine3(int x0, int x1, int y0, int y1, bool xy_interchange){
	if(xy_interchange){
		int change = x0;	x0 = x1;	x1 = change;
		change = y0;	y0 = y1;	y1 = change;
	}
	int x = x0;
	int y = y0;
	int a = y0 - y1;
	int b = -(x1 - x0);
	int d = 2 * a + b;
	int IncE = 2 * a;
	int IncNE = 2 * a + 2 * b;
	//line_start[num_line] = line_data(x, y);
	//lcp = &line_start[num_line];
	while(x <= x1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if(d <= 0){
			x++;
			d += IncE;
		}
		else{
			x++;
			y--;
			d += IncNE;
		}
	}
	glFlush();
	return;
}

// Draw line for dx<0 and dy<0
void drawLine4(int x0, int x1, int y0, int y1, bool xy_interchange){
	if(xy_interchange){
		int change = x0;	x0 = x1;	x1 = change;
		change = y0;	y0 = y1;	y1 = change;
	}
	int x = x0;
	int y = y0;
	int a = y1 - y0;
	int b = -(x1 - x0);
	int d = a - 2 * b;
	int IncE = -2 * b;
	int IncNE = 2 * a - 2 * b;
	//line_start[num_line] = line_data(x, y);
	//lcp = &line_start[num_line];
	while(y >= y1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if(d <= 0){
			y--;
			d += IncE;
		}
		else{
			x++;
			y--;
			d += IncNE;
		}
	}
	glFlush();
	return;
}

// Reset the ModelingTransformMatrix to default
void reset(){
	for(int i = 0; i < MTM_SIZE; i++){
		for(int j = 0; j < MTM_SIZE; j++){
			if(i == j)
				ModelingTransformMatrix[i][j] = 1.0;
			else
				ModelingTransformMatrix[i][j] = 0;
		}
	}
#if PRINT
	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
}

// Multiply ModelingTransformMatrix by scaling matrix
void scale(float sx, float sy, float sz){
	float scaling_matrix[MTM_SIZE][MTM_SIZE] 
		= { { sx, 0, 0, 0 }, 
			{ 0, sy, 0, 0 }, 
			{ 0, 0, sz, 0 }, 
			{ 0, 0, 0, 1 } };

	float new_matrix[MTM_SIZE][MTM_SIZE];

	Matrix_Multi_Matrix(scaling_matrix, ModelingTransformMatrix, new_matrix);

	update_Matrix(new_matrix, ModelingTransformMatrix);
#if PRINT
	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
}

// Multiply ModelingTransformMatrix by rotate matrix
void rotate(float Xdegree, float Ydegree, float Zdegree){
	float new_matrix[MTM_SIZE][MTM_SIZE];

	if(Xdegree != 0){
		float rad = Xdegree * PI / 180.0;
		float rotation_matrix[MTM_SIZE][MTM_SIZE] 
			= { { 1, 0, 0, 0 }, 
				{ 0, cos(rad), -sin(rad), 0 }, 
				{ 0, sin(rad), cos(rad), 0 }, 
				{ 0, 0, 0, 1 } };

		Matrix_Multi_Matrix(rotation_matrix, ModelingTransformMatrix, new_matrix);
		update_Matrix(new_matrix, ModelingTransformMatrix);
#if PRINT
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
	}

	if(Ydegree != 0){
		float rad = Ydegree * PI / 180.0;
		float rotation_matrix[MTM_SIZE][MTM_SIZE]
			= { { cos(rad), 0, sin(rad), 0 },
				{ 0, 1, 0, 0 },
				{ -sin(rad), 0, cos(rad), 0 },
				{ 0, 0, 0, 1 } };

		Matrix_Multi_Matrix(rotation_matrix, ModelingTransformMatrix, new_matrix);
		update_Matrix(new_matrix, ModelingTransformMatrix);
#if PRINT
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
	}

	if(Zdegree != 0){
		float rad = Zdegree * PI / 180.0;
		float rotation_matrix[MTM_SIZE][MTM_SIZE]
			= { { cos(rad), -sin(rad), 0, 0 },
				{ sin(rad), cos(rad), 0, 0 },
				{ 0, 0, 1, 0 },
				{ 0, 0, 0, 1 } };

		Matrix_Multi_Matrix(rotation_matrix, ModelingTransformMatrix, new_matrix);
		update_Matrix(new_matrix, ModelingTransformMatrix);
#if PRINT
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
	}
}

// Multiply ModelingTransformMatrix by translate matrix
void translate(float tx, float ty, float tz){
	float translate_matrix[MTM_SIZE][MTM_SIZE] 
		= { { 1, 0, 0, tx }, 
			{ 0, 1, 0, ty }, 
			{ 0, 0, 1, tz }, 
			{ 0, 0, 0, 1 } };

	float new_matrix[MTM_SIZE][MTM_SIZE];

	Matrix_Multi_Matrix(translate_matrix, ModelingTransformMatrix, new_matrix);

	update_Matrix(new_matrix, ModelingTransformMatrix);
#if PRINT
	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
#endif
}

// Read a ASCModel from file
void object(string objectname, float _R, float _G, float _B, float _Kd, float _Ks, float _N){
	ifstream fin(objectname);
	if(fin.is_open()){
		cout << "\topen the " << objectname << " successfully" << endl;
	}
	else{
		cout << "\tCan't open the " << objectname << endl;
		return;
	}
	// get number of vertex and face first
	fin >> ASCModel[num_ASCModel].num_vertex;
	fin >> ASCModel[num_ASCModel].num_face;
	// read vertex one by one
	for(int i = 0; i<ASCModel[num_ASCModel].num_vertex; i++) {
		for(int j = 0; j < 3; j++){
			fin >> ASCModel[num_ASCModel].vertex[i][j];
		}
		ASCModel[num_ASCModel].vertex[i][3] = 1;//fix to multiplication
	}

	// read face one by one
	for(int i = 0; i<ASCModel[num_ASCModel].num_face; i++) {
		fin >> ASCModel[num_ASCModel].face[i][0];
		for(int j = 1; j <= ASCModel[num_ASCModel].face[i][0]; j++){
			fin >> ASCModel[num_ASCModel].face[i][j];
		}
	}
	
	// Convert Object-Space to World-Space
	float multi_sum = 0;
	float WorldSpace[MTM_SIZE];
	for(int i = 0; i < ASCModel[num_ASCModel].num_vertex; i++){
		for(int j = 0; j < MTM_SIZE; j++){
			multi_sum = 0;
			for(int k = 0; k < MTM_SIZE; k++){
				multi_sum += ASCModel[num_ASCModel].vertex[i][k]
					* ModelingTransformMatrix[j][k];
			}
			WorldSpace[j] = multi_sum;
		}
		// Update(cover) the Object-Space
		for(int j = 0; j < MTM_SIZE; j++){
			ASCModel[num_ASCModel].vertex[i][j] = WorldSpace[j];
		}
	}

	ASCModel[num_ASCModel].R = _R;
	ASCModel[num_ASCModel].G = _G;
	ASCModel[num_ASCModel].B = _B;
	ASCModel[num_ASCModel].Kd = _Kd;
	ASCModel[num_ASCModel].Ks = _Ks;
	ASCModel[num_ASCModel].N = _N;

	num_ASCModel++;
}

// Set the observer
void observer(float PX, float PY, float PZ, float CX, float CY, float CZ,
	float Tilt, float zNear, float zFar, float hFOV){

	Eye_Transform(PX, PY, PZ, CX, CY, CZ, Tilt);
	
	Project_Transform(zNear, zFar, hFOV);

	EyeX = PX;
	EyeY = PY;
	EyeZ = PZ;

	WzNear = zNear;
	WzFar = zFar;
	WhFOV = hFOV;
}

// Set up Eye_Transform_Matrix
void Eye_Transform(float PX, float PY, float PZ, float CX, float CY, float CZ, float Tilt){
	float Eye_Translation_Matrix[MTM_SIZE][MTM_SIZE]
		= { { 1, 0, 0, -PX },
			{ 0, 1, 0, -PY },
			{ 0, 0, 1, -PZ },
			{ 0, 0, 0, 1 } };
#if PRINT
	printMatrix(Eye_Translation_Matrix, 4, 4, "Eye_Translation_Matrix");
#endif
	float Eye_Mirror_Matrix[MTM_SIZE][MTM_SIZE]
		= { { -1, 0, 0, 0 },
			{ 0, 1, 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 } };
#if PRINT
	printMatrix(Eye_Mirror_Matrix, 4, 4, "Eye_Mirror_Matrix");
#endif

	float TiltDegree = Tilt * PI / 180.0;
	float Eye_Tilt_Matrix[MTM_SIZE][MTM_SIZE]
		= { { cos(TiltDegree), sin(TiltDegree), 0, 0 },
			{ -sin(TiltDegree), cos(TiltDegree), 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 } };
#if PRINT
	printMatrix(Eye_Tilt_Matrix, 4, 4, "Eye_Tilt_Matrix");
#endif

	float view_vector[3] = { CX - PX, CY - PY, CZ - PZ };
	float top_vector[3] = { 0, 1, 0 };

	float vector3[3];
	memcpy(vector3, view_vector, sizeof(view_vector));
	UnitizeVector(vector3);
	float vector1[3];
	Cross_Multi(vector1, top_vector, view_vector);
	UnitizeVector(vector1);
	float vector2[3];
	Cross_Multi(vector2, vector3, vector1);
	UnitizeVector(vector2);

	float GRM[MTM_SIZE][MTM_SIZE] 
		= { { vector1[0], vector1[1], vector1[2], 0 }, 
			{ vector2[0], vector2[1], vector2[2], 0 }, 
			{ vector3[0], vector3[1], vector3[2], 0 }, 
			{ 0, 0, 0, 1 } };
#if PRINT
	printMatrix(GRM, 4, 4, "GRM");
#endif

	float new_Eye_Matrix[MTM_SIZE][MTM_SIZE] 
		= { { 1, 0, 0, 0 }, 
			{ 0, 1, 0, 0 }, 
			{ 0, 0, 1, 0 }, 
			{ 0, 0, 0, 1 } };
	Matrix_Multi_Matrix(Eye_Translation_Matrix, new_Eye_Matrix, new_Eye_Matrix);
	Matrix_Multi_Matrix(GRM, new_Eye_Matrix, new_Eye_Matrix);
	Matrix_Multi_Matrix(Eye_Mirror_Matrix, new_Eye_Matrix, new_Eye_Matrix);
	Matrix_Multi_Matrix(Eye_Tilt_Matrix, new_Eye_Matrix, new_Eye_Matrix);
	update_Matrix(new_Eye_Matrix, Eye_Matirx);
#if PRINT
	printMatrix(Eye_Matirx, 4, 4, "Eye_Matrix");
#endif
}

// Set up Project_Transform_Matrix
void Project_Transform(float zNear, float zFar, float hFOV){
	float PM4_3 = tan(hFOV * PI / 180.0);
	float PM3_3 = (zFar / (zFar - zNear)) * PM4_3;
	float PM3_4 = ((zNear * zFar) / (zNear - zFar)) * PM4_3;
	float new_Project_Matrix[MTM_SIZE][MTM_SIZE] 
		= { { 1, 0, 0, 0 }, 
			{ 0, 1, 0, 0 }, 
			{ 0, 0, PM3_3, PM3_4 }, 
			{ 0, 0, PM4_3, 0 } };
	update_Matrix(new_Project_Matrix, Project_Matrix);
}

// Multiplication Cross for 3-dimensionality
void Cross_Multi(float destination[], float a[], float b[]){
	destination[0] = a[1] * b[2] - a[2] * b[1];
	destination[1] = a[2] * b[0] - a[0] * b[2];
	destination[2] = a[0] * b[1] - a[1] * b[0];
}

// Unitize a 3-dimensionality Vector
void UnitizeVector(float vector[]){
	float diver = sqrt(vector[0] * vector[0] +
					   vector[1] * vector[1] +
					   vector[2] * vector[2]);
	for(int i = 0; i < 3; i++){
		vector[i] /= diver;
	}
}

// Set the view border
void viewport(float vxl, float vxr, float vyb, float vyt){
	float Vlength = vxr - vxl;
	float Vheight = vyt - vyb;
	Project_Matrix[1][1] = Vlength / Vheight;// Set Ar
#if PRINT
	printMatrix(Project_Matrix, 4, 4, "Project_Matrix");
#endif

	float wxl, wxr, wyb, wyt;
	wxl = wyb = -1.0;
	wxr = wyt = 1.0;
	wvmtype scaling_x = (wvmtype)((vxr - vxl) / (wxr - wxl));
	wvmtype scaling_y = (wvmtype)((vyt - vyb) / (wyt - wyb));
	wvmtype shift_x = (wvmtype)(vxl - scaling_x * wxl);
	wvmtype shift_y = (wvmtype)(vyb - scaling_y * wyb);
	wvmtype new_WVM_Matrix[MTM_SIZE][MTM_SIZE]
		= { { scaling_x, 0, shift_x, 0 }, 
			{ 0, scaling_y, shift_y, 0 }, 
			{ 0, 0, 1, 0 }, 
			{ 0, 0, 0, 1 } };
	update_Matrix(new_WVM_Matrix, WVM);
#if PRINT
	printMatrix(WVM, 4, 4, "WVM Matrix");
#endif
}

// Show all the object in final
void display(){
	viewport(0, width, 0, height);

	wordsToTA();

	initial();
	//clearScreen();
	//clearData();

	vector<PointWithColor> colorPointVector;
	PointWithColor newColorPoint;

	float multi_sum = 0;
	float Matrix[MTM_SIZE];
	ASCModel_struct Cur_ASCModel;
	for(int index = 0; index < num_ASCModel; index++){
		Cur_ASCModel = ASCModel[index];
		/*line_start[num_line] = line_data(-1, -1);
		lcp = &line_start[num_line];*/
#if PRINT
		cout << "World-Space:" << endl;
		cout << Cur_ASCModel.vertex[PRINT_VERTEX][0] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][1] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][2] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][3] << " " << endl;
#endif
		// Convert World-Space to Eye-Space
		for(int i = 0; i < ASCModel[index].num_vertex; i++){
			for(int j = 0; j < MTM_SIZE; j++){
				multi_sum = 0;
				for(int k = 0; k < MTM_SIZE; k++){
					multi_sum += Cur_ASCModel.vertex[i][k]
						* Eye_Matirx[j][k];
				}
				Matrix[j] = multi_sum;
			}
			// Update(cover) the Object-Space
			for(int j = 0; j < MTM_SIZE; j++){
				Cur_ASCModel.vertex[i][j] = Matrix[j];
			}
		}
#if PRINT
		cout << "Eye-Space:" << endl;
		cout << Cur_ASCModel.vertex[PRINT_VERTEX][0] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][1] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][2] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][3] << " " << endl;
#endif
		// Convert Eye-Space to Project-Space
		for(int i = 0; i < ASCModel[index].num_vertex; i++){
			for(int j = 0; j < MTM_SIZE; j++){
				multi_sum = 0;
				for(int k = 0; k < MTM_SIZE; k++){
					multi_sum += Cur_ASCModel.vertex[i][k]
						* Project_Matrix[j][k];
				}
				Matrix[j] = multi_sum;
			}
			// Update(cover) the Object-Space
			for(int j = 0; j < MTM_SIZE; j++){
				Cur_ASCModel.vertex[i][j] = Matrix[j] / Matrix[3];
			}
			//Cur_ASCModel.vertex[i][2] = 1;//Fix to three-dimensional homogeneous
		}
#if PRINT
		cout << "Project-Space:" << endl;
		cout << Cur_ASCModel.vertex[PRINT_VERTEX][0] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][1] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][2] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][3] << " " << endl;
#endif
		// Convert Project-Space to Screen-Space
		for(int i = 0; i < ASCModel[index].num_vertex; i++){
			for(int j = 0; j < MTM_SIZE; j++){
				multi_sum = 0;
				for(int k = 0; k < MTM_SIZE; k++){
					multi_sum += Cur_ASCModel.vertex[i][k]
						* WVM[j][k];
				}
				Matrix[j] = multi_sum;
			}
			// Update(cover) the Object-Space
			for(int j = 0; j < MTM_SIZE; j++){
				Cur_ASCModel.vertex[i][j] = Matrix[j];
			}
		}
#if PRINT
		cout << "Screen-Space:" << endl;
		cout << Cur_ASCModel.vertex[PRINT_VERTEX][0] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][1] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][2] << " "
			<< Cur_ASCModel.vertex[PRINT_VERTEX][3] << " " << endl;
#endif
		// Display
		for(int i = 0; i < Cur_ASCModel.num_face; i++){
			colorPointVector.clear();
			int min_y = INT_MAX;
			int max_y = INT_MIN;
			for(int j = 1; j <= Cur_ASCModel.face[i][0]; j++){
				newColorPoint.x = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j] - 1][0];
				newColorPoint.y = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j] - 1][1];
				if(newColorPoint.y < min_y)
					min_y = newColorPoint.y;
				if(newColorPoint.y > max_y)
					max_y = newColorPoint.y;
				newColorPoint.z = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j] - 1][2];
				newColorPoint.r = getColor(index, i, Cur_ASCModel.face[i][j] - 1, 'r');
				newColorPoint.g = getColor(index, i, Cur_ASCModel.face[i][j] - 1, 'g');
				newColorPoint.b = getColor(index, i, Cur_ASCModel.face[i][j] - 1, 'b');
				colorPointVector.push_back(newColorPoint);
			}
			//sortColorPointVector(colorPointVector);
			drawFace(colorPointVector, min_y, max_y);
			//system("pause");
		}
		//num_line++;
	}
	
	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			drawColorDot(j, i, Buffer[i][j].r, Buffer[i][j].g, Buffer[i][j].b);
		}
	}
	glFlush();
}

// Draw a Face with the point in vector
void drawFace(const vector<PointWithColor>& colorPointVector, int min_y, int max_y){
	// 自己的运算方法，首先存储边框，然后插值运算所有
	vector< priority_queue<PointWithColor> > vecPriQue;
	for(int i = min_y; i <= max_y; i++){
		priority_queue<PointWithColor> empty;
		vecPriQue.push_back(empty);
	}
	for(int i = 0; i < colorPointVector.size(); i++){
		int i_next = (i + 1 == colorPointVector.size()) ? 0 : i + 1;
		//int a = abs(colorPointVector[i].x - colorPointVector[i_next].x);
		int b = abs(colorPointVector[i].y - colorPointVector[i_next].y);
		//int max_dis = a > b ? a : b;
		int max_dis = b;
		//cout << a << "  " << b << "  " << max_dis << endl;
		if(max_dis != 0){
			PointWithColor newColorPoint;
			for(int j = 0; j < max_dis; j++){
				newColorPoint.x = colorPointVector[i].x + j
					* (colorPointVector[i_next].x - colorPointVector[i].x) / max_dis;
				newColorPoint.y = colorPointVector[i].y + j
					* (colorPointVector[i_next].y - colorPointVector[i].y) / max_dis;
				//cout << newColorPoint.x << "   " << newColorPoint.y << endl;
				newColorPoint.z = interpolation(colorPointVector[i].z, colorPointVector[i_next].z,
					colorPointVector[i].y, colorPointVector[i_next].y, newColorPoint.y);
				//cout << newColorPoint.z << endl;
				newColorPoint.r = interpolation(colorPointVector[i].r, colorPointVector[i_next].r, 
					colorPointVector[i].y, colorPointVector[i_next].y, newColorPoint.y);
				newColorPoint.g = interpolation(colorPointVector[i].g, colorPointVector[i_next].g,
					colorPointVector[i].y, colorPointVector[i_next].y, newColorPoint.y);
				newColorPoint.b = interpolation(colorPointVector[i].b, colorPointVector[i_next].b,
					colorPointVector[i].y, colorPointVector[i_next].y, newColorPoint.y);
				vecPriQue[newColorPoint.y - min_y].push(newColorPoint);
				//drawColorDot(newColorPoint.x, newColorPoint.y, newColorPoint.r, newColorPoint.g, newColorPoint.b);
			}
		}
		else{
			vecPriQue[colorPointVector[i].y - min_y].push(colorPointVector[i]);
			vecPriQue[colorPointVector[i_next].y - min_y].push(colorPointVector[i_next]);
		}
	}
	for(int i = 0; i < vecPriQue.size(); i++){
		if(!vecPriQue[i].empty()){
			PointWithColor left = vecPriQue[i].top();
			while(vecPriQue[i].size() > 1)
				vecPriQue[i].pop();
			PointWithColor right = vecPriQue[i].top();
			vecPriQue[i].pop();
			if(right.x - left.x == 0){
				if(left.z < Buffer[left.y][(int)left.x].z){
					Buffer[left.y][(int)left.x].z = left.z;
					Buffer[left.y][(int)left.x].r = left.r;
					Buffer[left.y][(int)left.x].g = left.g;
					Buffer[left.y][(int)left.x].b = left.b;
				}
				continue;
			}
			
			int step_x = left.x - 1;
			float step_z = (right.z - left.z) / (right.x - left.x);		float depth_z = left.z - step_z;
			float step_r = (right.r - left.r) / (right.x - left.x);		float cur_r = left.r - step_r;
			float step_g = (right.g - left.g) / (right.x - left.x);		float cur_g = left.g - step_g;
			float step_b = (right.b - left.b) / (right.x - left.x);		float cur_b = left.b - step_b;
			
			int steps = right.x - left.x;
			for(int j = 0; j <= steps; j++){
				step_x++;
				depth_z += step_z;
				cur_r += step_r;	cur_g += step_g;	cur_b += step_b;
				if(depth_z < Buffer[left.y][step_x].z){
					//cout << depth_z << endl;
					Buffer[left.y][step_x].z = depth_z;
					Buffer[left.y][step_x].r = cur_r;
					Buffer[left.y][step_x].g = cur_g;
					Buffer[left.y][step_x].b = cur_b;
					//drawColorDot(step_x, left.y, cur_r, cur_g, cur_b);
					//drawColorDot(step_x, left.y, colorPointVector[0].r, colorPointVector[0].g, colorPointVector[0].b);
					//glFlush();
				}
			}
		}
	}
}
//void drawFace(const vector<PointWithColor>& colorPointVector, int min_y, int max_y){
//	//老师发方法，必须判断top left right，且中间扫描过程可能改变
//	for(int y = max_y; y >= min_y; y--){
//		PointWithColor left, right;
//		// Get point left
//		left.y = y;
//		left.x = interpolation(colorPointVector[0].x, colorPointVector[1].x, 
//			colorPointVector[0].y, colorPointVector[1].y, y);
//		left.z = interpolation(colorPointVector[0].z, colorPointVector[1].z,
//			colorPointVector[0].y, colorPointVector[1].y, y);
//		left.r = interpolation(colorPointVector[0].r, colorPointVector[1].r,
//			colorPointVector[0].y, colorPointVector[1].y, y);
//		left.g = interpolation(colorPointVector[0].g, colorPointVector[1].g,
//			colorPointVector[0].y, colorPointVector[1].y, y);
//		left.b = interpolation(colorPointVector[0].b, colorPointVector[1].b,
//			colorPointVector[0].y, colorPointVector[1].y, y);
//		// Get point right
//		right.y = y;
//		right.x = interpolation(colorPointVector[0].x, colorPointVector[2].x,
//			colorPointVector[0].y, colorPointVector[2].y, y);
//		right.z = interpolation(colorPointVector[0].z, colorPointVector[2].z,
//			colorPointVector[0].y, colorPointVector[2].y, y);
//		right.r = interpolation(colorPointVector[0].r, colorPointVector[2].r,
//			colorPointVector[0].y, colorPointVector[2].y, y);
//		right.g = interpolation(colorPointVector[0].g, colorPointVector[2].g,
//			colorPointVector[0].y, colorPointVector[2].y, y);
//		right.b = interpolation(colorPointVector[0].b, colorPointVector[2].b,
//			colorPointVector[0].y, colorPointVector[2].y, y);
//		// one point in a line
//		if(left.x == right.x && left.y == right.y){
//			for(unsigned int i = 0; i < colorPointVector.size(); i++){
//				if(left.x == colorPointVector[i].x && left.y == colorPointVector[i].y){
//					if(colorPointVector[i].z < Buffer[left.y][left.x].z){
//						Buffer[left.y][left.x].z = colorPointVector[i].z;
//						Buffer[left.y][left.x].r = colorPointVector[i].r;
//						Buffer[left.y][left.x].g = colorPointVector[i].g;
//						Buffer[left.y][left.x].b = colorPointVector[i].b;
//					}
//					break;
//				}
//			}
//			continue;
//		}
//		// two point in a line
//		int step_x = left.x - 1;
//		int step_z = (right.z - left.z) / (right.x - left.x);		int depth_z = left.z - step_z;
//		float step_r = (right.r - left.r) / (right.x - left.x);		float cur_r = left.r - step_r;
//		float step_g = (right.g - left.g) / (right.x - left.x);		float cur_g = left.g - step_g;
//		float step_b = (right.b - left.b) / (right.x - left.x);		float cur_b = left.b - step_b;
//
//		int steps = right.x - left.x;
//		for(int j = 0; j <= steps; j++){
//			step_x++;
//			depth_z += step_z;
//			cur_r += step_r;	cur_g += step_g;	cur_b += step_b;
//			if(depth_z < Buffer[left.y][step_x].z){
//				Buffer[left.y][step_x].z = depth_z;
//				Buffer[left.y][step_x].r = cur_r;
//				Buffer[left.y][step_x].g = cur_g;
//				Buffer[left.y][step_x].b = cur_b;
//				drawColorDot(step_x, left.y, cur_r, cur_g, cur_b);
//				//drawColorDot(step_x, left.y, colorPointVector[0].r, colorPointVector[0].g, colorPointVector[0].b);
//			}
//		}
//	}
//	glFlush();
//}
//void drawFace(const vector<PointWithColor>& colorPointVector, int min_y, int max_y){
//	// 自己的运算方法，首先存储边框，然后取中点
//	vector< priority_queue<PointWithColor> > vecPriQue;
//	for(int i = min_y; i <= max_y; i++){
//		priority_queue<PointWithColor> empty;
//		vecPriQue.push_back(empty);
//	}
//	float sum_r = 0, sum_g = 0, sum_b = 0;
//	for(int i = 0; i < colorPointVector.size(); i++){
//		sum_r += colorPointVector[i].r;
//		sum_g += colorPointVector[i].g;
//		sum_b += colorPointVector[i].b;
//		int i_next = (i + 1 == colorPointVector.size()) ? 0 : i + 1;
//		int b = abs(colorPointVector[i].y - colorPointVector[i_next].y);
//		int max_dis = b;
//		if(max_dis != 0){
//			PointWithColor newColorPoint;
//			for(int j = 0; j < max_dis; j++){
//				newColorPoint.x = colorPointVector[i].x + j
//					* (colorPointVector[i_next].x - colorPointVector[i].x) / max_dis;
//				newColorPoint.y = colorPointVector[i].y + j
//					* (colorPointVector[i_next].y - colorPointVector[i].y) / max_dis;
//				newColorPoint.z = interpolation(colorPointVector[i].z, colorPointVector[i_next].z,
//					colorPointVector[i].y, colorPointVector[i_next].y, newColorPoint.y);
//				vecPriQue[newColorPoint.y - min_y].push(newColorPoint);
//				//drawColorDot(newColorPoint.x, newColorPoint.y, newColorPoint.r, newColorPoint.g, newColorPoint.b);
//			}
//		}
//	}
//	sum_r /= colorPointVector.size();
//	sum_g /= colorPointVector.size();
//	sum_b /= colorPointVector.size();
//	for(int i = 0; i < vecPriQue.size(); i++){
//		if(!vecPriQue[i].empty()){
//			PointWithColor left = vecPriQue[i].top();
//			while(vecPriQue[i].size() > 1)
//				vecPriQue[i].pop();
//			PointWithColor right = vecPriQue[i].top();
//			vecPriQue[i].pop();
//			if(right.x - left.x == 0){
//				if(left.z < Buffer[left.y][(int)left.x].z){
//					Buffer[left.y][(int)left.x].z = left.z;
//					Buffer[left.y][(int)left.x].r = sum_r;
//					Buffer[left.y][(int)left.x].g = sum_g;
//					Buffer[left.y][(int)left.x].b = sum_b;
//				}
//				continue;
//			}
//
//			int step_x = left.x - 1;
//			float step_z = (right.z - left.z) / (right.x - left.x);		float depth_z = left.z - step_z;
//
//			int steps = right.x - left.x;
//			for(int j = 0; j <= steps; j++){
//				step_x++;
//				depth_z += step_z;
//				if(depth_z < Buffer[left.y][step_x].z){
//					//cout << depth_z << endl;
//					Buffer[left.y][step_x].z = depth_z;
//					Buffer[left.y][step_x].r = sum_r;
//					Buffer[left.y][step_x].g = sum_g;
//					Buffer[left.y][step_x].b = sum_b;
//					drawColorDot(step_x, left.y, sum_r, sum_g, sum_b);
//					glFlush();
//				}
//			}
//		}
//	}
//}

// Return the value of interpolation
float interpolation(float p1, float p2, float q1, float q2, float q){
	return ((q - q1) / (q2 - q1) * (p2 - p1) + p1);
}

// glut way to draw a dot with color
void drawColorDot(int x, int y, float c_r, float c_g, float c_b){
	glBegin(GL_POINTS);
	// set the color of dot
	glColor3f(c_r, c_g, c_b);
	// invert height because the opengl origin is at top-left instead of bottom-left
	//glVertex2i(x, height - y);
	glVertex2i(x, y);

	glEnd();
}

// Redrwa the object
void redraw(){
	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			drawColorDot(j, i, Buffer[i][j].r, Buffer[i][j].g, Buffer[i][j].b);
		}
	}
	glFlush();
}

// Clear all the objects in store
void clearData(){
	for(int i = 0; i < num_line; i++){
		if(line_start[i].next != NULL){
			lcp = line_start[i].next;
			while(lcp != NULL){
				temp = lcp;
				lcp = lcp->next;
				delete(temp);
			}
		}
	}
	num_line = 0;
}

// Clear the screen
void clearScreen(){
	glClearColor(background_r, background_g, background_b, alpha);
	glClear(GL_COLOR_BUFFER_BIT);
	glFlush();
}

// Read the command from file
void ReadFile(bool& IsExit){
	/*ifstream fin(Inputfile);
	if(fin.is_open()){
		cout << "open the file successfully" << endl;
	}
	else{
		cout << "Can't not open the file" << endl;
		IsExit = true;
		return;
	}*/
	int _ID;
	float sx, sy, sz;
	float Xdegree, Ydegree, Zdegree;
	float tx, ty, tz;
	float vxl, vxr, vyt, vyb;
	float PX, PY, PZ, CX, CY, CZ, Tilt, zNear, zFar, hFOV;
	float AmKa, b_r, b_g, b_b;
	float _R, _G, _B, _Kd, _Ks, _N;
	float _Ip, _X, _Y, _Z;
	string command, comment, objectname;

	/*if(!fin.eof()){
		fin >> width >> height;
		setWinSize(width, height);
	}*/

	while(!fin.eof()){
		fin >> command;
		cout <<"COMMAND -- " << command << " : " << endl;
		if(command == "scale"){
			fin >> sx >> sy >> sz;
			scale(sx, sy, sz);
		}
		else if(command == "rotate"){
			fin >> Xdegree >> Ydegree >>Zdegree;
			rotate(Xdegree, Ydegree, Zdegree);
		}
		else if(command == "translate"){
			fin >> tx >> ty >> tz;
			translate(tx, ty, tz);
		}
		else if(command == "reset"){
			reset();
		}
		else if(command == "object"){
			fin >> objectname;
			fin >> _R >> _G >> _B;
			fin >> _Kd >> _Ks >> _N;
			object(objectname, _R, _G, _B, _Kd, _Ks, _N);
		}
		else if(command == "observer"){
			fin >> PX >> PY >> PZ;
			fin >> CX >> CY >> CZ;
			fin >> Tilt;
			fin >> zNear >> zFar >> hFOV;
			observer(PX, PY, PZ, CX, CY, CZ, Tilt, zNear, zFar, hFOV);
		}
		else if(command == "viewport"){
			fin >> vxl >> vxr >> vyb >> vyt;
			viewport(vxl, vxr, vyb, vyt);
		}
		else if(command == "display"){
			display();
			cout << "\tObjects display successfully" << endl;
		}
		else if(command == "clearData"){
			clearData();
			cout << "Data is cleared" << endl;
		}
		else if(command == "clearScreen"){
			clearScreen();
			cout << "Screen is cleared" << endl;
		}
		else if(command == "ambient"){
			fin >> AmKa;
			setAmbient(AmKa);
		}
		else if(command == "background"){
			fin >> b_r >> b_g >> b_b;
			setBackground(b_r, b_g, b_b);
		}
		else if(command == "light"){
			fin >> _ID;
			fin >> _Ip >> _X >> _Y >> _Z;
			setLight(_ID - 1, _Ip, _X, _Y, _Z);
		}
		else if(command == "end"){
			IsExit = true;
			fin.close();
			return;
		}
		else if(command == "#"){
			getline(fin, comment);
			cout << "\t" << comment << endl;
		}
		cout << endl;
	}
}

// Display function
void displayFunc(void){
	// clear the entire window to the background color
	glClear(GL_COLOR_BUFFER_BIT);
	while(!IsExit){
		glClearColor(background_r, background_g, background_b, alpha);
		ReadFile(IsExit);
		return;
	}

	if(IsExit){
		redraw();
	}
	return;
}

// Change the windows size function
void setWinSize(int winWidth, int winHeight){
	glutInitWindowSize(winWidth, winHeight);      // set window size
	glutInitWindowPosition(500, 100);            // set window position on screen
	glutCreateWindow("Lab4 Window");       // set window title

	// set background color
	glClearColor(background_r, background_g, background_b, alpha);     // set the background to white
	glClear(GL_COLOR_BUFFER_BIT); // clear the buffer

	// misc setup
	glMatrixMode(GL_PROJECTION);  // setup coordinate system
	glLoadIdentity();
	gluOrtho2D(0, winWidth, 0, winHeight);
	glShadeModel(GL_FLAT);
	glFlush();

	return;
}

// Set the Ka of Ambient
void setAmbient(float value){
	ambient_Ka = value;
}

// Set the Background Color
void setBackground(float _background_r, float _background_g, float _background_b){
	background_r = _background_r;
	background_g = _background_g;
	background_b = _background_b;
}

// Create a new Light Object
void setLight(int _ID, float _Ip, float _X, float _Y, float _Z){
	Light[_ID].enable = true;
	Light[_ID].Ip = _Ip;
	Light[_ID].X = _X;
	Light[_ID].Y = _Y;
	Light[_ID].Z = _Z;

	//  Convert to WorldSpace
	/*float multi_sum = 0;
	float WorldSpace[MTM_SIZE];
	float LWPosition[MTM_SIZE] = { _X, _Y, _Z, 1 };
	for(int j = 0; j < MTM_SIZE; j++){
		multi_sum = 0;
		for(int k = 0; k < MTM_SIZE; k++){
			multi_sum += LWPosition[k] * ModelingTransformMatrix[j][k];
		}
		WorldSpace[j] = multi_sum;
	}

	Light[_ID].X = WorldSpace[0];
	Light[_ID].Y = WorldSpace[1];
	Light[_ID].Z = WorldSpace[2];*/
}

// Return the total value of color of a point
//float getColor(int objectIndex, int faceIndex, int pointIndex, char whichColor){
//	// getColor的完全实现版本
//	float sumColor, ambient, diffuse, specular;
//	//float fatt = 1.0;//Maybe Wrong
//	if(whichColor == 'r' || whichColor == 'R'){
//		//ambient = ambient_Ka * background_r * ASCModel[objectIndex].R;
//		ambient = ambient_Ka * ASCModel[objectIndex].R;
//
//		diffuse = 0;
//		specular = 0;
//
//		float normalVector[3];
//		getNormalVector(normalVector, objectIndex, faceIndex);
//		UnitizeVector(normalVector);
//
//		for(int i = 1; i <= 4; i++){
//			if(Light[i].enable){
//				float lightVector[3];
//				lightVector[0] = Light[i].X - ASCModel[objectIndex].vertex[pointIndex][0];
//				lightVector[1] = Light[i].Y - ASCModel[objectIndex].vertex[pointIndex][1];
//				lightVector[2] = Light[i].Z - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(lightVector);
//				float NdotL = AbsDot_Multi(normalVector, lightVector);
//				float reflectVector[3];
//				reflectVector[0] = 2 * NdotL * normalVector[0] - lightVector[0];
//				reflectVector[1] = 2 * NdotL * normalVector[1] - lightVector[1];
//				reflectVector[2] = 2 * NdotL * normalVector[2] - lightVector[2];
//				UnitizeVector(reflectVector);
//				float viewVector[3];
//				viewVector[0] = EyeX - ASCModel[objectIndex].vertex[pointIndex][0];
//				viewVector[1] = EyeY - ASCModel[objectIndex].vertex[pointIndex][1];
//				viewVector[2] = EyeZ - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(viewVector);
//				/*float distance = sqrt(lightVector[0] * lightVector[0]
//				+ lightVector[1] * lightVector[1]
//				+ lightVector[2] * lightVector[2]);*/
//				//float fatt = 1.0 / (0.1 + 0.1 * distance + 0.1 * distance * distance); // Maybe Wrong
//				//diffuse += fatt * ASCModel[objectIndex].Kd * Light[i].Ip * AbsDot_Multi(normalVector, lightVector);
//				diffuse += ASCModel[objectIndex].Kd * AbsDot_Multi(normalVector, lightVector);
//
//				//float halfWayVector[3];
//				//// halfWayVector = lightVector + viewVector
//				//halfWayVector[0] = lightVector[0] + (EyeX - ASCModel[objectIndex].vertex[pointIndex][0]);
//				//halfWayVector[1] = lightVector[1] + (EyeY - ASCModel[objectIndex].vertex[pointIndex][1]);
//				//halfWayVector[2] = lightVector[2] + (EyeZ - ASCModel[objectIndex].vertex[pointIndex][2]);
//				//UnitizeVector(halfWayVector);
//				//float specular_last = pow(AbsDot_Multi(halfWayVector, normalVector), ASCModel[objectIndex].N);
//				float specular_last = pow(AbsDot_Multi(reflectVector, viewVector), ASCModel[objectIndex].N);
//				//specular += fatt * ASCModel[objectIndex].Ks * Light[i].Ip * specular_last;
//				specular += ASCModel[objectIndex].Ks * specular_last;
//			}
//		}
//		diffuse *= ASCModel[objectIndex].R;
//	}
//	else if(whichColor == 'g' || whichColor == 'G'){
//		//ambient = ambient_Ka * background_r * ASCModel[objectIndex].G;
//		ambient = ambient_Ka * ASCModel[objectIndex].G;
//
//		diffuse = 0;
//		specular = 0;
//
//		float normalVector[3];
//		getNormalVector(normalVector, objectIndex, faceIndex);
//		UnitizeVector(normalVector);
//
//		for(int i = 1; i <= 4; i++){
//			if(Light[i].enable){
//				float lightVector[3];
//				lightVector[0] = Light[i].X - ASCModel[objectIndex].vertex[pointIndex][0];
//				lightVector[1] = Light[i].Y - ASCModel[objectIndex].vertex[pointIndex][1];
//				lightVector[2] = Light[i].Z - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(lightVector);
//				float NdotL = AbsDot_Multi(normalVector, lightVector);
//				float reflectVector[3];
//				reflectVector[0] = 2 * NdotL * normalVector[0] - lightVector[0];
//				reflectVector[1] = 2 * NdotL * normalVector[1] - lightVector[1];
//				reflectVector[2] = 2 * NdotL * normalVector[2] - lightVector[2];
//				UnitizeVector(reflectVector);
//				float viewVector[3];
//				viewVector[0] = EyeX - ASCModel[objectIndex].vertex[pointIndex][0];
//				viewVector[1] = EyeY - ASCModel[objectIndex].vertex[pointIndex][1];
//				viewVector[2] = EyeZ - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(viewVector);
//				/*float distance = sqrt(lightVector[0] * lightVector[0]
//				+ lightVector[1] * lightVector[1]
//				+ lightVector[2] * lightVector[2]);*/
//				//float fatt = 1.0 / (0.1 + 0.1 * distance + 0.1 * distance * distance); // Maybe Wrong
//				//diffuse += fatt * ASCModel[objectIndex].Kd * Light[i].Ip * AbsDot_Multi(normalVector, lightVector);
//				diffuse += ASCModel[objectIndex].Kd * AbsDot_Multi(normalVector, lightVector);
//
//				//float halfWayVector[3];
//				//// halfWayVector = lightVector + viewVector
//				//halfWayVector[0] = lightVector[0] + (EyeX - ASCModel[objectIndex].vertex[pointIndex][0]);
//				//halfWayVector[1] = lightVector[1] + (EyeY - ASCModel[objectIndex].vertex[pointIndex][1]);
//				//halfWayVector[2] = lightVector[2] + (EyeZ - ASCModel[objectIndex].vertex[pointIndex][2]);
//				//UnitizeVector(halfWayVector);
//				//float specular_last = pow(AbsDot_Multi(halfWayVector, normalVector), ASCModel[objectIndex].N);
//				float specular_last = pow(AbsDot_Multi(reflectVector, viewVector), ASCModel[objectIndex].N);
//				//specular += fatt * ASCModel[objectIndex].Ks * Light[i].Ip * specular_last;
//				specular += ASCModel[objectIndex].Ks * specular_last;
//			}
//		}
//		diffuse *= ASCModel[objectIndex].G;
//	}
//	else if(whichColor == 'b' || whichColor == 'B'){
//		//ambient = ambient_Ka * background_r * ASCModel[objectIndex].B;
//		ambient = ambient_Ka * ASCModel[objectIndex].B;
//
//		diffuse = 0;
//		specular = 0;
//
//		float normalVector[3];
//		getNormalVector(normalVector, objectIndex, faceIndex);
//		UnitizeVector(normalVector);
//
//		for(int i = 1; i <= 4; i++){
//			if(Light[i].enable){
//				float lightVector[3];
//				lightVector[0] = Light[i].X - ASCModel[objectIndex].vertex[pointIndex][0];
//				lightVector[1] = Light[i].Y - ASCModel[objectIndex].vertex[pointIndex][1];
//				lightVector[2] = Light[i].Z - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(lightVector);
//				float NdotL = AbsDot_Multi(normalVector, lightVector);
//				float reflectVector[3];
//				reflectVector[0] = 2 * NdotL * normalVector[0] - lightVector[0];
//				reflectVector[1] = 2 * NdotL * normalVector[1] - lightVector[1];
//				reflectVector[2] = 2 * NdotL * normalVector[2] - lightVector[2];
//				UnitizeVector(reflectVector);
//				float viewVector[3];
//				viewVector[0] = EyeX - ASCModel[objectIndex].vertex[pointIndex][0];
//				viewVector[1] = EyeY - ASCModel[objectIndex].vertex[pointIndex][1];
//				viewVector[2] = EyeZ - ASCModel[objectIndex].vertex[pointIndex][2];
//				UnitizeVector(viewVector);
//				/*float distance = sqrt(lightVector[0] * lightVector[0]
//				+ lightVector[1] * lightVector[1]
//				+ lightVector[2] * lightVector[2]);*/
//				//float fatt = 1.0 / (0.1 + 0.1 * distance + 0.1 * distance * distance); // Maybe Wrong
//				//diffuse += fatt * ASCModel[objectIndex].Kd * Light[i].Ip * AbsDot_Multi(normalVector, lightVector);
//				diffuse += ASCModel[objectIndex].Kd * AbsDot_Multi(normalVector, lightVector);
//
//				//float halfWayVector[3];
//				//// halfWayVector = lightVector + viewVector
//				//halfWayVector[0] = lightVector[0] + (EyeX - ASCModel[objectIndex].vertex[pointIndex][0]);
//				//halfWayVector[1] = lightVector[1] + (EyeY - ASCModel[objectIndex].vertex[pointIndex][1]);
//				//halfWayVector[2] = lightVector[2] + (EyeZ - ASCModel[objectIndex].vertex[pointIndex][2]);
//				//UnitizeVector(halfWayVector);
//				//float specular_last = pow(AbsDot_Multi(halfWayVector, normalVector), ASCModel[objectIndex].N);
//				float specular_last = pow(AbsDot_Multi(reflectVector, viewVector), ASCModel[objectIndex].N);
//				//specular += fatt * ASCModel[objectIndex].Ks * Light[i].Ip * specular_last;
//				specular += ASCModel[objectIndex].Ks * specular_last;
//			}
//		}
//		diffuse *= ASCModel[objectIndex].B;
//	}
//
//	sumColor = ambient + diffuse + specular;
//	/*if(sumColor > 1)
//		return 1.0;
//	else if(sumColor < 0)
//		return 0;
//	else
//		return sumColor;*/
//	return sumColor;
//}
float getColor(int objectIndex, int faceIndex, int pointIndex, char whichColor){
	// 精简版（其实就是参数不全）
	//cout << objectIndex << " " << faceIndex << " " << pointIndex << endl;
	float sumColor, ambient, diffuse, specular;
	ambient = ambient_Ka;

	diffuse = 0;
	specular = 0;

	float normalVector[3];
	getNormalVector(normalVector, objectIndex, faceIndex);
	UnitizeVector(normalVector);

	for(int i = 0; i < MAX_LIGHT; i++){
		if(Light[i].enable){
			float lightVector[3];
			lightVector[0] = Light[i].X - ASCModel[objectIndex].vertex[pointIndex][0];
			lightVector[1] = Light[i].Y - ASCModel[objectIndex].vertex[pointIndex][1];
			lightVector[2] = Light[i].Z - ASCModel[objectIndex].vertex[pointIndex][2];
			UnitizeVector(lightVector);
			float NdotL = AbsDot_Multi(normalVector, lightVector);
			float reflectVector[3];
			reflectVector[0] = 2 * NdotL * normalVector[0] - lightVector[0];
			reflectVector[1] = 2 * NdotL * normalVector[1] - lightVector[1];
			reflectVector[2] = 2 * NdotL * normalVector[2] - lightVector[2];
			UnitizeVector(reflectVector);
			float viewVector[3];
			viewVector[0] = EyeX - ASCModel[objectIndex].vertex[pointIndex][0];
			viewVector[1] = EyeY - ASCModel[objectIndex].vertex[pointIndex][1];
			viewVector[2] = EyeZ - ASCModel[objectIndex].vertex[pointIndex][2];
			UnitizeVector(viewVector);
			diffuse += ASCModel[objectIndex].Kd * AbsDot_Multi(normalVector, lightVector);

			float specular_last = pow(AbsDot_Multi(reflectVector, viewVector), ASCModel[objectIndex].N);
			specular += ASCModel[objectIndex].Ks * specular_last;
		}
	}

	if(whichColor == 'r')
		sumColor = (ambient + diffuse) * ASCModel[objectIndex].R + specular;
	else if(whichColor == 'g')
		sumColor = (ambient + diffuse) * ASCModel[objectIndex].G + specular;
	else
		sumColor = (ambient + diffuse) * ASCModel[objectIndex].B + specular;

	return sumColor;
}

// Get the normal vector of a face of an object
void getNormalVector(float* destination, int objectIndex, int faceIndex){
	float point1[3];
	float point2[3];
	float point3[3];
	float vector1[3];
	float vector2[3];
	for(int i = 0; i < 3; i++){
		point1[i] = ASCModel[objectIndex].vertex[ASCModel[objectIndex].face[faceIndex][1] - 1][i];
		point2[i] = ASCModel[objectIndex].vertex[ASCModel[objectIndex].face[faceIndex][2] - 1][i];
		point3[i] = ASCModel[objectIndex].vertex[ASCModel[objectIndex].face[faceIndex][3] - 1][i];
		vector1[i] = point2[i] - point1[i];
		vector2[i] = point3[i] - point1[i];
	}
	Cross_Multi(destination, vector1, vector2);
}

// Return the abs value of Multiplication Dot for 3-dimensionality
float AbsDot_Multi(float a[], float b[]){
	float sum = 0;
	for(int i = 0; i < 3; i++){
		sum += a[i] * b[i];
	}
	//return sum;
	return (sum>0) ? sum : -sum; // Maybe Wrong
	//return (sum>0) ? sum : 0; // Maybe Wrong
}

// Judge a dot is on the line or not
bool is_onLine(int x, int y, int x1, int y1, int x2, int y2){
	int lineWidth = 10;
	int ans = (x - x1)*(y2 - y1) - (x2 - x1)*(y - y1);
	if(ans < lineWidth && ans > -lineWidth)
		return true;
	else
		return false;
}

// Sort Result : 0 for top, 1 for left, 2 for right
void sortColorPointVector(vector<PointWithColor>& colorPointVector){
	if(colorPointVector[1].y > colorPointVector[0].y){
		swap(colorPointVector[0], colorPointVector[1]);
	}
	if(colorPointVector[1].y == colorPointVector[0].y && colorPointVector[1].x < colorPointVector[0].x){
		swap(colorPointVector[0], colorPointVector[1]);
	}
	if(colorPointVector[2].y > colorPointVector[0].y){
		swap(colorPointVector[0], colorPointVector[2]);
	}
	if(colorPointVector[2].y == colorPointVector[0].y && colorPointVector[2].x < colorPointVector[0].x){
		swap(colorPointVector[0], colorPointVector[2]);
	}
	if(colorPointVector[2].x < colorPointVector[1].x){
		swap(colorPointVector[1], colorPointVector[2]);
	}
	// Fix
	if(colorPointVector[1].y == colorPointVector[0].y){
		colorPointVector[1].y--;
	}
	if(colorPointVector[2].y == colorPointVector[0].y){
		colorPointVector[2].y--;
	}
	return;
}

// Print some formation and Set the parameter
void initial(){
	Buffer_struct infBuffer(INF_FAR, background_r, background_g, background_b);
	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			Buffer[i][j] = infBuffer;
		}
	}
}

// Something wants TA knows
void wordsToTA(){
	cout << "输出比较慢，因为输出了中间过程Flat Shading" << endl;
	cout << "对比前后变化可以看出用了Gouraud Shading的方法" << endl;
	//cout << "用了Gouraud Shading的方法" << endl;
	cout << endl;
}

#pragma endregion

// Main
void main(int argc, char** argv) {
	int winSizeX, winSizeY;

	//Set the programme parameter
	Inputfile = (argc >= 2) ? (string(argv[1])) : "Hw4D.in";
	//Inputfile = (argc >= 2) ? (string(argv[1])) : "Hw4E.in";
	//Inputfile = (argc >= 2) ? (string(argv[1])) : "Hw4F.in";
	//Inputfile = (argc >= 2) ? (string(argv[1])) : "mytest.in";
	/*width = winSizeX = (argc >= 3) ? (atoi(argv[2])) : 800;
	height = winSizeY = (argc >= 4) ? (atoi(argv[3])) : 600;*/
	fin.open(Inputfile);
	if(fin.is_open()){
		cout << "open the file successfully" << endl;
	}
	else{
		cout << "Can't not open the file" << endl;
		IsExit = true;
		return;
	}
	if(!fin.eof()){
		fin >> winSizeX >> winSizeY;
		width = winSizeX;
		height = winSizeY;
	}
	//initial();

	// initialize OpenGL utility toolkit (glut)
	glutInit(&argc, argv);

	// single disply and RGB color mapping
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB); // set display mode
	glutInitWindowSize(winSizeX, winSizeY);      // set window size
	glutInitWindowPosition(500, 100);                // set window position on screen
	glutCreateWindow("Lab4 Window");       // set window title

	// set up the mouse and keyboard callback functions
	//glutKeyboardFunc(myKeyboard); // register the keyboard action function
	//glutMouseFunc(Mymouse);

	// displayFunc is called whenever there is a need to redisplay the window,
	// e.g., when the window is exposed from under another window or when the window is de-iconified
	glutDisplayFunc(displayFunc); // register the redraw function

	// set background color
	glClearColor(background_r, background_g, background_b, alpha);     // set the background to white
	glClear(GL_COLOR_BUFFER_BIT); // clear the buffer

	// misc setup
	glMatrixMode(GL_PROJECTION);  // setup coordinate system
	glLoadIdentity();
	gluOrtho2D(0, winSizeX, 0, winSizeY);
	glShadeModel(GL_FLAT);
	glFlush();
	glutMainLoop();
}
```

### 测试文件

测试文件用到了的asc文件为：
- teapot.asc
- skull.asc
- grid4x4.asc
- cube.asc

```
# Hw4D.in
# ##################
600 600

ambient 0.4

object teapot.asc 1.0 0.0 0.0 0.4  0.6  30

observer 10 10 10 0 0 0 0 .1 1000 15

background 0.2 0.5 0.7

light 1 1.0 -2.0 5.0 10.0

light 2 .7 0.0 10.0 0.0

light 3 .6 10.0 10.0 10.0


display

end
# ##################

# Hw4E.in
# ##################
600 600

ambient 0.4

background 0.2 0.3 0.4

observer 0.0 0.0 2 0 0 0 0 .1 1000 40

light 1 0.8 0.0 5.0 5.0


# SKULL

reset
object skull.asc 1.0 0.0 0.0 0.7  0.3  5

# EYE BALLS

reset
scale 0.2 0.2 0.2
translate 0.26 0.08 .28
object cube.asc 0.9 0.9 0.9 0.9 0.1 1

reset
scale 0.2 0.2 0.2
translate -0.26 0.08 .28
object cube.asc 1.0 1.0 1.0 0.9 0.1 1

# PUPILS

reset
scale 0.05 0.05 0.05
translate 0.26 0.08 .46
object cube.asc 0.5 0.5 0.0 0.7  0.3  5

reset
scale 0.05 0.05 0.05
translate -0.26 0.08 .46
object cube.asc 0.5 0.5 0.0 0.7  0.3  5

display


end
# ##################

# Hw4F.in
# ##################
600 600

ambient 0.4

scale 5.0 0.25 0.25
object cube.asc 0.0 1.0 0.0 0.8  0.2  1

reset
scale 0.25 5.0 0.25
object cube.asc 0.0 1.0 0.0 0.8  0.2  1

reset
scale 0.25 0.25 5.0 
object cube.asc 0.0 1.0 0.0 0.8  0.2  1

reset
rotate 180.0 0.0 0.0
translate -1.0 0.0 -1.0
object Grid4x4.asc 1.0 0.0 0.0 0.8  0.2  1

translate 2.0 0.0 0.0
object Grid4x4.asc 1.0 0.0 0.0 0.8  0.2  1

translate 0.0 0.0 2.0
object Grid4x4.asc 1.0 0.0 0.0 0.8  0.2  1

translate -2.0 0.0 0.0
object Grid4x4.asc 1.0 0.0 0.0 0.8  0.2  1

observer 10.0 10.0 10.0 0.0 0.0 0.0 0 .1 1000 10

light 1 0.8 0.0 10.0 0.0

display

end
# ##################
```

### 批量测试文件

命名方式如同上一篇所示，cmd大法

```
3DCG_hw4_quick.exe Hw4D.in

3DCG_hw4_quick.exe Hw4E.in

3DCG_hw4_quick.exe Hw4F.in
```

### 彩蛋
网上找到的三维图像渲染的极高级完成版本demo
只有演示没有代码
称之为 [这完美的茶壶](http://pan.baidu.com/s/1o6moeeu)