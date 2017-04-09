#C#的winform矩阵简单运算


----------
###程序截图
![](http://images.cnitblog.com/blog/701997/201502/231401035961164.png)
![](http://images.cnitblog.com/blog/701997/201502/231401122367956.png)

###关键代码
```
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MatrixMultiplication {
	public partial class MainForm : Form {
		public MainForm() {
			InitializeComponent();
			
		}

		int[,] A = new int[100,100];
		int[,] B = new int[100,100];
		int[,] AB = new int[100,100];
		int[,] C = new int[100,100];
		int[,] D = new int[100,100];
		int A_row = 0,A_col = 0;
		int B_row = 0,B_col = 0;
		int C_row = 0,C_col = 0;
		int D_row = 0,D_col = 0;
		int AB_row = 0,AB_col = 0;

		public void readMatrix(TextBox other,char towhere){
			if(towhere == 'A') {
				string[] arr = new string[other.Lines.Length];
				for(int i = 0; i < other.Lines.Length; i++) {
					arr[i] = other.Lines[i];
				}
				string[] tem = arr[0].Split();
				A_col = tem.Length;
				A_row = other.Lines.Length;
				for(int i = 0; i < A_row; i++) {
					string[] temp = arr[i].Split();
					for(int j = 0; j < A_col; j++) {
						A[i,j] = Convert.ToInt32(temp[j]);
					}
				}
			}
			else if(towhere == 'B') {
				string[] arr = new string[other.Lines.Length];
				for(int i = 0; i < other.Lines.Length; i++) {
					arr[i] = other.Lines[i];
				}
				string[] tem = arr[0].Split();
				B_col = tem.Length;
				B_row = other.Lines.Length;
				for(int i = 0; i < B_row; i++) {
					string[] temp = arr[i].Split();
					for(int j = 0; j < B_col; j++) {
						B[i,j] = Convert.ToInt32(temp[j]);
					}
				}
			}
			else if(towhere == 'C') {
				string[] arr = new string[other.Lines.Length];
				for(int i = 0; i < other.Lines.Length; i++) {
					arr[i] = other.Lines[i];
				}
				string[] tem = arr[0].Split();
				C_col = tem.Length;
				C_row = other.Lines.Length;
				for(int i = 0; i < C_row; i++) {
					string[] temp = arr[i].Split();
					for(int j = 0; j < C_col; j++) {
						C[i,j] = Convert.ToInt32(temp[j]);
					}
				}
			}
		}

		public void compute(char Char) {
			if(Char == '*') {
				AB_row = A_row;
				AB_col = B_col;
				for(int i = 0; i < AB_row; i++) {
					for(int j = 0; j < AB_col; j++) {
						AB[i,j] = 0;
						for(int k = 0; k < A_col; k++) {
							AB[i,j] += A[i,k] * B[k,j];
						}
					}
				}
			}
			else if(Char == '+') {
				AB_row = A_row;
				AB_col = A_col;
				for(int i = 0; i < AB_row; i++) {
					for(int j = 0; j < AB_col; j++) {
						AB[i,j] = A[i,j] + B[i,j];
					}
				}
					
			}
			else if(Char == '-') {
				AB_row = A_row;
				AB_col = A_col;
				for(int i = 0; i < AB_row; i++) {
					for(int j = 0; j < AB_col; j++) {
						AB[i,j] = A[i,j] - B[i,j];
					}
				}

			}
		}

		private void button1_Click(object sender,EventArgs e) {
			if(BoxA.Text == "" || BoxB.Text == "") {
				MessageBox.Show("请输入数据","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			readMatrix(BoxA,'A');
			readMatrix(BoxB,'B');
			if((A_row != B_col) || (A_col != B_row)) {
				MessageBox.Show("行列规则不符合","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			BoxAB.Text = "";
			compute('*');
			for(int i = 0; i < AB_row; i++) {
				for(int j = 0; j < AB_col; j++) {
					BoxAB.Text += AB[i,j].ToString();
					BoxAB.Text += " ";
				}
				BoxAB.Text += "\r\n";
			}
		}

		private void btnClear_Click(object sender,EventArgs e) {
			A_row = 0; A_col = 0;
			B_row = 0; B_col = 0;
			AB_row = 0; AB_col = 0;
			BoxA.Text = "";
			BoxB.Text = "";
			BoxAB.Text = "";
		}

		private void Add_Click(object sender,EventArgs e) {
			if(BoxA.Text == "" || BoxB.Text == "") {
				MessageBox.Show("请输入数据","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			readMatrix(BoxA,'A');
			readMatrix(BoxB,'B');
			if((A_row != B_row) || (A_col != B_col)) {
				MessageBox.Show("行列规则不符合","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			BoxAB.Text = "";
			compute('+');
			for(int i = 0; i < AB_row; i++) {
				for(int j = 0; j < AB_col; j++) {
					BoxAB.Text += AB[i,j].ToString();
					BoxAB.Text += " ";
				}
				BoxAB.Text += "\r\n";
			}
		}

		private void Minus_Click(object sender,EventArgs e) {
			if(BoxA.Text == "" || BoxB.Text == "") {
				MessageBox.Show("请输入数据","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			readMatrix(BoxA,'A');
			readMatrix(BoxB,'B');
			if((A_row != B_row) || (A_col != B_col)) {
				MessageBox.Show("行列规则不符合","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			BoxAB.Text = "";
			compute('-');
			for(int i = 0; i < AB_row; i++) {
				for(int j = 0; j < AB_col; j++) {
					BoxAB.Text += AB[i,j].ToString();
					BoxAB.Text += " ";
				}
				BoxAB.Text += "\r\n";
			}
		}

		private void Trspos_Click(object sender,EventArgs e) {
			if(BoxC.Text == "") {
				MessageBox.Show("请输入数据","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			readMatrix(BoxC,'C');
			#region 转置算法
			D_row = C_col;
			D_col = C_row;
			for(int i = 0; i < C_row; i++) {
				for(int j = 0; j < C_col; j++) {
					D[j,i] = C[i,j];
				}
			}
			#endregion
			BoxD.Text = "";
			for(int i = 0; i < D_row; i++) {
				for(int j = 0; j < D_col; j++) {
					BoxD.Text += D[i,j].ToString();
					BoxD.Text += " ";
				}
				BoxD.Text += "\r\n";
			}
		}

		private void MatrixReturn_Click(object sender,EventArgs e) {
			if(BoxC.Text == "") {
				MessageBox.Show("请输入数据","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			readMatrix(BoxC,'C');
			if(C_row!=C_col){
				MessageBox.Show("该矩阵没有逆矩阵","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}
			#region 创建double类型二维数组作为结果
			double y = 1.0;
			double tem,x;
			double[,] Return = new double[C_row,C_col*2];
			#endregion
			#region 求逆算法
			for(int i = 0; i < C_row; i++) {
				for(int j = 0; j < (2 * C_col); j++) {
					if(j < C_row)
						Return[i,j] = Convert.ToDouble(C[i,j]);
					else if(j == C_row + i)
						Return[i,j] = 1.0;
					else
						Return[i,j] = 0.0;

				}
			}
			for(int i = 0; i < C_row; i++) {
				for(int k = 0; k < C_row; k++) {
					if(k != i) {
						tem = Return[k,i] / Return[i,i];
						for(int j = 0; j < (2 * C_row); j++) {
							x = Return[i,j] * tem;
							Return[k,j] -= x;
						}
					}
				}
			}
			for(int i = 0; i < C_row; i++) {
				tem = Return[i,i];
				for(int j = 0; j < (2 * C_row); j++) {
					Return[i,j] /= tem;
				}
			}
			for(int i = 0; i < C_row; i++) {
				y *= Return[i,i];
			}
			#endregion

			if(y == 0) {
				MessageBox.Show("该矩阵没有逆矩阵","提示",MessageBoxButtons.OK,MessageBoxIcon.Information);
				return;
			}

			BoxD.Text = "";
			for(int i = 0; i < C_row; i++) {
				for(int j = 0; j < C_row; j++) {
					BoxD.Text += Return[i,j + C_row].ToString("f2");
					BoxD.Text += " ";
				}
				BoxD.Text += "\r\n";
			}
			
		}

		private void btnClear2_Click(object sender,EventArgs e) {
			BoxC.Text = "";
			BoxD.Text = "";
			C_row = 0;C_col = 0;
			D_row = 0;D_col = 0;
		}


	}
}

```

###完整工程
[度盘下载](http://pan.baidu.com/s/1i3qvtbR)