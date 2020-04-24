# verilog实现VGA显示方块屏幕保护

----------
## 输入和输出
- 时钟信号 clk
- 复位信号 reset
- rgb三颜色输出 [2:0] r,g, [1:0] b
- 行信号输出 hs
- 列信号输出 vs

----------
## 参数设定
设定边界，决定改变方向与否

```
parameter UP_BOUND = 31;
parameter DOWN_BOUND = 510;
parameter LEFT_BOUND = 144;
parameter RIGHT_BOUND = 783;
```
状态机决定下一次扫描输出的颜色
```
parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
reg [2:0] state, nextstate;
reg [2:0] nextr, nextg;
reg [1:0] nextb;
```

----------
## 程序处理
### 行信号和列信号的处理
行信号和列信号决定着当前像素是否显示出来。该程序选择的是在25Hz下640 * 480的分辨率显示。具体想改变分辨率的，可以在参考网上的资料。VGA的显示是逐行扫描像素点，除了可见区域，还有不可见区域的像素点，因此可以通过边界控制是否输出。
```
	wire myclk;
	reg [1:0] count;
	reg [9:0] hcount, vcount;
	
	assign myclk = count[1];
	always@(posedge clk)
	begin
		if(reset)
			count <= 0;
		else
			count <= count + 1'b1;
	end
	
	assign hs = (hcount < 96) ? 1'b0 : 1'b1;
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			hcount <= 0;
		else if(hcount == 799)
			hcount <= 0;
		else
			hcount <= hcount + 1'b1;
	end
	
	assign vs = (vcount < 2) ? 1'b0 : 1'b1;
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			vcount <= 0;
		else if(hcount == 799) 
		begin
			if(vcount == 520)
				vcount <= 0;
			else
				vcount <= vcount + 1'b1;
		end
		else
			vcount <= vcount;
	end
```
### 颜色持续变换形成彩色轮变
彩色变化，通过状态机实现。每一列像素点对应一个颜色，但是方块区域才通过彩色输出，否则输出黑色，形成了彩色轮转。
```
	always@(posedge myclk or posedge reset)
	begin
		if(reset) 
		begin
			r <= 0;
			g <= 0;
			b <= 0;
		end
		else begin
			if((vcount >= up_pos) 
			&& (vcount <= down_pos)
			&& (hcount >= left_pos) 
			&& (hcount<=right_pos)) 
			begin
				r <= nextr; 
				g <= nextg; 
				b <= nextb;
			end
			else 
			begin
				r <= 3'b000;
				g <= 3'b000;
				b <= 2'b00;
			end
		end
	end
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			state <= S0;
		else
			state <= nextstate;
	end
	
	always@(*)
	begin
		case(state)
			S0:		nextstate <= S1;
			S1:		nextstate <= S2;
			S2:		nextstate <= S3;
			S3:		nextstate <= S0;
			default:	nextstate <= S0;
		endcase
	end
	
	always@(*)
	begin
		case(state)
			S0:		begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b00; end
			S1:		begin nextr <= 3'b000; nextg <= 3'b111; nextb <= 2'b00; end
			S2:		begin nextr <= 3'b000; nextg <= 3'b000; nextb <= 2'b11; end
			S3:		begin nextr <= 3'b111; nextg <= 3'b111; nextb <= 2'b00; end
			default:	begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b11; end
		endcase
	end
```
### 信号处理
但列信号由输出变成非输出时触发。在这个情况下，应该处理下一帧的方向和速度。详见代码。
```
	always@(negedge vs or posedge reset)
	begin
		if(reset)
		begin
			h_speed <= 1;
			v_speed <= 0;
		end
		else 
		begin
			if(up_pos == UP_BOUND)
				v_speed <= 1;
			else if(down_pos == DOWN_BOUND)
				v_speed <= 0;
			else
				v_speed <= v_speed;
			
			if (left_pos == LEFT_BOUND)
				h_speed <= 1;
			else if (right_pos == RIGHT_BOUND)
				h_speed <= 0;
			else
				h_speed <= h_speed;
		end
	end
	
	always@(posedge vs or posedge reset)
	begin
		if(reset) 
		begin
			up_pos <= 391;
			down_pos <= 510;
			left_pos <= 384;
			right_pos <= 543;
		end
		else
		begin
			if(v_speed) 
			begin
				up_pos <= up_pos + 1'b1;
				down_pos <= down_pos + 1'b1;
			end
			else 
			begin
				up_pos <= up_pos - 1'b1;
				down_pos <= down_pos - 1'b1;
			end
			
			if(h_speed)
			begin
				left_pos <= left_pos + 1'b1;
				right_pos <= right_pos + 1'b1;
			end
			else 
			begin
				left_pos <= left_pos - 1'b1;
				right_pos <= right_pos - 1'b1;
			end
		end
	end
```



