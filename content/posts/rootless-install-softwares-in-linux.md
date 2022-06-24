---
title: "如何在 Linux 下装软件不求人"
date: 2022-06-16
published: true
tags: ['Solution', 'Linux']
series: false
canonical_url: false
description: "俗话说，求人不如求己。在 2022 年这一时间节点，有很多新的解决方案能够解决上述这类的问题，本文就是来探讨一些有哪些好的解决方案。"
---

# 如何在 Linux 下装软件不求人

大部分人日常使用电脑一般都是 Windows 系统和 macOS 系统，不少人可能因为尝鲜或者工作学习需求需要使用 Linux。在我们日常使用 Linux 中，我们自己就是管理员，所以我们可以自由地安装任何软件，当然出了问题就需要自己解决；但是在大学实验室、企业公司中，Linux 常常会以服务器的形式进行部署，一台服务器也会由多个用户互相共享，因此需要有专人负责维护管理 Linux 服务器，这种情况下我们想要安装软件就需要由「管理员」审核和操作。

服务器的管理之所以安排管理员，是为了避免由于用户不了解或操作不小心误删了系统文件，以及安装奇怪的软件导致现有的软件运行不了了。在该审核流程下，普通用户没有办法修改系统相关的配置，因此大大提高了运行环境的稳定性。但是，这样的流程可能会造成以下的一些困难：

- 因为一些原因，管理员审核不肯通过。

- 管理员经验不够丰富，无法胜任高级一点的安装操作。

- 审核流程过长，影响工作进度。

- 由于版本冲突，无法满足特别的个人需求。

俗话说，求人不如求己。在 2022 年这一时间节点，有很多新的解决方案能够解决上述这类的问题，本文就是来探讨一些有哪些好的解决方案。



## 为什么安装软件需要管理员

Linux 下安装软件主流的方式都是通过系统自带的包管理器，如 apt、yum、pacman、dnf 等，安装系统官方仓库的软件，而这些命令都需要写入 `/usr` 系统路径，因此往往都需要管理员权限才能操作。

