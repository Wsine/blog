#arm-elf-gcc交叉编译器的使用教程

一开始需要安装arm-elf-gcc，但是这是一个32位的程序，我是安装了64位的系统，据说安装ia32.libs依赖库能运行这个，但是看到博客上面前人安装完了系统图标少了一半，然后就怕了。经过了翻看ubuntu论坛和各种博客，才知道14版之后的ubuntu64位官方已经抛弃了ia32.libs这个依赖库，在源列表中也是找不到的。但是官方自身已经支持32位，自带32位依赖库，在根目录下面就有一个lib32文件夹。

###安装教程

博主使用的是arm-elf-tools-20040427.sh的编译器，比较老旧，但不影响使用。

1. 打开终端
2. 切换到arm-elf-tools-200427.sh所在路径
3. 增加执行权限
	`sudo chmod 755 arm-elf-tools-20040427.sh`
4. 安装
	`sudo sh arm-elf-tools-20040427.sh`

以上，安装完成

注：文件arm-elf-tools-20040427.sh的大小有17M，这个脚本就是安装文件。没事不要用普通的文本编辑器打开，高级点的文本编辑器可以。

###使用教程

首先上一份简单的测试代码

```
int max( int* pt, int size )
{
	int max_v = -32768;
	int* tmp = &pt[size];
	int* pi = pt;
	
	while(pi<tmp){
		if( *pi>max_v ){
			max_v = *pi;
		
		}
		pi++;
	}
	
	return max_v;	
}
```

1. `arm-elf-gcc -S max.c`
	得到由c文件生成的汇编文件max.s
	![1](http://images0.cnblogs.com/blog2015/701997/201507/211441303633071.png)

2. `arm-elf-gcc -c max.s`
	由汇编文件编译得到Object文件max.o
	![2](http://images0.cnblogs.com/blog2015/701997/201507/211442344734551.png)

3. `arm-elf-readelf -a max.o > max_elfinfo`
	这个命令将给出全部的Object文件信息,保存在max_elfinfo这个文件中
	![3](http://images0.cnblogs.com/blog2015/701997/201507/211443086447411.png)

4. 查看一下max_elfinfo文件：ELF_header
	![4](http://images0.cnblogs.com/blog2015/701997/201507/211443357542263.png)

5. 查看一下max_elfinfo文件：Section_header
	![5](http://images0.cnblogs.com/blog2015/701997/201507/211444108635437.png)
	![5_2](http://images0.cnblogs.com/blog2015/701997/201507/211444477236109.png)



6. `hexdump -C max.o > max_hex`
	直接打印出Object文件的全部字节，保存在max_hex文件中
	![6](http://images0.cnblogs.com/blog2015/701997/201507/211445129263276.png)
	以上面的.real.text为例子
	![6_2](http://images0.cnblogs.com/blog2015/701997/201507/211445554263959.png)

7. Elf最后输出的内容
	![7](http://images0.cnblogs.com/blog2015/701997/201507/211446258639194.png)
	.rel.text告诉链接器指令中的哪些地方需要做重定位;
	.symtab是符号表。Ndx列是每个符号所在的Section编号
8. `arm-elf-ld.real -o max2.out max.o`
	链接指定Object文件，max2.out为生成的文件，max.o为源文件
	![8](http://images0.cnblogs.com/blog2015/701997/201507/211447049571750.png)
	由于没有__gccmain函数入口，故有warning，此处先不管，绿色即为新生成文件
9. 用readelf命令分析新生成的max2.out
	`arm-elf-readelf -a max2.out > max2_elfinfo`
	![9](http://images0.cnblogs.com/blog2015/701997/201507/211447303489859.png)
	![9_2](http://images0.cnblogs.com/blog2015/701997/201507/211448135988913.png)
	![9_3](http://images0.cnblogs.com/blog2015/701997/201507/211448517387328.png)

10. 调用不同c文件中的子函数
	程序修改后如下：
	![10](http://images0.cnblogs.com/blog2015/701997/201507/211449421916648.png)
	![10_2](http://images0.cnblogs.com/blog2015/701997/201507/211450229881118.png)
	![10_3](http://images0.cnblogs.com/blog2015/701997/201507/211450508329109.png)

11. 编译两份c文件生成 .o 文件
	![11](http://images0.cnblogs.com/blog2015/701997/201507/211451369732148.png)

12. `arm-elf-ld.real -o main2.out main.o encrypt_char.o -lc`
	main2.out是链接生成的文件，main.o encrypt_char.o是参与链接的源文件，-lc 允许链接器搜索默认的路径，当你使用了系统自带的头文件或子函数时，需要添加该选项以便链接器能顺利链接到对应库
	![12](http://images0.cnblogs.com/blog2015/701997/201507/211452282546580.png)

13. `arm-elf-objdump -S main2.out > main2_1.s`
	反汇编链接后的.out文件，和链接前的.o文件反汇编结果进行比较
	![13](http://images0.cnblogs.com/blog2015/701997/201507/211453019267527.png)
	新生成的main2_1.s文件里面比原来的多了很多内容，最大的不同在于区分了各个文件的代码段
	![13_2](http://images0.cnblogs.com/blog2015/701997/201507/211453305665578.png)
	![13_3](http://images0.cnblogs.com/blog2015/701997/201507/211453536138603.png)
	![13_4](http://images0.cnblogs.com/blog2015/701997/201507/211454489574861.png)