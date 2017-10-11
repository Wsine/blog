# Linux之tmux学习

## 前言

在Linux的世界中，命令行是最优雅的交互方式。

但是，只会使用一个交互终端的程序员，是不足以成为Linux下的大牛的。

那么tmux是什么，引用一下原文介绍

> ```
> tmux is a "terminal multiplexer", it enables a number of terminals (or windows)
> to be accessed and controlled from a single terminal. tmux is intended to be a
> simple, modern, BSD-licensed alternative to programs such as GNU screen.
> ```

tmux可以让你在一个终端中同时交互多个命令，而不用多开终端和不断切换窗口，同屏显示的效率也更高一些。

## 正文

tmux的原生触发键是`Ctrl + b`，但是由于它的bash原生的后退字符快捷键冲突了，所以我修改了一下键位配置。

**触发键：**修改为`Ctrl + v`，该快捷键仅和vim中的block-visual模式冲突，但该模式使用频率低，而且冲突后可以再次触发进入block-visual，所以不用太介意

**左右分屏：**修改为`|`，形象生动，竖线表达左右分屏，避免记忆原生`%`才是左右分屏的快捷键

**上下分屏：**修改为`-`，形象生动，横线表达上下分屏，避免记忆原生`"`才是上下分屏的快捷键

**面板切换：**修改为hjkl，配合vim的操作方式，避免移动手掌和误操作性，分别对应上下左右

**窗口切换：**修改为序号1为第一窗口（默认0），切换第一个窗口的时候不用在找0的位置，切换方式为触发键后加窗口的序号`Ctrl + v，<index>`，序号默认显示在终端的最下方

**窗口自动重排列：**退出2号窗口后，3号窗口会自动序号变为2号，4号及后面的同理

**调整面板大小：**按住触发键`Ctrl + v`，不断按hjkl即可调整面板的大小

**显示效果：**

![请刷新](http://images2017.cnblogs.com/blog/701997/201710/701997-20171006162617177-143870885.png)

## 附录

[.tmux.conf](https://github.com/Wsine/Backup/blob/master/linux/.tmux.conf)文件内容，放置在`~/.tmux.conf`路径下，建议重定向tmux命令为`tmux -2`才能启动256色彩方案

```
# =====> TMUX general <=====
# reload settings message
bind R source-file ~/.tmux.conf \; display-message "Config reloaded..."

# remap prefix from 'C-b' to 'C-v'
unbind C-b
set-option -g prefix C-v
bind-key C-v send-prefix

# =====> TMUX display <=====
# use 256 colors
set -g default-terminal "screen-256color"
# use vi mode
setw -g mode-keys vi

# start window indexing at one instead of zero
set -g base-index 1
# auto reorder windows number
set-option -g renumber-windows on

# =====> TMUX key bindings <=====
# split window to two horizontal panes
bind | split-window -h
# split window to two vertical panes
bind - split-window -v
# resize-pane with hjkl
bind -r C-h resize-pane -L
bind -r C-j resize-pane -D
bind -r C-k resize-pane -U
bind -r C-l resize-pane -R
# select-pane with hjkl
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R
```
