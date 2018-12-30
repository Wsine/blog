# C++实现数字媒体二维图像变换

### 必备环境
- glut.h 头文件
- glut32.lib 对象文件库
- glut32.dll 动态连接库

### 程序说明
C++实现了用glut画正方形，画三角形的功能。并附带放大缩小，旋转，平移的功能。同时实现了填充颜色这个功能。

### 操作说明
#### 重要说明
**define CLIP_METHOD 0**
该参数为0时，切割方式为 多边形 切割（默认）
该参数为1时，切割方式为 点 切割
**define FILL_ENABLE !CLIP_METHOD&&1**
该参数为1并且启用多边形切割时，启用填充对象（默认）
该参数为0时，不填充对象，仅描绘边界 
**define READ_MULTI_FILE 0**
该参数为0时，读取文件为单文件，窗口可移动
该参数为1时，读取文件为多文件，在任意键盘控制确认显示下一个，窗口可移动（默认）

#### 指令说明
- reset ：把变换矩阵重置为单位矩阵
- scale ：把变换矩阵进行相应的放大缩小
- rotate ： 把变换矩阵进行相应的旋转
- translate ： 把变换矩阵进行相应的平移
- square ：根据变换矩阵创建一个矩形对象
- triangle ：根据变换矩阵创建一个三角形对象
- clearData ：清空所有的对象数据
- clearScreen ：清空屏幕
- end ： 结束程序

### 函数说明

**void initial()**
输出程序信息，并提示如何输入

**void scale(float sx, float sy)**
改变变换矩阵进行相应放大缩小

**void rotate(float degree)**
改变变换矩阵进行相应的角度旋转

**void translate(float tx, float ty)**
改变变换矩阵进行相应的平移变换

**void reset()**
重置变换矩阵为单位矩阵

**void square()**
根据变换矩阵创建一个矩形对象并存储

**void triangle()**
根据变换矩阵创建一个三角形对象并存储

**void view(float wxl, float wxr, float wyb, float wyt, float vxl, float vxr, float vyb, float vyt)**
根据参数把对象坐标系的区域进行投影到视图坐标系下，同时把裁剪非可见区域，并对投影区域进行颜色填充

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

**void update_CurMatrix(float resource[][CTM_SIZE], float destination[][CTM_SIZE])**
更新变换矩阵

**void update_WVM(int sx, int sy, int tx, int ty)**
更新投影函数

**void AddtoSquareStore(float matrix[][CTM_SIZE])**
增加一个矩形对象到仓库中

**void AddtoTriangleStore(float matrix[][CTM_SIZE])**
增加一个三角形到仓库中

**void GetFromSquareStore(int index, float destination[][CTM_SIZE])**
从仓库中获取一个矩形对象

**void GetFromTriangleStore(int index, float destination[][CTM_SIZE])**
从仓库中获取一个三角形对象

**void DrawSquareDirect(int matrix[][CTM_SIZE])**
直接绘制出仓库中最新的矩形对象

**void DrawSquareByindex(int index)**
根据序号绘制出仓库中指定的矩形对象

**void DrawTriangleDirect(int matrix[][CTM_SIZE])**
直接绘制出仓库中最新的三角形对象

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

**void DrawFrame()**
绘制投影区域的边框

**bool DotToDraw(const int& x, const int& y)**
决定这个点是否绘制

**void redraw()**
重绘整个视窗，恢复显示的时候调用

**void FillPolygon(int PointVectorSize, string object)**
填充函数，根据object决定填充颜色。方式是通过遍历一个多边形存储的边，以y轴从上往下扫描边的两个端点，然后水平绘制一条直线。颜色的选择是从颜色库中轮询选择。

**void DrawHorizontalLine(int x0, int x1, int y)**
绘制一条水平直线

**template<class T> void printMatrix(T* matrix, int row, int col, string str)**
打印矩阵函数，debug时使用

**vector( pair(int, int) ) ClipPolygon(const vector( pair(int, int) )& PointVector, string boundary)**
多边形剪切函数，boundary指定剪切方向。容器中存储一个多边形的各个点，如果需要被裁剪，这容器中的点会变成裁剪边界的点。

**bool cmp_pair(const pair(int, int)& a, const pair(int, int)& b)**
比较函数，对点进行排序时调用

**void myKeyboard(unsigned char key, int x, int y)**
键盘回调函数

### 运行效果

