---
title: "balena：你的树莓派的强力后援"
date: 2021-12-07
---

[TOC]

树莓派是一个小巧的设备，由英国树莓派基金会开发的微型单板，设计的目标是以低价硬件和自由软件促进学校的基本计算机科学教学。麻雀虽小，树莓派本身也是一个五脏俱全的计算机，并且提供通用的 USB 接口、RJ45 网口以及 GPIO 排针接口予以扩展。且由于其较低的售价，受到了各种人群的喜欢。

但是，并不是喜欢树莓派的所有人都有计算机科学的背景，相当大一部分小白都在通过关注极客玩家们的教程，一步一步跟着教程操作来复刻他们做出来的东西。可是，尽管有了教程的帮助，小白在实际操作的过程中也还是会遇到很多失败的情况且不知道如何独立解决。

所以我打算向大家介绍 Balena 这个一站式的解决方案。

## Balena： 完整的生态

Balena 是一套完整用于开发、部署、管理 IOT 设备，并提供了云用于连接这些 IOT 设备们的工具和服务。它包括了：

- balenaEngine 是一个为嵌入式设备优化的运行引擎，等同于 Docker 的存在，但胜在软件体积更小，需要传输的镜像层更小，内存占用也更少。
- balenaOS 是一个极简的 Linux 系统，不同于 Raspberry Pi OS，仅包含了 balenaEngine 以及一些必要的系统组件，使得硬件资源能够被最大化目标软件的使用，但借助 Balena 的其他服务，又可以很轻松的部署我们想要的工具。。
- balenaHub 是一个类似 Github 的地方，开发者把软件装载进 balenaOS 中并发布到这里，用户可以从这里免费下载已经打包好的「系统镜像」。
- balenaEtcher 是一个开源跨平台的系统镜像烧录工具，有精美易用的 UI 界面，可以把上述系统镜像烧录到 tf 卡中，然后插入树莓派直接开始使用。
- balenaFin 一个建立于树莓派计算模块之上的开发板，有更好的存储和电源扩展等。
- balenaCloud 就是承载了上述的开发交互界面，包括打包镜像、管理设备的云端等功能，balenaCloud 我们后面展开细说。
- openbalena 则是 balenaCloud 的开源版本，如果不信任由 Balena 这家商业公司提供的云，那么就可以考虑自己部署云端，不过只支持单用户，也没有 Web UI。后者在 Github 上有第三方的开源版本可以使用。

从该生态版图可见，Balena 基本包含了嵌入式开发中的所有环节，哪怕你会说没有树莓派，都给你考虑到了。

Balena 服务的定价策略比较良心，对于个人用户来说，前 10 个设备使用 balenaCloud 都是全功能且免费的，基本上普通的用户也不会超过 10 个 IOT 设备需要连接云吧。后续的服务收费档位主要是根据设备的数量来决定的。

对于上述的小白用户来说，最有价值的莫过于 balenaHub 这个大仓库，可以直接下载极客玩家们开发打包好的应用程序的系统镜像，然后烧录到自己的树莓派中即可享用。

## balenaHub： Airplay 服务器

