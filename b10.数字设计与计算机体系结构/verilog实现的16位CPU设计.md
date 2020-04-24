# verilog实现的16位CPU设计

------
## 整体电路图

![整体电路图](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image193.png)

![整体电路图](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image194.png)

#### CPU状态图

![CPU状态图](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image195.png)


idle代表没有工作，exec代表在工作
## 实验设计思路
五级流水线，增加硬件消耗换取时间的做法。
具体每一部分写什么将由代码部分指明。
## 完整代码
### headfile.v
头文件定义。包含整个工程中的特殊变量定义。后文中只用到gr0到gr3部分，因此该部分没写gr4到gr7，有需要的同学请自行加上。
```
`ifndef HEADFILE_H_

//State for CPU
`define	idle		1'b0
`define	exec		1'b1

//Data transfer & Arithmetic
`define  NOP		5'b00000
`define  HALT		5'b00001
`define  LOAD		5'b00010
`define  STORE		5'b00011
`define  LDIH		5'b10000
`define  ADD		5'b01000
`define	ADDI		5'b01001
`define	ADDC		5'b10001
`define	CMP		5'b01100

//Logical / shift
`define	AND		5'b01101
`define	SLL		5'b00100
`define	SLA		5'b00101

//Control
`define	JUMP		5'b11000
`define	JMPR		5'b11001
`define	BZ			5'b11010
`define	BNZ		5'b11011
`define	BN			5'b11100
`define	BC			5'b11110

//Add by myself
`define	SUB   	5'b01010
`define 	SUBI  	5'b01011
`define 	SUBC  	5'b10010
`define 	OR    	5'b01110
`define 	XOR   	5'b01111
`define 	SRL   	5'b00110
`define 	SRA   	5'b00111
`define 	BNN   	5'b11101
`define 	BNC   	5'b11111

//gr
`define gr0 3'b000
`define gr1 3'b001
`define gr2 3'b010
`define gr3 3'b011

`endif
```
### CPU.v
这个是整个工程的顶层模块。输入100MHz时钟信号，四个开关选择控制七段译码管显示的内容，用button来控制CPU的一次流水线。
首先三个部分的时钟快慢要求不一样。七段译码器的时钟要求最快，要实时显示内容；memory的时钟要求较快，在PCPU下一级流水线到来之前完成数据读写。PCPU模块的时钟要求最慢，这个只是相对前面来说较慢。整个CPU的工作频率是比较快的。
```
`timescale 1ns / 1ps

module CPU(
	input clk,
	input enable,
	input reset,
	input [3:0] SW,
	input start,
	input button,
	output [6:0] light,
	output [3:0] en
    );

	wire PCPU_clk;
	wire MEM_clk;
	wire LIGHT_clk;
	
	wire [15:0] d_datain;
	wire [15:0] i_datain;
	wire [3:0] select_y;
	wire [7:0] d_addr;
	wire [15:0] d_dataout;
	wire d_we;
	wire [7:0] i_addr;
	wire [15:0] y;
	
	clk_div getMEMclk(
		.orgin_clk(clk),
		.reset(reset),
		.div(16'b0100_0000_0000_0000),
		.div_clk(MEM_clk)
	);
	
	clk_div getLIGHTclk(
		.orgin_clk(clk),
		.reset(reset),
		.div(16'b0010_0000_0000_0000),
		.div_clk(LIGHT_clk)
	);
	
	PCPUcontroller PCPUctrl(
		.myclk(clk),
		.button(button),
		.reset(reset),
		.sense(PCPU_clk)
	);
	
	PCPU pcpu(
		.clock(PCPU_clk),
		.enable(enable),
		.reset(reset),
		.start(start),
		.d_datain(d_datain),
		.i_datain(i_datain),
		.select_y(SW),
		.d_addr(d_addr),
		.d_dataout(d_dataout),
		.d_we(d_we),
		.i_addr(i_addr),
		.y(y)
	);
	
	I_mem i_mem(
		.mem_clk(MEM_clk),
		.addr(i_addr),
		.rdata(i_datain)
	);
	
	D_mem d_mem(
		.mem_clk(MEM_clk),
		.dwe(d_we),
		.addr(d_addr),
		.wdata(d_dataout),
		.rdata(d_datain)
	);
	
	light_show show_light(
		.light_clk(LIGHT_clk),
		.reset(reset),
		.y(y),
		.light(light),
		.en(en)
	);

endmodule
```
### clk_div.v
时钟分频模块，要是开始做CPU设计了还不会时钟分频的话，那我没话说了。不解释，贴代码。
```
`timescale 1ns / 1ps

