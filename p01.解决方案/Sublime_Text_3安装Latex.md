# Sublime Text 3安装Latex

### 安装环境
Sublime Text 3已安装Package Control

### 安装过程

1. 进入官网下载安装MikTex，www.miktex.org
2. 进入官网下载安装SumatraPDF, www.sumatrapdfreader.org
3. Control + Shift + P, install package, 搜索LatexTools并安装
4. Control + Shift + P, 搜索LatexTools: Reconfigure and migrate settings并确认
5. 菜单栏，Preferences，Package Setting，LatexTools，setting - user
6. 找到以下内容并根据自己实际情况修改

```
"windows": {
	// Path used when invoking tex & friends; "" is fine for MiKTeX
	// For TeXlive 2011 (or other years) use
	// "texpath" : "C:\\texlive\\2011\\bin\\win32;$PATH",
	"texpath" : "D:\\Program Files (x86)\\MiKTeX 2.9\\miktex\\bin;$PATH",
	// TeX distro: "miktex" or "texlive"
	"distro" : "miktex",
	// Command to invoke Sumatra. If blank, "SumatraPDF.exe" is used (it has to be on your PATH)
	"sumatra": "D:\\PortableSoftware\\SumatraPDF.exe"
},

"builder": "simple",
```

注意符号不能打错和打漏

### 如何使用

最简单的测试文件test.tex
```
\documentclass{article}
  
\title{Title}
\author{Your Name}
  
\begin{document}
  
\maketitle{}
  
\section{Introduction}
  
This is where you will write your content.
  
\end{document}
```

上面的设置中我们已经修改成了使用pdflatex编译器，用SumatraPDF打开生成文件。

Ctrl + B可以编译tex文件，会自动用SumatraPDF打开生成文件，在tex文件的所在目录下有同名的pdf文件

### 反向操作

在SumaPDF中，菜单，设置，选项

最下面的反向搜索命令行根据自己实际路径输入

`"C:\Program Files\Sublime Text 3\sublime_text.exe" "%f:%l"`

在SumatraPDF中，双击即可反向搜索tex文件