下面我将以 [balena-rpiplay](https://hub.balena.io/gh_rahul_thakoor/balena-rpiplay) 项目作为案例在树莓派进行部署，让大家可以清晰直观的看到项目部署的流程有多简单。

[balena-rpiplay](https://github.com/rahul-thakoor/balena-rpiplay) 可以把你的树莓派变成 Airplay Server，用户把苹果设备的屏幕镜像串流到树莓派上，而树莓派则通过 HDMI 连接电视/显示器/投影仪，部署了这个项目以后算是 Apple TV 盒子中 Airplay 功能的平替。

balena-rpiplay 项目包含了 [RPiPlay ](https://github.com/FD-/RPiPlay)项目，后者的安装原本需要你手动安装 cmake 包管理器、一堆 C 语言的依赖库、OpenMAX 库和客户端。直接在 Raspberry Pi OS 安装时需要从源码开始构建软件，对于没有 Linux 基础的普通玩家来说，整个部署流程十分硬核且枯燥。但是如果进入 [balena-rpiplay](https://github.com/rahul-thakoor/balena-rpiplay) 的项目主页看，里面没有一行实体代码，只有简单的配置文件描述，整个过程被大幅度地简化了。

![image-20211216203458740](https://image.wsine.top/b2ec202be31ff854264ccdde268bb665.png)

那么实际部署流程是怎么样的呢？

- 首先在 balenaHub 找到 [balena-rpiplay](https://hub.balena.io/gh_rahul_thakoor/balena-rpiplay) ，点击图中的 Get started 按钮。
- 在弹出界面选择自己的树莓派版本。
- 输入自己家的 WiFi 连接方式（SSID 和密码），也可以选择用网线连接。
- 下载镜像，通过 balenaEtcher 刷入到 tf 卡中，并插入到树莓派中。
- (可选) 对于没有自带 WiFi 模块的树莓派 （2代及以下），需要自备 WiFi 适配器。
- 然后通电，静待几分钟，就拥有了自己的 Airplay 服务器。

![image-20211216203548715](https://image.wsine.top/5fcad0b590ea46075ed321d7cbe2ba64.png)

整个过程不需要用户用终端配置任何的东西，最麻烦的步骤仅是烧录系统到 tf 卡中。烧录镜像到树莓派的步骤，可以参考这篇文章：[《从选购到入手：树莓派零基础入坑指南》](https://sspai.com/post/66938)



![image-20211216203605818](https://image.wsine.top/cacb0cff9c2fb87f1e2d7ce5f64e637b.png)

整个部署上没有手动输入命令，修改配置文件的体验，背后多亏 balenaCloud 的帮助。当你烧录好系统的时候，它的软件架构是上图这个样子的。当你第一次给硬件通电的时候，首先如同绝大多数 Linux 发行版一样，systemd 作为第一个守护进程启动，并带起 NetworkManager 通过预设的 WiFi 信息连接你家里的网络，另一方面唤醒并守护你安装的容器，完成整个工作流程。

而从用户的角度来看，整个过程就像是通了电就能自动完成安装 Airplay Server 一样，最后只需要拿出的苹果设备搜索并连接上该树莓派就可以进行投屏了。

## balenaCloud：你的 IOT 管家

细心的同学可能还会发现，图中还有一个抓眼球的 Device Supervisor Container (DSC)，它一方面跟云端的 balenaCloud 进行通讯，一方面也在本地网络广播自己的存在，使得整个开发部署管理流程有了更多的可能。根据我自己的经验，我会从几个痛点聊聊 balena 是如何帮助开发者更好地解决 DevOps 的问题的。

### 开发

当要利用树莓派进行开发的时候，我们首先遇到的问题就是「如何交互」。一般来说，在树莓派上开发，你需要准备一个键盘、一个鼠标、一个显示器以及一根 HDMI 线，才能满足基本的开发要求。

虽然新的 Raspberry Pi OS 系统版本支持了通过 txt 配置 WiFi 连接和启动 sshd 服务，让你可以通过无线 ssh 直接操作终端命令行。但是你又会发现缺少顺手的开发工具、必要的运行时等，等把这些又千辛万苦地安装好后，相信你的热情已经被消磨了一大半了。

DSC 是帮助开发者解决这个问题的关键。首先，balena 提供了 balenaOS base 镜像给用户烧录到 tf 卡中，启动它，DSC 会不断广播自己的存在。然后，用户在自己熟悉的 PC/Laptop 中安装 balena 这个 client 软件，通过 `sudo balena scan` 命令即可搜索到自己的树莓派的 ip 地址。

```Plain%20Text
Reporting scan results
-
  host:          63ec46c.local
  address:       192.168.86.45
  dockerInfo:
    Containers:        1
    ContainersRunning: 1
    ContainersPaused:  0
    ContainersStopped: 0
    Images:            4
    Driver:            aufs
    SystemTime:        2020-01-09T21:17:11.703029598Z
    KernelVersion:     4.19.71
    OperatingSystem:   balenaOS 2.43.0+rev1
    Architecture:      armv7l
  dockerVersion:
    Version:    18.09.8-dev
    ApiVersion: 1.39
```

假设你已经在 PC/Laptop 开发并测试好了软件和应用，下一步需要的就是验证在树莓派上也可运行。那只需要一行命令 `balena push 63ec46c.local` 即可把当前项目的信息一键发送到树莓派中，DSC 负责接收并自动执行构建和运行，所有的命令行输出会回传到自己的 PC/Laptop 中，查看并解决可能的错误，大大减轻了需要反复查看日志的繁琐过程。

```Plain%20Text
[Info]    Starting build on device 63ec46c.local
[Info]    Creating default composition with source: .
[Build]   [main] Step 1/9 : FROM balenalib/raspberrypi3-node:10-stretch-run
[Build]   [main]  ---> 383e163cf46d
...
[Build]   [main] Successfully built 88065a1a3f00
[Build]   [main] Successfully tagged local_image_main:latest

[Info]    Streaming device logs...
...
[Logs]    [1/9/2020, 1:47:03 PM] [main] > node server.js
[Logs]    [1/9/2020, 1:47:03 PM] [main]
[Logs]    [1/9/2020, 1:47:04 PM] [main] Example app listening on port  80
```

### 部署

到了真正需要部署的时候，一个比较麻烦的事情是，给不同的硬件适配性地打包。回想我们给树莓派开发部署好的软件和应用，由于只有一张 tf 卡且暂时要把树莓派挪作他用，等到想回顾这个应用或者重新玩一下的时候，又需要重头再来折腾。

balena 帮助开发者把这件事情放到了 balenaCloud 中执行。开发者只需要编写一份 balena.yml 文件描述一些必要的信息，比如支持的硬件如树莓派 1、2、3、4 等，项目名称等展示在 balenaHub 中。通过输入 `balena deploy` 命令，即可把项目信息发送给 balenaCloud 然后构建出所有描述中支持的硬件的系统镜像。当然，必要的 `balena login` 步骤还是需要的。

只需要开发完成，并上传到 balenaHub 以后，想要重温重温以前的美好随时都可以在 balenaHub 中下载回来这个镜像，只需要做烧录的步骤就可以了。

### 管理

管理的需求因人而异，但是对我而言曾经遇到的问题似乎都覆盖到了。balenaCloud 提供了 Web 界面友好地让用户查看自己的设备信息，并实现交互。

![image-20211216203624607](https://image.wsine.top/fbd296221b5168fd787ff1797f4832c7.png)



**设备状态查看。**有的时候自己编写的软件稳定性不够高，总会发生一些奇奇怪怪的事情，比方说：连不上自己的服务了。这时我们可以 balenaHub 里 Logs 的位置查看服务在命令行的输出，它还支持 Filter 功能方便我们进行筛选分析。通过输出，我们可以查看软件遇到了什么问题，甚至在 Terminal 界面进行交互，相当于提供了远程 SSH 内网穿透。一个机器多个服务的情况下，也可以友好地切换。

**远程重启 / 关机。**如果实在是不知道出了什么问题，万能的重启大法总没错，面板上的 Restart 按钮可以重启特定的服务，Reboot 可以重启整个机器。

**更新软件。**如果你 debug 能力比较强，在修复 bug 以后，通过 `balena deploy` 重新推送新的版本，DSC 会根据系统镜像下载页面中的高级配置项「自动检查更新间隔」来定期自动更新软件。当然，急于用上修复后的版本，也可以通过 Web 界面手动触发更新。

**公网访问。**在我们的日常网络中，由于 IPv4 地址的耗尽，一般情况下已经基本没有家用带宽能获得公网地址了。balena 提供了内网穿透服务，如图中的 PUBLIC DEVICE URL，启用该功能即可通过旁边箭头按钮跳转访问服务，不过当你服务比较多的时候要自己手动加端口号。



以上，就是我在探索 balena 生态时发现的好功能，着实是惊艳了我一番，后续如果有更好玩实用的用法我会再继续分享。感谢阅读。