module clk_div(
	input orgin_clk,
	input reset,
	input [15:0] div,
	output reg div_clk
    );
	
	reg [15:0] count;
	
	always@(posedge orgin_clk or posedge reset)
	begin
		if(reset)
		begin
			div_clk <= 0;
			count <= 0;
		end
		else
		begin
			if(count == div)
			begin
				div_clk <= ~div_clk;
				count <= 0;
			end
			else
				count <= count + 1'b1;
		end
	end


endmodule
```
### PCPUcontroller.v
PCPU模块的状态控制模块。因为用的button来手动控制CPU的流水线，以免时钟太快一下子就跑完了。实现的方法是用状态机，加入trap状态，实现消抖。具体想不明白的话，建议自己画一下状态机转移图，聪明的你一定会明白的。
```
`timescale 1ns / 1ps

module PCPUcontroller(
	input myclk,
	input button,
	input reset,
	output reg sense
    );

	parameter STOP = 2'b00, INC = 2'b01, TRAP = 2'b10;
	
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
				if(button)	nextstate <= INC;
				else			nextstate <= STOP;
			INC:				nextstate <= TRAP;
			TRAP:
				if(button)	nextstate <= TRAP;
				else			nextstate <= STOP;
			default:			nextstate <= STOP;
		endcase
	end
	
	always@(*)
	begin
		if(reset)
			sense <= 0;
		else
			case(state)
				INC:		sense <= 1'b1;
				default:	sense <= 1'b0;
			endcase
	end

endmodule
```
### PCPU.v
整个工程中最核心的部分。注释部分是冲突处理之后的。如不需要冲突处理，把注释部分指明的代码注释掉即可。对应于前图中的五级流水线，该部分的代码亦分为五部分，请自行研啃。
```
`timescale 1ns / 1ps
`include"headfile.v"

module PCPU(
	input clock,
	input enable,
	input reset,
	input start,
	input [15:0] d_datain,
	input [15:0] i_datain,
	input [3:0] select_y,
	output wire [7:0] d_addr,
	output wire [15:0] d_dataout,
	output wire d_we,
	output wire [7:0] i_addr,
	output reg [15:0] y
    );

	reg state;
	reg [7:0] pc;
	reg [15:0] id_ir;
	reg [15:0] ex_ir, reg_A, reg_B, smdr;
	reg [15:0] mem_ir, reg_C, smdr1; reg dw; reg flag; reg [15:0] ALUo;reg zf, nf, cf;
	reg [15:0] wb_ir, reg_C1;
	
	reg [15:0] gr[0:7];
	
	assign d_dataout = smdr1;
	assign d_we = dw;
	assign d_addr = reg_C[7:0];
	assign i_addr = pc;
	
	/*******CPUcontrol**********************/
	reg nextstate;
	
	always@(posedge clock or posedge reset)
	begin
		if(reset)
			state <= `idle;
		else
			state <= nextstate;
	end
	
	always@(*)
	begin
		case(state)
			`idle:
				if((enable == 1'b1) && (start == 1'b1))
					nextstate <= `exec;
				else
					nextstate <= `idle;
			`exec:
				if((enable == 1'b0) || (wb_ir[15:11] == `HALT))
					nextstate <= `idle;
				else
					nextstate <= `exec;
		endcase
	end
	
	/***************************************/
	
	/****************IF*********************/
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			id_ir <= 16'b0000_0000_0000_0000;
			pc <= 8'b0000_0000;
		end
		else if(state == `exec)
		begin
			/*************Hazard*******************/
			if((id_ir[15:11] == `LOAD)
			 &&(i_datain[15:11] == `ADD) 
			 &&((id_ir[10:8] == i_datain[7:4]) 
			  ||(id_ir[10:8] == i_datain[3:0])))
			begin
				id_ir <= 16'bxxxx_xxxx_xxxx_xxxx;
				pc <= pc;
			end
			/**************************************/
			else
			begin
				id_ir <= i_datain;
				if(((mem_ir[15:11] == `BZ)  && (zf == 1'b1))
				 ||((mem_ir[15:11] == `BN)  && (nf == 1'b1))
				 ||((mem_ir[15:11] == `BC)  && (cf == 1'b1))
				 ||((mem_ir[15:11] == `BNZ) && (zf == 1'b1))
				 ||((mem_ir[15:11] == `BNN) && (nf == 1'b1))
				 ||((mem_ir[15:11] == `BNZ) && (cf == 1'b1)))
					pc <= reg_C[7:0];
				else if((mem_ir[15:11] == `JUMP)
						||(mem_ir[15:11] == `JMPR))
					pc <= reg_C[7:0];
				else
					pc <= pc + 1'b1;
			end
		end
		else
		begin
			pc <= pc;
			id_ir <= id_ir;
		end
	end
	
	/***************************************/
	
	/****************ID*********************/
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			ex_ir <= 16'b0000_0000_0000_0000;
			reg_A <= 16'b0000_0000_0000_0000;
			reg_B <= 16'b0000_0000_0000_0000;
			smdr <= 16'b0000_0000_0000_0000;
		end
		else if(state == `exec)
		begin
			ex_ir <= id_ir;
			if(id_ir[15:11] == `STORE)	//for Hazard Mode
				smdr <= ALUo;
			//reg_A
			/********************Hazard**********************/
			if(wb_ir[15:11] == `LOAD && id_ir[7:4] == wb_ir[10:8])
				reg_A <= reg_C1;
			else if(mem_ir[15:11] == `LOAD && id_ir[7:4] == mem_ir[10:8])
				reg_A <= d_datain;
			else if(ex_ir[15:11] != `LOAD && id_ir[7:4] == ex_ir[10:8])
				reg_A <= ALUo;
			else if(mem_ir[15:11] != `LOAD && id_ir[7:4] == mem_ir[10:8])
				reg_A <= reg_C;	
			else if(wb_ir[15:11] != `LOAD && id_ir[7:4] == wb_ir[10:8])
				reg_A <= reg_C1;
			else
			begin
			/***********************************************/
				if((id_ir[15:11] == `BZ)
				 ||(id_ir[15:11] == `BN)
				 ||(id_ir[15:11] == `JMPR)
				 ||(id_ir[15:11] == `BC)
				 ||(id_ir[15:11] == `BNZ)
				 ||(id_ir[15:11] == `BNN)
				 ||(id_ir[15:11] == `BNC)
				 ||(id_ir[15:11] == `ADDI)
				 ||(id_ir[15:11] == `SUBI)
				 ||(id_ir[15:11] == `LDIH))
					reg_A <= gr[(id_ir[10:8])];
				else
					reg_A <= gr[(id_ir[6:4])];
			end
			//reg_B
			/********************Hazard*********************/
			if(wb_ir[15:11] == `LOAD && id_ir[3:0] == wb_ir[10:8])
				reg_B <= reg_C1;
			else if(mem_ir[15:11] == `LOAD && id_ir[3:0] == mem_ir[10:8])
				reg_B <= d_datain;
			else if(ex_ir[15:11] != `LOAD && id_ir[3:0] == ex_ir[10:8])
				reg_B <= ALUo;
			else if(mem_ir[15:11] != `LOAD && id_ir[3:0] == mem_ir[10:8])
				reg_B <= reg_C;
			else if(wb_ir[15:11] != `LOAD && id_ir[3:0] == wb_ir[10:8])
				reg_B <= reg_C1;	
			else
			begin
			/***********************************************/
				if((id_ir[15:11] == `LOAD)
				 ||(id_ir[15:11] == `SLL)
				 ||(id_ir[15:11] == `SLA)
				 ||(id_ir[15:11] == `SRL)
				 ||(id_ir[15:11] == `SRA))
					reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
				else if((id_ir[15:11] == `BZ)
						||(id_ir[15:11] == `BN)
						||(id_ir[15:11] == `JUMP)
						||(id_ir[15:11] == `JMPR)
						||(id_ir[15:11] == `BC)
						||(id_ir[15:11] == `BNZ)
						||(id_ir[15:11] == `BNN)
						||(id_ir[15:11] == `BNC)
						||(id_ir[15:11] == `ADDI))
					reg_B <= {8'b0000_0000, id_ir[7:0]};
				else if((id_ir[15:11] == `STORE))
				begin
					reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
					//smdr <= gr[(id_ir[10:8])];	//for not Hazard
				end
				else if(id_ir[15:11] == `LDIH)
					reg_B <= {id_ir[7:0], 8'b0000_0000};
				else
					reg_B <= gr[id_ir[2:0]];
			end
		end
		else
		begin
			ex_ir <= ex_ir;
			reg_A <= reg_A;
			reg_B <= reg_B;
			smdr <= smdr;
		end
	end
	/***************************************/
	
	/****************EX*********************/
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			mem_ir <= 16'b0000_0000_0000_0000;
			reg_C <= 16'b0000_0000_0000_0000;
			smdr1 <= 16'b0000_0000_0000_0000;
			zf <= 1'b0;
			nf <= 1'b0;
			cf <= 1'b0;
			dw <= 1'b0;
		end
		else if(state == `exec)
		begin
			mem_ir <= ex_ir;
			reg_C <= ALUo;
			cf <= cf_temp;
			if((ex_ir[15:11] == `ADD)
			 ||(ex_ir[15:11] == `CMP)
			 ||(ex_ir[15:11] == `ADDI)
			 ||(ex_ir[15:11] == `SUB)
			 ||(ex_ir[15:11] == `SUBI)
			 ||(ex_ir[15:11] == `LDIH)
			 ||(ex_ir[15:11] == `SLL)
			 ||(ex_ir[15:11] == `SRL)
			 ||(ex_ir[15:11] == `SLA)
			 ||(ex_ir[15:11] == `SRA)
			 ||(ex_ir[15:11] == `ADDC)
			 ||(ex_ir[15:11] == `SUBC))
			begin
				if(ALUo == 16'b0000_0000_0000_0000)
					zf <= 1'b1;
				else
					zf <= 1'b0;
				
				if(ALUo[15] == 1'b1)
					nf <= 1'b1;
				else
					nf <= 1'b0;
			end
			else if(ex_ir[15:11] == `STORE)
			begin
				dw <= 1'b1;
				smdr1 <= smdr;
			end
		end
		else
		begin
			reg_C <= reg_C;
			smdr1 <= smdr1;
			dw <= dw;
		end
	end
	//ALU
	reg cf_temp;
	always@(*)
	begin
		if(state == `exec)
		begin
			if(reset)
			begin
				ALUo <= 16'b0000_0000_0000_0000;
				cf_temp <= 0;
			end
			else
				case(ex_ir[15:11])
					`NOP:		{cf_temp, ALUo} <= {cf_temp, ALUo};
					`HALT:	{cf_temp, ALUo} <= {cf_temp, ALUo};
					`AND:		{cf_temp, ALUo} <= {cf_temp, reg_A & reg_B};
					`OR:		{cf_temp, ALUo} <= {cf_temp, reg_A | reg_B};
					`XOR:		{cf_temp, ALUo} <= {cf_temp, reg_A ^ reg_B};
					`SLL:		{cf_temp, ALUo} <= {cf_temp, reg_A << reg_B};
					`SRL:		{cf_temp, ALUo} <= {cf_temp, reg_A >> reg_B};
					`SLA:		{cf_temp, ALUo} <= {cf_temp, reg_A <<< reg_B};
					`SRA:		{cf_temp, ALUo} <= {cf_temp, reg_A >>> reg_B};
					`JUMP:	{cf_temp, ALUo} <= {cf_temp, reg_B};
					`LDIH:	{cf_temp, ALUo} <= {1'b0 + reg_A} + {1'b0 + reg_B};
					`ADD:		{cf_temp, ALUo} <= {1'b0 + reg_A} + {1'b0 + reg_B};
					`ADDI:	{cf_temp, ALUo} <= {1'b0 + reg_A} + {1'b0 + reg_B};
					`ADDC:	{cf_temp, ALUo} <= {1'b0 + reg_A} + {1'b0 + reg_B} + cf;
					`SUB:		{cf_temp, ALUo} <= {1'b0 + reg_A} - {1'b0 + reg_B};
					`SUBI:	{cf_temp, ALUo} <= {1'b0 + reg_A} - {1'b0 + reg_B};
					`SUBC:	{cf_temp, ALUo} <= {1'b0 + reg_A} - {1'b0 + reg_B} - cf;
					`CMP:		{cf_temp, ALUo} <= {1'b0 + reg_A} - {1'b0 + reg_B};
					`LOAD:	begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`STORE:	begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`JMPR:	begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BZ:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BNZ:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BN:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BNN:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BC:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					`BNC:		begin ALUo <= reg_A + reg_B; cf_temp <= cf_temp; end
					default:	{cf_temp, ALUo} <= {cf_temp, ALUo};
				endcase
		end
	end
	/***************************************/
	
	/***************MEM*********************/
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			reg_C1 <= 16'b0000_0000_0000_0000;
			wb_ir <= 16'b0000_0000_0000_0000;
		end
		else if(state == `exec)
		begin
			wb_ir <= mem_ir;
			if(mem_ir[15:11] == `LOAD)
				reg_C1 <= d_datain;
			else
				reg_C1 <= reg_C;
		end
	end
	/***************************************/
	
	/****************WB********************/
	always@(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			gr[0] <= 16'b0000_0000_0000_0000;
			gr[1] <= 16'b0000_0000_0000_0000;
			gr[2] <= 16'b0000_0000_0000_0000;
			gr[3] <= 16'b0000_0000_0000_0000;
			gr[4] <= 16'b0000_0000_0000_0000;
			gr[5] <= 16'b0000_0000_0000_0000;
			gr[6] <= 16'b0000_0000_0000_0000;
			gr[7] <= 16'b0000_0000_0000_0000;
		end
		else if(state == `exec)
		begin
			if((wb_ir[15:11] == `LOAD)
			 ||(wb_ir[15:11] == `ADD)
			 ||(wb_ir[15:11] == `ADDI)
			 ||(wb_ir[15:11] == `ADDC)
			 ||(wb_ir[15:11] == `SUB)
			 ||(wb_ir[15:11] == `SUBI)
			 ||(wb_ir[15:11] == `SUBC)
			 ||(wb_ir[15:11] == `AND)
			 ||(wb_ir[15:11] == `OR)
			 ||(wb_ir[15:11] == `XOR)
			 ||(wb_ir[15:11] == `SLL)
			 ||(wb_ir[15:11] == `SRL)
			 ||(wb_ir[15:11] == `SLA)
			 ||(wb_ir[15:11] == `SRA)
			 ||(wb_ir[15:11] == `LDIH))
				gr[wb_ir[10:8]] <= reg_C1;
		end
		else
		begin
		
		end
	end
	/***************************************/
	
	/**************select Y*****************/
	always@(*)
	begin
		case(select_y)
			4'b0000:	y <= reg_C;
			4'b0001:	y <= reg_A;
			4'b0010:	y <= reg_B;
			4'b0011:	y <= {pc, 8'b0000_0000};
			4'b0100:	y <= id_ir;
			4'b0101:	y <= smdr;
			4'b0110:	y <= reg_C1;
			4'b0111:	y <= smdr1;
			4'b1000:	y <= ex_ir;
			4'b1001:	y <= mem_ir;
			4'b1010:	y <= wb_ir;
			default: y <= reg_C;
		endcase
	end
	/***************************************/
endmodule
```
### I_mem.v
指令存储区域。把指令写在这一部分，即可让CPU跑指定的指令。
```
`timescale 1ns / 1ps
`include"headfile.v"

module I_mem(
	input mem_clk,
	input [7:0] addr,
	output wire [15:0] rdata
    );

	reg [15:0] i_mem [255:0];
	assign rdata = i_mem[addr];
	
	always@(posedge mem_clk)
	begin
		case(addr)
			0:		i_mem[addr] <= {`ADDI, `gr1, 4'b1010, 4'b1011};
			1:		i_mem[addr] <= {`LDIH, `gr2, 4'b0011, 4'b1100};
			2:		i_mem[addr] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};
			3:		i_mem[addr] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0000};
			4:		i_mem[addr] <= {`ADDI, `gr1, 4'b0001, 4'b0001};
			5:		i_mem[addr] <= {`LDIH, `gr2, 4'b0001, 4'b0001};
			6:		i_mem[addr] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};
			7:		i_mem[addr] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0001};
			8:		i_mem[addr] <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000};
			9:		i_mem[addr] <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0001};
			10:	i_mem[addr] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};
			11:	i_mem[addr] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0001};
			12:	i_mem[addr] <= {`JUMP, 4'b0000, 4'b0010, 4'b1000};
			13:	i_mem[addr] <= {`ADDI, `gr1, 4'b1010, 4'b1011};
			40:	i_mem[addr] <= {`HALT, 11'b000_0000_0000};
			default:		i_mem[addr] <= {`NOP, 11'b000_0000_0000};
		endcase
	end

endmodule
```
### D_mem.v
数据存储区域。结构简单，根据dwe信号来决定是读取还是写入。
```
`timescale 1ns / 1ps
`include"headfile.v"

module D_mem(
	input mem_clk,
	input dwe,
	input [7:0] addr,
	input [15:0] wdata,
	output wire [15:0] rdata
    );
	
	reg [15:0] d_mem [255:0];
	assign rdata = d_mem[addr];
	
	always@(posedge mem_clk)
	begin
			if(dwe)
				d_mem[addr] <= wdata;
	end


endmodule
```
### light_show.v
七段译码管显示模块。
```
`timescale 1ns / 1ps

module light_show(
	input light_clk,
	input reset,
	input [15:0] y,
	output reg [6:0] light,
	output reg [3:0] en
    );

	reg [1:0] dp;
	reg [3:0] four;

	always@(posedge light_clk or posedge reset)
	begin
		if(reset)
			dp <= 0;
		else
		begin
			dp <= dp + 1'b1;
		end
	end
	
	always@(*)
	begin
		if(reset)
		begin
			four <= 0;
			en <= 0;
		end
		else
		begin
			case(dp)
				0:			begin four <= y[3:0]; en <= 4'b1110; end
				1:			begin four <= y[7:4]; en <= 4'b1101; end
				2:			begin four <= y[11:8]; en <= 4'b1011; end
				3:			begin four <= y[15:12]; en <= 4'b0111; end
				default:	begin four <= 0; en <= 0; end
			endcase
		end
	end
	
	always@(*)
	begin
		if(reset)
		begin
			light <= 7'b0001000;
		end
		else
		begin
			case(four)
				0:				light <= 7'b0000001;
				1:				light <= 7'b1001111;
				2:				light <= 7'b0010010;
				3:				light <= 7'b0000110;
				4:				light <= 7'b1001100;
				5:				light <= 7'b0100100;
				6:				light <= 7'b0100000;
				7:				light <= 7'b0001111;
				8:				light <= 7'b0000000;
				9:				light <= 7'b0000100;
				4'b1010:		light <= 7'b0001000;
				4'b1011:		light <= 7'b1100000;
				4'b1100:		light <= 7'b0110001;
				4'b1101:		light <= 7'b1000010;
				4'b1110:		light <= 7'b0110000;
				4'b1111:		light <= 7'b0111000;
				default:		light <= 7'b0000001;
			endcase
		end
	end

endmodule
```
### VTF_CPU.v
仿真测试文件。
```
`timescale 1ns / 1ps

module VTF_CPU;

	// Inputs
	reg clk;
	reg enable;
	reg reset;
	reg [3:0] SW;
	reg start;
	reg button;

	// Outputs
	wire [6:0] light;
	wire [3:0] en;

	// Instantiate the Unit Under Test (UUT)
	CPU uut (
		.clk(clk), 
		.enable(enable), 
		.reset(reset), 
		.SW(SW), 
		.start(start), 
		.button(button), 
		.light(light), 
		.en(en)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		enable = 0;
		reset = 0;
		SW = 0;
		start = 0;
		button = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		$display("pc:     id_ir      :reg_A:reg_B:reg_C:da:dd:  :w:reC1:gr1 :gr2 : gr3");
		$monitor("%h:%b:%h:%h:%h:%h:%h:%b:%h:%h:%h:%h", 
			uut.pcpu.pc, uut.pcpu.id_ir, uut.pcpu.reg_A, uut.pcpu.reg_B, uut.pcpu.reg_C,
			uut.d_addr, uut.d_dataout, uut.d_we, uut.pcpu.reg_C1, uut.pcpu.gr[1], uut.pcpu.gr[2], uut.pcpu.gr[3]);
			
      enable <= 0; start <= 0;
		// Add stimulus here
		#10 reset <= 1;
		#10 reset <= 0;
		#10 enable <= 1;
		#10 start <=1;
		//#10 start <= 0;
		#100;
	end
   always #20 button = ~button;
	always #5 clk = ~clk;
endmodule

```