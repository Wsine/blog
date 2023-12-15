---
title: "旧酒换新杯，Linux 游戏的春天"
date: 2022-05-16
---

# 旧酒换新杯，Linux 游戏的春天

Steam Deck 是最近最火的游戏掌机，由 Steam 的母公司 Valve 在今年初发布，至今一机难求。正式发售后，从各种评测视频中我们可以看到 Steam Deck 的游戏表现相当不错。

可是你又是否知道 Steam Deck 使用的是基于 Linux 开发的操作系统，但是却能运行各种 Windows 平台的大型游戏，这背后多亏了一个兼容层「Proton」。而 Valve 已经把这个兼容层开源奉献给社区，本文就来一起在 Linux 下实践和研究一下这个神奇的兼容层，看看实际表现如何。

## Proton 的本质是什么？

Valve 在 Github 的[开源主页](https://github.com/ValveSoftware/wine)中是这么描述 Proton 的：

> **Proton** is a tool for use with the Steam client which allows games which are exclusive to Windows to run on the Linux operating system. It uses Wine to facilitate this.

这里透露了几个信息：Proton 是一个在 Steam 的客户端中使用的工具；它的目标就是让 Windows 游戏运行在 Linux 操作系统中；它使用了 Wine（红酒）来实现。

我们知道，Wine 是在 Linux 平台上一个久负盛名的运行 Windows 应用的兼容层，不同于虚拟机或者模拟器去虚拟化/仿真 Windows 的运行时，Wine 主要靠动态地转译 Windows 的系统调用为 POSIX 的系统调用来兼容 Windows 应用的。

但是，从 Wine 的支持应用数据库 [appdb.winehq.org](https://appdb.winehq.org/) 来看，我们看到 Wine 目前对新游戏和新应用的兼容性是比较差的。所以也从侧面表明了 Valve 基于 Wine 做了很多定制开发的工作才能达到比较好的运行效果。

## 如何安装 Proton？

我一开始也是打算自己编译安装 Proton 的，Proton 的 Github 主页上详细阐述了如何编译，甚至搭建好了 Docker 容器，以及编译的产物放在哪个目录下生效。但是，后面仔细研读了 Readme 后发现，**我们并不需要自行编译安装 Proton，Steam Linux 客户端已经自带了该工具。**

这里有一个小插曲，目前 Steam 提供的 Linux 客户端是 32 位的，在我全新安装了一遍 Ubuntu 20.04 操作系统中，并不能直接双击运行安装成功。有两个方法可以安装，其一是启用 `multiverse` 这个仓库并安装其中的 steam 包，其二是启用 `i386` 这个 32 位的架构支持然后就可以安装从官网下载的 Steam 安装包了。详情可以看这个网站的[教程](https://linuxconfig.org/how-to-install-steam-on-ubuntu-20-04-focal-fossa-linux)。

然后，第一次打开 Steam 客户端的过程中耐心等待，它需要安装很多的更新，其中就包括了 Proton 这个工具，这其中也需要良好的网络环境，如果安装更新不成功的话，反复多尝试几次。然后在菜单栏 Steam -> Settings -> Steam Play 中，勾选 "Enable Steam Play for supported titles" 和 "Enable Steam Play for all other titles" 两个选项，默认它会选 "Proton Experimental" 这个 Proton 版本，建议手动选择最新的稳定分支版本。确认后需要重启 Steam 客户端才会生效。

![image-20220531210508233](https://image.wsine.top/35250914b0e9547ab2658bb4852d498b.png)

Caption: 我反正一次就安装更新就成功了

## Proton 实际表现如何？

由于我使用的一台几年前的笔记本，CPU 为 i5-5200U + GPU 为 GeForce 840M，格式化全盘安装 Ubuntu 20.04 进行实验测试，所以游戏表现不会很出众，仅供参考。

当安装完 Proton 并重启 Steam 客户端后，原本灰色不可点击的安装按钮会变成蓝色（INSTALL），然后经过漫长的下载安装游戏过程后，它就能看到那个激动人心的绿色按钮（PLAY）。点击之后，还需要另一个漫长的初次启动过程，我观察了一下是在安装 "Microsoft DirectX for Windows" 和 "Vulkan"，以及进行 "Processing Vulkan shaders"。这个过程也是要保证网络状况良好。

![image-20220531210521464](https://image.wsine.top/ef9eec51f5cd32688af71f72ba866d05.png)

然后就能很顺利地进入游戏了，完全不需要用户额外安装配置什么，十分省心。我简单地玩了一下巫师三，游戏开低特效的模式下锁 30FPS，也能稳定在 25FPS 的水平（左上角）。流畅度主观来说，跟我印象中当年用这台电脑玩的时候是差不多的。

![image-20220531210537042](https://image.wsine.top/1a7ae4fa6732c2dfc9ab8a6641db0751.png)

## Proton 对游戏的支持情况如何？

跟 Wine 一样，Proton 也有自己的支持游戏数据库 [protondb.com](https://www.protondb.com/) 。上面对大部分现在的流行游戏都进行了评级，除了 Linux 原生支持的游戏，评级白金的游戏不用额外调整就能玩，评级金的游戏需要一些调整就能玩，评级银的游戏可能就差强人意了。

那么如何对游戏进行调整呢？在数据库的某一款游戏中，点开会发现玩家的各种评论，其中不乏大神的评论，会报告一串神秘的启动参数。比如 GTA5 游戏的评论中，大神留下了 `DXVK_ASYNC=1 WINE_FULLSCREEN_FSR=1 %command%` 这串神秘参数。我们可以点开 Steam 游戏界面的设置小齿轮，在通用选单里把这串神秘参数原封不动填写到启动选项里就可以了。

![image-20220531210558559](https://image.wsine.top/d1c587456bdd649cf05101e782ab4a0d.png)

## 总结

如果你正好日常使用 Linux 电脑进行深度学习的研究，也有小小的游戏需求，我觉得 Proton 正好就切合这一部分群体的需要，不用额外再安装配置双系统。Proton 整体使用起来真的非常简单，如果正好有环境，不妨一试。
