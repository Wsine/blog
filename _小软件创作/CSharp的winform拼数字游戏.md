#C#的winform拼数字游戏

----------
声明：阅读了别人的代码学习修改而来，增加了美观度和游戏乐趣。（作者出处忘了不好意思）

###程序截图
![](http://images.cnitblog.com/blog/701997/201502/231410550491338.png)

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

namespace PingNumberGame {
    public partial class MainForm : Form {
        public MainForm() {
            InitializeComponent();
			btnGiveup.Visible = false;
        }
        Label[,] arrLbl = new Label[3, 3];
        int unRow = 0, unCol = 0;
        bool playing = false;
		const int maxWarning = 5;
		string[] warning ={"你简直弱爆了",
						  "小学没毕业吧你",
						  "天呐，什么人呐",
						  "真为你的智商感到捉急",
						  "你走开我有傻逼恐惧症"};

		public void move(object sender) {
			if(!playing) {
				return;
			}
			int row = ((Label)sender).Top / 120;
			int col = ((Label)sender).Left / 120;
			if(Math.Abs(row - unRow) + Math.Abs(col - unCol) == 1) {
				string temp = arrLbl[unRow, unCol].Text;
				arrLbl[unRow, unCol].Text = arrLbl[row, col].Text;
				arrLbl[row, col].Text = temp;
				arrLbl[unRow, unCol].Visible = true;
				arrLbl[row, col].Visible = false;
				unRow = row;
				unCol = col;
			}
			for(int i = 0; i < 9; i++) {
				if(arrLbl[i / 3, i % 3].Text != Convert.ToString(i + 1))
					break;
				if(i == 8) {
					arrLbl[unRow, unCol].Visible = true;
					playing = false;
					MessageBox.Show("恭喜你通过了游戏！", "祝贺", MessageBoxButtons.OK, MessageBoxIcon.Information);
					btnGiveup.Visible = false;
					btnPlay.Visible = true;
				}
			}
		}

        private void label1_Click(object sender, EventArgs e) {
			move(sender);
        }

        private void label2_Click(object sender, EventArgs e) {
			move(sender);
        }

		private void label3_Click(object sender, EventArgs e) {
			move(sender);
		}

        private void label4_Click(object sender, EventArgs e) {
			move(sender);
        }

		private void label5_Click(object sender, EventArgs e) {
			move(sender);
		}

		private void label6_Click(object sender, EventArgs e) {
			move(sender);
		}

		private void label7_Click(object sender, EventArgs e) {
			move(sender);
		}

		private void label8_Click(object sender, EventArgs e) {
			move(sender);
		}

		private void label9_Click(object sender, EventArgs e) {
			move(sender);
		}

		private void btnPlay_Click(object sender, EventArgs e) {
			arrLbl[0, 0] = label1;
			arrLbl[0, 1] = label2;
			arrLbl[0, 2] = label3;
			arrLbl[1, 0] = label4;
			arrLbl[1, 1] = label5;
			arrLbl[1, 2] = label6;
			arrLbl[2, 0] = label7;
			arrLbl[2, 1] = label8;
			arrLbl[2, 2] = label9;
			arrLbl[unRow, unCol].Visible = true;
			int[] arrNum = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
			Random rm = new Random();
			for(int i = 0; i < 8; i++) {
				int rmNum = rm.Next(i, 9);
				int temp = arrNum[i];
				arrNum[i] = arrNum[rmNum];
				arrNum[rmNum] = temp;
			}
			for(int i = 0; i < 9; i++) {
				arrLbl[i / 3, i % 3].Text = arrNum[i].ToString();
			}
			int cover = rm.Next(0, 9);
			unRow = cover / 3;
			unCol = cover % 3;
			arrLbl[unRow, unCol].Visible = false;
			playing = true;
			btnGiveup.Visible = true;
			btnPlay.Visible = false;
		}

		private void btnGiveup_Click(object sender, EventArgs e) {
			Random rm=new Random();
			int num = rm.Next(0, maxWarning);
			MessageBox.Show(warning[num], "鄙视", MessageBoxButtons.OK, MessageBoxIcon.Warning);
			btnPlay.Visible = true;
			btnGiveup.Visible = false;
		}
    }
}


```

###完整工程
[度盘下载](http://pan.baidu.com/s/1c0hcgzY)