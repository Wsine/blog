# Markdown标题格式化

## 前言

刚开始学习markdown的时候，觉得这门语言很有意思，那时候还没普及，rules一共就几条且非常容易上手，由于年少无知，遂能成功渲染就算，故养成了一个坏习惯。PS. 如同当年学C++不喜欢敲空格一样。

这里先普及一下[GitHub Flavored Markdown Spec](https://github.github.com/gfm/)这个目前使用最为广泛的扩展标准

>  An [ATX heading](https://github.github.com/gfm/#atx-heading) consists of a string of characters, parsed as inline content, between an opening sequence of 1–6 unescaped `#` characters and an optional closing sequence of any number of unescaped `#` characters. The opening sequence of `#` characters must be followed by a [space](https://github.github.com/gfm/#space) or by the end of line. The optional closing sequence of `#`s must be preceded by a [space](https://github.github.com/gfm/#space) and may be followed by spaces only. The opening `#`character may be indented 0-3 spaces. The raw contents of the heading are stripped of leading and trailing spaces before being parsed as inline content. The heading level is equal to the number of `#` characters in the opening sequence. 

总结性来说，就是**每一个作为标题的#后面都需要添加一个空格**

## 解决方案

为了使旧文档能够在github成功渲染，本文给出了实验后的方法

我的思路就是用正则表达式匹配出markdown的标题，然后补上一个空格

假设你已经有类Unix的环境了，进入终端，一行命令解决

```bash
sed -i -E "s/^#(#*)(\w)/#\1 \2/g" */*.md
```

下面来逐个解释一下这里几个参数都是什么意思

- `sed`是GNU下面的一个文本替换工具
- `-i`代表替换模式，在测试替换效果的时候，可以先不加，在标准输出中就能看到替换效果
- `-E`代表使用regex正则表达式做匹配和替换，这也是我们这里的重点
- `s`代表字符串匹配
- `^`代表文本行的开头（如果你还喜欢在标题前后乱加空格等，那我这个solution也救不了你了）
- `()`代表一个pattern，用于记忆匹配到的内容
- `\1`代表第一个pattern，原文填充
- `g`代表全局替换，不加的话默认只替换匹配到的第一个
- `*/*.md`代表当前目录下的一级子目录下的md后缀名的文件，这个符合我的结构，如果你的目录不太规整，可以用find命令加pipeline管道符组合替换，就不在本文的讨论范围里面了

至此，我们的markdown标题就格式化好了，能够被GFM正确渲染了

#### 但是

上述的方法会有**误杀**，比如说下面这样的例子

```cpp
#include <iostream>
#ifdef AAA
#define BBB
#endif
#etc
```

由于不想代码变得太丑或不可用，我们需要将误杀的这一部分修复回来

同样也是一行命令`sed -i "s/# include/#include/g" */*.md `

如果有太多的话可以写一个for循环，如果不多的话手动敲几次就替换完了，节省时间很重要

至此，才是真的完成了

