---
title: "Microsoft Terminal 颜值在线的终端模拟器"
date: 2019-12-09
published: true
tags: ['Terminal', 'Windows']
series: false
cover_image: https://image.wsine.top/b1398c74eae46ef8491492a1b6deccbe.jpg
canonical_url: false
description: "最后一块拼图，Microsoft Terminal能够很好地用于日常工作中了"
---

在 Microsoft Build 2019 的大会上，微软给我们带来了一款全新设计的终端模拟器 Microsoft Terminal. 虽然过度好看的宣传片和实际的效果有着巨大的落差，但是也不影响它在 Windows 阵营里取得最高的颜值称号。

![terminal](https://image.wsine.top/1746B559BC9685F1E4D9BFFF9F5F9EAC.png)

从 Preview v0.2 版本开始我就试用了这款工具，到今天的 Preview v0.6 版本最后关键的问题修复后我才想说来跟大家分享一下这个工具。

## 安装 Terminal

Microsoft Terminal （下称 Terminal） 明确要求了系统版本至少需要 “Windows 10 version 18362” 或以上才能使用。

而现在的安装方法也很简单，从 Microsoft Store 里面搜索 “Microsoft Terminal” 就可以直接安装和卸载了。

但是到目前为止，Terminal 还是处于一个 Preview 的阶段，功能上来说不会囊括所有的用户的期望，如果想要有自己期望的功能，可以在官方的开源仓库的 [Github issue](https://github.com/microsoft/terminal/issues) 上发 Feature Request 哟~

## 全新配置管理方式

Terminal 采用了 JSON 文件作为它的配置文件，这就意味着你可以将整个配置文件备份，然后在别的地方下载下来快速使用，十分的方便。

实际使我眼前一亮的点是，当我用 Sublime 修改该配置文件保存的时候，已经打开了的 Terminal 的样式能实时发生改变，这大大提高了用户调整配置的便捷程度，而很多工具要做到这点都是将设置界面做成软件的一部分才能实现的，这点给 Terminal 大大的加分。

由于是 JSON 纯文本配置文件，总是有可能出现手抖或者配置出错的问题，这时候保存配置文件会被提示文件哪里的配置有问题，而该次的保存不会生效，实际调试样式还是十分方便的。

![vim](https://image.wsine.top/52104FB432B5BCF495FA7E7C056DBA6C.gif)

## Less is More 的配置项

Terminal 提供的配置项不多，但我觉得 98% 的人也只需要修改到这些配置项就足够了，下面来跟大家陈列一下它提供的配置项吧（我只挑重点的来展示）：

- defaultProfile：默认启动的方案，可以为 CMD，PowerShell，Azure 等
- keybindings：快捷键映射
- acrylic：透明度
- background：背景颜色或者背景图片 ~~动漫女神~~
- colorScheme：配色方案，可以自定义配色
- commandline：默认启动的程序，一般为 cmd.exe 等
- cursorColor：光标颜色
- cursorShape：光标形状
- fontFace：字体方案
- fontSize：字体大小
- icon：该方案的代表图标
- name：该方案的名称
- padding：外边距
- historySize：保留的历史输出大小

一般情况下，当你调整好了显示的字体和大小，调整背景和透明度，还有配色方案，基本上就把一个终端模拟器的外观给定义好了。

由于是 JSON 配置文件，文件里面也不能像以前的方式一样给出选项，微软将一份配置文件说明放在了仓库中 => [Settings Schema](https://github.com/microsoft/terminal/blob/master/doc/cascadia/SettingsSchema.md) . 但是却没有在配置文件里面提供链接，我觉得这点还是需要改进的。

## 功能的最后一块拼图

谈及终端模拟器，一般情况下我会从一些特定的功能去考察它是否功能完备，以及它的加分点有哪些

### GPU加速

这个就属于新时代的终端模拟器的代表功能了，之前在 Manjaro 下面使用 Alacritty 终端模拟器时才体会到在GPU加速的这一功能。在大量的文本打印的时候，得益于GPU的加速，丝毫没有那种播放PPT的卡顿感，这个对于长时间在终端下工作的我来说还是十分舒服的。

![vim](https://image.wsine.top/CC87571D29A2461C0502CF5A3C9268A9.gif)

### 多标签

诚然，很多的终端模拟器都自带了多标签，比如 xshell，mobaxterm 和 cmder 等。前两者在工作用途上是收费的，后者总是占用了太多的 Linux 快捷键。之前我不得不使用 CMD 代替它们（发现意外的好用），现在 Terminal 来将 CMD 缺失的多标签功能给补齐了。

### Emoji支持

虽然微软平台的Emoji真的很丑，但是有总比没有好不是嘛，我还是很喜欢在Git commit里面加点emoji让它好看一点的。

![vim](https://image.wsine.top/E56D8ABFB6EA3F8AF3782EC3B0DBFF0B.png)

### NCURSES的支持

对于重度使用终端的人来说，基本上离不开两个重要的工具，文本编辑器（Vim / Emacs）和终端复用器（Tmux / Screen）。而它们的底层，其实都是由 ncurses 来提供支持的。这个库可以让你的终端除了不断打印出新的东西，还能后退擦除一些东西，从而造成屏幕不断刷新的效果。

通过我两周以来的实际体验，在我的日常使用中完全没有问题，因此才会想推荐给大家。

![vim](https://image.wsine.top/63A4C2739333EFDD11711E7F9D791BA8.png)

![tmux](https://image.wsine.top/C85D32FC99D632208A9B029AAD6E2FB3.png)

### 复制与粘贴

这个就是我指的最后的一块拼图。在 v0.6 版本之前，Terminal 的复制粘贴功能一直有很大的问题。在 Github issue 中搜索 “copy / paste” 等关键字就可以知道。开发团队为了兼容微软长期以来的 Ctrl + C 的复制快捷键做了大量的工作。

v0.6 版本以前，复制多段文字的时候，在别的地方粘贴总是会出现超长的一行，比如`a\nb`可能会被粘贴成`a \space*555 b`的情况，十分影响正常的工作，可惜我已经展示不了了。之前总是需要借助 tmux + http 才能绕过这个问题。现在这个恼人的问题终于被修复了，也就是说可以被大家广泛使用了。

### 基础的功能

Terminal 本身还支持 xterm-256 color ，UTF-8 和 unicode 编码，这些我认为都是必要的功能，这里就不细说了。

## 我的使用分享

我最近使用的是微软为开发者打造的一款字体 Cascadia，开源仓库在这里 => [Cascadia Code](https://github.com/microsoft/cascadia-code/releases) . 我很喜欢它，得益于对 unicode 编码的支持，在GPU加速的情况下，它总能给我很多很好看的小惊喜，比如`=>`会被渲染成一个完整的箭头，并且跟随进度条移动。更多的就等你们使用发掘啦。

我用的是里面默认的 "One Half Dark" 配色，我觉得很好看，搭配 70% 的透明度和 5 pixel 的外边距，整体效果很不错。

![configuration](https://image.wsine.top/8480A1CD36C62A350D33E5F09904EDAC.png)

最后放上我的配置图，剩下的就大家去尝试一下吧~