----------
## 完整代码

```
//main.v
`timescale 1ns / 1ps

module VGA(
    input clk,
    input reset,
    output reg [2:0] r,
    output reg [2:0] g,
    output reg [1:0] b,
    output hs,
    output vs
    );

	parameter UP_BOUND = 31;
	parameter DOWN_BOUND = 510;
	parameter LEFT_BOUND = 144;
	parameter RIGHT_BOUND = 783;
	
	parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
	reg [2:0] state, nextstate;
	reg [2:0] nextr, nextg;
	reg [1:0] nextb;
	
	reg h_speed, v_speed;
	reg [9:0] up_pos, down_pos, left_pos, right_pos;

	wire myclk;
	reg [1:0] count;
	reg [9:0] hcount, vcount;
	
	assign myclk = count[1];
	always@(posedge clk)
	begin
		if(reset)
			count <= 0;
		else
			count <= count + 1'b1;
	end
	
	assign hs = (hcount < 96) ? 1'b0 : 1'b1;
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			hcount <= 0;
		else if(hcount == 799)
			hcount <= 0;
		else
			hcount <= hcount + 1'b1;
	end
	
	assign vs = (vcount < 2) ? 1'b0 : 1'b1;
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			vcount <= 0;
		else if(hcount == 799) 
		begin
			if(vcount == 520)
				vcount <= 0;
			else
				vcount <= vcount + 1'b1;
		end
		else
			vcount <= vcount;
	end
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset) 
		begin
			r <= 0;
			g <= 0;
			b <= 0;
		end
		else begin
			if((vcount >= up_pos) 
			&& (vcount <= down_pos)
			&& (hcount >= left_pos) 
			&& (hcount<=right_pos)) 
			begin
				r <= nextr; 
				g <= nextg; 
				b <= nextb;
			end
			else 
			begin
				r <= 3'b000;
				g <= 3'b000;
				b <= 2'b00;
			end
		end
	end
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			state <= S0;
		else
			state <= nextstate;
	end
	
	always@(*)
	begin
		case(state)
			S0:		nextstate <= S1;
			S1:		nextstate <= S2;
			S2:		nextstate <= S3;
			S3:		nextstate <= S0;
			default:	nextstate <= S0;
		endcase
	end
	
	always@(*)
	begin
		case(state)
			S0:		begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b00; end
			S1:		begin nextr <= 3'b000; nextg <= 3'b111; nextb <= 2'b00; end
			S2:		begin nextr <= 3'b000; nextg <= 3'b000; nextb <= 2'b11; end
			S3:		begin nextr <= 3'b111; nextg <= 3'b111; nextb <= 2'b00; end
			default:	begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b11; end
		endcase
	end
	
	always@(negedge vs or posedge reset)
	begin
		if(reset)
		begin
			h_speed <= 1;
			v_speed <= 0;
		end
		else 
		begin
			if(up_pos == UP_BOUND)
				v_speed <= 1;
			else if(down_pos == DOWN_BOUND)
				v_speed <= 0;
			else
				v_speed <= v_speed;
			
			if (left_pos == LEFT_BOUND)
				h_speed <= 1;
			else if (right_pos == RIGHT_BOUND)
				h_speed <= 0;
			else
				h_speed <= h_speed;
		end
	end
	
	always@(posedge vs or posedge reset)
	begin
		if(reset) 
		begin
			up_pos <= 391;
			down_pos <= 510;
			left_pos <= 384;
			right_pos <= 543;
		end
		else
		begin
			if(v_speed) 
			begin
				up_pos <= up_pos + 1'b1;
				down_pos <= down_pos + 1'b1;
			end
			else 
			begin
				up_pos <= up_pos - 1'b1;
				down_pos <= down_pos - 1'b1;
			end
			
			if(h_speed)
			begin
				left_pos <= left_pos + 1'b1;
				right_pos <= right_pos + 1'b1;
			end
			else 
			begin
				left_pos <= left_pos - 1'b1;
				right_pos <= right_pos - 1'b1;
			end
		end
	end

endmodule
```