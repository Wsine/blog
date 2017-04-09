#C++实现数字媒体三维图像变换

###必备环境
- glut.h 头文件
- glut32.lib 对象文件库
- glut32.dll 动态连接库

###程序说明
C++实现了用glut画物体对象的功能。并附带放大缩小，旋转，平移和在不同视角观察的功能。

###操作说明
####重要说明
**define MAX_MODEL 20**
程序最多支持创建20个对象，如需要创建更多的对象，请调高这个参数
**define MAX_MODEL_NUM 4000**
程序最多支持对象拥有4000个点和4000个面，如需要读入更复杂的对象，请调高这个参数

####指令说明
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
- end ： 结束程序

###函数说明

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

###程序截图

![132](http://images0.cnblogs.com/blog2015/701997/201507/151702581268376.png)

![456](http://images0.cnblogs.com/blog2015/701997/201507/151703075327769.png)

###完整代码

```
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <cmath>
#include <string>
#include <vector>
#include <algorithm>
#include <iomanip>
#include "glut.h"
using namespace std;

#pragma region Data

typedef float wvmtype;
#define MTM_SIZE 4
#define PI 3.14159265
#define MAX_MODEL 20
#define MAX_MODEL_NUM 4000
#define MAX_LINE 100

struct ASCModel_struct{
	int num_vertex;
	int num_face;
	float vertex[MAX_MODEL_NUM][MTM_SIZE];
	int face[MAX_MODEL_NUM][MTM_SIZE];
}ASCModel[MAX_MODEL];

struct line_data{
	int x, y;
	line_data* next;
	line_data(int _x = -1, int _y = -1){
		x = _x;
		y = _y;
		next = NULL;
	}
};

struct line_structure{
	int x0, x1, y0, y1;
};

float ModelingTransformMatrix[MTM_SIZE][MTM_SIZE] 
	= { { 1, 0, 0, 0 }, 
		{ 0, 1, 0, 0 }, 
		{ 0, 0, 1, 0 }, 
		{ 0, 0, 0, 1 } };
float Eye_Matirx[MTM_SIZE][MTM_SIZE];
float Project_Matrix[MTM_SIZE][MTM_SIZE];
float WzNear, WzFar, WhFOV;
wvmtype WVM[MTM_SIZE][MTM_SIZE];

line_structure line[MAX_LINE];
line_data line_start[MAX_LINE];
line_data* lcp;
line_data* temp;
int num_ASCModel = 0;
int num_line = 0;

const float default_r = 0.0;
const float default_g = 0.0;
const float default_b = 0.0;
float r = 0.0;
float g = 1.0;
float b = 1.0;
const float alpha = 0.0;

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
void object(string objectname);
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
	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
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

	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
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
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
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
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
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
		printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
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

	printMatrix(ModelingTransformMatrix, 4, 4, "ModelingTransformMatrix");
}

// Read a ASCModel from file
void object(string objectname){
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

	int n;
	// read face one by one
	for(int i = 0; i<ASCModel[num_ASCModel].num_face; i++) {
		fin >> n;
		//if(i < 20) cout << "n = " << n <<  " , ";
		for(int j = 0; j < n; j++){
			fin >> ASCModel[num_ASCModel].face[i][j];
			//if(i < 20)	cout << ASCModel[num_ASCModel].face[i][j] << " ";
		}
		if(n < MTM_SIZE)
			for(int j = n; j < MTM_SIZE; j++)
				ASCModel[num_ASCModel].face[i][j] = -1;
		//if(i < 20) cout << endl;
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

	num_ASCModel++;
}

// Set the observer
void observer(float PX, float PY, float PZ, float CX, float CY, float CZ,
	float Tilt, float zNear, float zFar, float hFOV){

	Eye_Transform(PX, PY, PZ, CX, CY, CZ, Tilt);
	
	Project_Transform(zNear, zFar, hFOV);

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
	printMatrix(Eye_Translation_Matrix, 4, 4, "Eye_Translation_Matrix");

	float Eye_Mirror_Matrix[MTM_SIZE][MTM_SIZE]
		= { { -1, 0, 0, 0 },
			{ 0, 1, 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 } };
	printMatrix(Eye_Mirror_Matrix, 4, 4, "Eye_Mirror_Matrix");

	float TiltDegree = Tilt * PI / 180.0;
	float Eye_Tilt_Matrix[MTM_SIZE][MTM_SIZE]
		= { { cos(TiltDegree), sin(TiltDegree), 0, 0 },
			{ -sin(TiltDegree), cos(TiltDegree), 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 } };
	printMatrix(Eye_Tilt_Matrix, 4, 4, "Eye_Tilt_Matrix");

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
	printMatrix(GRM, 4, 4, "GRM");

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
	printMatrix(Eye_Matirx, 4, 4, "Eye_Matrix");
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
	printMatrix(Project_Matrix, 4, 4, "Project_Matrix");

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
	printMatrix(WVM, 4, 4, "WVM Matrix");
}

// Show all the object in final
void display(){
	clearScreen();
	clearData();

	float multi_sum = 0;
	float Matrix[MTM_SIZE];
	ASCModel_struct Cur_ASCModel;
	for(int index = 0; index < num_ASCModel; index++){
		Cur_ASCModel = ASCModel[index];
		line_start[num_line] = line_data(-1, -1);
		lcp = &line_start[num_line];

		cout << "World-Space:" << endl;
		cout << Cur_ASCModel.vertex[0][0] << " "
			<< Cur_ASCModel.vertex[0][1] << " "
			<< Cur_ASCModel.vertex[0][2] << " "
			<< Cur_ASCModel.vertex[0][3] << " " << endl;

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
		cout << "Eye-Space:" << endl;
		cout << Cur_ASCModel.vertex[0][0] << " "
			<< Cur_ASCModel.vertex[0][1] << " "
			<< Cur_ASCModel.vertex[0][2] << " "
			<< Cur_ASCModel.vertex[0][3] << " " << endl;

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
			Cur_ASCModel.vertex[i][2] = 1;//Fix to three-dimensional homogeneous
		}
		cout << "Project-Space:" << endl;
		cout << Cur_ASCModel.vertex[0][0] << " "
			<< Cur_ASCModel.vertex[0][1] << " "
			<< Cur_ASCModel.vertex[0][2] << " "
			<< Cur_ASCModel.vertex[0][3] << " " << endl;

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
		cout << "Screen-Space:" << endl;
		cout << Cur_ASCModel.vertex[0][0] << " "
			<< Cur_ASCModel.vertex[0][1] << " "
			<< Cur_ASCModel.vertex[0][2] << " "
			<< Cur_ASCModel.vertex[0][3] << " " << endl;
		
		// Display
		for(int i = 0; i < Cur_ASCModel.num_face; i++){
			for(int j = 0; j < MTM_SIZE; j++){
				bool vertice = (j < 3 && Cur_ASCModel.face[i][j + 1] == -1);
				int j_next = (j == 3 || vertice) ? 0 : j + 1;
				int x0 = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j] - 1][0];
				int x1 = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j_next] - 1][0];
				int y0 = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j] - 1][1];
				int y1 = Cur_ASCModel.vertex[Cur_ASCModel.face[i][j_next] - 1][1];
				//DrawLine(x0, x1, y0, y1);
				drawLine0(x0, x1, y0, y1);
				if(vertice)	break;
			}
		}
		num_line++;
	}
}

// Redrwa the object
void redraw(){
	line_data* rd_line;
	for(int i = 0; i < num_line; i++){
		rd_line = &line_start[i];
		while(rd_line != NULL){
			drawDot(rd_line->x, rd_line->y);
			rd_line = rd_line->next;
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
	glClearColor(default_r, default_g, default_b, alpha);
	glClear(GL_COLOR_BUFFER_BIT);
	glFlush();
}

// Read the command from file
void ReadFile(bool& IsExit){
	ifstream fin(Inputfile);
	if(fin.is_open()){
		cout << "open the file successfully" << endl;
	}
	else{
		cout << "Can't not open the file" << endl;
		IsExit = true;
		return;
	}
	float sx, sy, sz;
	float Xdegree, Ydegree, Zdegree;
	float tx, ty, tz;
	float vxl, vxr, vyt, vyb;
	float PX, PY, PZ, CX, CY, CZ, Tilt, zNear, zFar, hFOV;
	string command, comment, objectname;
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
			object(objectname);
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
		glClearColor(default_r, default_g, default_b, alpha);
		ReadFile(IsExit);
		return;
	}

	if(IsExit){
		redraw();
	}
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
	cout << "\tobject - create an object" << endl;
	cout << "\tobverser - set the camera position" << endl;
	cout << "\tviewport - set the window to display" << endl;
	cout << "\tdisplay - draw all the objects" << endl;
	cout << "\tclearData - clear up data" << endl;
	cout << "\tclearScreen - clear the screen" << endl;
	cout << "\tend - Quit" << endl;
}

#pragma endregion

// Main
void main(int argc, char** argv) {
	int winSizeX, winSizeY;

	//Set the programme parameter
	Inputfile = (argc >= 2) ? (string(argv[1])) : "tilt1.in";
	//Inputfile = (argc >= 2) ? (string(argv[1])) : "chair.in";
	//Inputfile = (argc >= 2) ? (string(argv[1])) : "mytest.in";
	height = winSizeX = (argc >= 3) ? (atoi(argv[2])) : 800;
	width = winSizeY = (argc >= 4) ? (atoi(argv[3])) : 600;

	initial();

	// initialize OpenGL utility toolkit (glut)
	glutInit(&argc, argv);

	// single disply and RGB color mapping
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB); // set display mode
	glutInitWindowSize(winSizeX, winSizeY);      // set window size
	glutInitWindowPosition(500, 100);                // set window position on screen
	glutCreateWindow("Lab3 Window");       // set window title

	// set up the mouse and keyboard callback functions
	//glutKeyboardFunc(myKeyboard); // register the keyboard action function
	//glutMouseFunc(Mymouse);

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

###测试文件

opengl经典测试——茶壶 titl1.in
使用了teapot.asc文件，上网搜索即可得到

```
scale 1 1 1
rotate 0 0 0
translate 0 0 0

object teapot.asc

observer 0 10 10    0 0 0    0 1 1000 30

viewport 0 800 0 600

display


end

```

opengl经典测试二——椅子 chair.in
使用了cube.asc文件，上网搜索即可得到

```
# makes a chair on a groundplane

# ground plane
scale      5 .2 5 
translate  1 -.1 1
object cube.asc    

# leg of chair
reset
scale      .05 .4 .05 
translate  1.15 .2 1.15
object cube.asc 

# leg of chair
reset
scale      .05 .4 .05   
translate  1.15 .2 .85
object cube.asc      

# leg of chair
reset
scale      .05 .4 .05
translate  .85 .2 .85
object cube.asc      

# leg of chair
reset
scale      .05 .4 .05
translate  .85 .2 1.15
object cube.asc     

# seat of chair
reset
scale      .3 .05 .3
translate  1  .425 1
object cube.asc      

# back of chair
reset
scale      .3 .5 .1
translate  1  .7  .9
object cube.asc      

observer 2 .5 0 1 1 1 0 1 1000 30 

viewport -.5 .5 -.5 .5

display

observer 3 4 5 0 0 0 10 1 1000 30

viewport 0 800 0 600

display

end

```

测试三为茶壶的变体，包含5份。

```
# teapot1.in
# #####################
# load a teapot

object teapot.asc

# set viewport

viewport 0 800 0 600

# Eye (0,0,10)  Look at (0,0,0)

observer 0 0 10  0 0 0  0 1 100 45

display

end
# #####################

# teapot2.in
# #####################
# load a teapot

object teapot.asc

# set viewport

viewport 100 400 100 400

# Eye (0,0,10)  Look at (0,0,0)

observer 0 0 10  0 0 0  0 1 100 45

display

end
# #####################

# teapot3.in
# #####################
# modeling trasnform

translate 3 0 0

# load a teapot

object teapot.asc

# set viewport

viewport 0 800 0 600

# Eye (0,0,10)  Look at (0,0,0)

observer 0 0 10  0 0 0  0 1 100 45

display

end
# #####################

# teapot4.in
# #####################
# modeling trasnform

translate 3 0 0

# load a teapot

object teapot.asc

# set viewport

viewport 0 800 0 600

# Eye at(5,5,5)  Look at (0,0,0)

observer 5 5 5  0 0 0  0 1 100 45

display

end
# #####################

# teapot5.in
# #####################
# modeling trasnform

rotate 0 90 0

translate 3 0 0

# load a teapot

object teapot.asc

# set viewport

viewport 0 800 0 600

# Eye (0,0,10)  Look at (0,0,0)

observer 5 5 5  0 0 0  0 1 100 45

display

end
# #####################
```

###综合测试批处理文件

记事本保存下面的代码为 xxx.bat 即可
3DCG_hw3.exe为VS编译生成的可执行文件名，可以选择更改批处理文件里面的名字，或更改自己的编译得到的可执行文件名。

```
# run sample


3DCG_hw3.exe tilt1.in

3DCG_hw3.exe chair.in

3DCG_hw3.exe teapot1.in

3DCG_hw3.exe teapot2.in

3DCG_hw3.exe teapot3.in

3DCG_hw3.exe teapot4.in

3DCG_hw3.exe teapot5.in
```