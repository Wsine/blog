---
title: "从 SSH 无感远程复制"
date: 2022-01-18
published: true
tags: ['Solution']
series: false
canonical_url: false
description: "使用 OSC code 从远程机器复制到本地剪切板"
---

# 从 SSH 无感远程复制

终端是很多人日常打交道的工具之一。比如，深度学习是目前一个大热的研究课题，由于训练和推理过程需要强大的 GPU, 研究生们共享 GPU 服务器，并通过终端使用 SSH 连接并编写代码。而公司中的运维人员，也是时刻需要登陆服务器，通过 SSH 工具远程访问。

在日常操作中，最大的问题莫过于要从远程主机中复制文本并粘贴到本机中。

### 问题：跨平台系统剪贴板不通

远程主机这里我们指 Linux 主机，一般没有图形界面，需要通过 SSH 访问在终端操作。

而本机和远程主机都各自有自己的一套剪切板，在命令操作中复制的文本只会保存在远程主机的剪贴板中。那我们通过终端的图形界面选择并复制不可以吗？

![Picture1](https://image.wsine.top/4d3dc9c5151b617846f1fa6a720dafb4.png)

上图展示我们日常操作中想要执行复制时候的场景，展示的是一个广泛使用的 VIM 工具。

- 困难一：如果只想要复制正文，那么左侧的代码行号也不得不被选择。尽管这个可以通过绑定快捷键快速开关行号。
- 困难二：细心观察，图中文本的第三行超过了终端的宽度，自动换行到下一行展示。如果同时选择这两行，粘贴出来的效果也会是两行而不是它本该的一行。
- 困难三：整份文档并不只有 24 行，如果想要复制整份文档，则不得不分几次逐次选择并复制全终端屏幕。

而这个也是一个困扰了我好久的问题。

### 解决方案：OSC codes

OSC 代表的是 Operating System Controls, 是一种约定俗成的使用于终端程序中的逃逸序列表达，终端根据 OSC codes 所定义的行文处理它所包围的文本。

而正巧的是，[OSC 52 escape sequence](https://chromium.googlesource.com/apps/libapps/+/master/nassh/doc/FAQ.md#Is-OSC-52-aka-clipboard-operations_supported) 定义了从接受终端中拷贝文本到用于的系统剪贴板中。

OSC 52 定义了一次最长接受 100000 个字节，其中前 7 个字节为 "\033]52;c;"，中间 99992 个字节为待复制文本，最后一个字节为 "\a"。待复制文本需要编码为 base64 表达，因此实际可用的复制长度为 74994 个字节。

我觉得已经远超一般的纯文本范围了，能够满足日常的使用了。然后就是怎么优雅地应用到我们的日常工作流中呢？

日常中我们终端人主要用两款软件，一个是 tmux 用于持久化会话，另一个是 vim 用于编辑文本文件。

首先我们需要的上述的 OSC 52 实现，站在巨人的肩膀上，先搜索一下网络资源。我找到了 Github 上的一个开源 [Bash 实现](https://github.com/sunaku/home/blob/master/bin/yank)，顺藤摸瓜，我也找到了 [@sunaku](https://github.com/sunaku) 对应 [tmux ](https://github.com/sunaku/home/blob/master/.tmux.conf.erb)和 [vim](https://github.com/sunaku/.vim/blob/master/plugin/yank.vim) 的实现，十分感谢。

吸收精华，只取所需能够更好的维护自己的版本，也方便日后遇到问题的时候寻找解决方案。

我在这个路径`~/.local/bin/` 中创建了名为 yank 文件，赋予执行权限，并加入到 PATH 路径中。

```Bash
#!/bin/sh

# copy via OSC 52
buf=$( cat "$@" )
len=$( printf %s "$buf" | wc -c ) max=74994
test $len -gt $max && echo "$0: input is $(( len - max )) bytes too long" >&2
printf "\033]52;c;$( printf %s "$buf" | head -c $max | base64 | tr -d '\r\n' )\a"
```

对于 VIM 的实现，我主要用 neovim，日常使用 packer.nvim 管理我使用的插件。因此在 `~/.config/nvim/lua/plugins.lua` 中加入了一个依赖 `ojroques/vim-oscyank`。

```Lua
return require('packer').startup({function(use)
  use 'ojroques/vim-oscyank'
end})
```

复制的动作是通过 VIM 的 visual 模式选择中想要复制的文本，通过 vim 命令 `:OSCYank` 即可快速复制，然后在本机中随意粘贴。

对于 tmux 的实现，则只需要在 `~/.tmux.conf` 中添加一行绑定快捷键 Y 即可。

```Perl
# transfer copied text to attached terminal with yank
bind-key -T copy-mode-vi Y send-keys -X copy-pipe 'yank > #{pane_tty}'
```

使用方法是先触发 tmux 的热键并依次键入序列：`ctrl+b, [, <hjkl>, v, <hjkl>, Y`。其中，ctrl+b 是 tmux 的热键，[ 进入会话冻结状态，<hjkl> 代表使用 vim 方式控制光标，v 进入选择模式并选择文本，最后 Y 复制选中的文本。然后就可以在本机任意粘贴了。

对于普通的终端环境下，可以通过管道将前者命令的输出输送给 yank 命令进行复制，具体如下：

```Bash
$ cat your_file.txt | yank
```

然后在本机粘贴即可。

### 支持的平台

总结一下，想要实现上述的效果需要两个条件，其一是合适的软件和可编程配置的编辑器。我搜索并汇总了一些常见的平台的终端模拟器软件对于 OSC 52 支持情况。

- Windows 平台 - Windows Terminal：支持
- Mac 平台 - iTerm2：支持
- Mac 平台 - terminal.app：不支持
- Ubuntu 平台 - Gnome Terminal：不支持
- Chromebook - hterm：支持
- 跨平台 - alacritty：支持
- 跨平台 - kitty：支持
- 终端复用 - tmux：支持
- 终端复用 - screen：支持

必须要在支持 OSC 的软件下面，才能用 OSC 52 来传递复制的内容，且这个动作需要通过脚本/插件来辅助，在编辑器内置的选择模式下调用脚本/插件才行。但基本上来说，常用的软件是能够满足我们这个需求的。

![Picture2](https://image.wsine.top/5a2c7c729710918bda5db7c8e1dc181d.gif)

最后是一个展示，希望能帮助到各位终端人提高效率，下次见。
