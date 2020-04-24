# verilog实现毫秒计时器

----------
## 整体电路图
![整体电路图](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image177.png)

## 实验状态图
![实验状态图](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image178.png)
Stop代表没有计时，Start代表开始计时，Inc代表计时器加1，Trap代表inc按钮按下去时候的消抖状态。

## 状态编码表
![状态编码表](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image179.png)

## 实验设计思路
- 时钟分频：用一个diver=49999来让count从0根据100MHz的内部时钟变化到diver让myclk取反一次，以达到myclk的频率为1KHz的时钟。
- 计时器：以myclk来触发，从小数点后第三位开始计数，每次+1，用往前面进位的方法，从而不需要分成四个自定义时钟。
- 显示器：定义好七段译码器的数字显示，然后每次挑选一位数字，分频每次显示一位，小数点同最高位同时显示消失。分频足够低的时候，肉眼的视觉暂留效果，看起来就是同时显示。
- 亮点：代码全程用模块实现，简单易读易维护。

----------

## 完整代码
```
//counter.v
`timescale 1ns / 1ps

module counter(
	input myclk,
	input reset,
	input cen,
	output [15:0] number
    );
	 
	wire up0, up1, up2;
	
	counter4bit c1(
		.myclk(myclk),
		.reset(reset),
		.cen(cen),
		.four(number[3:0]),
		.up(up0)
	);
	
	counter4bit c2(
		.myclk(myclk),
		.reset(reset),
		.cen(cen & up0),
		.four(number[7:4]),
		.up(up1)
	);
	
	counter4bit c3(
		.myclk(myclk),
		.reset(reset),
		.cen(cen & up0 & up1),
		.four(number[11:8]),
		.up(up2)
	);
	
	counter4bit c4(
		.myclk(myclk),
		.reset(reset),
		.cen(cen & up0 & up1 & up2),
		.four(number[15:12]),
		.up()
	);

endmodule
```

----------

```
//clk_div.v
`timescale 1ns / 1ps

module clk_div(
	input clk_in,
	input reset,
	output reg clk_out
    );
	parameter diver = 49999;//for FPGA
	//parameter diver = 4;//for test
	reg [15:0] count;//just for 49999 or warning
	
	always@(posedge clk_in or posedge reset)
	begin
		if(reset)
		begin
			count <= 0;
			clk_out <= 1'b0;
		end
		else if(count == diver)
		begin
			clk_out <= ~clk_out;
			count <= 0;
		end
		else
		begin
			count <= count + 1'b1;
		end
	end

endmodule
```

----------

```
//MillisecondCounter.v
`timescale 1ns / 1ps

module MillisecondCounter(
	input start,
	input stop,
	input inc,
	input clk,
	input reset,
	output [3:0] en,
	output [6:0] light,
	output dot
    );
	
	wire myclk;
	wire cen;
	wire [15:0] number;
	
	clk_div d(
		.clk_in(clk),
		.reset(reset),
		.clk_out(myclk)
	);
	
	state_transform st(
		.start(start),
		.stop(stop),
		.inc(inc),
		.myclk(myclk),
		.reset(reset),
		.cen(cen)
	);
	
	counter ct(
	.myclk(myclk),
	.reset(reset),
	.cen(cen),
	.number(number[15:0])
    );
	 
	show_number sn(
	.myclk(myclk),
	.reset(reset),
	.number(number[15:0]),
	.en(en[3:0]),
	.light(light[6:0]),
	.dot(dot)
    );

endmodule
```

----------

```
//counter4bit.v
`timescale 1ns / 1ps

module counter4bit(
	input myclk,
	input reset,
	input cen,
	output reg [3:0] four,
	output up
    );

	assign up = (four == 4'b1001) ? 1'b1 : 1'b0;
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			four <= 0;
		else if(cen)
		begin
			if(four == 4'b1001)
				four <= 0;
			else
				four <= four + 1'b1;
		end
	end

endmodule
```

----------

```
//state_transform.v
`timescale 1ns / 1ps

