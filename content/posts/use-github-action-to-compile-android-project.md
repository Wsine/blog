---
title: "使用 Github Action 编译 Android 项目"
date: 2021-12-15
---

[TOC]

和 Android 系统一样，很多 Android 应用也会选择将源码进行开放，一方面供开源社区对代码进行审查保证安全性，另一方面也能「集思广益」，经其它开发者之手发展、演变出更多有意思的代码分支和功能。

更重要的是，因为源码人人可获取，当这些应用的商店版本（如 Play 商店）因为各种原因更新缓慢，或原始分支不再维护时，我们也可以直接绕过商店、借助源码编译「原汁原味」的最新版本。

本文就为大家介绍一种相对简单、能够自给自足的 Android 应用编译方法。



## 编译 Android 项目所需工具

要想编译 Android 项目，首先我们就先来看看项目源码的一般目录结构，了解我们需要一些什么样的编译工具。

![image-20211216205520582](https://image.wsine.top/e290608b0930f14d4801fd8aaa7341fb.png)

**编程语言：** 2021 年 Android 项目主要支持的编程语言是 Java 和 Kotlin。两者语言都是运行在 JVM 环境中，都需要各自的编译器 javac 和 kotlinc 把源码编译为 JVM 的字节码。

**包管理器：** Android 项目常见的包管理器是 Gradle，它负责管理和下载项目的第三方依赖，并且构建出可安装运行的 Android 安装包 (apk)。

**开发套件：** 开发套件在图中是一个隐藏的依赖 —— Android SDK 。在大部分的平台架构上开发 GUI 程序，基本绕不开平台的 SDK。

至此，我们了解清楚了我们所需要的工具，那么下一个问题就是从哪里获取这些工具。

## 传统方法的弊端

传统的办法编译 Android 项目是下载 Android Studio 集成开发环境，作为一个 IDE 它包含了上述所需要的全部的工具，但是它也有以下的弊端：

- 从 Android Studio 下载指定的 Android SDK 版本也还需要一定的步骤
- Android Studio 自带的 Java 版本较新，不一定能编译通过旧代码
- Gradle 下载依赖的时候由于服务器在外网，需要一些特殊的技巧

这些都是我认为对于小白用户来说比较困难的地方，因此我并不推荐使用大家只是为了构建 APK 就下载 Android Studio 折腾一番。

## 巧用 Github Action 构建

我个人比较推荐 Github Action ，它有两个重要且十分合适我们场景的特点，这里也提供一个实例展示如何使用。

### 为什么选择 Github Action

**开箱即用的环境。** 从 Github 官方的[虚拟环境仓库](https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu2004-README.md)可以看到，Ubuntu 20.04 的环境中自带了 Java 11，Kotlin 1.6.0，Gradle 7.3，和 Android SDK 的常用版本。相比上面的传统方法，Ubuntu 这套环境其实已经解决了很多编译环境问题了，且合适大部分的 Android 项目的构建，如果遇到不满足的地方，下面也有方法告诉你怎么轻易地解决。

**足够的免费配额。** Github Action 对于免费的账户也是有[一定的限制](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)的，具体表现在：每个仓库的构建产物限制是 500MB，每个月的运行时长是 2000 分钟。对于我们只是构建一个普通的 Android 项目安装包来说，也够用了，运行时长也是绰绰有余。

### 如何使用 Github Action

下面就通过实战来看看如何方便快捷地用 Github Action 来构建一个开源 Android 项目的 APK 安装包吧。我这里选择的是 [FolioReader](https://github.com/FolioReader/FolioReader-Android)，一个 Java 编写的 ePub 阅读器，在 Github 上开源并获得 2k ⭐。

这里是我编写的 Github Action 运行的配置文件并开源在 [Wsine/android_builder](https://github.com/Wsine/android_builder/blob/main/.github/workflows/build.yaml)，我会详细地说明一下每个步骤都做了什么。

```YAML
name: android_build

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the code
        uses: actions/checkout@v2
      - name: Set up JDK
        uses: actions/setup-java@v1
        with:
          java-version: 1.8
      - id: get-project
        name: Get project name
        run: echo "::set-output name=PROJECT::$(cat project-to-build)"
      - name: Clone project
        run: git clone --depth=1 ${{ steps.get-project.outputs.PROJECT }} project
      - name: Build the app
        working-directory: ./project
        run: |
          if [ ! -f "gradlew" ]; then gradle wrapper; fi
          chmod +x gradlew
          ./gradlew assembleDebug --stacktrace
      - name: Upload APK
        uses: actions/upload-artifact@v2
        with:
          name: my-build-apk
          path: ./**/*.apk
```

这个 Workflow 的触发条件设置为手动触发，因为还需要一些修改才能满足目标 Android 项目的构建条件，因此没有设置为常规的基于文件改动就触发。虚拟环境这里我使用的是 `ubuntu-latest`，在此时就是指向 Ubuntu 20.04 这个 LTS 版本，日常开发中可能不建议使用这种不确定的版本，但在我们的场景中还是毕竟合适的，因为一个还在维护的 Android 项目一般都会适配较新的 LTS 版本的。

Workflow 中的第一步是拉取 android_builder 的源代码，主要目的是获取 project-to-build 这份文件，里面包含了我们的目标 Android 项目的 Github 地址。在我们这个实战中就是 https://github.com/FolioReader/FolioReader-Android 这个地址，如需编译其它的项目，把该地址替换为其相应的 Github 地址即可。

第二步是设置运行环境，这里是重点。一般情况下，Android 项目中的 Java 代码语法需要一定的 Java 编译器版本，因此我这里引入了 [actions/setup-java](https://github.com/actions/setup-java) 这个 action 来快捷地设置 Java 的版本，如这里我使用了 1.8 版本（Java 8）覆盖环境中自带的 Java 11 版本。同样地，设置 Gradle 和 Android SDK 也有快捷的 action 可以复用，分别为 [gradle/gradle-build-action](https://github.com/gradle/gradle-build-action) 和 [android-actions/setup-android](https://github.com/android-actions/setup-android)。Github 官方的 Ubuntu 20.04 的环境中自带的版本已经是比较高的版本了，一般情况下程序都有后向兼容，所以大部分的情况下你其实可以完全不用设置。这里仅是一个例子来展示如何轻松地修改版本。

第三步的目标是从 project-to-build 这份文件中读取 Android 项目的开源地址并传递给下一步进行拉取Android 项目源码。注意，目标 Android 项目要开源并且是处于公开的状态。`cat project-to-build `可以读取这份文件包含的地址，然后通过 Github Action 中特殊的语法 `::set-output name=PROJECT::XXX`设置地址为该步骤的输出。

第四步是拉取目标 Android 项目源码到虚拟环境中准备编译。首先通过 `${{ steps.get-project.outputs.PROJECT }}` 获取上一步的输出地址，然后用 Git 命令克隆 Android 项目源码到虚拟环境的本地中。至此，编译前的准备工作已完成。

第五步是构建 APK 的关键步骤，这里假设目标 Android 项目是已经能够编译通过的了。gradlew 是 Gradle 包管理工具自己产生的一个 bash 脚本，用于命令行环境下的自动构建，绝大部分的开源项目已经包含了该文件，因此我加了个判断，如果不存在该文件则用 Gradle 生成出来，并赋予执行权限。得益于优秀的包管理器，Android 项目下只需要一句命令即可构建出 APK 安装包——`./gradlew assembleDebug --stacktrace`，该命令用于构建调试版 APK，调试版本已满足个人的使用，折腾应用签名就没有必要了。后面的 `stacktrace` 参数只是为了显示更多的运行信息。执行完这步， APK 就已经生成好了。

最后一步，把生成的 APK 文件打包上传到 Github Action 的网页端，方便下载。你也可以上[这里](https://github.com/Wsine/android_builder/actions/runs/1561922173)看看我构建的 APK 输出，最后会得到一个 zip 压缩包，包含了最终生成的 APK 文件。

![image-20211216205539491](https://image.wsine.top/f4dcff2a76b6651ef4674ba2fd4a0a9a.png)

整个构建过程只需要 2m 47s，就得到了我们的 APK 文件，其中包含了下载全部依赖库和从零开始编译两个过程，相比自己下载到本地编译从运行速度和网速两个角度来说，整个过程就显得非常快了。然后就可以把 APK 文件传输到自己的手机，在设置中打开「允许安装未知来源应用」的选项，就能够顺利安装到手机中。

### 如何复刻该 Workflow

首先 fork 一下 [Wsine/android_builder](https://github.com/Wsine/android_builder) 这个仓库，根据上面第三步的操作，修改 project-to-build 这个文件改为你需要编译的 Android 项目的 Github 地址，然后如下图所示点击，即可运行该 Workflow。运行完毕后点开 Workflow 在 Summary 的选项卡中找到 Artifacts，即可下载带 APK 的压缩包。

![image-20211216205547944](https://image.wsine.top/0fab346b98a0a2cf789043791c138135.png)

![image-20211216205555364](https://image.wsine.top/9b5cd9a75a22a8a35a94466a98e9b9a8.png)



感谢 Github Action，让我们的生活更加的简单快捷。现在就开始上手试试吧。