![image-20220624202020828](https://image.wsine.top/a3d086db0c5d8a666e874778cbb8f798.png)

哪怕是一些新兴的包管理器，如 homebrew 和 nix， 也需要管理员权限才能创建特殊的路径用于安装软件，如 `/home/homebrew` 和 `/nix`  。前者虽然经过设置也能安装在用户 home 目录，但是因为背后需要使用 git 同步完整的仓库克隆以及缺少很多的预编译二进制可执行文件，因此最终也没能在  Linux 中流行起来。



## 可行的解决办法是什么

上述的问题是因为需要写入系统路径，而写入用户目录（`/home/user`）是不需要管理员权限的，因此只需要将软件所在的路径加入到 PATH 环境变量中，就可以实现在任意目录下运行目标软件，这其实就是我们平常所说的绿色软件，这也是我们解决方案的基石。

比如，我会在 .bashrc 配置文件中把 `~/.local/bin/` 加入到 PATH 环境变量中，且优先于原本 PATH 中的系统路径：

```Bash
export PATH="$HOME/.local/bin/:$PATH"
```

这样，系统在寻找软件的时候就会优先寻找我们用户目录下的软件执行，找不到了才去原本的系统路径下寻找，我们在自主安装软件的时候就不用受到现有软件的困扰。

另一方面可行的原因是由于新兴编程语言的崛起，如 Python、Nodejs、Golang、Rust 等，很多当下热门的工具软件是通过这些语言编写。前两者为解析型语言，后两者不约而同地在编译期偏向静态链接，这两个特性为我们后续在我们用户目录下安装使用他们提供了极大的方便，关于这一点我们会在下文中详细展开。

至于传统的 C/C++ 编写的软件，如今也有了更高级的沙盒机制和打包迁移方案，最大化地减少我们的主动编译麻烦，而且也有了社区级别的工具解决方案，对于暂时不能应用的 corner case ，社区会持续更新该工具使其有强大的生命力。



## 方案一：AppImage （推荐）

[AppImage](https://appimage.org/) 的 Slogan 是「让 Linux 应用随处运行」。他们有领先的 Linux 应用打包方式，能够让用户只下载一个应用程序（文件），赋予可执行权限，然后双击/命令回车即可运行。和传统安装方式的运行情况没有任何差异，但无需走传统的安装过程，也不需要产生对外依赖。主流的操作系统如 Ubuntu、Debian、Fedora、Arch 等都原生支持 AppImage。

以安装 neovim 为例。打开 neovim 的 github 仓库中的 [Release ](https://github.com/neovim/neovim/releases/tag/v0.7.0)页面，在下面 Assets 资源中找到 nvim.appimage 文件，下载到 `~/.local/bin/` 目录下，给予可执行权限，即可运行。用命令行的话表达来说就是：

```Bash
$ cd ~/.local/bin/  # 切换路径
$ wget https://github.com/neovim/neovim/releases/download/v0.7.0/nvim.appimage -O nvim  # 下载
$ chmod +x nvim  # 赋予可执行权限
$ nvim --version  # 运行（查看版本）
NVIM v0.7.0
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
Compilation: /usr/bin/gcc-11 ......

Features: +acl +iconv +tui
See ":help feature-compile"

   system vimrc file: "$VIM/sysinit.vim"
  fall-back for $VIM: "
/home/runner/work/neovim/neovim/build/nvim.AppDir/usr/share/nvim"

Run :checkhealth for more info
```

可以看到一些信息，nvim 也是通过 gcc 在别的机器编译打包的，但不需要额外的包管理器执行一系列的安装过程就能完美运行，这背后多亏了 AppImage 的沙盒运行机制，有兴趣的读者可以到官网深入了解。AppImage 也支持桌面应用程序。

如果想要找 appimage 打包的软件，[appimagehub.com](https://www.appimagehub.com/) 是一个去处，但更新并不频繁，我更多地是通过 “软件名称+appimage” 作为关键词在 github 中搜索，不少开发者为开源的传统软件重新打包了 appimage 的版本。



## 方案二：预编译软件

### 静态链接程序

上面我们提到，对于编译型语言如 Golang 和 Rust，大量用他们编写的流行工具软件都不约而同地选择了生成静态链接的版本。对于静态链接的软件，它不需要依赖动态库即可单独运行，换言之它的使用跟 appimage 的格式一样方便。

首先如何确定一个软件是静态链接的？在终端下使用 `file <executable>` 命令即可查看可执行文件的链接属性。以 hugo 为例，一个流行的 Golang 编写的静态博客生成程序：

```Bash
$ file hugo
hugo: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=dCIdntYpNd5KK2REUzpq/KjT_yySAiQCm81Kbau6Q/se7uF5SyXa-m-AowDvsp/RNDslKYNwc6AicqzvkEm, stripped
```

其中，`statically linked` 关键字表明该可执行文件为静态链接。

然后后面的步骤就和 appimage 差不多了，直接下载可执行文件（如在压缩包中则先解压）到 PATH 路径上，赋予可执行权限，即可运行。很多常见的软件如 [hugo](https://github.com/gohugoio/hugo), [fzf](https://github.com/junegunn/fzf), [rclone](https://github.com/rclone/rclone), [act](https://github.com/nektos/act) 等都能用这种方式安装。

```Bash
$ wget https://github.com/gohugoio/hugo/releases/download/v0.100.2/hugo_0.100.2_Linux-64bit.tar.gz  # 下载
$ tar -zxvf hugo_0.100.2_Linux-64bit.tar.gz  # 解压
$ chmod +x hugo  # 赋予可执行权限
$ mv hugo ~/.local/bin/  # 移动到 PATH 路径上
$ hugo version  # 运行（查看版本）
hugo v0.100.2-d25cb2943fd94ecf781412aeff9682d5dc62e284 linux/amd64 BuildDate=2022-06-08T10:25:57Z VendorInfo=gohugoio
```

部分用 C/C++ 编写的软件也是可以用这种方式的，如 [upx ](https://github.com/upx/upx)。

### 系统库依赖程序

对于动态链接的程序，如果只是依赖发行版的系统动态库而不依赖其它的第三方动态库，也是可以通过下载的方式安装的。这其中最实用的莫过于编程语言本身的解析器或编译器。

Python 已经内置于各大发行版中，这里我们跳过它不聊。我们以另一个流行的编程语言 Nodejs 举例说明。首先打开 nodejs 官网的[下载页面](https://nodejs.org/en/download/)，点击下载预编译的二进制压缩包，然后解压到一个文件夹（我习惯放在 `~/.local/share/` 中），将里面的 bin 文件夹加入 PATH 环境变量或者在 PATH 路径中创建软链接到可执行文件都可以。以命令行形式表达是这样的：

```Bash
$ wget https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz  # 下载
$ tar -xvf node-v16.15.1-linux-x64.tar.xz  # 解压
$ mv node-v16.15.0-linux-x64 ~/.local/share/node  # 移动

# 以下二选一
## 加入到 PATH 环境变量
$ echo 'export PATH="$PATH:$HOME/.local/share/node/bin/"' >> ~/.bashrc  # 如用 bash
## 增加软链接
$ cd ~/.local/bin/  # 切换路径
$ ln -sf ../share/node/bin/node node
$ ln -sf ../share/node/bin/npm npm
$ ln -sf ../share/node/bin/npx npx
$ ln -sf ../share/node/bin/corepack corepack

$ node --version  # 运行（查看版本）
v16.15.0
```

类似地，Golang 也可以通过这样的方法下载安装；对于 Rust ，官网的[安装教程](https://www.rust-lang.org/tools/install)中甚至提供了一键安装脚本；对于 Python，可以使用 [pyenv](https://github.com/pyenv/pyenv) 这个项目提供的[一键安装脚本](https://github.com/pyenv/pyenv-installer)。

用这样的方法可以自由地安装特定的版本，而不用担心跟系统版本冲突。对于有多版本的共存和快速切换需求，也可以安装一些管理工具，这里就不展开了。



## 方案三：源码即是软件

除了传统意义上的编译型软件，现在还很流行一些用脚本语言编写的软件工具，最典型的就是 Python 和 Nodejs 编写的软件，用语言本身的解析器 + 软件代码就能运行，且通过它们各自自带的包管理器就能方便地安装。但是，在默认设置情况下，包管理器下载的源码是要放置在系统目录下的，因此都需要管理员权限才能安装。

通过修改包管理器的设置，我们完全可以指定下载回来的源码放置在用户目录的路径下，这样就不需要管理员权限也能方便地自主安装了。

首先是 Python 的说明，以 python3 为例，pip3 是它的包管理器。默认情况下，通过 `pip3 install` 命令就能够正常下载软件包，可选加上 `--user` 参数，效果相同，但不要用 `sudo` 命令调用。默认的包下载路径为 `~/.local/lib/python3.x/site-packages/` ，但如果这个软件包也包含可执行文件，那么该可执行文件会被下载到 `~/.local/bin/` 路径下，跟我们上述的路径一致，因此只需要将该路径加入到 PATH 中即可。用我比较喜欢的 [pipenv](https://github.com/pypa/pipenv) 工具为例：

```Bash
$ pip3 install pipenv  # 安装
$ echo 'export PATH="$HOME/.local/bin/:$PATH"' >> ~/.bashrc  # 加入 PATH
$ pipenv --version  # 运行（查看版本）
pipenv, version 2022.6.7
```

类似地，对于 Nodejs，npm 是它的自带包管理器。默认无管理员权限的情况下，无法全局安装软件包，因此我们要修改它的配置文件 `~/.npmrc` ，在其中加入 `prefix=${HOME}/.npm-packages`，并将其子目录 `bin` 加入到 PATH 路径中，然后就能全局安装软件包了。用一个命令手册工具 [tldr](https://tldr.sh/) 作演示：

```Bash
$ echo 'prefix=${HOME}/.npm-packages' >> ~/.npmrc  # 修改 npm 配置
$ echo 'export PATH="$PATH:$HOME/.npm-packages/bin/"' >> ~/.bashrc  # 加入 PATH
$ npm install -g tldr
$ tldr npm

  npm

  JavaScript and Node.js package manager.
  Manage Node.js projects and their module dependencies.
  More information: https://www.npmjs.com.

  - Interactively create a package.json file:
    npm init
```

对于其它的解析型的语言，方案也是差不多的，通过查询配置文档即可举一反三。



## 方案四：软件迁移

最后的方案，如果需要使用的软件是一个动态链接程序，且不仅仅只是依赖系统库，那么可以通过二进制打包迁移的方式从一台已安装或有管理员权限的机器上，迁移到要使用的目标机器上。

有读者可能会提出开源软件都可以通过自己本地编译构建。但是 C/C++ 编写的软件之所以难以编译构建，是因为它没有官方配套的现代包管理器，各个软件各自依赖的工具链繁多。举个简单例子，如果需要编译安装 [tmux](https://github.com/tmux/tmux) 程序，则需要编译 ncurse 库，而编译后者又需要编译 libevent 库。寻找互相兼容的版本，下载，配置编译参数，都是一个十分枯燥无趣的过程（4 年前我还为此专门写了一个[脚本](https://gist.github.com/Wsine/b016c6634a465051f24755c0e6a78342)）。

那么，如何确认我们的目标软件是否需要软件迁移呢？在 Linux 上，我们可以通过 `ldd` 命令查看一个动态程序都依赖什么动态库，这里还是以 [tmux](https://github.com/tmux/tmux) 程序为例：

```Bash
$ ldd /usr/bin/tmux
        linux-vdso.so.1 (0x00007ffdfd595000)
        libutil.so.1 => /lib/x86_64-linux-gnu/libutil.so.1 (0x00007fadaae09000)
        libutempter.so.0 => /usr/lib/x86_64-linux-gnu/libutempter.so.0 (0x00007fadaae04000)
        libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007fadaadd4000)
        libevent-2.1.so.7 => /usr/lib/x86_64-linux-gnu/libevent-2.1.so.7 (0x00007fadaad7e000)
        libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 (0x00007fadaad62000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fadaab70000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fadaab4b000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fadaaeda000)
```

如果你粗暴地将目标程序拷贝到目标机器上，然后运行 ldd 命令，发现部分库没有找到对应的链接库，或者所有库都有十六进制地址了，但是尝试运行就出现 Segmentation fault 。那么，你需要软件迁移。

解决方案也很简单直观，只要把缺失/不兼容的动态链接库一个一个拷贝到目标机器上的 LD_LIBRARY_PATH 中并重设一下目标软件的链接情况就好了（听起来就很枯燥）。好消息是，总是有良心的开发者开发优秀的工具，并无私奉献给社区，[Exodus](https://github.com/intoli/exodus) 就是该解决方案的开源工具。

Exodus 通过 Python 编写，用上述的方案三即可在用户目录便捷安装，然后通过命令 `exodus <executable> | ssh example``.com` 由管道通过 ssh 输送到目标机器的 `~/.exodus/` 路径上，将该路径下的 bin 文件夹加入 PATH 路径即可运行。此处引用一下 Exodus 在 Github 上的动图展示：

![b1a64392-825a-4665-b321-69dc0c891438](https://image.wsine.top/b214fe236c0d74d32922d0667596b5ca.gif)

如果不方便通过 ssh 直接输送，那么将软件打包到一个压缩包，在目标机器上再解压，Exodus 也是支持的，详情可以看项目主页。我觉得比较实用的是配合 Docker 在镜像内用 apt 类工具安装复杂的软件，然后一并打包到目标机器中使用。

这类解决方案也是有它一定的限制的：1. 系统库 glibc 或 内核 kernel 不兼容。 2. 依赖库中有驱动相关的依赖。前者不必太过担心，现代的 Linux 发行版 glibc 和 kernel 版本上下兼容能力非常强大，而后者属于硬件相关的问题，不是靠软件能解决的。



## 后记

通过上述的 4 个解决方案，我基本覆盖了在日常 Linux 环境中各种软件使用的需求，而不必依赖管理员审核安装，实现了软件安装的自给自足。由于安装过程直观明了，升级和卸载也是水到渠成的事情简单地删除或替换文件和文件夹即可。通过一些配套工具能将安装过程管理并自动化，大大简化了新机器的配置过程。

上述的部分解决方案其实也适用于 Windows 和 macOS 操作系统，但是由于使用这两个操作系统一般都能自由地通过各种工具安装应用程序，因此没必要折磨自己。如果偏向于绿色软件，可以参考里面的思维构建自己顺手的便携软件。

如果有更好的解决办法，可以在评论区留下你的方案。
