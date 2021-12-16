---
title: "修复 Zotero 和 Papership 的联动"
date: 2021-11-08
published: true
tags: ['Solution']
series: false
canonical_url: false
description: "随着 Zotero 的不断更新以及 Papership 的年久失修，它们之间的友谊出现了小小的问题，困扰着很多现有用户。我遍寻网络资源，虽然找到了一些解决方案，但我觉得不够优雅，因此提出一套自己的解决方案，以供有类似需求的读者们参考。"
---

[TOC]

[Zotero](https://www.zotero.org) 作为一款开源文献管理工具，受到了很多科研工作者的喜爱，尤其是它能够安装插件以增强软件本身的功能。另一方面，[Papership](https://www.papershipapp.com) 作为 iOS 及 iPadOS 上目前唯一与之适配的客户端，支持双向同步，综合体验十分出色。

然而，随着 Zotero 的不断更新以及 Papership 的年久失修，它们之间的友谊出现了小小的问题，困扰着很多现有用户。我遍寻网络资源，虽然找到了一些解决方案，但我觉得不够优雅，因此提出一套自己的解决方案，以供有类似需求的读者们参考。

### Zotero 和 Papership 之间的问题在哪

在探讨解决方案之前，我们先来聊聊前文提到的问题具体在哪。

> https://forums.zotero.org/discussion/64967/cant-access-webdav-files-from-papership-or-zotero-org

Zotero 本身作为开源工具并不收费，但是免费的文件存储空间只提供 300M 的空间，对于大量阅读 PDF 文献的小伙伴来说，很快就会把这部分的配额给消耗殆尽。如果要进一步购买空间 2G 档位，则需要支付每年 20 美元的费用，对学生党来说有点高。但是好在 Zotero 允许外挂 WebDAV 来存放文件，十分良心，所以不少用户都选择以这种方式同步文献。

而 Papership 则是一个支持 Zotero 的第三方客户端，它可以直接登录 Zotero 账号以获取文献库中所有文献的 metadata 的信息，然后通过 WebDAV 链接直接访问文件，最终实现与 Zotero 的完美联动。

Papership 唯一额外要求的一点是需要将一个特殊的文本文件 lastsync.txt 放置在 WebDAV 的同步目录内，Papership 在同步文件时会优先检查这个文件，如果发现本地的文件变动时间没有比 lastsync.txt 存储的最后变动文件更新，则采取「懒同步」的方式——也就是不同步。

问题就出在 Papership 的同步机制上。随着 Zotero 的更新，不知道出于何种原因，Zotero 在同步 WebDAV 文件的时候会主动删除 lastsync.txt。这个机制让 Papership 失去了「懒同步」的参照系，导致在 Papership 中阅读和标注的内容无法更新到云端，Zotero 的文件变动也无法同步至 Papership。

更麻烦的是，Papership 已被确认被 Elsevier 公司收购了，而 Elsevier 旗下有自己的文献管理工具 Mendeley。收购完成后，Papership 的开发重点也转向了母公司的产品，甚至可能不会再修复和 Zotero 相关的 bug。与此同时，Zotero 也在开发自己的 iOS 客户端，beta 版发布至今仍未支持 WebDAV 同步。在各方原因和背景之下，夹在中间的用户们只好自行寻求解决方案。

### 当前网上流行的解决方案

目前，网络社群中解决该问题的主要方案是放弃 Papership，使用 Zotero 的插件来解决文件同步的问题。

Zotero 中有一个很多人都会安装的插件「zotfile」，它有一个功能可以把待阅读批注的文献发送到平板电脑上，然后等到在平板端阅读和标注后，再取回到整体的文献库中。它背后的工作原理是这样子的：

- 将待阅读标注文献复制到另一个文件夹
- 该文件夹依靠第三方云存储进行同步（如 OneDrive、坚果云等）
- 在 Android 设备或 iPad 上用自己喜欢的批注工具阅读（如 PDF Expert 等）
- 将该文献从同步文件夹中移动并替换文献库的文件

![image-20211216210137802](https://image.wsine.top/b57bf92e3d21defae1565bf50e2bb715.png)

其中，发送和取回两个动作都需要手动操作，因此，从整体的联动性来说，我觉得是不够方便的。而且由于没有自动双向同步，将文献从 A 集合移动到 B 集合，它对应的存储位置不会改变，这对于我习惯使用 Inbox 来消化文章的用户来说，极大地不方便。

### 如果没有就创造

既然现有的解决方案不满意，那就创造自己的解决方案。

通过上文的讨论，我们知道整个问题的关键在于 lastsync.txt 文件身上，如何存储和恢复该文件就成了该解决方案的关键。同样地，我通过查询英文资料得知，哪怕只创建空白的 lastsync.txt ，也能激活 Papership，让它启动正确的同步机制。

手动创建 lastsync.txt 是一件很麻烦的事情，但是如今比较流行的 serverless 的技术却能够很好地帮助我们自动化完成这一目标。不少的 serverless 服务都是以 web 作为入口，且使用这些服务或需要绑定信用卡或需要备案，比较麻烦，因此我最终选择了 Github Actions 作为本次的自动化工具。

- 注：serverless 是一种功能即服务（Function-as-a-Service），它也需要服务器运行，但分离了网页和数据库，仅保留运算部分对外提供服务。
- 注：如果你还不会使用 Github Actions，可以参考阮一峰大神的教程，简单易懂。https://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html

由于目标比较简单，因此两行简单的 bash 命令就可以完成核心的目标。

```Bash
touch lastsync.txt
curl -u ${WEBDAV_EMAIL}:${WEBDAV_DAVPASS} -T lastsync.txt https://your/webdav/url/zotero/lastsync.txt
```

这两行的意思分别是：创建空白的 lastsync.txt 文件，上传到 WebDAV 的指定路径上。其中，`${WEBDAV_EMAIL}` 是你的 WebDAV 的登录账号或邮箱，`${WEBDAV_DAVPASS}` 是你 WebDAV 的应用密码。

然后只需要在 GitHub 的任意一个仓库中（可新建），在 `.github/workflows/webdav_lastsync.yml`[ ](https://github.com/Wsine/actions/tree/main/.github/workflows)路径下放入这两行代码即可，具体的文件模板我都给大家创建好了。

```YAML
name: webdav_lastsync

on:
  schedule:
    - cron: '0 4,16 * * *'
  workflow_dispatch:

jobs:
  fix:
    runs-on: ubuntu-18.04
    steps:
      - name: Fix
        run: |
          export SYNCFILE="lastsync.txt"
          export REMOTEFILE="https://app.koofr.net/dav/Koofr/zotero/${SYNCFILE}"
          touch ${SYNCFILE}
          curl -u ${KOOFR_EMAIL}:${KOOFR_DAVPASS} -T ${SYNCFILE} ${REMOTEFILE}
        env:
          KOOFR_EMAIL: ${{ secrets.KOOFR_EMAIL }}
          KOOFR_DAVPASS: ${{ secrets.KOOFR_DAVPASS }}
```

该文件也是我放在 Github 中的实际文件，以一个具体的例子供大家参考，记得修改为自己的字段。

该 workflow 会在北京时间的每天 12 点和 0 点自动运行一遍，我觉得已经能满足我日常的同步需求了，我并不需要完全的实时同步。如果你希望增加同步的频率，在第 5 行中的 `4,16` 处增加你想同步的整点时间即可。值得注意的是，这里的时间是以格林威治时间为标准的，换算为北京时间（UTC+8）时，需要将你的目标时间倒推 8 小时。

创建完该 workflow 后，别忘了在 GitHub 的 settings -> secrets 中添加你的登录邮箱和应用密码字段。接下来，GitHub Actions 就会依照你设定好的时间，自动生成 lastsync.txt 并同步至你的 WebDAV 目录，Papership 只要识别到该文件，也会保持同步状态啦。

该解决方案已正确运行一周，解决了我的巨大的痛点，仅以此文献给有需要的小伙伴。
