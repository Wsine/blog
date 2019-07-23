# C++实现glut绘制点、直线、多边形、圆

### 必备环境
- glut.h 头文件
- glut32.lib 对象文件库
- glut32.dll 动态连接库

### 程序说明
C++实现了用glut画点、画直线、画多边形和画圆形，并有一些清屏、重绘、清楚数据和窗口重绘的功能。

### 操作说明
- D：进入画点模式
- L：进入画直线模式
	- 第一次单击确定直线起点
	- 第二次单击绘出直线
- P：进入画多边形模式
	- 第一次单击确定多边形起点
	- 第n次单击绘出多边形的线
	- 右击结束该多边形的绘制
- O：进入画圆模式
	- 第一次单击决定圆心位置
	- 第二次单击绘出圆
- C：清除屏幕
- X：消除全部数据
- R：重绘对象
- ` ：数字键调整画笔颜色
	- 1~7对应红橙黄绿蓝靛紫
	- 8为默认黑色
- Q：退出程序 

### 函数说明

**void init( )**
程序执行初用于告诉用户的基本操作

**void displayFunc( void )**
glut窗口显示和恢复显示的时候调用的函数

**void myKeyboard( unsigned char k, int x, int y )**
键盘控制函数，用于绑定不同的画图函数到glut鼠标操作函数、改变画笔颜色及其他一些功能

**void drawDot( int x, in y )**
在glut坐标轴(x, y)的位置根据画笔设定绘制一个点

**void Mouse_Dot( int button, int state, int x, int y )**
鼠标控制画点函数

**void Mymouse_Line( int button, int state, int x, int y )**
鼠标控制画直线函数

**void Mymouse_Polygon( int button, int state, int x, int y )**
鼠标控制画多边形函数

**void Mymouse_Circle( int button, int state, int x, int y )**
鼠标控制画圆函数

**void drawLine1( int x0, int x1, int y0, int y1, bool xy_interchange )**
直线绘制函数，负责区域1和区域5

**void drawLine2( int x0, int x1, int y0, int y1, bool xy_interchange )**
直线绘制函数，负责区域2和区域6

**void drawLine3( int x0, int x1, int y0, int y1, bool xy_interchange )**
直线绘制函数，负责区域3和区域7

**void drawLine4( int x0, int x1, int y0, int y1, bool xy_interchange )**
直线绘制函数，负责区域4和区域8

**void DrawLine( int x0, int x1, int y0, int y1 )**
直线绘制函数，自行添加，可全区域使用，目前暂给画多边形使用

**void drawCircle( int radius, int center_x, int center_y )**
圆绘制函数，负责画出一个圆

**void CirclePoints( int x, int y, int center_x, int center_y )**
圆的八个点的绘制函数，每次画出八个点

**void redraw( )**
重绘函数，把存储的数据重绘出来

**void clear( )**
清空当前glut窗口的显示

**void erase( )**
删除所有保存的数据

### 重要函数说明
画直线函数，把二维坐标区域分成8个区域，从第四象限靠近y轴的负半轴的区域开始算起为1号区域，逆时针计算。
![adflkjsdf](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image218.png)


注意的是，1号区域和5号区域是用同样的函数控制的，唯一不同的是xy_interchange的值。1号区域的画线方向是从原点画到数字1的区域，5号区域的画线是从数字5画到原点。实质上画线的方向是一致的。因此5~8号区域可以按照1~4号区域的相反来运算。

画线的方法是中点二分法。取两个像素点的中点，计算判断邻域像素点取哪一个。

```
// Draw line for dx>0 and dy>0
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange){
	if (xy_interchange){
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
	while (y >= y0){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if (d <= 0){
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
```

各方向均ok的画线函数，由于需要每一步都使用乘法和除法，相比上一个画线函数时间复杂一些，但是各方向均可绘图，而且单纯绘制一条直线在人脑反应时间上是无差别的。

```
void DrawLine(int x0, int x1, int y0, int y1) {
	//polygon_start[num_polygon] = line_data(x0, y0);
	int max_dis = abs(x1 - x0);
	max_dis = max_dis > abs(y0 - y1) ? max_dis : abs(y0 - y1);
	//lcp = &polygon_start[num_polygon];
	lcp = temp;
	if (max_dis != 0) {
		for (int i = 0; i < max_dis; ++i) {
			lcp->next = new line_data(x0 + i * (x1 - x0) / max_dis, y0 + i * (y1 - y0) / max_dis);
			lcp = lcp->next;
		}
	}
	lcp = temp;
	while (lcp != NULL) {
		drawDot(lcp->x, lcp->y);
		temp = lcp;
		lcp = lcp->next;
	}
	glFlush();
	return;
}
```

绘制圆形，将一个圆分成1/8个圆，如图所示
![dsfasdf](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image219.png)
可以通过8个点之间相互关系，绘制出整个圆
（x, y） -> （y, x）->（x, -y）->（y, -x）->（-x, -y）->（-y, -x）->（-x, y）->（-y, x）
假设圆的半径为R，只需要计算（0, R）->（R/2, R/2）即可

```
void CirclePoints(int x, int y, int center_x, int center_y){
	drawDot(center_x + x, center_y + y);
	drawDot(center_x + y, center_y + x);
	drawDot(center_x + x, center_y - y);
	drawDot(center_x + y, center_y - x);
	drawDot(center_x - x, center_y - y);
	drawDot(center_x - y, center_y - x);
	drawDot(center_x - x, center_y + y);
	drawDot(center_x - y, center_y + x);
	glFlush();
	return;
}
```

程序添加了颜色管理，清屏等操作。

### 实现效果
求轻喷~
![picture](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image220.png)


### 完整代码

```
#include <iostream>
#include <stdlib.h>
#include <cmath>
#include "glut.h"
using namespace std;

int height, width;
static int xOrg = 0, yOrg = 0;
#define MAX_LINE 100
// Max number of lines for drawing: 100
#define MAX_POLYGON 20
// Max number of polygons for drawing: 20
#define MAX_CIRCLE 20
// Max number of circles for drawing: 20

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

struct center_data{
	int c_x, c_y;
	center_data(int cx = -1, int cy = -1){
		c_x = cx;
		c_y = cy;
	}
};

line_structure line[MAX_LINE];
line_data line_start[MAX_LINE];
line_data polygon_start[MAX_POLYGON];
line_data circle_start[MAX_CIRCLE];
center_data center[MAX_CIRCLE];
line_data* lcp;
line_data* temp;

int num_line = 0;
int num_polygon = 0;
int num_circle = 0;
int key_line = 1;
bool first_point = true;

const float default_r = 255.0;
const float default_g = 255.0;
const float default_b = 255.0;
float r = 0.0;
float g = 0.0;
float b = 0.0;
float alpha = 0.0;

void init();
void drawDot(int x, int y);
void Mymouse_Dot(int button, int state, int x, int y);
void Mymouse_Line(int button, int state, int x, int y);
void Mymouse_Polygon(int button, int state, int x, int y);
void Mymouse_Circle(int button, int state, int x, int y);
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine2(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine3(int x0, int x1, int y0, int y1, bool xy_interchange);
void drawLine4(int x0, int x1, int y0, int y1, bool xy_interchange);
void DrawLine(int x0, int x1, int y0, int y1);
void drawCircle(int radius, int center_x, int center_y);
void CirclePoints(int x, int y, int center_x, int center_y);
void redraw();
void myKeyboard(unsigned char key, int x, int y);
void clear();
void erase();
void displayFunc(void);

void init(){
	cout << "Welcome GLUT painter" << endl;
	cout << "Here are command key: (case insensitive)" << endl;
	cout << "\tD - Dot Mode" << endl;
	cout << "\tL - Line Mode" << endl;
	cout << "\tP - Polygon Mode" << endl;
	cout << "\tO - Circle Mode" << endl;
	cout << "\tC - Clear Screen" << endl;
	cout << "\tX - Clear all objects" << endl;
	cout << "\tR - Redraw Objects" << endl;
	cout << "\t` - Number to set color" << endl;
	cout << "\tQ - Quit" << endl;
}

// Draw 8 points
void CirclePoints(int x, int y, int center_x, int center_y){
	drawDot(center_x + x, center_y + y);
	drawDot(center_x + y, center_y + x);
	drawDot(center_x + x, center_y - y);
	drawDot(center_x + y, center_y - x);
	drawDot(center_x - x, center_y - y);
	drawDot(center_x - y, center_y - x);
	drawDot(center_x - x, center_y + y);
	drawDot(center_x - y, center_y + x);
	glFlush();
	return;
}

// Draw a circle
void drawCircle(int radius, int center_x, int center_y){
	int x = 0;
	int y = radius;
	int d = 1 - radius;
	int IncE = 3;
	int IncSE = -2 * radius + 5;
	while (x <= y){
		if (d <= 0){
			x++;
			d += IncE;
			IncE += 2;
			IncSE += 2;
		}
		else{
			x++;
			y--;
			d += IncSE;
			IncE += 2;
			IncSE += 4;
		}
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		CirclePoints(x, y, center_x, center_y);
	}
	return;
}

// Mouse control for circle drawing
void Mymouse_Circle(int button, int state, int x, int y){
	if (state == GLUT_DOWN && first_point == true){
		cout << "\tcircle center" << endl;
		cout << "\t\ton location (" << x << ", " << y << ")" << endl;
		center[num_circle] = center_data(x, y);
		first_point = false;
	}
	else if (state == GLUT_DOWN && first_point == false){
		cout << "\tmouse clicks" << endl;
		cout << "\t\ton location (" << x << ", " << y << ")" << endl;
		int radius = (int)sqrt(pow(x - center[num_circle].c_x, 2) + pow(y - center[num_circle].c_y, 2));
		circle_start[num_circle] = line_data(center[num_circle].c_x + 0, center[num_circle].c_y + radius);
		lcp = &circle_start[num_circle];
		drawCircle(radius, center[num_circle].c_x, center[num_circle].c_y);
		num_circle++;
		first_point = true;
	}
	return;
}

// Clear screen
void clear(){
	glClearColor(default_r, default_g, default_b, alpha);
	glClear(GL_COLOR_BUFFER_BIT);
	glFlush();
}

// Clear objects
void erase(){
	for (int i = 0; i < num_line; i++){
		if (line_start[i].next != NULL){
			lcp = line_start[i].next;
			while (lcp != NULL){
				temp = lcp;
				lcp = lcp->next;
				delete(temp);
			}
		}
	}
	num_line = 0;
	for (int i = 0; i < num_polygon; i++){
		if (polygon_start[i].next != NULL){
			lcp = polygon_start[i].next;
			while (lcp != NULL){
				temp = lcp;
				lcp = lcp->next;
				delete(temp);
			}
		}
	}
	num_polygon = 0;
	for (int i = 0; i < num_circle; i++){
		if (circle_start[i].next != NULL){
			lcp = circle_start[i].next;
			while (lcp != NULL){
				temp = lcp;
				lcp = lcp->next;
				delete(temp);
			}
		}
	}
	num_circle = 0;
}

// Mouse control for polygon drawing
void Mymouse_Polygon(int button, int state, int x, int y){
	if (button == GLUT_LEFT_BUTTON){
		if (state == GLUT_DOWN && first_point == true){
			cout << "\tpolygon starts" << endl;
			cout << "\t\ton location (" << x << ", " << y << ")" << endl;
			polygon_start[num_polygon] = line_data(x, y);
			temp = lcp = &polygon_start[num_polygon];
			first_point = false;
			num_polygon++;
		}
		else if (state == GLUT_DOWN && first_point == false){
			cout << "\tpolygon clicks" << endl;
			cout << "\t\ton location (" << x << ", " << y << ")" << endl;
			DrawLine(temp->x, x, temp->y, y);
		}
	}
	else if (button == GLUT_RIGHT_BUTTON){
		if (state == GLUT_DOWN){
			first_point = true;
		}
	}
	return;
}

void DrawLine(int x0, int x1, int y0, int y1) {
	//polygon_start[num_polygon] = line_data(x0, y0);
	int max_dis = abs(x1 - x0);
	max_dis = max_dis > abs(y0 - y1) ? max_dis : abs(y0 - y1);
	//lcp = &polygon_start[num_polygon];
	lcp = temp;
	if (max_dis != 0) {
		for (int i = 0; i < max_dis; ++i) {
			lcp->next = new line_data(x0 + i * (x1 - x0) / max_dis, y0 + i * (y1 - y0) / max_dis);
			lcp = lcp->next;
		}
	}
	lcp = temp;
	while (lcp != NULL) {
		drawDot(lcp->x, lcp->y);
		temp = lcp;
		lcp = lcp->next;
	}
	glFlush();
	return;
}

// Redraw all objects stored 
void redraw(){
	int i;
	line_data* rd_line;
	line_data* rd_polygon;
	line_data* rd_circle;

	for (i = 0; i<num_line; i++){
		rd_line = &line_start[i];
		while (rd_line != NULL){
			drawDot(rd_line->x, rd_line->y);
			rd_line = rd_line->next;
		}
	}
	for (i = 0; i<num_polygon; i++){
		rd_polygon = &polygon_start[i];
		while (rd_polygon != NULL){
			drawDot(rd_polygon->x, rd_polygon->y);
			rd_polygon = rd_polygon->next;
		}
	}
	for (i = 0; i<num_circle; i++){
		rd_circle = &circle_start[i];
		while (rd_circle != NULL){
			CirclePoints(rd_circle->x, rd_circle->y, center[i].c_x, center[i].c_y);
			rd_circle = rd_circle->next;
		}
	}
	glFlush();
}

// draw a dot at location with integer coordinates (x,y)
void drawDot(int x, int y){
	glBegin(GL_POINTS);
	// set the color of dot
	glColor3f(r, g, b);
	// invert height because the opengl origin is at top-left instead of bottom-left
	glVertex2i(x, height - y);

	glEnd();
}

// Mouse callback function
void Mymouse_Dot(int button, int state, int x, int y){
	if (state == GLUT_DOWN) {
		cout << "\tdot clicks" << endl;
		cout << "\t\ton location (" << x << ", " << y << ")" << endl;
		drawDot(x, y);
		glFlush();
	}
}

#pragma region Drawline

// Mouse control for line drawing 
void Mymouse_Line(int button, int state, int x, int y){
	if (state == GLUT_DOWN && first_point == true){
		cout << "\tline starts" << endl;
		cout << "\t\ton location (" << x << ", " << y << ")" << endl;
		line[num_line].x0 = x;
		line[num_line].y0 = y;
		first_point = false;
	}
	else if (state == GLUT_DOWN && first_point == false){
		cout << "\tline ends" << endl;
		cout << "\t\ton location (" << x << ", " << y << ")" << endl;
		line[num_line].x1 = x;
		line[num_line].y1 = y;
		first_point = true;
		int dx = line[num_line].x1 - line[num_line].x0;
		int dy = line[num_line].y1 - line[num_line].y0;
		if (dx >= 0 && dy > 0 && abs(dx) < abs(dy)){
			drawLine1(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
		}
		else if (dx > 0 && dy >= 0 && abs(dx) >= abs(dy)){
			drawLine2(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
		}
		else if (dx > 0 && dy <= 0 && abs(dx) > abs(dy)){
			drawLine3(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
		}
		else if (dx >= 0 && dy < 0 && abs(dx) <= abs(dy)){
			drawLine4(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, false);
		}
		else if (dx <= 0 && dy < 0 && abs(dx) < abs(dy)){
			drawLine1(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
		}
		else if (dx < 0 && dy <= 0 && abs(dx) >= abs(dy)){
			drawLine2(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
		}
		else if (dx < 0 && dy >= 0 && abs(dx) > abs(dy)){
			drawLine3(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
		}
		else{
			drawLine4(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1, true);
		}
		//DrawLine(line[num_line].x0, line[num_line].x1, line[num_line].y0, line[num_line].y1);
		num_line++;
	}
	return;
}

// Draw line for dx>0 and dy>0
void drawLine1(int x0, int x1, int y0, int y1, bool xy_interchange){
	if (xy_interchange){
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
	while (y >= y0){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if (d <= 0){
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
	if (xy_interchange){
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
	while (x <= x1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if (d <= 0){
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
	if (xy_interchange){
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
	while (x <= x1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if (d <= 0){
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
	if (xy_interchange){
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
	while (y >= y1){
		lcp->next = new line_data(x, y);
		lcp = lcp->next;
		drawDot(x, y);
		if (d <= 0){
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
#pragma endregion

// Keyboard callback function
void myKeyboard(unsigned char key, int x, int y) {
	switch (key) {
		// Draw dots with 'd' or 'D'
	case 'd':
	case 'D':
		cout << "\nchoose the Dot mode" << endl;
		glutMouseFunc(Mymouse_Dot);
		break;
		// Draw lines with 'l' or 'L'
	case 'l':
	case 'L':
		cout << "\nchoose the Line mode" << endl;
		first_point = true;
		glutMouseFunc(Mymouse_Line);
		break;
		// Draw polygons with 'p' or 'P'
	case 'p':
	case 'P':
		cout << "\nchoose the Polygon mode" << endl;
		first_point = true;
		glutMouseFunc(Mymouse_Polygon);
		break;
		// Draw circle with 'c' or 'C'
	case 'o':
	case 'O':
		cout << "\nchoose the Circle mode" << endl;
		first_point = true;
		glutMouseFunc(Mymouse_Circle);
		break;
		// Redraw all with 'r' or 'R'
	case 'r':
	case 'R':
		cout << "\nnow redraw all" << endl;
		redraw();
		break;
		// Clear screen with 'c' or 'C'
	case 'c':
	case 'C':
		cout << "\nclear the screen" << endl;
		clear();
		break;
	case 'x':
	case 'X':
		cout << "\nclear all the objects" << endl;
		erase();
		break;
		// Quit with 'q' or 'Q'
	case 'q':
	case 'Q':
		cout << "\napplication exit successfully" << endl;
		exit(0);
		break;
	case '1':
		r = 1.0;	g = 0;		b = 0;
		break;
	case '2':
		r = 1.0;	g = 0.5;	b = 0;
		break;
	case '3':
		r = 1.0;	g = 1.0;	b = 0;
		break;
	case '4':
		r = 0;		g = 1.0;	b = 0;
		break;
	case '5':
		r = 0;		g = 0;		b = 1.0;
		break;
	case '6':
		r = 0;		g = 1.0;	b = 1.0;
		break;
	case '7':
		r = 1.0;	g = 0;		b = 1.0;
		break;
	case '8':
		r = 0;		g = 0;		b = 0;
		break;
	default:
		break;
	}
}

// Display function
void displayFunc(void){
	// clear the entire window to the background color
	glClear(GL_COLOR_BUFFER_BIT);
	glClearColor(default_r, default_g, default_b, alpha);

	// draw the contents!!! Iterate your object's data structure!
	redraw();
	
	// flush the queue to actually paint the dots on the opengl window
	glFlush();
}

// Main
int main(int argc, char** argv) {
	int winSizeX, winSizeY;

	//set the window size
	if (argc == 3) {
		winSizeX = atoi(argv[1]);
		winSizeY = atoi(argv[2]);
	}
	else { // default window size
		winSizeX = 800;
		winSizeY = 600;
	}
	width = winSizeX;
	height = winSizeY;

	init();

	// initialize OpenGL utility toolkit (glut)
	glutInit(&argc, argv);

	// single disply and RGB color mapping
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB); // set display mode
	glutInitWindowSize(winSizeX, winSizeY);      // set window size
	glutInitWindowPosition(500, 100);                // set window position on screen
	glutCreateWindow("Lab1 Window");			 // set window title

	// set up the mouse and keyboard callback functions
	glutKeyboardFunc(myKeyboard);				// register the keyboard action function

	// displayFunc is called whenever there is a need to redisplay the window
	glutDisplayFunc(displayFunc);				// register the redraw function

	// set background color
	glClearColor(default_r, default_g, default_b, alpha);	// set the background to white
	glClear(GL_COLOR_BUFFER_BIT);				// clear the buffer

	// misc setup
	glMatrixMode(GL_PROJECTION);				// setup coordinate system
	glLoadIdentity();
	gluOrtho2D(0, winSizeX, 0, winSizeY);
	glShadeModel(GL_FLAT);
	glFlush();
	glutMainLoop();

	return 0;
}
```