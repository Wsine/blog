---
title: "安装 WSL2 到非系统盘"
date: 2022-07-22
---

# 安装 WSL2 到非系统盘

在上一篇关于 WSL 新功能的文章的评论中，有读者提到了安装 WSL 到非系统盘是一件困难的事情。

在 Windows 系统的默认情况下，WSL2 会被安装到系统盘中。现在系统盘大多为固态硬盘，存储空间比较珍贵；而 WSL2 基于虚拟机实现，跨系统访问数据盘文件读写速度缓慢。如果你的电脑环境 C 盘空间并不大，又有需求高度使用 Linux 环境，那么将 WSL2 安装到非系统盘是一个必不可少的步骤。

但是，对于安装 WSL1 到数据盘的方法现在已不可用了。本文分析旧方法的不可行的原因，并对于 WSL2 的迁移整理了新的方法。

## WSL1 的方法不兼容 WSL2

WSL 经历了两个大版本，分别称为 WSL1 和 WSL2。前者是通过兼容层方式转译系统调用，而后者通过虚拟机的方式运行完整的 Linux 内核。

网络上原有的安装 WSL1 到非系统盘的方法对于 WSL2 来说已不可行，简单总结一下：

1. 手动下载 Linux 发行版安装包，通过改后缀为 zip 自行解压后运行发行版的 exe 文件。

1. 使用 LxRunOffline 工具将方法一自动化处理。

![image-20220826193002741](https://image.wsine.top/ec0e25322c0fd4493dbccc82459846c2.png)

Caption - 图解方法一：此方法已不可行，见下图

当你完成下载，改名和解压后，你会发现压缩包里面递归嵌套了很多层 appx 的文件，而且没有任何一个 exe 文件。该方法在 WSL1 中可行，因为会产生对应的 ubuntu.exe 这样的入口程序。根据网上的[教程](https://damsteen.nl/blog/2018/08/29/installing-wsl-manually-on-non-system-drive)，当你运行 ubuntu.exe 这个程序后会进行 ubuntu 设置用户名和密码的初始化，然后产生一个 rootfs 的文件夹存储着 Linux 的根系统文件树。

但是，WSL2 中分离了入口文件和磁盘存储文件，并不随着发行版安装包分发。当无法找到 ubuntu.exe 入口程序的时候，就无法进行下一步了。而一个正确安装的 WSL2 环境，Linux 的根系统文件树都在一个 ext4.vhdx 的虚拟磁盘中。

![image-20220826193013565](https://image.wsine.top/46aa1344e8a89cab609d2ad6b8d493cd.png)

Caption - 除了 ext4.vhdx 都是压缩包内的文件

## 兼容 WSL1 和 WSL2 的新方法

好消息是，WSL 的工具集也在不断更新，现在官方的 wsl.exe 工具已经能够支持导入导出 Linux 发行版了。我们可以通过这个功能来实现将 WSL2 迁移到别的系统盘符上。

假设你已经安装好了 WSL2 的环境，如果还没安装可以参考[《为 WSL 配置这些新功能，不用虚拟机也能体验完整 Linux》](https://sspai.com/post/74167)。

首先要确认我们电脑上安装了什么发行版，主要是确认具体的发行版在电脑上的名称，通过 `wsl.exe --list` 列出即可。我这里的具体名字为「Ubuntu-20.04」。

```PowerShell
PS C:\Users\someone> wsl.exe --list
Windows Subsystem for Linux Distributions:
Ubuntu-20.04 (Default)
```

然后，我们导出该发行版到一个压缩包中；反注册该发行版；再重新导入该发行版，并指定安装的位置。用 D 盘来做一个具体的例子，假设我首先创建了一个空白的路径 `D:\WSL\Ubuntu`，然后执行：

```PowerShell
PS C:\Users\someone> cd D:\WSL
PS D:\WSL> wsl.exe --export Ubuntu-20.04 Ubuntu-20.04.tar
PS D:\WSL> wsl.exe --unregister Ubuntu-20.04
PS D:\WSL> wsl.exe --import Ubuntu-20.04 D:\WSL\Ubuntu Ubuntu-20.04.tar
```

导入之后，wsl.exe 工具会自动注册导入发行版的位置，可以通过 `wsl.exe --list` 命令再次查看。

还有一个可选命令是 `wsl.exe --set-default Ubuntu-20.04` ，如执行该命令，后续敲 wsl.exe 便会直接进入该发行版。但我不喜欢，因为它默认会切换到当前 windows 路径下，还得手动切换到 home 目录。可以通过补全功能敲 ubuntu2004.exe 命令直接进入 home 目录。 

![image-20220826193036385](https://image.wsine.top/a0f2b985ad12312f35b9ee8fc3a4cc7d.png)

caption：两种进入 WSL2 的命令方式

ubuntu2004.exe 命令并没有跟随发行版安装包分发，如果仔细查找，它会出现在 AppData 中。但文件本身不大，我们不用动它。

```PowerShell
PS D:\WSL> Get-Command ubuntu2004.exe

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Application     ubuntu2004.exe                                     0.0.0.0    C:\Users\someone\AppData\Local\Microsoft\WindowsApps\ubuntu2004.exe
```

然后就是常规的 Linux 命令行配置和捣鼓了，少数派上有很多文章可供参考，可以自行搜索。
