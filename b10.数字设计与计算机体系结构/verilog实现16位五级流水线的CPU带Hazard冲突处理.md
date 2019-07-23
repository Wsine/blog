# verilog实现16位五级流水线的CPU带Hazard冲突处理

该文是基于博主之前一篇博客[http://www.cnblogs.com/wsine/p/4292869.html](http://www.cnblogs.com/wsine/p/4292869.html)所增加的Hazard处理，相同的内容就不重复写了，可点击链接查看之前的博客。

### CPU设计

**该处理器的五级流水线设计：**
类似于MIPS体系架构依据流水线结构设计。只要CPU从缓存中获取数据，那么执行每条MIPS指令就被分成五个流水阶段，并且每个阶段占用固定的时间，通常是只耗费一个处理器时钟周期。

处理器在设计时，将处理器的执行阶段划分为以下五个阶段:
1. IF: Instruction Fetch，取指。从指令缓存（I-Cache）中获取下一条指令。
2. ID：Instruction Decode（Read Register），译码（读寄存器）。翻译指令，识别操作码和操作数，从寄存器堆中读取数据到ALU输入寄存器。
3. EX（ALU）：Execute，执行（算术/逻辑运算）。在一个时钟周期内，完成算术或逻辑操作。注意，浮点算术运算和整数乘除运算不能在一个时钟周期内完成。
4. MEM：Memory Access，内存数据读或者写。在该阶段，指令可以从数据缓存（D-Cache）中读/写内存变量。平均来说，大约四分之三的指令在这一阶段没有执行任何操作，为每条指令分配这个阶段是为了保证同一时刻不会有两条指令都访问数据缓存。
5. WB：Write Back，写回。操作完成后，将计算结果从ALU输出寄存器写回到通用寄存器中。

**该CPU用到的指令集,16位8个通用寄存器**

![CPUregister](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image148.png)

**该CPU的全部指令一览**

![Op1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image149.png)
![Op2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image150.png)
![Op3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image151.png)

**该CPU的系统框图**

![BlockDiagram](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image152.png)

### 设计思路：(部分代码太长处理为伪代码)

- CPU Control

时序逻辑，表示CPU当前状态，有两个枚举值exec和idle，分别是正在运行和空闲两种状态

![CPU Control](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image153.png)

- Instruction Fetch

时序逻辑，每一个上升沿从Instruction Memory中根据地址pc取出一条指令，LOAD指令需要根据不同的指令从当前CPU运算中特定位置读取；Branch指令及其标志位为true则Flush掉一条指令；跳转指令则直接跳转并处理pc值延后一个周期的情况，其余情况直接读取下一条指令

![IF1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image154.png)
![IF2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image155.png)
![IF3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image156.png)

- Instruction Decode （以reg_A为例子）

时序逻辑，根据不同的指令，从通用寄存器中取出相应的值出来作运算或者存储到Data Memory中；如果为Branch指令且标志位为true则需要Flush掉当前内容；否则如果冲突出现，则需要根据不同的运算指令从不同的地方取出内容

![ID1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image157.png)
![ID2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image158.png)
![ID3](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image159.png)
![ID4](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image160.png)

- Execute

时序逻辑，根据不同的运算指令作不同的运算；如果为存储指令则直接转移到下一级寄存器，并将写入指令标记为true；如果为其余指令，则保持当前内容不变

![EX](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image161.png)

- ALU

组合逻辑，根据不同的指令进行不同的运算，得注意SLA和SRA两条指令在verilog里面的做法。同时注意进位操作的处理。详细看代码。

![ALU](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image162.png)

- Memory Access

时序逻辑，只有当LOAD指令需要从Data Memory里面取出内容，其余情况把reg_C传递给reg_C1即可。cf进位标志在此阶段更新。

![MEM](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image163.png)

- Write Back

时序逻辑，对需要写回到寄存器的指令把运算结果写回到寄存器中，其余情况只需让寄存器保持不变

![WB](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image164.png)

- Instruction Memory

组合逻辑，根据地址的读入，输出一条指令

![IM](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image165.png)

- Data Memory

读取Data是组合逻辑，根据地址直接读取一条指令输出。
写入Data是时序逻辑，每一个周期可能会进行一次写入，根据dw信号进行写入，Memory的时钟频率需要比CPU的时钟快。

![DM](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image166.png)

### CPU仿真测试

Testbench内容

![Testbench](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image167.png)

在test中，通过每隔5个ns，时钟取反一次，CPU从button每20个ns进行一次反转即时钟周期为20ns，Memory时钟的设置为三个clk即15个ns反转一次，通过输出用到的通用寄存器和用到的data memory里面的变量来观察整个CPU的流程结果，测试CPU是否正确工作。以及观察仿真流程的变化过程测试CPU是否正常工作。

Instruction Memory:

![Instructino1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image168.png)
![Instructino2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image169.png)

**下面结果用16进制表示，括号内为10进制**
指令0：gr1原本初始化时为0，把gr1加上一个立即数AB，gr1为00AB
指令1：gr2原本初始化时为0，把gr2加上一个高八位3C，gr2为3C00
指令2：从gr1和gr2中取值相加，结果保存在gr3中，gr3应为3CAB
指令3：把gr3的值保存到data memory中的dm0，dm0为3CAB
指令4：gr1的值为00AB，加上一个立即数11，gr1为00BC
指令5：gr2的值为3C00，加上一个高八位立即数11，gr2为4D00
指令6：从gr1和gr2中取值相加，结果保存在gr3中，gr3应为4DBC
指令7：把gr3的值保存到data memory中的dm1，dm1为4DBC
指令8：从dm0中取值到gr1中，gr1为3CAB
指令9：从dm1中取值到gr2中，gr2为4DBC
指令10：从gr2和gr1中取值相减，结果保存在gr3中，gr3应为1111
指令11：把gr3的值保存到data memory中的dm2，dm2为1111
指令12：跳转指令，PC跳转到第16条指令
指令13：该指令不被执行，如gr1中出现3D55则出错
指令14：该指令不被执行，如gr1中出现3D55则出错
指令15：该指令不被执行，如gr1中出现3D55则出错
指令16：gr4原本初始化时为0，把gr4加上一个立即数14，gr4为0014(20)
指令17：CMP指令让两个相同的值相减让标志位 zf  =  1
指令18：zf = 1, 跳转到gr4 + 2 = 22的指令
指令19：该指令不被执行，如gr1中出现3C83则出错
指令20：该指令不被执行，如gr1中出现3C83则出错
指令21：该指令不被执行，如gr1中出现3C83则出错
指令22：立即数加法，gr1 + AA = 3D55，测试跳转后流水线继续正常工作
指令23：CMP指令让一个小的数值减去一个大的数值，让标志位 nf  =  1
指令24：nf = 1, 不跳转 !
指令25：立即数减法，对象是gr1，gr1 – AA = 3CAB
指令26：立即数加法，对象是gr1，gr1 + AA = 3D55
指令27：立即数减法，对象是gr1，gr1 – AA = 3CAB
指令28：空白指令，仅仅是留空，验收时补充指令用的
指令29：空白指令，仅仅是留空，验收时补充指令用的
指令30：跳转指令至40
指令40：终止指令

**仿真结果**

![re1](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image170.png)
![re2](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image171.png)

**结果分析**
1. 指令0~3，测试立即数加法和加法，计算00AB+3C00，得到3CAB存储在dm0上。此处有Data Hazard的产生，ADD指令取gr1和gr2的时候，ADDI和LDIH指令都还没有到达WB指令，因此要提前从结果取出。而结果显示dm0的结果为3CAB正确。√
2. 指令4~7，测试立即数加法和加法，计算00BC+4D00，得到4DBC存储在dm1上。此处有Data Hazard的产生，ADD指令取gr1和gr2的时候，ADDI和LDIH指令都还没有到达WB指令，因此要提前从结果取出。而结果显示dm1的结果为4DBC正确。√
3. 指令8~11，连续两个LOAD指令，LOAD从Data Memory里面取的值还没回到通用寄存器中，下一周期的SUB指令就需要从寄存器中取出相应的值，因此产生Hazard，但没办法Data Forward，所以用Stall的方法让下一指令延后一个周期。结果gr3和dm2得到1111正确。 √
4. 指令12~16，测试跳转指令，PC值从12跳转到16，从结果来看JUMP对应在ID阶段的时候，下一条指令就会产生无关指令，需要Flush掉，因此指令13无效。从结果来看，PC值的变化正确，gr1的值也没有变为3D55 。√
5. 指令17~22，测试分支指令且需要跳转，ZF标志位置为1，分支指令需要跳转，且后续三条指令都需要被跳过，然后执行gr1 = 3D55 。结果显示PC值的跳转从20到22是因为跳转成立与否在exe阶段判断，如不跳转则不能Flush掉后续指令的内容。从结果来看，gr1没有变成3CAB，且PC结果正确√
6. 指令23~25，测试分支指令且不需要跳转，CMP指令让NF的值为1，BNN指令则不需要跳转，后续的运算指令没有被Flush掉，结果正确。√
7. 指令25~27，连续对gr1这个寄存器取值运算并存储回gr1中，结果显示gr1连续在3CAB和3D55之间变化，结果正确，Data Hazard二次验证。√
8. 最后HALT指令让整个CPU停止，由于需要到达WB阶段才执行，所以有后续的PC=41，但是指令内容都被处理为空，不会对CPU造成影响，结果正确。√

由于是基于上一篇博客的5级流水线的基础上加入Hazard冲突处理，因此这次没有测试各条指令的运算结果是否正确，运算结果的正确性在上一篇博客中已经保证了。这次的测试内容是Data Hazard, Control Hazard, Stall, Branch true, Branch false, halt全部会产生Hazard的情况，结果和预期结果相符。

补充说明：
结果中出现两个PC = 6，三个PC = 10，两个PC = 16的情况，是由于ISE中的检测机制$monitor函数产生的，只要有值变化就会多输出一条，由于Memory的时钟频率比CPU的时钟频率高，因此Memory的变化先于CPU里面的，所以多输出一条，后面的情况类似。实际情况为一个PC = 6，两个PC = 10，一个PC = 16，其中两个PC = 10的情况是LOAD指令产生的Stall，这是正确的。附仿真波形图（较难看清）：

![fangzhen](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image172.png)

**三个实用测试**

![Pro13](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image173.jpg)
![Pro14](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image174.jpg)
![Pro15](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image175.jpg)

**一些感言**
刚开始做的时候对Hazard的情况不是很理解，原本以为只需要判断指令的操作数域是否发生冲突就算做完Data Hazard的冲突处理，就像PPT上面的图指示的一样。

![ppt](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image176.png)

但是自己开始做了之后就发现并不是这样的，指令的类型很多，例如运算指令，比较指令，分支指令，跳转指令，存储指令，读取指令，单纯判断操作数域的冲突是不足以判断是否产生Hazard的，因为有些指令时立即数也可能和gr寄存器的编号相同。所以需要连同op域一同比较。
个人对Hazard的理解是，指令都是每一个时钟周期下来流水线往前流动一级，但是一次完整的周期包括读取指令、判断指令、运算指令、存储指令、回写指令这五个周期。Data Hazard是指前一周期的指令还没到达WB回写寄存器这一阶段，后一周期就需要在ID判断指令阶段读取相应寄存器，因此需要把Data Forwarding操作，也就是优先把运算完成的内容取出来；Stall是针对LOAD指令的特殊操作，LOAD只能在MEM阶段才能得到相应的内容，如果下一周期的指令想要Data是不能Forwarding得到的，只能通过延后一周期才能配合Data Forwarding得到相应的内容；Flush是指分支和跳转指令需要到达EX阶段才能知道标志位Flag的判断是否应该跳转，如果需要跳转，则需要把后两个周期读进来的指令冲掉，否则会对结果有无关的影响；如果不需要Flush，则流水线继续往前流动即可。

### 完整代码

CPU.v

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
		//.div(16'b0100_0000_0000_0000),
		.div(16'b0000_0000_0000_0001),
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

clk_div.v

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

D_mem.v

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

	//Test by me
	/*initial begin//初始化时全为0
		d_mem[0] = 16'b0000000000000000;
		d_mem[1] = 16'b0000000000000000;
		d_mem[2] = 16'b0000000000000000;
		d_mem[3] = 16'b0000000000000000;
		d_mem[4] = 16'b0000000000000000;
		d_mem[5] = 16'b0000000000000000;
		d_mem[6] = 16'b0000000000000000;
		d_mem[7] = 16'b0000000000000000;
		d_mem[8] = 16'b0000000000000000;
		d_mem[9] = 16'b0000000000000000;
		d_mem[10] = 16'b0000000000000000;
		d_mem[11] = 16'b0000000000000000;
		d_mem[12] = 16'b0000000000000000;
		d_mem[13] = 16'b0000000000000000;
		d_mem[14] = 16'b0000000000000000;
		d_mem[15] = 16'b0000000000000000;
		d_mem[16] = 16'b0000000000000000;
		d_mem[17] = 16'b0000000000000000;
		d_mem[18] = 16'b0000000000000000;
		d_mem[19] = 16'b0000000000000000;
	end*/
	
	// Bubble Test
	/*initial begin
		d_mem[0] = 16'h000a;
		d_mem[1] = 16'h0004;
		d_mem[2] = 16'h0005;
		d_mem[3] = 16'h2369;
		d_mem[4] = 16'h69c3;
		d_mem[5] = 16'h0060;
		d_mem[6] = 16'h0fff;
		d_mem[7] = 16'h5555;
		d_mem[8] = 16'h6152;
		d_mem[9] = 16'h1057;
		d_mem[10] = 16'h2895;
	end*/
	
	// GCD Test
	/*initial begin
		d_mem[0] = 16'h0000;
		d_mem[1] = 16'h0020;
		d_mem[2] = 16'h0018;
		d_mem[3] = 16'h0000;
		d_mem[4] = 16'h0000;
		d_mem[5] = 16'h0000;
		d_mem[6] = 16'h0000;
		d_mem[7] = 16'h0000;
		d_mem[8] = 16'h0000;
		d_mem[9] = 16'h0000;
		d_mem[10] = 16'h0000;
	end*/
	
	// Sort Test
	/*initial begin
		d_mem[0] = 16'h000a;
		d_mem[1] = 16'h0009;
		d_mem[2] = 16'h0006;
		d_mem[3] = 16'h0005;
		d_mem[4] = 16'h0001;
		d_mem[5] = 16'h0004;
		d_mem[6] = 16'h0003;
		d_mem[7] = 16'h0011;
		d_mem[8] = 16'h0000;
		d_mem[9] = 16'h0000;
		d_mem[10] = 16'h0000;
	end*/
	
	// ADD64 Test
	initial begin
		d_mem[0] <= 16'hfffe;
		d_mem[1] <= 16'hfffe;
		d_mem[2] <= 16'hfffe;
		d_mem[3] <= 16'h0000;
		d_mem[4] <= 16'hffff;
		d_mem[5] <= 16'hffff;
		d_mem[6] <= 16'hffff;
		d_mem[7] <= 16'h0000;
		d_mem[8] = 16'h0000;
		d_mem[9] = 16'h0000;
		d_mem[10] = 16'h0000;
	end
	
	// Test All
	/*initial begin
		d_mem[0] <= 16'hfffd;
		d_mem[1] <= 16'h0004;
		d_mem[2] <= 16'h0005;
		d_mem[3] <= 16'hc369;
		d_mem[4] <= 16'h69c3;
		d_mem[5] <= 16'h0041;
		d_mem[6] <= 16'hffff;
		d_mem[7] <= 16'h0001;
	end*/

endmodule
```

headfile.v

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
`define gr4 3'b100
`define gr5 3'b101
`define gr6 3'b110
`define gr7 3'b111

`endif
```

I_mem.v

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
	
	// Test by me
	/*initial begin
		i_mem[0] <= {`ADDI, `gr1, 4'b1010, 4'b1011}; // gr1 = 00AB;
		i_mem[1] <= {`LDIH, `gr2, 4'b0011, 4'b1100}; // gr2 = 3C00;
		i_mem[2] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2}; // gr3 = 3CAB;
		i_mem[3] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0000}; // dm0 = 3CAB;
		i_mem[4] <= {`ADDI, `gr1, 4'b0001, 4'b0001}; // gr1 = 00BC;
		i_mem[5] <= {`LDIH, `gr2, 4'b0001, 4'b0001}; // gr2 = 4D00;
		i_mem[6] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2}; // gr3 = 4DBC;
		i_mem[7] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0001}; // dm1 = 4DBC;
		i_mem[8] <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000}; // gr1 = 3CAB;
		i_mem[9] <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0001}; // gr2 = 4DBC;
		i_mem[10] <= {`SUB, `gr3, 1'b0, `gr2, 1'b0, `gr1}; // gr3 = 1111;
		i_mem[11] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0010}; // dm2 = 1111;
		i_mem[12] <= {`JUMP, 3'b000, 4'b0001, 4'b0000}; // Jump to 16
		i_mem[13] <= {`ADDI, `gr1, 4'b1010, 4'b1011};//Not Used
		i_mem[14] <= {`ADDI, `gr1, 4'b1010, 4'b1011};//Not Used
		i_mem[15] <= {`ADDI, `gr1, 4'b1010, 4'b1011};//Not Used
		i_mem[16] <= {`ADDI, `gr4, 4'b0001, 4'b0100}; // gr4 = 20(0014);
		i_mem[17] <= {`CMP, 3'b000, 1'b0, `gr1, 1'b0, `gr1}; // let zf = 1
		i_mem[18] <= {`BZ, `gr4, 4'b0000, 4'b0010}; // Branch true to 22
		i_mem[19] <= {`SUBI, `gr1, 4'b0010, 4'b1000};//Not Used
		i_mem[20] <= {`SUBI, `gr1, 4'b0010, 4'b1000};//Not Used
		i_mem[21] <= {`SUBI, `gr1, 4'b0010, 4'b1000};//Not Used
		i_mem[22] <= {`ADDI, `gr1, 4'b1010, 4'b1010}; // gr1 = 3D55;
		i_mem[23] <= {`CMP, 3'b000, 1'b0, `gr1, 1'b0, `gr2}; // let nf = 1
		i_mem[24] <= {`BNN, `gr4, 4'b0000, 4'b0101}; // Branch false to 25
		i_mem[25] <= {`SUBI, `gr1, 4'b1010, 4'b1010}; // gr1 = 3CAB;
		i_mem[26] <= {`ADDI, `gr1, 4'b1010, 4'b1010}; // gr1 = 3D55;
		i_mem[27] <= {`SUBI, `gr1, 4'b1010, 4'b1010}; // gr1 = 3CAB;
		i_mem[28] <= {`NOP, `gr1, 4'b1010, 4'b1010};
		i_mem[29] <= {`NOP, `gr1, 4'b1010, 4'b1010};
		i_mem[30] <= {`JUMP, 3'b000, 4'b0010, 4'b1000}; // Jump to 40
		i_mem[40] <= {`HALT, 11'b000_0000_0000}; // Stop
	end*/
	
	// Bubble Test
	/*initial begin
		i_mem[0] <= {`LOAD, `gr3, 4'b0000, 4'b0000};
		i_mem[1] <= {`SUBI, `gr3, 4'b0000, 4'b0010};
		i_mem[2] <= {`ADD, `gr1, 1'b0, `gr0, 1'b0, `gr0};
		i_mem[3] <= {`ADD, `gr2, 1'b0, `gr3, 1'b0, `gr0}; // loop1
		i_mem[4] <= {`LOAD, `gr4, 1'b0, `gr2, 4'b0001}; // loop2
		i_mem[5] <= {`LOAD, `gr5, 1'b0, `gr2, 4'b0010};
		i_mem[6] <= {`CMP, 3'b000, 1'b0, `gr5, 1'b0, `gr4};
		i_mem[7] <= {`BN, `gr0, 4'b0000, 4'b1010};// Jump to 10 or not
		i_mem[8] <= {`STORE, `gr4, 1'b0, `gr2, 4'b0010};
		i_mem[9] <= {`STORE, `gr5, 1'b0, `gr2, 4'b0001};
		i_mem[10] <= {`SUBI, `gr2, 4'b0000, 4'b0001};     //bunkisaki
		i_mem[11] <= {`CMP, 3'b000, 1'b0, `gr2, 1'b0, `gr1};
		i_mem[12] <= {`BNN, `gr0, 4'b0000, 4'b0100};//Jump to 4 or not
		i_mem[13] <= {`ADDI, `gr1, 4'b0000, 4'b0001};
		i_mem[14] <= {`CMP, 3'b000, 1'b0, `gr3, 1'b0, `gr1};
		i_mem[15] <= {`BNN, `gr0, 4'b0000, 4'b0011};//Jump to 3 or not
		i_mem[16] <= {`HALT, 11'b000_0000_0000};
	end*/
	
	// Gcd Test
	/*initial begin
		i_mem[0] <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0001}; //GCM
		i_mem[1] <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0010}; 
		i_mem[2] <= {`ADD, `gr3, 1'b0, `gr0, 1'b0, `gr1}; //(1)
		i_mem[3] <= {`SUB, `gr1, 1'b0, `gr1, 1'b0, `gr2};
		i_mem[4] <= {`BZ, `gr0, 4'b0000, 4'b1001}; //jump to (2)
		i_mem[5] <= {`BNN, `gr0, 4'b0000, 4'b0010}; //jump to (1)
		i_mem[6] <= {`ADD, `gr1, 1'b0, `gr0, 1'b0, `gr2};
		i_mem[7] <= {`ADD, `gr2, 1'b0, `gr0, 1'b0, `gr3};
		i_mem[8] <= {`JUMP, 3'b000, 4'b0000, 4'b0010}; //jump to (1)
		i_mem[9] <= {`STORE, `gr2, 1'b0, `gr0, 4'b0011}; //(2)
		i_mem[10] <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0001};  //LCM
		i_mem[11] <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0010};
		i_mem[12] <= {`ADDI, `gr4, 4'b0000, 4'b0001}; //(3)
		i_mem[13] <= {`SUB, `gr2, 1'b0, `gr2, 1'b0, `gr3};
		i_mem[14] <= {`BZ, `gr0, 4'b0001, 4'b0000}; //jump to (4)
		i_mem[15] <= {`JUMP, 3'b000, 4'b0000, 4'b1100}; //jump to (3)
		i_mem[16] <= {`SUBI, `gr4, 4'b0000, 4'b0001}; //(4)
		i_mem[17] <= {`BN, `gr0, 4'b0001, 4'b0100}; //jump to (5)
		i_mem[18] <= {`ADD, `gr5, 1'b0, `gr5, 1'b0, `gr1};
		i_mem[19] <= {`JUMP, 3'b000, 4'b0001, 4'b0000}; //jump to (4)
		i_mem[20] <= {`STORE, `gr5, 1'b0, `gr0, 4'b0100}; //(5)
		i_mem[21] <= {`HALT, 11'b000_0000_0000};
	end*/
	
	// Sort Test
	/*initial begin
		i_mem[0] <= {`ADDI, `gr1, 4'b0000, 4'b1001};// init
		i_mem[1] <= {`ADDI, `gr2, 4'b0000, 4'b1001};
		i_mem[2] <= {`JUMP, 3'b000, 8'b00000101};// jump to START
		i_mem[3] <= {`SUBI, `gr1, 4'b0000, 4'b0001};// NEW_ROUND
		i_mem[4] <= {`BZ, `gr7, 4'b0000, 4'b0001};// jump to END
		i_mem[5] <= {`LOAD, `gr3, 1'b0, `gr0, 4'b0000};// START
		i_mem[6] <= {`LOAD, `gr4, 1'b0, `gr0, 4'b0001};
		i_mem[7] <= {`CMP, 3'b000, 1'b0, `gr3, 1'b0, `gr4};
		i_mem[8] <= {`BN, `gr7, 8'b00001011};// jump to NO_OP
		i_mem[9] <= {`STORE, `gr3, 1'b0, `gr0, 4'b0001};// store back
		i_mem[10] <= {`STORE, `gr4, 1'b0, `gr0, 4'b0000};
		i_mem[11] <= {`ADDI, `gr0, 4'b0000, 4'b0001}; // NO_OP
		i_mem[12] <= {`CMP, 3'b000, 1'b0, `gr0, 1'b0, `gr2};
		i_mem[13] <= {`BN, `gr7, 8'b00010001}; // jump to CONTINUE
		i_mem[14] <= {`SUBI, `gr2, 8'b00000001}; // UPDATE
		i_mem[15] <= {`SUB, `gr0, 1'b0, `gr0, 1'b0, `gr0};
		i_mem[16] <= {`JUMP, 3'b000, 8'b00000011};// jump to NEW_ROUND
		i_mem[17] <= {`JUMP, 3'b000, 8'b00000101};// jump to START #CONTINUE#
		i_mem[18] <= {`HALT, 11'b000_0000_0000};
	end*/
	
	// 64Add Test
	initial begin
		i_mem[0] <= {`ADDI, `gr4, 4'b0000, 4'b0100};
		i_mem[1] <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000};
		i_mem[2] <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0100};
		i_mem[3] <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};
		i_mem[4] <= {`BNC, `gr5, 4'b0000, 4'b0110};//bnc to 6 11111 101 0000 0110
		i_mem[5] <= {`ADDI, `gr6, 4'b0000, 4'b0001};
		i_mem[6] <= {`ADD, `gr3, 1'b0, `gr3, 1'b0, `gr7};
		i_mem[7] <= {`BNC, `gr5, 4'b0000, 4'b1011};//bnc to 11 // 11111 101 0000 1011
		i_mem[8] <= {`SUBI, `gr6, 4'b0000, 4'b0000};                               // {`}
		i_mem[9] <= {`BNZ, `gr5, 4'b0000, 4'b1011} ;//bnz to 11        // 11011 101 0000 1011               // {`BNZ, }
		i_mem[10] <= {`ADDI, `gr6, 4'b0000, 4'b0001};  			//01001'110'0000'0001 // {`ADDC, `gr6, 1'b0, `gr0, 1'b0, `gr1}
		i_mem[11] <= {`SUB, `gr7, 1'b0, `gr7, 1'b0, `gr7};	  			//01010'111'0111'0111 // {`SUB, `gr7, 1'b0, `gr7, 1'b0, `gr7}
		i_mem[12] <= {`ADD, `gr7, 1'b0, `gr7, 1'b0, `gr6};   			//01000'111'0111'0110 // {`ADD, `gr7, 1'b0, `gr7, 1'b0, `gr6}
		i_mem[13] <= {`SUB, `gr6, 1'b0, `gr6, 1'b0, `gr6};	  			//01010'110'0110'0110 // {`SUB, `gr6, 1'b0, `gr6, 1'b0, `gr6}
		i_mem[14] <= {`STORE, `gr3, 4'b0000, 4'b1000};	  			//00011'011'0000'1000 // {`STORE, `gr3, 4'b0000, 4'b1000}
		i_mem[15] <= {`ADDI, `gr0, 4'b0000, 4'b0001};		  			//01001'000'0000'0001 // {`ADDC, `gr0, 1'b0, `gr0, 1'b0, `gr1}
		i_mem[16] <= {`CMP, 3'b000, 1'b0, `gr0, 1'b0, `gr4};   			//01100'000'0000'0100 // {`CMP, 3'b000, 1'b0, `gr0, 1'b0, `gr4}
		i_mem[17] <= {`BN, `gr5, 4'b0000, 4'b0001};//bn to 1 //11100'101'0000'0001 // {`BZ, `gr5, 4'b0000, 4'b0001}
		i_mem[18] <= {`HALT, 11'b000_0000_0000};				//00001'000'0000'0000 // {`HALT, 11'b000_0000_0000};
	end
	
	// Test All
	/*initial begin
		i_mem[0]={`ADDI,`gr7,4'd1,4'd0};              // gr7 <= 16'h10 for store address
		i_mem[1]={`LDIH,`gr1,4'b1011,4'b0110};        // test for LDIH  gr1<="16'hb600"
		i_mem[2]={`STORE,`gr1,1'b0,`gr7,4'h0};        // store to mem10	
		i_mem[3]={`LOAD,`gr1,1'b0,`gr0,4'h0};         // gr1 <= fffd 
		i_mem[4]={`LOAD,`gr2,1'b0,`gr0,4'h1};         // gr2 <= 4
		i_mem[5]={`ADDC,`gr3,1'b0,`gr1,1'b0,`gr2};    // gr3 <= fffd + 4 + cf(=0) = 1, cf<=1
		i_mem[6]={`STORE,`gr3,1'b0,`gr7,4'h1};        // store to mem11		
		i_mem[7]={`ADDC,`gr3,1'b0,`gr0,1'b0,`gr2};    // gr3 <= 0 + 4 + cf(=1) = 5, cf<=0
		i_mem[8]={`STORE,`gr3,1'b0,`gr7,4'h2};        // store to mem12
		i_mem[9]={`LOAD,`gr1,1'b0,`gr0,4'h2};          // gr1 <= 5 
		i_mem[10]={`SUBC,`gr3,1'b0,`gr1,1'b0,`gr2};    // gr3 <= 5 - 4 + cf(=0) =1, cf<=0    
		i_mem[11]={`STORE,`gr3,1'b0,`gr7,4'h3};        // store to mem13		
		i_mem[12]={`SUB,`gr3,1'b0,`gr2,1'b0,`gr1};     // gr3 <= 4 - 5 = -1, cf<=1    
		i_mem[13]={`STORE,`gr3,1'b0,`gr7,4'h4};        // store to mem14		
		i_mem[14]={`SUBC,`gr3,1'b0,`gr2,1'b0,`gr1};    // gr3 <= 5 - 4 - cf(=1) =2, cf<=0 
		i_mem[15]={`STORE,`gr3,1'b0,`gr7,4'h5};        // store to mem15		
		i_mem[16]={`LOAD,`gr1,1'b0,`gr0,4'h3};         // gr1 <= c369
		i_mem[17]={`LOAD,`gr2,1'b0,`gr0,4'h4};         // gr2 <= 69c3		
		i_mem[18]={`AND,`gr3,1'b0,`gr1,1'b0,`gr2};     // gr3 <= gr1 & gr2 = 4141
		i_mem[19]={`STORE,`gr3,1'b0,`gr7,4'h6};        // store to mem16		
		i_mem[20]={`OR,`gr3,1'b0,`gr1,1'b0,`gr2};      // gr3 <= gr1 | gr2 = ebeb
		i_mem[21]={`STORE,`gr3,1'b0,`gr7,4'h7};        // store to mem17		
		i_mem[22]={`XOR,`gr3,1'b0,`gr1,1'b0,`gr2};     // gr3 <= gr1 ^ gr2 = aaaa
		i_mem[23]={`STORE,`gr3,1'b0,`gr7,4'h8};        // store to mem18
		i_mem[24]={`SLL,`gr3,1'b0,`gr1,4'h0};          // gr3 <= gr1 < 0 
		i_mem[25]={`STORE,`gr3,1'b0,`gr7,4'h9};        // store to mem19		
		i_mem[26]={`SLL,`gr3,1'b0,`gr1,4'h1};          // gr3 <= gr1 < 1 
		i_mem[27]={`STORE,`gr3,1'b0,`gr7,4'ha};        // store to mem1a		
		i_mem[28]={`SLL,`gr3,1'b0,`gr1,4'h4};          // gr3 <= gr1 < 8 
		i_mem[29]={`STORE,`gr3,1'b0,`gr7,4'hb};        // store to mem1b	
		i_mem[30]={`SLL,`gr3,1'b0,`gr1,4'hf};          // gr3 <= gr1 < 15 
		i_mem[31]={`STORE,`gr3,1'b0,`gr7,4'hc};        // store to mem1c
		i_mem[32]={`SRL,`gr3,1'b0,`gr1,4'h0};          // gr3 <= gr1 > 0
		i_mem[33]={`STORE,`gr3,1'b0,`gr7,4'hd};        // store to mem1d		
		i_mem[34]={`SRL,`gr3,1'b0,`gr1,4'h1};          // gr3 <= gr1 > 1
		i_mem[35]={`STORE,`gr3,1'b0,`gr7,4'he};        // store to mem1e		
		i_mem[36]={`SRL,`gr3,1'b0,`gr1,4'h8};          // gr3 <= gr1 > 8
		i_mem[37]={`STORE,`gr3,1'b0,`gr7,4'hf};        // store to mem1f		
		i_mem[38]={`SRL,`gr3,1'b0,`gr1,4'hf};          // gr3 <= gr1 > 15
		i_mem[39]={`ADDI,`gr7,4'd1,4'd0};              // gr7 <= 16'h20 for store address
		i_mem[40]={`STORE,`gr3,1'b0,`gr7,4'h0};        // store to mem20
		i_mem[41]={`SLA,`gr3,1'b0,`gr1,4'h0};          // gr3 <= gr1 < 0
		i_mem[42]={`STORE,`gr3,1'b0,`gr7,4'h1};        // store to mem21
		i_mem[43]={`SLA,`gr3,1'b0,`gr1,4'h1};          // gr3 <= gr1 < 1 
		i_mem[44]={`STORE,`gr3,1'b0,`gr7,4'h2};        // store to mem22
		i_mem[45]={`SLA,`gr3,1'b0,`gr1,4'h8};          // gr3 <= gr1 < 8 
		i_mem[46]={`STORE,`gr3,1'b0,`gr7,4'h3};        // store to mem23
		i_mem[47]={`SLA,`gr3,1'b0,`gr1,4'hf};          // gr3 <= gr1 < 15
		i_mem[48]={`STORE,`gr3,1'b0,`gr7,4'h4};        // store to mem24
		i_mem[49]={`SLA,`gr3,1'b0,`gr2,4'h0};          // gr3 <= gr1 < 0
		i_mem[50]={`STORE,`gr3,1'b0,`gr7,4'h5};        // store to mem25
		i_mem[51]={`SLA,`gr3,1'b0,`gr2,4'h1};          // gr3 <= gr1 < 1
		i_mem[52]={`STORE,`gr3,1'b0,`gr7,4'h6};        // store to mem26
		i_mem[53]={`SLA,`gr3,1'b0,`gr2,4'h8};          // gr3 <= gr1 < 8
		i_mem[54]={`STORE,`gr3,1'b0,`gr7,4'h7};        // store to mem27
		i_mem[55]={`SLA,`gr3,1'b0,`gr2,4'hf};          // gr3 <= gr1 < 15
		i_mem[56]={`STORE,`gr3,1'b0,`gr7,4'h8};        // store to mem28
		i_mem[57]={`SRA,`gr3,1'b0,`gr1,4'h0};          // gr3 <= gr1 > 0
		i_mem[58]={`STORE,`gr3,1'b0,`gr7,4'h9};        // store to mem29
		i_mem[59]={`SRA,`gr3,1'b0,`gr1,4'h1};          // gr3 <= gr1 > 1
		i_mem[60]={`STORE,`gr3,1'b0,`gr7,4'ha};        // store to mem2a
		i_mem[61]={`SRA,`gr3,1'b0,`gr1,4'h8};          // gr3 <= gr1 > 8
		i_mem[62]={`STORE,`gr3,1'b0,`gr7,4'hb};        // store to mem2b
		i_mem[63]={`SRA,`gr3,1'b0,`gr1,4'hf};          // gr3 <= gr1 > 15
		i_mem[64]={`STORE,`gr3,1'b0,`gr7,4'hc};        // store to mem2c
		i_mem[65]={`SRA,`gr3,1'b0,`gr2,4'h0};          // gr3 <= gr1 > 0
		i_mem[66]={`STORE,`gr3,1'b0,`gr7,4'hd};        // store to mem2d
		i_mem[67]={`SRA,`gr3,1'b0,`gr2,4'h1};          // gr3 <= gr1 > 1
		i_mem[68]={`STORE,`gr3,1'b0,`gr7,4'he};        // store to mem2e
		i_mem[69]={`SRA,`gr3,1'b0,`gr2,4'h8};          // gr3 <= gr1 > 8
		i_mem[70]={`STORE,`gr3,1'b0,`gr7,4'hf};        // store to mem2f
		i_mem[71]={`ADDI,`gr7,4'd1,4'd0};              // gr7 <= 16'h30 for store address
		i_mem[72]={`SRA,`gr3,1'b0,`gr2,4'hf};          // gr3 <= gr1 > 15
		i_mem[73]={`STORE,`gr3,1'b0,`gr7,4'h0};        // store to mem30		
		i_mem[74]={`LOAD,`gr1,1'b0,`gr0,4'h5};         // gr1 <= 41
		i_mem[75]={`LOAD,`gr2,1'b0,`gr0,4'h6};         // gr2 <= ffff
		i_mem[76]={`LOAD,`gr3,1'b0,`gr0,4'h7};         // gr3 <= 1
		i_mem[77]={`JUMP, 3'd0,8'h4f};                 // jump to 4f
		i_mem[78]={`STORE,`gr7,1'b0,`gr7,4'h1};        // store to mem31
		i_mem[79]={`JMPR, `gr1,8'h10};                 // jump to 41+10 = 51
		i_mem[80]={`STORE,`gr7,1'b0,`gr7,4'h2};        // store to mem32
		i_mem[81]={`ADD, `gr4,1'b0,`gr2,1'b0,`gr3};    // gr4<= ffff + 1,cf<=1
		i_mem[82]={`BNC,`gr1,8'h28};                   // if(cf==0) jump to 69
		i_mem[83]={`BC,`gr1,8'h14};                    // if(cf==1) jump to 55
		i_mem[84]={`STORE,`gr7,1'b0,`gr7,4'h3};        // store to mem33
		i_mem[85]={`ADD, `gr4,1'b0,`gr3,1'b0,`gr3};    // gr4<= 1 + 1 , cf<=0
		i_mem[86]={`BC,`gr1,8'h28};                   // if(cf==1) jump to 69
		i_mem[87]={`BNC,`gr1,8'h18};                  // if(cf==0) jump to 59
		i_mem[88]={`STORE,`gr7,1'b0,`gr7,4'h4};        // store to mem34
		i_mem[89]={`CMP, 3'd0,1'b0,`gr3,1'b0,`gr3};    // 1-1=0 , zf<=1,nf<=0
		i_mem[90]={`BNZ,`gr1,8'h28};                   // if(zf==0) jump to 69
		i_mem[91]={`BZ,`gr1,8'h1c};                    // if(zf==1) jump to 5d
		i_mem[92]={`STORE,`gr7,1'b0,`gr7,4'h5};        // store to mem35
		i_mem[93]={`CMP, 3'd0,1'b0,`gr4,1'b0,`gr3};    // 2-1=1 , zf<=0,nf<=0 
		i_mem[94]={`BZ,`gr1,8'h28};                    // if(zf==1) jump to 69
		i_mem[95]={`BNZ,`gr1,8'h20};                   // if(zf==0) jump to 61
		i_mem[96]={`STORE,`gr7,1'b0,`gr7,4'h6};        // store to mem36
		i_mem[97]={`CMP, 3'd0,1'b0,`gr3,1'b0,`gr4};    // 1-2=-1, nf<=1,zf<=0
		i_mem[98]={`BNN,`gr1,8'h28};                   // if(nf==0) jump to 69
		i_mem[99]={`BN,`gr1,8'h24};                    // if(nf==1) jump to 65 
		i_mem[100]={`STORE,`gr7,1'b0,`gr7,4'h7};        // store to mem37
		i_mem[101]={`CMP, 3'd0,1'b0,`gr4,1'b0,`gr3};    // 2-1=1, nf<=0,zf<=0
		i_mem[102]={`BN,`gr1,8'h28};                    // if(nf==1) jump to 69
		i_mem[103]={`BNN,`gr1,8'h27};                   // if(nf==0) jump to 68
		i_mem[104]={`STORE,`gr7,1'b0,`gr7,4'h8};        // store to mem38
		i_mem[105]={`HALT, 11'd0};                      // STOP
	end*/
	

endmodule
```

PCPU.v

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
			if ((id_ir[15:11]==`LOAD)
			  &&(i_datain[15:11]!=`JUMP)&&(i_datain[15:11]!=`NOP)
			  &&(i_datain[15:11]!=`HALT)&&(i_datain[15:11]!=`LOAD))
				begin
					/*********r1*********/
					if((id_ir[10:8]==i_datain[2:0])
					 &&((i_datain[15:11]==`ADD)||(i_datain[15:11]==`ADDC)
					  ||(i_datain[15:11]==`SUB)||(i_datain[15:11]==`SUBC)
					  ||(i_datain[15:11]==`CMP)||(i_datain[15:1]==`AND)
					  ||(i_datain[15:11]==`OR)||(i_datain[15:11]==`XOR)))
						begin
							pc <= pc;
							id_ir <= i_datain;
						end
					/*********r2*********/
					else if((id_ir[10:8]==i_datain[6:4])
							&&((i_datain[15:11]==`STORE)||(i_datain[15:11]==`ADD)
							 ||(i_datain[15:11]==`ADDC)||(i_datain[15:11]==`SUB)
							 ||(i_datain[15:11]==`SUBC)||(i_datain[15:11]==`CMP)
							 ||(i_datain[15:11]==`AND)||(i_datain[15:11]==`OR)
							 ||(i_datain[15:11]==`XOR)||(i_datain[15:11]==`SLL)
							 ||(i_datain[15:11]==`SRL)||(i_datain[15:11]==`SLA)
							 ||(i_datain[15:11]==`SRA)))		//r2
						begin
							pc <= pc;
							id_ir <= i_datain;
						end
					/*********r3*********/
					else if((id_ir[10:8]==i_datain[10:8])
						   &&((i_datain[15:11]==`STORE)||(i_datain[15:11]==`LDIH)
							 ||(i_datain[15:11]==`ADDI)||(i_datain[15:11]==`SUBI)
							 ||(i_datain[15:11]==`JMPR)||(i_datain[15:11]==`BZ)
							 ||(i_datain[15:11]==`BNZ)||(i_datain[15:11]==`BN)
							 ||(i_datain[15:11]==`BNN)||(i_datain[15:11]==`BC)
							 ||(i_datain[15:11]==`BNC)))
						begin
							pc <= pc;
							id_ir <= i_datain;
						end
					else
						begin
							pc <= pc + 1'b1;
							id_ir <= i_datain;
						end
				end
			/**************************************/
			else
			begin
				if(((ex_ir[15:11] == `BZ)  && (zf == 1'b1))
				 ||((ex_ir[15:11] == `BN)  && (nf == 1'b1))
				 ||((ex_ir[15:11] == `BC)  && (cf == 1'b1))
				 ||((ex_ir[15:11] == `BNZ) && (zf == 1'b0))
				 ||((ex_ir[15:11] == `BNN) && (nf == 1'b0))
				 ||((ex_ir[15:11] == `BNC) && (cf == 1'b0))
				 || (ex_ir[15:11] == `JMPR))
					begin pc <= ALUo[7:0]; id_ir <= {`NOP, 000_0000_0000}; end // Flush
				else if(id_ir[15:11] == `JUMP)
					begin pc <= id_ir[7:0]; id_ir <= {`NOP, 000_0000_0000}; end
				else if(id_ir[15:11] == `HALT) // STOP
					begin pc <= pc; id_ir <= id_ir; end
				else
					begin pc <= pc + 1'b1; id_ir <= i_datain; end
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
		/********Flush*********/
		else if((state == `exec) &&
				  (((ex_ir[15:11]==`BZ)&&(zf==1'b1))
				 ||((ex_ir[15:11]==`BNZ)&&(zf==1'b0))
				 ||((ex_ir[15:11]==`BN)&&(nf==1'b1))
				 ||((ex_ir[15:11]==`BNN)&&(nf==1'b0))
				 ||((ex_ir[15:11]==`BC)&&(cf==1'b1))
				 ||((ex_ir[15:11]==`BNC)&&(nf==1'b0))
				 || (ex_ir[15:11]==`JMPR)))
				 ex_ir <= {`NOP, 000_0000_0000};
		/********Flush*********/
		else if(state == `exec)
		begin
			ex_ir <= id_ir;
			//reg_A
			/********************Hazard**********************/
			if((id_ir[15:11]==`BZ)||(id_ir[15:11]==`BNZ)
			 ||(id_ir[15:11]==`BN)||(id_ir[15:11]==`BNN)
			 ||(id_ir[15:11]==`BC)||(id_ir[15:11]==`BNC)
			 ||(id_ir[15:11]==`ADDI)||(id_ir[15:11]==`SUBI)
			 ||(id_ir[15:11]==`LDIH)||(id_ir[15:11]==`JMPR))
				begin
					if(((id_ir[15:11]==`BZ)||(id_ir[15:11]==`BNZ)
					 ||(id_ir[15:11]==`BN)||(id_ir[15:11]==`BNN)
					 ||(id_ir[15:11]==`BC)||(id_ir[15:11]==`BNC))
					 &&(id_ir[10:8]==`gr0))//分支指令，基地址为0直接到偏移量地址的不会有冲突
						begin		reg_A <= gr[id_ir[10:8]];		end
					else if((id_ir[10:8]==ex_ir[10:8])
					 &&(ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`HALT)
					 &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`CMP)
					 &&(ex_ir[15:11]!=`JUMP)
					 &&(id_ir[15:0] != ex_ir[15:0]))//该行避免LOAD产生的Stall有影响
						begin		reg_A <= ALUo;		end
					else if((id_ir[10:8]==mem_ir[10:8])
							&&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`HALT)
							&&(mem_ir[15:11]!=`CMP)&&(mem_ir[15:11]!=`JUMP))
						begin
							if(mem_ir[15:11]==`LOAD)	reg_A <= d_datain;
							else								reg_A <= reg_C;
						end
					else if((id_ir[10:8]==wb_ir[10:8])
						   &&(wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`HALT)
							&&(wb_ir[15:11]!=`CMP)&&(wb_ir[15:11]!=`JUMP)
							&&(id_ir[15:11] != wb_ir[15:11]))//该行避免同指令的无效位冲突
						begin		reg_A <= reg_C1;		end
					else
						begin		reg_A <= gr[id_ir[10:8]];		end	//r1
				end
			else if((id_ir[15:11]==`LOAD)||(id_ir[15:11]==`STORE)
					||(id_ir[15:11]==`ADD)||(id_ir[15:11]==`ADDC)
					||(id_ir[15:11]==`SUB)||(id_ir[15:11]==`SUBC)
					||(id_ir[15:11]==`CMP)||(id_ir[15:11]==`AND)
					||(id_ir[15:11]==`OR)||(id_ir[15:11]==`XOR)
					||(id_ir[15:11]==`SLL)||(id_ir[15:11]==`SRL)
					||(id_ir[15:11]==`SLA)||(id_ir[15:11]==`SRA))
				begin
					if((id_ir[6:4]==ex_ir[10:8])
					 &&(ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`HALT)
					 &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`CMP)
					 &&(ex_ir[15:11]!=`JUMP)
					 &&(id_ir[6:4]!=`gr0))//gr0冲突无关紧要，允许冲突
						begin		reg_A <= ALUo;		end
					else if((id_ir[6:4]==mem_ir[10:8])
							&&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`HALT)
							&&(mem_ir[15:11]!=`CMP)&&(mem_ir[15:11]!=`JUMP)
							&&(id_ir[6:4]!=`gr0))//gr0冲突无关紧要，允许冲突
						begin
							if(mem_ir[15:11]==`LOAD)	reg_A <= d_datain;
							else								reg_A <= reg_C;
						end
					else if((id_ir[6:4]==wb_ir[10:8])
							&&((wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`HALT)
							&&(wb_ir[15:11]!=`CMP)&&(wb_ir[15:11]!=`JUMP))
							&&(id_ir[6:4]!=`gr0))//gr0冲突无关紧要，允许冲突
						begin		reg_A <= reg_C1;		end
					else
						begin		reg_A <= gr[id_ir[6:4]];		end	//r2
				end
			else if(((mem_ir[15:11]==`BZ)&&(zf==1'b1))
					||((mem_ir[15:11]==`BNZ)&&(zf==1'b0))
					||((mem_ir[15:11]==`BN)&&(nf==1'b1))
					||((mem_ir[15:11]==`BNN)&&(nf==1'b0))
					||((mem_ir[15:11]==`BC)&&(cf==1'b1))
					||((mem_ir[15:11]==`BNC)&&(nf==1'b0))
					|| (mem_ir[15:11]==`JMPR))
				begin		reg_A <= 16'b0;		end
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
				else if(id_ir[15:11] == `JUMP)
					reg_A <= 16'b0000_0000_0000_0000;
				else
					reg_A <= gr[(id_ir[6:4])];
			end
			
			//reg_B
			/********************Hazard*********************/
			if(id_ir[15:11]==`LDIH)
				begin		reg_B <= {id_ir[7:0], 8'b0000_0000};	end
			else if((id_ir[15:11]==`STORE)||(id_ir[15:11]==`LOAD)
					||(id_ir[15:11]==`SLL)||(id_ir[15:11]==`SRL)
					||(id_ir[15:11]==`SLA)||(id_ir[15:11]==`SRA))
				begin		reg_B <= {12'b0000_0000_0000, id_ir[3:0]};	end
			else if((id_ir[15:11]==`BZ)||(id_ir[15:11]==`BNZ)
					||(id_ir[15:11]==`BN)||(id_ir[15:11]==`BNN)
					||(id_ir[15:11]==`BC)||(id_ir[15:11]==`BNC)
					||(id_ir[15:11]==`ADDI)||(id_ir[15:11]==`SUBI)
					||(id_ir[15:11]==`JUMP)||(id_ir[15:11]==`JMPR))
				begin		reg_B <= {8'b0000_0000, id_ir[7:0]};	end
			else if((id_ir[15:11]==`ADD)||(id_ir[15:11]==`ADDC)
					||(id_ir[15:11]==`SUB)||(id_ir[15:11]==`SUBC)
					||(id_ir[15:11]==`CMP)||(id_ir[15:11]==`AND)
					||(id_ir[15:11]==`OR)||(id_ir[15:11]==`XOR))
				begin
					if((id_ir[2:0]==ex_ir[10:8])
					 &&((ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`HALT)
					  &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`CMP)
					  &&(ex_ir[15:11]!=`JUMP)))
						begin		reg_B <= ALUo;		end
					else if((id_ir[2:0]==mem_ir[10:8])
							&&((mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`HALT)
							&&(mem_ir[15:11]!=`CMP)&&(mem_ir[15:11]!=`JUMP)))
						begin
							if(mem_ir[15:11]==`LOAD)	reg_B <= d_datain;
							else								reg_B <= reg_C;
						end
					else if((id_ir[2:0]==wb_ir[10:8])
							&&((wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`HALT)
							&&(wb_ir[15:11]!=`CMP)&&(wb_ir[15:11]!=`JUMP)))
						begin		reg_B <= reg_C1;		end
					else
						begin		reg_B <= gr[id_ir[2:0]];		end	//r3
				end
			else if(((mem_ir[15:11]==`BZ)&&(zf==1'b1))
					 ||((mem_ir[15:11]==`BNZ)&&(zf==1'b0))
					 ||((mem_ir[15:11]==`BN)&&(nf==1'b1))
					 ||((mem_ir[15:11]==`BNN)&&(nf==1'b0))
					 ||((mem_ir[15:11]==`BC)&&(cf==1'b1))
					 ||((mem_ir[15:11]==`BNC)&&(nf==1'b0))
					 || (mem_ir[15:11]==`JMPR))
				begin		reg_B <= 16'b0;		end	
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
						||(id_ir[15:11] == `ADDI)
						||(id_ir[15:11] == `SUBI))
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
			
			//smdr
			/********************Hazard**********************/
			if(id_ir[15:11]==`STORE)
				begin
					if((id_ir[10:8]==ex_ir[10:8])
					 &&((ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`HALT)
					 &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`CMP)
					 &&(ex_ir[15:11]!=`JUMP)))
						begin		smdr <= ALUo;		end
					else if((id_ir[10:8]==mem_ir[10:8])
						   &&((mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`HALT)
							&&(mem_ir[15:11]!=`CMP)&&(mem_ir[15:11]!=`JUMP)))
						begin
							if(mem_ir[15:11]==`LOAD)	smdr <= d_datain;
							else								smdr <= reg_C;
						end
					else if((id_ir[10:8]==wb_ir[10:8])
							&&((wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`HALT)
							&&(wb_ir[15:11]!=`CMP)&&(wb_ir[15:11]!=`JUMP)))
						begin		smdr <= reg_C1;		end
					else
						begin		smdr <= gr[id_ir[10:8]];		end
				end
			else
				smdr <= gr[id_ir[10:8]];
			
			/********************Hazard**********************/
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
			smdr1 <= smdr;
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
			 ||(ex_ir[15:11] == `SUBC)
			 ||(ex_ir[15:11] == `AND)
			 ||(ex_ir[15:11] == `OR)
			 ||(ex_ir[15:11] == `XOR))
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
			else
			begin
				zf <= zf;
				nf <= nf;
			end
			
			if(ex_ir[15:11] == `STORE)
			begin
				dw <= 1'b1;
			end
			else
			begin
				dw <= 1'b0;
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
	always@(reg_A or reg_B or ex_ir[15:11])
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
					`SLA:		{cf_temp, ALUo} <= {cf_temp, $signed(reg_A) <<< reg_B};
					`SRA:		{cf_temp, ALUo} <= {cf_temp, $signed(reg_A) >>> reg_B};
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
			cf <= cf_temp;
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
				gr[wb_ir[10:8]] <= gr[wb_ir[10:8]];
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

PCPUcontroller.v

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

VTF_CPU.v

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
		
		// Test by me
		/*$display("pc :     id_ir      :reg_A:reg_B:reg_C:da:dd  :w:reC1:gr1 :gr2 : gr3: dm0: dm1: dm2");
		$monitor("%d:%b:%h :%h :%h :%h:%h:%b:%h:%h:%h:%h:%h:%h:%h", 
			uut.pcpu.pc, uut.pcpu.id_ir, uut.pcpu.reg_A, uut.pcpu.reg_B, uut.pcpu.reg_C,
			uut.d_addr, uut.d_dataout, uut.d_we, uut.pcpu.reg_C1, uut.pcpu.gr[1], uut.pcpu.gr[2], uut.pcpu.gr[3],
			uut.d_mem.d_mem[0], uut.d_mem.d_mem[1], uut.d_mem.d_mem[2]);*/
		// Bubble Test
		$display("pc :     id_ir      :reg_A:reg_B:reg_C:da:dd  :w:reC1:gr1 :gr2 : gr3: dm0: dm1: dm2: dm3: dm4: dm5: dm6: dm7: dm8: dm9: dm10");
		$monitor("%d:%b:%h :%h :%h :%h:%h:%b:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h", 
			uut.pcpu.pc, uut.pcpu.id_ir, uut.pcpu.reg_A, uut.pcpu.reg_B, uut.pcpu.reg_C,
			uut.d_addr, uut.d_dataout, uut.d_we, uut.pcpu.reg_C1, uut.pcpu.gr[1], uut.pcpu.gr[2], uut.pcpu.gr[3],
			uut.d_mem.d_mem[0], uut.d_mem.d_mem[1], uut.d_mem.d_mem[2], uut.d_mem.d_mem[3], uut.d_mem.d_mem[4], uut.d_mem.d_mem[5],
			uut.d_mem.d_mem[6], uut.d_mem.d_mem[7], uut.d_mem.d_mem[8], uut.d_mem.d_mem[9], uut.d_mem.d_mem[10]);
			
      enable <= 0; start <= 0;
		// Add stimulus here
		#10 reset <= 1;
		#10 reset <= 0;
		#10 enable <= 1;
		#10 start <=1;
		//#10 start <= 0;
		//Test Need 100.00us
		#100000 $display("After Computing");
					$display("dm0 = %h", uut.d_mem.d_mem[0]);
					$display("dm1 = %h", uut.d_mem.d_mem[1]);
					$display("dm2 = %h", uut.d_mem.d_mem[2]);
					$display("dm3 = %h", uut.d_mem.d_mem[3]);
					$display("dm4 = %h", uut.d_mem.d_mem[4]);
					$display("dm5 = %h", uut.d_mem.d_mem[5]);
					$display("dm6 = %h", uut.d_mem.d_mem[6]);
					$display("dm7 = %h", uut.d_mem.d_mem[7]);
					$display("dm8 = %h", uut.d_mem.d_mem[8]);
					$display("dm9 = %h", uut.d_mem.d_mem[9]);
					$display("dm10 = %h", uut.d_mem.d_mem[10]);
					$display("dm11 = %h", uut.d_mem.d_mem[11]);
	
	end
   always #20 button = ~button;
	always #5 clk = ~clk;
endmodule
```

调试小tips：
工程文件中有一份PCPU_OnebyOne.wcfg的文件，仿真丝打开即可比较舒服得观察调试，打开后需要重新跑一下仿真

传送门：

- CPU2
- CPU2_Add
- CPU2_Bubble
- CPU2_GCD_LCM
- CPU2_Mytest
- CPU2_Sort

点击[这里](http://pan.baidu.com/s/1i3pMzLN)