module state_transform(
	input start,
	input stop,
	input inc,
	input myclk,
	input reset,
	output reg cen
    );
	parameter STOP = 2'b00, START = 2'B01, INC = 2'b10, TRAP = 2'b11;
	
	reg [1:0] state, nextstate;
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			state <= STOP;
		else
			state <= nextstate;
	end
	
	always@(*)
	begin
		case(state)
			STOP:
				if(stop)			nextstate <= STOP;
				else if(start)	nextstate <= START;
				else if(inc)	nextstate <= INC;
				else				nextstate <= STOP;
			START:
				if(start)		nextstate <= START;
				else if(stop)	nextstate <= STOP;
				else				nextstate <= START;
			INC:
									nextstate <= TRAP;
			TRAP:
				if(inc)			nextstate <= TRAP;
				else				nextstate <= STOP;
			default:
									nextstate <= STOP;
		endcase
	end
	
	always@(*)
	begin
		case(state)
			STOP:		cen <= 1'b0;
			START:	cen <= 1'b1;
			INC:		cen <= 1'b1;
			TRAP:		cen <= 1'b0;
			default:	cen <= 1'b0;
		endcase
	end

endmodule
```

----------

```
//show_number.v
`timescale 1ns / 1ps

module show_number(
	input myclk,
	input reset,
	input [15:0] number,
	output reg [3:0] en,
	output reg [6:0] light,
	output dot
    );
	 
	reg [1:0] index;
	reg [3:0] num_index;
	
	assign dot = (index == 2'b11) ? 1'b0 : 1'b1;
	
	always@(posedge myclk or posedge reset)
	begin
		if(reset)
			index <= 0;
		else
			index <= index + 1'b1;
	end
	
	always@(*)
	begin
		case(index)
			2'b00:	en <= 4'b1110;
			2'b01:	en <= 4'b1101;
			2'b10:	en <= 4'b1011;
			2'b11:	en <= 4'b0111;
			default:	en <= 4'b1111;
		endcase
	end

	always@(*)
	begin
		case(index)
			2'b00:	num_index <= number[3:0];
			2'b01:	num_index <= number[7:4];
			2'b10:	num_index <= number[11:8];
			2'b11:	num_index <= number[15:12];
			default:	num_index <= 4'b0000;
		endcase
	end

	always@(*)
	begin
		case(num_index)
			4'b0000: light <= 7'b0000001;  
			4'b0001: light <= 7'b1001111;  
			4'b0010: light <= 7'b0010010;  
			4'b0011: light <= 7'b0000110;  
			4'b0100: light <= 7'b1001100;  
			4'b0101: light <= 7'b0100100;  
			4'b0110: light <= 7'b0100000;  
			4'b0111: light <= 7'b0001111;  
			4'b1000: light <= 7'b0000000;  
			4'b1001: light <= 7'b0000100;  
			default: light <= 7'b1111111; 
		endcase
	end


endmodule
```

----------

仿真测试文件
```
//VTF_Millisecond.v
`timescale 1ns / 1ps

module VTF_Millisecond;

	// Inputs
	reg start;
	reg stop;
	reg inc;
	reg clk;
	reg reset;

	// Outputs
	wire [3:0] en;
	wire [6:0] light;
	wire dot;

	// Instantiate the Unit Under Test (UUT)
	MillisecondCounter uut (
		.start(start), 
		.stop(stop), 
		.inc(inc), 
		.clk(clk), 
		.reset(reset), 
		.en(en), 
		.light(light), 
		.dot(dot)
	);

	initial begin
		// Initialize Inputs
		start = 0;
		stop = 0;
		inc = 0;
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 0;
		// Add stimulus here
		start = 1;
		#1200;
		start = 0;
		stop = 1;
		#200;
		inc = 1;
		#200;
		stop = 1;
		#200;
		start = 1;
		#200;
		inc = 0;
		#200;
		reset = 1;
		#200;
		reset = 0;
	end
   
	always #2 clk = ~clk;
	
endmodule

```