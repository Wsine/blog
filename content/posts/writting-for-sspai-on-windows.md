---
title: "Windows平台下的少数派新写稿流程"
date: 2020-06-02
published: true
tags: ['Windows', 'Solution', 'SSPAI']
series: false
cover_image: https://image.wsine.top/bcf36126e162a7d610effe869dc8b8c1.jpg
canonical_url: false
description: "谈及写作，不少的用户都是使用 Mac 平台配合多样的 App 完成从写稿到发布的一条龙服务"
---

谈及写作，不少的用户都是使用 Mac 平台配合多样的 App 完成从写稿到发布的一条龙服务。但是在 Windows 平台上，往往需要很多手动的过程。比如，在少数派平台上，官方提供了专用的接口给 MWeb App 完成从写稿、插图、发布的完善服务，但是 MWeb App 仅在 Mac 平台上提供，Windows 用户常常因为插图图床问题困扰。

最近，随着两大写作好伴侣 App 的更新，这一情况得以改善。PicGo 迎来了 v2.0 版本的大更新，剥离了核心功能同时支持 CLI 调用和 API 调用。Typora 集成了 PicGo 并提供一键上传图片服务。如果需要更详细的资料，请看这两篇文章：

[图床「神器」PicGo v2.0更新，插件系统终于来了](https://sspai.com/post/52527)

[Typora 支持自定义图片上传服务了](https://sspai.com/post/59128)

配合上述两大神器，是否有方法能够改善少数派平台上的写作流程，下面我就来谈谈我的方案。

## Typora 之功能增强

首先，从 Typora 官网上能够下载 Win / Linux / OSX 对应平台的安装文件并正确安装。

然后，我们需要启用图片上传功能。点击 File -> Preferences -> Image，在 Image Upload Setting 那栏，选择 PicGo-Core (command line) ，然后点击 Download and Upgrade，即可完成安装。

![enhance](https://image.wsine.top/628cb7601505f1aaf9d736a4f59f68a6.png)

## PicGo 之少数派插件

得益于 PicGo 的插件系统，我们可以为少数派平台编写插件，快捷完成图片上传到少数派的服务器。那么，如何安装少数派插件？

步骤一

首先我们打开 PicGo 配置文件所在的目录，你可以点击上图的 Open Config File 按钮，或者手动打开对应平台的文件夹。

Windows 平台位于`C:\Users\<your username>\.picgo\`

Linux 和 OSX 平台位于`~/.picgo/``

然后，克隆或下载[github.com/Wsine/picgo-plugin-sspai](https://github.com/Wsine/picgo-plugin-sspai)仓库到该文件夹中，注意如果从网页端下载，解压后去除多余的分支名，这很重要。

步骤二

在 PicGo 配置文件夹下创建`node_modules`文件夹，并在里面创建同名快捷方式/软链接，指向刚才下载的仓库文件夹。

步骤三

编辑`package.json``文件，修改里面的依赖项。

```json
{
  "dependencies": {
    "picgo-plugin-sspai": "file:picgo-plugin-sspai"
  }
}
```

步骤四

创建`package-lock.json``，内容填充如下：

```json
{
  "name": "picgo-plugins",
  "requires": true,
  "lockfileVersion": 1,
  "dependencies": {
    "picgo-plugin-sspai": {
      "version": "file:picgo-plugin-sspai"
    }
  }
}
```

验证

最终配置文件夹中的目录结构如应如下图所示

```
~/.picgo > tree
.
├── config.json
├── node_modules
│   └── picgo-plugin-sspai <soft link>
├── package.json
├── package-lock.json
├── picgo.log
└── picgo-plugin-sspai
    ├── index.js
    ├── License
    ├── md5.min.js
    ├── package.json
    └── README.md
```

## 配置个人信息

打开少数派官网，登陆自己的账号，然后按F12打开开发者模式，找到 Console 选项卡，输入

`document.cookie.split('; sspai_cross_token=').pop().split(';').shift()``

该命令会返回一串字符串，记住该字符串，并重新在 Typora 中打开 PicGo 的配置文件，替换下面样例的 token 占位符，保存

```json
{
  "picBed": {
    "current": "sspai",
    "uploader": "sspai",
    "transformer": "base64",
    "sspai": {
      "cross_token": "<replace here>"
    }
  },
  "picgoPlugins": {
    "picgo-plugin-sspai": true
  }
}
```

好了，至此为止，你已完成了全部的配置，那么来看看效果如何吧。

## 样例效果

我们就以本文作为目标图片展示一下该写作流程的优化吧，通过菜单栏的 Format -> Image -> Upload All Local Images 能够一键上传该文章下面的全部图片，也可以通过右击图片的方式单张图片上传

![example](https://image.wsine.top/4472f6471191c61072d1e54de3f941d9.gif)

最后，打开少数派网站的编辑器，复制全文富文本格式进去，即可完成发布流程。

## 后记

该插件的开发仅仅是为了方便用户在少数派平台上写作而创作。图床，一直是流量消耗的大户，目前少数派的图床仅能在 sspai.com 域名下显示，也即启用的防盗链技术，如有别的用途的用户就不用折腾啦。

等后续的 Typora 更新了发布功能，我会再来优化该流程。那么，希望这个插件能帮得到大家。
