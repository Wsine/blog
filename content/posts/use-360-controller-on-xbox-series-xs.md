---
title: "让次世代 Xbox 支持旧手柄"
date: 2022-03-24
published: true
tags: ["Solution"]
series: false
canonical_url: false
description: "试问哪个男孩子不想拥有一台游戏机呢？借着女朋友生日的机会，我购置了一台 Xbox Series S 作为生日礼物 🐶。目前使用了一个多月，本篇文章就来说说我遇到的问题以及解决方案。"
---

# 让次世代 Xbox 支持旧手柄

试问哪个男孩子不想拥有一台游戏机呢？借着女朋友生日的机会，我购置了一台 Xbox Series S 作为生日礼物 🐶。目前使用了一个多月，本篇文章就来说说我遇到的问题以及解决方案。

### 问题缘起：旧手柄与新机器不兼容

我购买游戏机的初心之一，是想跟女朋友一起打打游戏。我们都种草了《双人成行》，因此借着春节假期之前，就毫不犹豫地购入了一台 Xbox Series S 。

游戏机配件中随机附带了一个 Xbox 的新手柄，想着配合我手上原有的 4 个手柄之一就能愉快地一起本地双人游戏了。结果却大大地超出了我的预料，没有一个额外的手柄支持在该新游戏机上使用，哪怕有线连接也不行。我所拥有的游戏手柄如下：

- XBOX 360 Wireless Controller
- Switch Pro Controller
- Switch JoyCon Controller
- 良值手柄（支持 Switch 和 PC）

后来查询了一下 [网上的资料](https://www.windowscentral.com/does-xbox-series-x-series-s-controller-work-xbox-one) 发现，Xbox Series S 仅支持次世代手柄和 Xbox One 的手柄。换言之，从 Xbox 360 跨世纪升级的玩家连配件都无法沿用，从头到尾都要重新买。

因此，我也走上了一条探索解决方案的道路，毕竟种草的双人游戏就这一个，额外花 400 大洋买多一个新手柄性价比太低了。

### 解决方案：巧用「远程同乐」

首先，**手柄直连** **Xbox** **主机是肯定不行了**，考虑到 Xbox 平台对 PC 的兼容性，以及 PC 对 Xbox 360 手柄的兼容性，引入一台 Windows 电脑作为媒介是首选。

Xbox 主机支持在 Windows 端启用「远程同乐」功能，也就是基于局域网的远程游戏。查询了一下 [资料 1](https://www.lifewire.com/how-to-stream-xbox-series-x-or-s-to-your-pc-5093348) 和 [资料 2](https://www.youtube.com/watch?v=_7_ag3KtxMQ)，都需要特别的技巧才能正确启用该功能。

- 方法一：安装 Xbox Game Streaming Test 应用
  - 通过一个第三方网站下载别的 Windows 商店地区的 app 离线安装包
  - 启用 Windows 电脑的开发者模式
  - 通过离线安装包安装该应用
  - 通过 Streaming Test app 远程 Xbox 主机进行游戏
- 方法二：在 Xbox 应用中启用 Insider 功能
  - 从 Windows 应用商店下载 Xbox Insider Hub
  - 在 Hub 的 Preview 菜单中加入 Windows Gaming Preview 计划
  - 在 Windows 应用商店更新 Xbox app
  - 通过 Xbox app（不是 Xbox 小助手）远程 Xbox 主机进行游戏

上述的方法最终并不能真的解决问题，因此我没有写下详细的步骤。方法一的问题除了启用了开发者模式增加了安全风险，还引入一系列的运行时依赖问题，因此我没有继续下去；方法二的问题在于完成了一系列的操作之后，启动「远程同乐」功能后没有出现小飞机的连线界面就卡住了，同样的问题也能在网上找到 [报告](https://www.reddit.com/r/xboxinsiders/comments/rg95wl/xsx_to_pc_remote_play_black_screen_issue/)。

直接在 Windows 端使用「远程同乐」功能不行，因此我把视线转移到 Android 端。为了保留 Xbox 360 手柄的兼容性，我依旧使用 PC 平台，下载了 [Bluestacks 5](https://www.bluestacks.com/tw/index.html) 这款 Android 模拟器，并安装上 Xbox 应用。通过「远程同乐」可以将模拟器与 Xbox 成功连线，但这也引入了两个新的问题：

1. Bluestacks 支持的手柄中不包括 XBox 360 Controller
2. 局域网远程游戏在 5G Wi-Fi 下有累计延迟

虽然不支持 Xbox 360 Controller，但是 Bluestacks 有一个重要的功能——控制映射。点开模拟器里的 Xbox app 后，点击右侧的「键盘 ⌨️」图标，选择 Controls for「手柄 🎮」图标后，点击 Controls editor，然后根据 UI 拖动不同的模块绑定到虚拟按键上就可以了（这里反而能识别到 XBox 360 手柄）。

![image-20220531205908336](https://image.wsine.top/717bcedbc5faa2285ed1d60a73e09f9e.png)

![image-20220531205931610](https://image.wsine.top/2dfc5ed74127b8d7f81469269a0b186f.png)

在探索的过程中，我发现了一个 Xbox 的重要属性——Xbox 支持在主机有线视频输出到电视的同时也串流给远程游戏端。换句话说，哪怕 PC 端远程游戏画面延迟卡顿，它只需要负责将手柄信号输入到 Xbox 主机即可，游戏画面还是通过电视端观看游玩。

![image-20220531205949810](https://image.wsine.top/1103169dfc7e7cfc2cb2070b51ea50c6.png)

至此，整个本地双人游戏流程就打通了，体验上也还不错。这套方案理论上也适用其它 Xbox Series X|S 不兼容但可以被 PC 识别的手柄，希望能给有需要的人一点帮助。