![F](http://images0.cnblogs.com/blog2015/701997/201507/111756140966873.png)
![A](http://images0.cnblogs.com/blog2015/701997/201507/111756281432449.png)
![B](http://images0.cnblogs.com/blog2015/701997/201507/111756373461371.png)
![C](http://images0.cnblogs.com/blog2015/701997/201507/111756429242166.png)
![D](http://images0.cnblogs.com/blog2015/701997/201507/111756503777888.png)
![E](http://images0.cnblogs.com/blog2015/701997/201507/111756562055141.png)

### 完整代码

```
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <cmath>
#include <string>
#include <vector>
#include <algorithm>
#include "glut.h"
using namespace std;

#pragma region Data

#define CLIP_METHOD 0
// 0 for compile to clip polygon
// 1 for compile to clip dot
#define FILL_ENABLE !CLIP_METHOD&&1
// only enalbe it when CLIP_METHOD is 0 
#define READ_MULTI_FILE 1

#define CTM_SIZE 3
#define MAX_SQUARE 20
#define MAX_TRIANGLE 20
#define MAX_LINE 200
// MAX_LINE >= MAX_SQUARE * 4 + MAX_TRIANGLE * 3 + MAX_VIEW_IN_FIN * 4
#define PI 3.14159265
//const float PI = acos(-1);
#define MAX_COLOR 8
#define MAX_FILL_LINE 1000
#define MAX_FILE 6

struct line_structure{
	int x0, x1, y0, y1;
};

struct line_data{
	int x, y;
	line_data* next;
	line_data(int _x = -1, int _y = -1){
		x = _x;
		y = _y;
		next = NULL;
	}
};

struct point{
	float x, y;
	float z;
};

struct square_struct{
	point right_up;
	point left_up;
	point left_down;
	point right_down;
}SquareStore[MAX_SQUARE];

struct triangle_struct{
	point first;
	point second;
	point third;
}TriangleStore[MAX_TRIANGLE];

struct fill_line_struct{
	int x0, x1, y;
	fill_line_struct(int _x0, int _x1, int _y){
		x0 = _x0;
		x1 = _x1;
		y = _y;
	}
};

struct frame_struct{
	int vxl, vxr, vyb, vyt;
	frame_struct(int _vxl, int _vxr, int _vyb, int _vyt){
		vxl = _vxl;
		vxr = _vxr;
		vyb = _vyb;
		vyt = _vyt;
	}
};
vector<frame_struct> frame_store;

struct color_struct{
	float r, g, b;
	color_struct(float _r = 0, float _g = 0, float _b = 0){
		r = _r;
		g = _g;
		b = _b;
	}
};
const color_struct Color[MAX_COLOR] = { { 0.0, 0.0, 0.0 },	// black for default 
								  { 0.0, 0.0, 1.0 },	// blue for triangle
								  { 1.0, 0.0, 0.0 },	// red for square
								  { 1.0, 0.5, 0.0 },	// orange for square 
								  { 1.0, 1.0, 0.0 },	// yellow for square
								  { 0.0, 1.0, 0.0 },	// green for square
								  { 0.0, 1.0, 1.0 },	// light blue for square 
								  { 1.0, 0.0, 1.0 } };	// purple for square
int color_index = 2;

string file_list[MAX_FILE] = { "hw2E.in", "hw2B.in", "hw2A.in", "hw2D.in", "hw2F.in", "hw2C.in" };
int cur_file = 0;

int height, width;
int Frame[4];
/*
 * Frame[0] = vxl;
 * Frame[1] = vxr;
 * Frame[2] = vyb;
 * Frame[3] = vyt;
 */
float current_matrix[CTM_SIZE][CTM_SIZE];
int WVM[CTM_SIZE][CTM_SIZE] = { { 15, 0, 100 }, { 0, 15, 100 }, { 0, 0, 1 } };

line_structure line[MAX_LINE];
line_data line_start[MAX_LINE];
int line_color[MAX_LINE];
line_data* lcp;
line_data* temp;
vector<fill_line_struct> fill_line;
vector<int> fill_line_color;

int num_square = 0;
int num_triangle = 0;
int num_line = 0;
int num_fill_line = 0;

const float default_r = 255.0;
const float default_g = 255.0;
const float default_b = 255.0;
float r = 1.0;
float g = 0.0;
float b = 0.0;
float alpha = 0.0;

bool IsExit = false;

enum ScanFlag{ odd, even };

#pragma endregion

#pragma region FunctionDefinition

void initial();
void scale(float sx, float sy);
void rotate(float degree);
void translate(float tx, float ty);
void reset();
void square();
void triangle();
void view(float wxl, float wxr, float wyb, float wyt, float vxl, float vxr, float vyb, float vyt);
void clearData();
void clearScreen();
void displayFunc(void);
void ReadInput(bool& IsExit);
void Matrix_Multi_Matrix(float a[][CTM_SIZE], float b[][CTM_SIZE], float c[][CTM_SIZE]);
void update_CurMatrix(float resource[][CTM_SIZE], float destination[][CTM_SIZE]);
void update_WVM(int sx, int sy, int tx, int ty);
void AddtoSquareStore(float matrix[][CTM_SIZE]);
void AddtoTriangleStore(float matrix[][CTM_SIZE]);
void GetFromSquareStore(int index, float destination[][CTM_SIZE]);
void GetFromTriangleStore(int index, float destination[][CTM_SIZE]);
void DrawSquareDirect(int matrix[][CTM_SIZE]);
void DrawSquareByindex(int index);
void DrawTriangleDirect(int matrix[][CTM_SIZE]);
void drawDot(int x, int y);
void DrawLine(int x0, int x1, int y0, int y1);
void drawLine0(int x0, int x1, int y0, int y1);
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine2(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine3(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine4(int x0, int x1, int y0, int y1, bool xy_interchange);
void ReadFile(bool& IsExit);
void DrawFrame();
bool DotToDraw(const int& x, const int& y);
void redraw();
vector<pair<int, int>> ClipPolygon(const vector<pair<int, int>>& PointVector, string boundary);
void FillPolygon(int PointVectorSize, string object);
bool cmp_pair(const pair<int, int>& a, const pair<int, int>& b);
void DrawHorizontalLine(int x0, int x1, int y);
template<class T> void printMatrix(T* matrix, int row, int col, string str);
void myKeyboard(unsigned char key, int x, int y);

#pragma endregion

#pragma region FunctionImplement

template<class T>
void printMatrix(T* matrix, int row, int col, string str){
	cout << endl;
	cout << str << " : " << endl;
	for (int i = 0; i < row; i++){
		cout << "\t[ ";
		for (int j = 0; j < col; j++){
			cout << matrix[i][j] << ", ";
		}
		cout << " ]" << endl;
	}
}

// Set current transform matrix to Identity
void reset(){
	for (int i = 0; i < CTM_SIZE; i++){
		for (int j = 0; j < CTM_SIZE; j++){
			if (i == j)
				current_matrix[i][j] = 1.0;
			else
				current_matrix[i][j] = 0;
		}
	}
	printMatrix(current_matrix, 3, 3, "current_matrix");
}

// Multiply current matrix by scaling matrix
void scale(float sx, float sy){
	float scaling_matrix[CTM_SIZE][CTM_SIZE]
		= { { sx, 0, 0 },
			{ 0, sy, 0 },
			{ 0, 0, 1  } };

	float new_matrix[CTM_SIZE][CTM_SIZE];

	Matrix_Multi_Matrix(scaling_matrix, current_matrix, new_matrix);

	update_CurMatrix(new_matrix, current_matrix);

	printMatrix(current_matrix, 3, 3, "current_matrix");

}

// Multiply current matrix by rotation matrix
void rotate(float degree){
	float rad = degree * PI / 180.0;
	float rotation_matrix[CTM_SIZE][CTM_SIZE]
		= { { cos(rad), -sin(rad), 0 },
			{ sin(rad), cos(rad),  0 },
			{ 0,		0,		   1 } };

	//printMatrix(rotation_matrix, 3, 3, "rotation_matrix");

	float new_matrix[CTM_SIZE][CTM_SIZE];

	Matrix_Multi_Matrix(rotation_matrix, current_matrix, new_matrix);

	update_CurMatrix(new_matrix, current_matrix);
	
	printMatrix(current_matrix, 3, 3, "current_matrix");

}

// Multiply current matrix by translation matrix
void translate(float tx, float ty){
	float translate_matrix[CTM_SIZE][CTM_SIZE]
		= { { 1, 0, tx },
			{ 0, 1, ty },
			{ 0, 0, 1  } };

	float new_matrix[CTM_SIZE][CTM_SIZE];

	Matrix_Multi_Matrix(translate_matrix, current_matrix, new_matrix);

	update_CurMatrix(new_matrix, current_matrix);

	printMatrix(current_matrix, 3, 3, "current_matrix");

}

// Two 3 * 3 Matrixs Multiplication
void Matrix_Multi_Matrix(float a[][CTM_SIZE], float b[][CTM_SIZE], float c[][CTM_SIZE]){
	float multi_sum = 0;
	for (int i = 0; i < CTM_SIZE; i++){
		for (int j = 0; j < CTM_SIZE; j++){
			multi_sum = 0;
			for (int k = 0; k < CTM_SIZE; k++){
				multi_sum += b[k][j] * a[i][k];
			}
			c[i][j] = multi_sum;
		}
	}
}

// update the current_matrix
void update_CurMatrix(float resource[][CTM_SIZE], float destination[][CTM_SIZE]){
	for (int i = 0; i < CTM_SIZE; i++){
		for (int j = 0; j < CTM_SIZE; j++){
			destination[i][j] = resource[i][j];
		}
	}
}

// Create a square and save it
void square(){
	float org_square[4][CTM_SIZE]
		= { { 1,  1,  1 },
			{ -1, 1,  1 },
			{ -1, -1, 1 },
			{ 1,  -1, 1 } };

	float WorldCoord_square[4][CTM_SIZE];

	float multi_sum = 0;
	for (int i = 0; i < 4; i++){
		for (int j = 0; j < CTM_SIZE; j++){
			multi_sum = 0;
			for (int k = 0; k < CTM_SIZE; k++){
				multi_sum += org_square[i][k] * current_matrix[j][k];
			}
			WorldCoord_square[i][j] = multi_sum;
		}
	}

	AddtoSquareStore(WorldCoord_square);
	num_square++;

	printMatrix(WorldCoord_square, 4, 3, "WorldCoord_square");

}

// Add a new square to SquareStore
void AddtoSquareStore(float matrix[][CTM_SIZE]){
	SquareStore[num_square].right_up.x = matrix[0][0];
	SquareStore[num_square].right_up.y = matrix[0][1];
	SquareStore[num_square].right_up.z = matrix[0][2];

	SquareStore[num_square].left_up.x = matrix[1][0];
	SquareStore[num_square].left_up.y = matrix[1][1];
	SquareStore[num_square].left_up.z = matrix[1][2];

	SquareStore[num_square].left_down.x = matrix[2][0];
	SquareStore[num_square].left_down.y = matrix[2][1];
	SquareStore[num_square].left_down.z = matrix[2][2];

	SquareStore[num_square].right_down.x = matrix[3][0];
	SquareStore[num_square].right_down.y = matrix[3][1];
	SquareStore[num_square].right_down.z = matrix[3][2];

}

// Show all objects on the screen
void view(float wxl, float wxr, float wyb, float wyt, float vxl, float vxr, float vyb, float vyt){
	int scaling_x = (int)((vxr - vxl) / (wxr - wxl));
	int scaling_y = (int)((vyt - vyb) / (wyt - wyb));
	int shift_x = (int)(vxl - scaling_x * wxl);
	int shift_y = (int)(vyb - scaling_y * wyb);
	update_WVM(scaling_x, scaling_y, shift_x, shift_y);

	printMatrix(WVM, 3, 3, "WVM");

	float WorldCoord_matrix[4][CTM_SIZE];
	int ScreenCoord_matrix[4][CTM_SIZE];

	//Set Frame
	Frame[0] = (int)vxl;
	Frame[1] = (int)vxr;
	Frame[2] = (int)vyb;
	Frame[3] = (int)vyt;
	frame_store.push_back(frame_struct(Frame[0], Frame[1], Frame[2], Frame[3]));
	
	//Draw Square
	r = 1.0;	g = 0.0;	b = 0.0;
	float multi_sum = 0;
	int count = 0;
	while (count < num_square){
		GetFromSquareStore(count, WorldCoord_matrix);
		printMatrix(WorldCoord_matrix, 4, 3, "WorldCoord_matrix");
		for (int i = 0; i < 4; i++){
			for (int j = 0; j < CTM_SIZE; j++){
				multi_sum = 0;
				for (int k = 0; k < CTM_SIZE; k++){
					multi_sum += WorldCoord_matrix[i][k] * WVM[j][k];
				}
				ScreenCoord_matrix[i][j] = (int)multi_sum;
			}
		}
		printMatrix(ScreenCoord_matrix, 4, 3, "ScreenCoord_matrix");
		DrawSquareDirect(ScreenCoord_matrix);
		//void DrawSquareByindex(count);
		count++;
	}
	
	//Draw Triangle
	r = 0.0;	g = 0.0;	b = 1.0;
	count = 0;
	while (count < num_triangle){
		GetFromTriangleStore(count, WorldCoord_matrix);
		printMatrix(WorldCoord_matrix, 3, 3, "WorldCoord_matrix");
		for (int i = 0; i < 3; i++){
			for (int j = 0; j < CTM_SIZE; j++){
				multi_sum = 0;
				for (int k = 0; k < CTM_SIZE; k++){
					multi_sum += WorldCoord_matrix[i][k] * WVM[j][k];
				}
				ScreenCoord_matrix[i][j] = (int)multi_sum;
			}
		}
		printMatrix(ScreenCoord_matrix, 3, 3, "ScreenCoord_matrix");
		DrawTriangleDirect(ScreenCoord_matrix);
		count++;
	}

	// Draw Frame
	r = 0.0;	g = 0.0;	b = 0.0;
	DrawFrame();

	return;
}

// Draw a frame
void DrawFrame(){
	temp = &line_start[num_line];
	line_color[num_line] = 0;
	DrawLine(Frame[0], Frame[1], Frame[2], Frame[2]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 0;
	DrawLine(Frame[1], Frame[1], Frame[2], Frame[3]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 0;
	DrawLine(Frame[1], Frame[0], Frame[3], Frame[3]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 0;
	DrawLine(Frame[0], Frame[0], Frame[3], Frame[2]);
	num_line++;
}

// Draw a square
void DrawSquareDirect(int matrix[][CTM_SIZE]){
#if CLIP_METHOD
	temp = &line_start[num_line];
	line_color[num_line] = 2;
	DrawLine(matrix[1][0], matrix[0][0], matrix[1][1], matrix[0][1]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 2;
	DrawLine(matrix[0][0], matrix[3][0], matrix[0][1], matrix[3][1]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 2;
	DrawLine(matrix[3][0], matrix[2][0], matrix[3][1], matrix[2][1]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 2;
	DrawLine(matrix[2][0], matrix[1][0], matrix[2][1], matrix[1][1]);
	num_line++;
#else
	vector<pair<int, int>> PointVector;
	PointVector.push_back(make_pair(matrix[1][0], matrix[1][1]));
	PointVector.push_back(make_pair(matrix[0][0], matrix[0][1]));
	PointVector.push_back(make_pair(matrix[3][0], matrix[3][1]));
	PointVector.push_back(make_pair(matrix[2][0], matrix[2][1]));
	PointVector.push_back(make_pair(matrix[1][0], matrix[1][1]));
	
	PointVector = ClipPolygon(PointVector, "left");
	PointVector = ClipPolygon(PointVector, "bottom");
	PointVector = ClipPolygon(PointVector, "right");
	PointVector = ClipPolygon(PointVector, "top");

	for(int i = 1; i < PointVector.size(); i++){
		temp = &line_start[num_line];
		line_color[num_line] = 2;
		DrawLine(PointVector[i - 1].first, PointVector[i].first, PointVector[i - 1].second, PointVector[i].second);
		num_line++;
	}
#if FILL_ENABLE
	FillPolygon(PointVector.size(), "square");
#endif
#endif
}

// Clip the Polygon by one side
vector<pair<int, int>> ClipPolygon(const vector<pair<int, int>>& PointVector, string boundary){
	pair<int, int> PointS, PointP;
	vector<pair<int, int>> NewPointVector;
	
	// 1-st pass
	if(boundary == "left"){
		for(int i = 1; i < PointVector.size(); i++){
			PointS = PointVector[i - 1];
			PointP = PointVector[i];
			// Rule 1
			if(PointS.first >= Frame[0] && PointP.first >= Frame[0]){
				NewPointVector.push_back(PointP);
			}
			// Rule 2
			else if(PointS.first >= Frame[0] && PointP.first < Frame[0]){
				int left_y = (int)((PointS.second - PointP.second)*1.0 / (PointS.first - PointP.first)*(Frame[0] - PointP.first) + PointP.second);
				NewPointVector.push_back(make_pair(Frame[0], left_y));
			}
			// Rule 4
			else if(PointS.first < Frame[0] && PointP.first >= Frame[0]){
				int left_y = (int)((PointS.second - PointP.second)*1.0 / (PointS.first - PointP.first)*(Frame[0] - PointP.first) + PointP.second);
				NewPointVector.push_back(make_pair(Frame[0], left_y));
				NewPointVector.push_back(PointP);
			}
		}
		if(!NewPointVector.empty())
			NewPointVector.push_back(NewPointVector[0]);
	}
	// 2-nd pass
	else if(boundary == "bottom"){
		for(int i = 1; i < PointVector.size(); i++){
			PointS = PointVector[i - 1];
			PointP = PointVector[i];
			// Rule 1
			if(PointS.second >= Frame[2] && PointP.second >= Frame[2]){
				NewPointVector.push_back(PointP);
			}
			// Rule 2
			else if(PointS.second >= Frame[2] && PointP.second < Frame[2]){
				int bottom_x = (int)((PointS.first - PointP.first)*1.0 / (PointS.second - PointP.second)*(Frame[2] - PointP.second) + PointP.first);
				NewPointVector.push_back(make_pair(bottom_x, Frame[2]));
			}
			// Rule 4
			else if(PointS.second < Frame[2] && PointP.second >= Frame[2]){
				int bottom_x = (int)((PointS.first - PointP.first)*1.0 / (PointS.second - PointP.second)*(Frame[2] - PointP.second) + PointP.first);
				NewPointVector.push_back(make_pair(bottom_x, Frame[2]));
				NewPointVector.push_back(PointP);
			}
		}
		if(!NewPointVector.empty())
			NewPointVector.push_back(NewPointVector[0]);
	}
	// 3-rd pass
	else if(boundary == "right"){
		for(int i = 1; i < PointVector.size(); i++){
			PointS = PointVector[i - 1];
			PointP = PointVector[i];
			// Rule 1
			if(PointS.first <= Frame[1] && PointP.first <= Frame[1]){
				NewPointVector.push_back(PointP);
			}
			// Rule 2
			else if(PointS.first <= Frame[1] && PointP.first > Frame[1]){
				int right_y = (int)((PointS.second - PointP.second)*1.0 / (PointS.first - PointP.first)*(Frame[1] - PointP.first) + PointP.second);
				NewPointVector.push_back(make_pair(Frame[1], right_y));
			}
			// Rule 4
			else if(PointS.first > Frame[1] && PointP.first <= Frame[1]){
				int right_y = (int)((PointS.second - PointP.second)*1.0 / (PointS.first - PointP.first)*(Frame[1] - PointP.first) + PointP.second);
				NewPointVector.push_back(make_pair(Frame[1], right_y));
				NewPointVector.push_back(PointP);
			}
		}
		if(!NewPointVector.empty())
			NewPointVector.push_back(NewPointVector[0]);
	}
	// 4-th pass
	else if(boundary == "top"){
		for(int i = 1; i < PointVector.size(); i++){
			PointS = PointVector[i - 1];
			PointP = PointVector[i];
			// Rule 1
			if(PointS.second <= Frame[3] && PointP.second <= Frame[3]){
				NewPointVector.push_back(PointP);
			}
			// Rule 2
			else if(PointS.second <= Frame[3] && PointP.second > Frame[3]){
				int top_x = (int)((PointS.first - PointP.first)*1.0 / (PointS.second - PointP.second)*(Frame[3] - PointP.second) + PointP.first);
				NewPointVector.push_back(make_pair(top_x, Frame[3]));
			}
			// Rule 4
			else if(PointS.second > Frame[3] && PointP.second <= Frame[3]){
				int top_x = (int)((PointS.first - PointP.first)*1.0 / (PointS.second - PointP.second)*(Frame[3] - PointP.second) + PointP.first);
				NewPointVector.push_back(make_pair(top_x, Frame[3]));
				NewPointVector.push_back(PointP);
			}
		}
		if(!NewPointVector.empty())
			NewPointVector.push_back(NewPointVector[0]);
	}

	return NewPointVector;
}

// Draw a square
void DrawSquareByindex(int index){
	temp = &line_start[num_line];
	DrawLine(SquareStore[index].left_up.x, SquareStore[index].right_up.x, 
			 SquareStore[index].left_up.y, SquareStore[index].right_up.y);
	num_line++;

	temp = &line_start[num_line];
	DrawLine(SquareStore[index].right_up.x, SquareStore[index].right_down.x,
			SquareStore[index].right_up.y, SquareStore[index].right_down.y);
	num_line++;

	temp = &line_start[num_line];
	DrawLine(SquareStore[index].right_down.x, SquareStore[index].left_down.x,
			SquareStore[index].right_down.y, SquareStore[index].left_down.y);
	num_line++;

	temp = &line_start[num_line];
	DrawLine(SquareStore[index].left_down.x, SquareStore[index].left_up.x,
			SquareStore[index].left_down.y, SquareStore[index].left_up.y);
	num_line++;
}

// Draw a triangle
void DrawTriangleDirect(int matrix[][CTM_SIZE]){
#if CLIP_METHOD
	temp = &line_start[num_line];
	line_color[num_line] = 1;
	DrawLine(matrix[0][0], matrix[1][0], matrix[0][1], matrix[1][1]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 1;
	DrawLine(matrix[1][0], matrix[2][0], matrix[1][1], matrix[2][1]);
	num_line++;

	temp = &line_start[num_line];
	line_color[num_line] = 1;
	DrawLine(matrix[2][0], matrix[0][0], matrix[2][1], matrix[0][1]);
	num_line++;
#else
	vector<pair<int, int>> PointVector;
	PointVector.push_back(make_pair(matrix[0][0], matrix[0][1]));
	PointVector.push_back(make_pair(matrix[1][0], matrix[1][1]));
	PointVector.push_back(make_pair(matrix[2][0], matrix[2][1]));
	PointVector.push_back(make_pair(matrix[0][0], matrix[0][1]));

	PointVector = ClipPolygon(PointVector, "left");
	PointVector = ClipPolygon(PointVector, "bottom");
	PointVector = ClipPolygon(PointVector, "right");
	PointVector = ClipPolygon(PointVector, "top");

	for(int i = 1; i < PointVector.size(); i++){
		temp = &line_start[num_line];
		line_color[num_line] = 1;
		DrawLine(PointVector[i - 1].first, PointVector[i].first, PointVector[i - 1].second, PointVector[i].second);
		num_line++;
	}
#if FILL_ENABLE
	FillPolygon(PointVector.size(), "triangle");
#endif
#endif
}

// Judge wheather to draw dot
bool DotToDraw(const int& x, const int& y){
	if (x >= Frame[0] && x <= Frame[1] && y >= Frame[2] && y <= Frame[3]){
		return true;
	}
	return false;
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
	lcp = temp;
	if (max_dis != 0) {
		for (int i = 0; i < max_dis; ++i) {
			int new_p_x = x0 + i * (x1 - x0) / max_dis;
			int new_p_y = y0 + i * (y1 - y0) / max_dis;
#if CLIP_METHOD
			if (DotToDraw(new_p_x, new_p_y)){
				drawDot(new_p_x, new_p_y);
				lcp->next = new line_data(new_p_x, new_p_y);
				lcp = lcp->next;
			}
#else
			drawDot(new_p_x, new_p_y);
			lcp->next = new line_data(new_p_x, new_p_y);
			lcp = lcp->next;
#endif
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
		drawLine1(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
	}
	else if(dx > 0 && dy >= 0 && abs(dx) >= abs(dy)){
		drawLine2(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
	}
	else if(dx > 0 && dy <= 0 && abs(dx) > abs(dy)){
		drawLine3(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
	}
	else if(dx >= 0 && dy < 0 && abs(dx) <= abs(dy)){
		drawLine4(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
	}
	else if(dx <= 0 && dy < 0 && abs(dx) < abs(dy)){
		drawLine1(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
	}
	else if(dx < 0 && dy <= 0 && abs(dx) >= abs(dy)){
		drawLine2(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
	}
	else if(dx < 0 && dy >= 0 && abs(dx) > abs(dy)){
		drawLine3(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
	}
	else{
		drawLine4(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
	}
	num_line++;
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
	line_start[num_line] = line_data(x, y);
	lcp = &line_start[num_line];
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
	line_start[num_line] = line_data(x, y);
	lcp = &line_start[num_line];
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
	line_start[num_line] = line_data(x, y);
	lcp = &line_start[num_line];
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
	line_start[num_line] = line_data(x, y);
	lcp = &line_start[num_line];
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

// Draw a horizontal line
void DrawHorizontalLine(int x0, int x1, int y){
	for(int x = x0; x <= x1; x++){
		drawDot(x, y);
	}
	glFlush();
	return;
}

// Get matrix from SquareStore
void GetFromSquareStore(int index, float destination[][CTM_SIZE]){
	destination[0][0] = SquareStore[index].right_up.x;
	destination[0][1] = SquareStore[index].right_up.y;
	destination[0][2] = SquareStore[index].right_up.z;

	destination[1][0] = SquareStore[index].left_up.x;
	destination[1][1] = SquareStore[index].left_up.y;
	destination[1][2] = SquareStore[index].left_up.z;

	destination[2][0] = SquareStore[index].left_down.x;
	destination[2][1] = SquareStore[index].left_down.y;
	destination[2][2] = SquareStore[index].left_down.z;

	destination[3][0] = SquareStore[index].right_down.x;
	destination[3][1] = SquareStore[index].right_down.y;
	destination[3][2] = SquareStore[index].right_down.z;
}

// update the WVM matrix
void update_WVM(int sx, int sy, int tx, int ty){
	WVM[0][0] = sx;
	WVM[1][1] = sy;
	WVM[0][2] = tx;
	WVM[1][2] = ty;
	WVM[2][2] = 1;
	WVM[0][1] = WVM[1][0] = WVM[2][0] = WVM[2][1] = 0;
}

// Draw a triangle and Save it
void triangle(){
	float org_triangle[3][CTM_SIZE]
		= { { 0,  1,  1 },
			{ -1, -1, 1 },
			{ 1,  -1, 1 } };

	float WorldCoord_square[3][CTM_SIZE];

	float multi_sum = 0;
	for (int i = 0; i < 3; i++){
		for (int j = 0; j < CTM_SIZE; j++){
			multi_sum = 0;
			for (int k = 0; k < CTM_SIZE; k++){
				multi_sum += org_triangle[i][k] * current_matrix[j][k];
			}
			WorldCoord_square[i][j] = multi_sum;
		}
	}

	AddtoTriangleStore(WorldCoord_square);
	num_triangle++;

	printMatrix(WorldCoord_square, 3, 3, "WorldCoord_square");
}

// Add a new triangle to TriangleStore
void AddtoTriangleStore(float matrix[][CTM_SIZE]){
	TriangleStore[num_triangle].first.x = matrix[0][0];
	TriangleStore[num_triangle].first.y = matrix[0][1];
	TriangleStore[num_triangle].first.z = matrix[0][2];

	TriangleStore[num_triangle].second.x = matrix[1][0];
	TriangleStore[num_triangle].second.y = matrix[1][1];
	TriangleStore[num_triangle].second.z = matrix[1][2];

	TriangleStore[num_triangle].third.x = matrix[2][0];
	TriangleStore[num_triangle].third.y = matrix[2][1];
	TriangleStore[num_triangle].third.z = matrix[2][2];

}

// Get a triangle data from TriangleStore
void GetFromTriangleStore(int index, float destination[][CTM_SIZE]){
	destination[0][0] = TriangleStore[index].first.x;
	destination[0][1] = TriangleStore[index].first.y;
	destination[0][2] = TriangleStore[index].first.z;

	destination[1][0] = TriangleStore[index].second.x;
	destination[1][1] = TriangleStore[index].second.y;
	destination[1][2] = TriangleStore[index].second.z;

	destination[2][0] = TriangleStore[index].third.x;
	destination[2][1] = TriangleStore[index].third.y;
	destination[2][2] = TriangleStore[index].third.z;
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
	num_square = 0;
	num_triangle = 0;
	num_fill_line = 0;
	fill_line.clear();
	fill_line_color.clear();
	frame_store.clear();
	return;
}

// Clear the screen
void clearScreen(){
	glClearColor(default_r, default_g, default_b, alpha);
	glClear(GL_COLOR_BUFFER_BIT);
	glFlush();
}

// Redraw all objects stored 
void redraw(){
	r = 0;		g = 1.0;	b = 1.0;
	int i;
	line_data* rd_line;

	for (i = 0; i < num_line; i++){
		rd_line = &line_start[i];
		r = Color[line_color[i]].r;
		g = Color[line_color[i]].g;
		b = Color[line_color[i]].b;
		while (rd_line != NULL){
			drawDot(rd_line->x, rd_line->y);
			rd_line = rd_line->next;
		}
	}

	for(i = 0; i < fill_line.size(); i++){
		r = Color[fill_line_color[i]].r;
		g = Color[fill_line_color[i]].g;
		b = Color[fill_line_color[i]].b;
		DrawHorizontalLine(fill_line[i].x0, fill_line[i].x1, fill_line[i].y);
	}

	r = 0.0;	g = 0.0;	b = 0.0;
	for(i = 0; i < frame_store.size(); i++){
		DrawLine(frame_store[i].vxl, frame_store[i].vxr, frame_store[i].vyb, frame_store[i].vyb);
		DrawLine(frame_store[i].vxr, frame_store[i].vxr, frame_store[i].vyb, frame_store[i].vyt);
		DrawLine(frame_store[i].vxr, frame_store[i].vxl, frame_store[i].vyt, frame_store[i].vyt);
		DrawLine(frame_store[i].vxl, frame_store[i].vxl, frame_store[i].vyt, frame_store[i].vyb);
	}

	glFlush();
}

// Read the command from std
void ReadInput(bool& IsExit){
	float sx, sy, degree, tx, ty, wxl, wxr, wyb, wyt, vxl, vxr, vyt, vyb;
	string command, comment;
	cin >> command;
	if (command == "scale"){
		cin >> sx;
		cin >> sy;
		scale(sx, sy);
		cout << command << endl;
	}
	else if (command == "rotate"){
		cin >> degree;
		rotate(degree);
		cout << command << endl;
	}
	else if (command == "translate"){
		cin >> tx;
		cin >> ty;
		translate(tx, ty);
		cout << command << endl;
	}
	else if (command == "reset"){
		reset();
		cout << command << endl;
	}
	else if (command == "square"){
		square();
		cout << command << endl;
	}
	else if (command == "triangle"){
		triangle();
		cout << command << endl;
	}
	else if (command == "view"){
		cin >> wxl >> wxr >> wyb >> wyt >> vxl >> vxr >> vyb >> vyt;
		view(wxl, wxr, wyb, wyt, vxl, vxr, vyb, vyt);
		cout << command << endl;
	}
	else if (command == "clearData"){
		clearData();
		cout << command << endl;
	}
	else if (command == "clearScreen"){
		cout << "Screen is cleared" << endl;
		clearScreen();
		cout << command << endl;
	}
	else if (command == "end"){
		IsExit = true;
		cout << command << endl;
		exit(0);
	}
	else if (command == "#"){
		getline(cin, comment);
	}
}

// Read the command from file
void ReadFile(bool& IsExit){
#if READ_MULTI_FILE
	ifstream fin(file_list[cur_file]);
#else
	ifstream fin("myhw2.in");
#endif
	if (fin.is_open()){
		cout << "open the file successfully" << endl;
	}
	float sx, sy, degree, tx, ty, wxl, wxr, wyb, wyt, vxl, vxr, vyt, vyb;
	string command, comment;
	while (!fin.eof()){
		fin >> command;
		if (command == "scale"){
			fin >> sx;
			fin >> sy;
			scale(sx, sy);
			cout << command << endl;
		}
		else if (command == "rotate"){
			fin >> degree;
			rotate(degree);
			cout << command << endl;
		}
		else if (command == "translate"){
			fin >> tx;
			fin >> ty;
			translate(tx, ty);
			cout << command << endl;
		}
		else if (command == "reset"){
			reset();
			cout << command << endl;
		}
		else if (command == "square"){
			square();
			cout << command << endl;
		}
		else if (command == "triangle"){
			triangle();
			cout << command << endl;
		}
		else if (command == "view"){
			fin >> wxl >> wxr >> wyb >> wyt >> vxl >> vxr >> vyb >> vyt;
			view(wxl, wxr, wyb, wyt, vxl, vxr, vyb, vyt);
			cout << command << endl;
		}
		else if (command == "clearData"){
			clearData();
			cout << command << endl;
		}
		else if (command == "clearScreen"){
			cout << "Screen is cleared" << endl;
			clearScreen();
			cout << command << endl;
		}
		else if (command == "end"){
			IsExit = true;
			cout << command << endl;
			fin.close();
			return;
		}
		else if (command == "#"){
			getline(fin, comment);
		}
	}
}

// Display function
void displayFunc(void){
	// clear the entire window to the background color
	glClear(GL_COLOR_BUFFER_BIT);
	while (!IsExit){
		glClearColor(default_r, default_g, default_b, alpha);
#if READ_MULTI_FILE
		if(cur_file < MAX_FILE){
			clearScreen();
			clearData();
			//ReadInput(IsExit);
			ReadFile(IsExit);
			glFlush();
			cout << "Enter any key to run next: ";
			cur_file++;
		}
		else if(cur_file == MAX_FILE){
			exit(0);
		}
#else
		ReadFile(IsExit);
#endif
		return;
	}

	if (IsExit){
		redraw();
	}
	//cout << "enter any key to exit: "; getchar();
	//exit(0);
	return;
}

// Print some formation and Set the parameter
void initial(){
	cout << "Welcome GLUT painter" << endl;
	cout << "Here are command key: (case insensitive)" << endl;
	cout << "\treset - reset matrix to identity" << endl;
	cout << "\tscale - scale the matrix" << endl;
	cout << "\trotate - totate the matrix" << endl;
	cout << "\ttranslate - translate the matrix" << endl;
	cout << "\tsquare - create a square" << endl;
	cout << "\ttriangle - create a triangle" << endl;
	cout << "\tview - draw all the objects" << endl;
	cout << "\tclearData - clear up data" << endl;
	cout << "\tclearScreen - clear the screen" << endl;
	cout << "\tend - Quit" << endl;
}

// Return the order of pair->x
bool cmp_pair(const pair<int, int>& a, const pair<int, int>& b){
	return (a.first < b.first);
}

// Fill the Polygon
void FillPolygon(int PointVectorSize, string object){
	vector<pair<int, int>> Intersections;
	ScanFlag flag = even;
	int cur_num_line = num_line;

	if(object == "triangle"){
		r = Color[1].r;
		g = Color[1].g;
		b = Color[1].b;
	}
	else if(object == "square"){
		r = Color[color_index].r;
		g = Color[color_index].g;
		b = Color[color_index].b;
	}

	for(int y = Frame[3]; y >= Frame[2]; y--){
		flag = even;
		Intersections.clear();
		for(int x = Frame[0]; x <= Frame[1]; x++){
			for(int k = PointVectorSize - 1; k > 0; k--){
				lcp = &line_start[cur_num_line - k];
				while(lcp){
					if(lcp->x == x && lcp->y == y){
						Intersections.push_back(make_pair(x, y));
						break;
					}
					lcp = lcp->next;
				}
			}
		}
		//sort(Intersections.begin(), Intersections.end(), cmp_pair);
		int SIZE = Intersections.size();
		if(SIZE >= 2){
			if(object == "triangle")
				fill_line_color.push_back(1);
			else
				fill_line_color.push_back(color_index);
			fill_line.push_back(fill_line_struct(Intersections[0].first, Intersections[SIZE - 1].first, y));
			DrawHorizontalLine(Intersections[0].first, Intersections[SIZE - 1].first, y);
		}
	}

	color_index = (color_index + 1 == MAX_COLOR) ? 2 : color_index + 1;

	return;
}

// call for the keyboard
void myKeyboard(unsigned char key, int x, int y){
	IsExit = false;
	displayFunc();
	return;
}

#pragma endregion

// Main
void main(int argc, char** argv) {
	int winSizeX, winSizeY;
	string name;
	initial();
	if (argc == 3) {
		winSizeX = atoi(argv[1]);
		winSizeY = atoi(argv[2]);
		//		cout<<"Done";
	}
	else { // default window size
		winSizeX = 800;
		winSizeY = 600;

	}

	width = winSizeX;
	height = winSizeY;

	// initialize OpenGL utility toolkit (glut)
	glutInit(&argc, argv);

	// single disply and RGB color mapping
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB); // set display mode
	glutInitWindowSize(winSizeX, winSizeY);      // set window size
	glutInitWindowPosition(500, 100);                // set window position on screen
	glutCreateWindow("Lab2 Window");       // set window title

#if READ_MULTI_FILE
	// set up the mouse and keyboard callback functions
	glutKeyboardFunc(myKeyboard); // register the keyboard action function
	//glutMouseFunc(Mymouse);
#endif

	// displayFunc is called whenever there is a need to redisplay the window,
	// e.g., when the window is exposed from under another window or when the window is de-iconified
	glutDisplayFunc(displayFunc); // register the redraw function

	// set background color
	glClearColor(default_r, default_g, default_b, alpha);     // set the background to white
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

hw2A.in文件

```
# Computer Graphics Hw2 Test Input A
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

# create a square and its transformation
reset
scale 2.0 2.0
rotate 45.0
translate 10.0 10.0
square

view 0.0 20.0 0.0 20.0 100 400 100 400

end
```

hw2B.in文件

```
# Computer Graphics Hw2 Test Input B
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

# create 4 triangles and place them such that
# the assembly looks like a 4-winged fan

reset
translate 0.0 -1.0
scale 0.5 1.0
rotate 0.0
triangle

rotate 90.0
triangle

rotate 90.0
triangle

rotate 90.0
triangle

view -3.0 3.0 -3.0 3.0 0.0 400.0 0.0 400.0

end
```

hw2C.in文件

```
# Computer Graphics Hw2 Test Input C
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

reset
scale 0.9 0.9 
rotate 15.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 20 220 20 220

reset
scale 0.9 0.9 
rotate 15.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 240 440 20 220

reset
scale 0.8 0.8 
rotate 30.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 460 680 20 220

reset
scale 0.7 0.7 
rotate 45.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 20 220 240 440

reset
scale 0.6 0.6 
rotate 60.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 240 440 240 440

reset
scale 0.5 0.5 
rotate 75.0 
translate 0.0 0.0
square

view -3.0 3.0 -3.0 3.0 460 660 240 440

end
```

hw2D.in

```
# Computer Graphics Hw2 Test Input D
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

reset
scale 0.5 0.5 
rotate 0.0 
translate -.3 -1.0
square

reset
scale 1.5 1.5
rotate 45.0 
translate 0.6 -0.2
square

reset
scale 0.5 0.5
rotate 0.0
translate -0.2 0.2
square

view -2.0 2.0 -2.0 2.0 100 400 100 400

view 0.0 2.0 0.0 2.0 420 450 100 500

view 0.0 2.0 0.0 2.0 600 650 200 300

view -2.0 0.0 0.0 2.0 550 600 200 300

view -2.0 0.0 -2.0 0.0 550 600 100 200

view 0.0 2.0 -2.0 0.0 600 650 100 200

end
```

hw2E.in

```
# Computer Graphics Hw2 Test Input E
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

# HOUSE
reset
scale 4 2
rotate 0 
translate 4.0 2.0
square

# GROUND
reset
scale 20 0.5
rotate 0
translate -10  -0.5
square

# DOOR
reset
scale 0.24 1.0
rotate 0
translate 4.0 1.25
square

# WINDOW
reset
scale 0.25 0.5
rotate 0
translate 2.0 2.5
square

# WINDOW
reset
scale 0.25 0.5
rotate 0
translate 6.0 2.5
square

# ROOF
reset
scale 5.0 1.0
rotate 0
translate 4.0 5.0
triangle

# SUPPORT
reset
scale 0.25 3.0
rotate 0
translate -4.0 3.0
triangle

# BLADE
reset
scale 0.25 3.5
rotate -45
translate -4 5.75
square

# BLADE
reset
scale 0.25 3.5
rotate 45
translate -4 5.75
square

# VIEW SCENE
view -10.0 10.0 -2.0 10.0 20 220 20 140

# VIEW SCENE
view -5.0 5.0 -2.0 10.0 270 500 20 140

# VIEW SCENE
view -10.0 10.0 1.0  4.0 20 320 160 580

# VIEW SCENE
view -10.0 10.0 1.0  4.0 340 740 220 340

end
```

hw2F.in

```
# Computer Graphics Hw2 Test Input F
# copy file content to "hw2.in" and run "CG_Hw2_Sample.exe"

reset
scale 5.0 4.0 
rotate 0 
translate 0.0 0.0
square

reset
scale 8.5 0.5 
rotate 45
translate 0.5 5.5
square

reset
scale 8.5 0.5 
rotate -45
translate 0.5 5.5
square

reset
scale 8.5 0.5 
rotate -135
translate 0.5 5.5
square

reset
scale 8.5 0.5 
rotate 135
translate 0.5 5.5
square

# VIEW SCENE
view -10.0 10.0 0.0  10.0 500 700 20 140

end
```