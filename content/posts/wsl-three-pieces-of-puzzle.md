---
title: "WSL 的三块新拼图，这就是为师的完全体"
date: 2022-07-08
---

# WSL 的三块新拼图，这就是为师的完全体

Windows Subsystem for Linux（WSL）是微软在 Windows 平台下支持 Linux 环境的子系统，一经推出便受到各大开发者的青睐。少数派平台上也有很多篇 WSL 相关的文章：

- [不用装双系统，直接在 Windows 上体验 Linux：Windows Subsystem for Linux](https://sspai.com/post/43813)

- [💡 在 Windows 上用 WSL 开发的操作体验指北](https://sspai.com/post/47719)

- [想安装更多 Linux 发行版？LxRunOffline 让 WSL 更好用](https://sspai.com/post/61634)

如果你也是一名深度学习科研人员，科研圈里的新文章大部分都是基于 Linux 环境的科研实验，而我们日常使用的电脑却是 Windows 平台。而普通的 Linux 虚拟机又无法访问显卡以获得深度学习加速。另一方面，有部分的科研实验开源了他们的 toolkit，但是却是使用 Linux 桌面环境开发的，在 Linux 服务器上也无法使用。

现在，随着时间的推移，WSL 不断迎来了它的功能增强，分别是 WSL2，NVIDIA CUDA on WSL，和 WSLg。它们各自解决了 WSL 在上述场景下不同的开发难题。「Microsoft loves Linux」

本篇文章就是一个教程指导安装和配置 WSL 使其能够使用上上述的新功能。

## 第二代 WSL 完整的 Linux 体验

### 主要区别

WSL 目前有两个主要版本，分别称为 WSL1 和 WSL2。它们最大的不同是，WSL1 是基于动态翻译的方式将 Linux 的系统调用翻译为 Windows NT（Windows 操作系统的内核）的系统调用，而 WSL2 是基于虚拟机的，在 Windows 主系统之上创建完整的 Linux 内核。

开发者在 WSL1 中遇到的问题就是，部分 linux 的命令无法成功运行。当你遇到这个问题，将会一件非常恼火的事情。比如，WSL1 中无法成功运行 docker，因为需要 linux 关于名称空间的系统调用，而 WSL1 并不支持。最终，微软还是决定使用虚拟化技术来克服这一问题。

WSL1 和 WSL2 之间其它的主要功能比较，可以参照这这个[微软文档](https://docs.microsoft.com/zh-cn/windows/wsl/compare-versions)中的表格：

![image-20220826192131397](https://image.wsine.top/0c6d9e26fa7407344a76b7764d884e9b.png)

从表格中可以看出，WSL2 在功能支持的数量上明显优于 WSL1，但跨 OS 文件系统的性能这一项除外。后面我们会根据实际路径说明，如何避免跨 OS 文件访问以避免性能问题。

### 启用 WSL2

首先，WSL2 能在 Windows 11 or Windows 10, Version 1903, **Build 18362** 或更高的版本号中启用。

**方式一：命令行方式。**最快捷的方式莫过于命令行，一行命令即可完成启用和安装，`wsl --install` 。该命令会帮助用户启用必要的系统组件，下载最新的 Linux 内核，设置 WSL2 为默认版本，下载并安装 Ubuntu 作为初始版本。

如果想要更细致的控制安装选项，可以使用下面的方式二手动启用。

**方式二：图形选项卡。**由于 WSL2 的实现方式是基于虚拟机的形式，因此在 Windows功能 的菜单里需要打开两个关键的组件「Virtual Machine Platform」和「Windows Subsystem for Linux」。否则是没有办法创建磁盘，启动并进入 WSL2 的，而 WSL1 仅需打开「Windows Subsystem for Linux」。

![image-20220826192158618](https://image.wsine.top/2a758eb36a1dd07a20c2d3b44b3e8362.png)

经过重启电脑后，勾选的新功能将会被启动。打开终端，输入 `wsl --set-default-version 2` 命令即可将 WSL 的版本设置为使用 WSL2.

```PowerShell
PS C:\Users\someone> wsl --set-default-version 2
For information on key differences with WSL 2 please visit https://aka.ms/wsl2
The operation completed successfully.
```

安装 Linux 发行版应该不必多说，通过 Windows 应用商店点击一下即可安装。

![image-20220826192218199](https://image.wsine.top/19670132395833aba93a697f5a9d5447.png)

默认情况下，这两种安装方式都会将 WSL 安装到系统盘。如果想要将 WSL 安装到非系统盘，可以参考下面这篇文章。

### WSL2 跨系统访问文件

由于 WSL2 变成了一个虚拟机的形式，那么以前便捷的资源管理器访问 Linux 目录树的功能便不容易找到对应的位置了，如上图，都整合为一个虚拟磁盘 ext4.vhdx 文件了。

但是，在资源管理器中输入 `\\wsl$\Ubuntu-20.04\home\user` 可以通过 smb 协议访问 Linux 目录树，也可以将其绑定在网络位置中快速进入。

![image-20220826192232957](https://image.wsine.top/9cee6070d74f76c468d912a6a26c5fa0.png)

Caption: dotfiles 很乱，应该遵照 XDG Base Directory Specification

能够使用系统的资源管理器访问虚拟机的文件真的很方便。在我的使用场景中，我会用来查看实验运行结果产生的图片，以初步判断目标检测的效果。而这之前，我都需要起一个 HTTP 服务来浏览或者通过 scp 拷贝一份到本机才能浏览。

## WSL 的图形小尾巴： WSLg

![image-20220826192248769](https://image.wsine.top/cd236ffb467fc6a33e68d512421d7fcc.png)

Caption: 图源 https://github.com/microsoft/wslg

WSLg 是微软开发的一套技术栈，致力于将 Linux 的 GUI 应用无感地带到 Windows 操作系统中。简单点来说，就可以通过开始菜单运行一个 Linux 的图形化应用，而用户却感知不到它其实运行在 WSL2 中。

在之前，如果想要运行 Linux 图形化应用，我们需要使用实体机/虚拟机安装完整的 Linux 桌面系统才行。更高级一点，需要在 Windows 端安装 XServer，然后通过 X11 forward 转发来渲染图形化。

WSLg 实现了相同的功能，且功能更丰富。首先，不需要完整的桌面系统环境的情况下，WSLg 更轻量化，只包含了显示服务器（X Window Manager）。其次，XServer 仅支持 X11 App 这类应用，而 WSLg 进一步支持 Wayland App。最后，WSLg 方案引入了 RDP 的本地远程桌面方案显示 GUI 应用，能够最大限度地支持复制粘贴切换应用等一些列 Windows 的使用习惯。

如果你想体验一下现在 Linux 下的软件生态的话，WSLg 是一个支持最丰富的方案了，尝鲜完后也可以完全卸载 WSL2，干干净净，清清爽爽。

### 安装 WSLg

WSLg 要在 Windows 11 或更高的版本号中启用，注意 Windows 10 用户便无法使用该功能了。

WSLg 的安装更为简单，其实已经包含在上述的步骤中了。当执行 `wsl --install` 的时候，WSLg 也会被一并安装。如下图，我重新执行了一遍全新安装，WSL 所要求的相关组件也会自动安装，然后只需要重启一遍系统便能启动该功能。对于已安装 WSL2 的用户，可以执行 `wsl --update`。

![image-20220826192302826](https://image.wsine.top/b3c34376e14edf4e614b93eebffbb201.png)

Caption: 注意需要使用管理员权限运行

你可以通过 apt 安装 `x11-apps` 然后运行 `xeyes` 来确认安装成功。

但是，WSLg 也不是所有的图形应用都能完美运行，网上有不少的帖子表示很多用户遇到的困难，大部分都指向了 systemd 和图形驱动相关的问题。这也可以作为你的初步判断看看 WSLg 是否能满足自己的需求。

### 实际应用

在我的日常工作中，还需要对实验数据进行数据分析。我常常使用 python 调用 matplotlib 库绘制论文插图，通过 WSLg 可以方便地直接渲染并显示绘制的插图，这样我就能快速地迭代调整插图的细节。

在这之前，我都是通过 Google Colab 来完成绘图工作的。但是在实验的 artifacts 比较多和比较大的时候，我需要花费大量精力想办法把 artifacts 同步到 Colab 的运行时中；或者通过端口转发让 Colab 使用本地运行时来访问 artifacts。但无论哪种方法，都比不上 WSLg 来得直接和方便。

![image-20220826192322018](https://image.wsine.top/15eeb974e3b2c1a28b9563326812bc4e.png)

Caption: 用我最喜欢的正弦函数来做演示

对于很多以 Linux 作为第一优先级支持的 GUI 应用，我认为也是很值得使用 WSLg 的，比如，著名仿真软件 [GAZEBO](https://gazebosim.org/home)、机器人软件包 [ROS](https://www.ros.org/)、生物信息工具 [Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi) 等。

![image-20220826192340565](https://image.wsine.top/f51e1aa88ac10d28f66b40f1d065c154.png)

Caption: 官网 showcases

如果你有正好在练习和熟悉 Linux 的操作，那么我推荐你安装使用 [Timeshift](https://github.com/teejee2008/timeshift) 这款应用。它可以给你指定的路径创建备份作为还原点，然后就可以放心地折腾 WSL2 以学习 Linux 的使用，遇到问题后快速恢复。

![image-20220826192354134](https://image.wsine.top/c36fdd45faf53e5bf61058eb69cd7a5d.png)

Caption: 来源 Timeshift 的 github 主页

如果你有在电脑端阅读电子书的习惯，而且听说过江湖传说「Windows 的字体渲染是很糟糕的」，那么不妨试试字体渲染更好一些的 Linux 阅读器 [Foliate](https://johnfactotum.github.io/foliate/)。虽然有点曲线救国的意思，但也不失为一种不错的解决方案。

![image-20220826192411123](https://image.wsine.top/45d5ed35923c335ea25e0d957d16825f.png)

Caption: 来源 Foliate 主页

## 进击的 WSL with CUDA

CUDA，全称「Compute Unified Device Architecture」，是 Nvidia 公司发行的针对自家公司 GPU 显卡的并行计算开发套件。使用 CUDA 这个开发套件可以直接访问 GPU 中的流处理器，更高效地完成大量且重复的简单计算。

由于 GPU 的并行计算能力比 CPU 强大，因此更加适合矩阵计算，图形渲染等任务。而目前很热门的深度学习技术正是因为大量使用的矩阵计算，所以对 CUDA 有很大的依赖。

在我的日常工作中需要对深度学习技术进行研究，现在 WSL 也能支持 CUDA ，对我来说就能降低对于服务器的需求，在本地机器上完成基础的代码编写和运行测试，然后再同步到服务器进行大规模的实验了。

### 安装 CUDA

CUDA on WSL 可以在 Windows 11 或 Windows 10, Version 21H2 及更高的版本号中启用。

很多同学看了微软和英伟达关于 CUDA on WSL 相关的文档，还是一头雾水。除了因为大量的英文描述以外，还因为他们都没有言简意赅地告诉你，**整个安装过程对于用户其实是非常简单的**。

整个安装过程可以分为三步走：

1. 在 Windows 侧升级 Linux 内核；

1. 安装 Nvidia 的显卡驱动；

1. 在 WSL 内安装 Nvidia CUDA 的开发套件；

![image-20220826192426623](https://image.wsine.top/f75ec77d1f4a7597f897b0b15ba74693.png)

Caption: 架构简易图示

第一步，升级 Linux 内核，这里需要分三种情况讨论：

1. 如果你是通过上述步骤全新安装的 WSL，那么你可以跳过这一步，因为初次安装就是最新的内核版本了。

1. 如果你日常使用 Windows 打开了自动更新功能（最多关21天），那么你也不用升级，因为日常它就会帮你自动升级。

1. 如果真的需要手动安装，`wsl --install`命令一键安装完成。

最后你可以通过 `wsl cat /proc/version` 命令确认内核版本大于 5.10.43.3.

```PowerShell
PS C:\Users\someone> wsl cat /proc/version
Linux version 5.10.102.1-microsoft-standard-WSL2 (oe-user@oe-host) (x86_64-msft-linux-gcc (GCC) 9.3.0, GNU ld (GNU Binutils) 2.34.0.20200220) #1 SMP Wed Mar 2 00:30:59 UTC 2022
```

第二步，安装 Nvidia 显卡驱动。这个其实大部分配置了英伟达显卡的个人电脑都已经安装了，否则根本无法正常使用显卡的功能。如果你能在系统托盘看到 Nvidia GeForce Experience，那么说明你已经安装好了。如果没装，进入[英伟达驱动官网](https://www.nvidia.com/download/index.aspx)，选择自己的显卡型号下载安装包一路点下一步就好。

虽然 Nvidia 没说具体的版本号要求，只提了最新的驱动能支持。但个人来说我也推荐偶尔手动更新到最新版本，以获取更稳定高效的驱动表现和更高的游戏性能。

第三步，安装 Nvidia CUDA 的开发套件。Nvidia 的 [CUDA 官网](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_local)中已经贴心地将 WSL 视作一个独立的 Linux 发行版，只要选择如下图的选项，根据网站下面显示的指令敲一遍就能顺利安装 CUDA 开发套件。整个过程和其它的发行版安装无异，完全不用额外的学习成本。

![image-20220826192440571](https://image.wsine.top/9a56929b02a6c606330a00313c44bf46.png)

从深度学习用户的角度来说，我并不推荐无脑安装最新的 CUDA 版本，除非自己清楚影响范围是什么。一般来说，使用深度学习环境如 [pytorch](https://pytorch.org/get-started/locally/) 和 [tensorflow](https://www.tensorflow.org/install/gpu) 官网中推荐安装的版本能获得最少 bug 的体验。因此，在 [CUDA 官网](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_local) 下面选择 Archive of Previous CUDA Releases 可以获取历史版本的安装指令。

在 WSL 下运行 `nvidia-smi` 等命令可以确认是否正确安装 CUDA 套件。

![image-20220826192453120](https://image.wsine.top/0f62285b2aad0615b394b053a79d6194.png)

至此，你已经安装完成了 WSL 下 CUDA 的全部依赖了，可以和普通的 Linux 环境一样正常安装使用深度学习的环境了。

### 实际应用

和大多数的深度学习科研工作者一样，我一般使用 CUDA 来运行深度学习应用。在 WSL 的环境下，编码体验和服务器端完全一样，但由于不用考虑和同学们分时复用 GPU，编码和测试就能够更频繁地交替。在同样的 RTX2080Ti 的显卡下，也没有明显感知到运行速度的差异。

![image-20220826192505276](https://image.wsine.top/cf37c2828c387e3990833c23929b1037.png)

类似地，Intel 和 AMD 也有等同于 CUDA 的开发套件，分别是 [oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/overview.html#gs.53ka13) 和 [ROCm](https://rocmdocs.amd.com/en/latest/) 。[微软](https://devblogs.microsoft.com/commandline/oneapi-l0-openvino-and-opencl-coming-to-the-windows-subsystem-for-linux-for-intel-gpus/)和[英特尔](https://www.intel.com/content/www/us/en/artificial-intelligence/harness-the-power-of-intel-igpu-on-your-machine.html)在博客中各自宣布了在 WSL2 中支持 oneAPI，但关于 ROCm 的消息还没有看到。对于另外两家的硬件有需求的读者可以去探索一下。

## 后记

软件的功能层出不穷，但永恒不变的还是那句话，适合自己的才是好的。如果你也有类似的需求，想要兼顾 Windows 系统上大量的常用软件，那么 WSL2 从这个角度看是很理想的选择，不妨试试。关于 WSL2 的使用有什么痛点以及更合适的使用场景和软件推荐，也欢迎在评论区留下你的评论。

**关联阅读**：

- [Enable NVIDIA CUDA on WSL](https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl)

- [CUDA on WSL User Guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
