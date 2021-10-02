---
title: "我的Vim配置"
date: 2019-07-23
published: true
tags: ['Solution', 'Vim']
series: false
canonical_url: false
description: "今天来分享一下我对于Vim的一下配置和心得"
---

## 前言

#### 为什么选择vim？

曾经我也是一个小白，使用Dev-C++来学习C++语言，使用Visual Studio开发工程，它们都被称为IDE(Integrated development environment)。但是，逐渐的，我渐渐意识到，你只能遵循它制定的一系列的流程来开发程序，自定义程度不高，而且大型的IDE消耗计算资源严重。

后来，我认识到了编辑和编译应该是一个分开的过程，便转战到了文本编辑器，选择Sublime Text。Sublime优秀的UI界面，优秀的快捷键，拥有插件系统，着实让我着迷。它的初始环境便可直接上手，它的默认配色Monokai让人看得很舒服。

但是，离开Sublime选择Vim的原因有三点，一是Sublime依赖于图形化界面，二是Sublime移动光标需要移动右手使用方向键，三是Sublime编辑远程文件要么借助工具要么经常传输。至此，我终于理解了那个古老的梗。

>  世界上只有三种程序员，一种是使用Vim的，一种是使用Emacs的，还有一种是其他

而这篇博文也是放置于效率分类下

*加个小彩蛋：*我实验室的Boss爱用Emacs，我们互视为异教徒，我说“你的手指会变形的”，他说“程序员谁的手指不变形”，我“......[冷漠]”

#### 如何学习Vim

我的观点是，自己一行一行写自己的配置文件才会深入学会Vim。如果一开始就用配置好的，那和直接使用IDE没有太大的差别。知道配置文件每一行干了些什么，不懂就搜，想加功能想改功能就动手，最后这就是一份**你的配置文件**。相信每个Vim大牛都是这样做的。同样的，我的Vim配置也会不断更新，可能会持续n年也不一定。而这也是为什么我的文章标题起名如此。

## 原则

我的Vim配置有一定的原则，遵循原则才会让配置不会超出自己的控制

1. 插件能用轻量级的就不用复杂的
2. 非需要的功能不会添加
3. 尽量消耗更少的资源
4. 配色一定不能忍
5. 尽可能的做到一键配置

## 正文

#### 配色

说得多还不如先看看总体的配色，配色我采用了vim自带的desert主题，在这个基础上加了一点自定义

![配色图](https://wsine.cn-gd.ufileos.com/image/468539c3f437335584ebdfa2f8c4aa34.png)

从左往右说起好了，左侧我添加了一个目录树，使用的是`scrooloose/nerdtree`的插件，并且绑定了`<leader>q`来启动和隐藏目录树，使用起来还是蛮方便的

中间的配色我刻意挑了一个黑色的主题。我不喜欢那种惨淡的白色，函数名和命名空间是白色就和变量名看起来没有区分度了，因此搜了好久，找到了`octol/vim-cpp-enhanced-highlight`插件能满足这个需求，修改了一下它的颜色。弹出菜单的颜色我也自己修改了。颜色都采用了暗色调的color，确保不会刺眼，同时也能将不同的元素区分出来。`set t_Co=256 " Enable status bar color`很重要。

顶部和底部采用的是比较出名的`vim-airline/vim-airline`插件，以及其相应的`vim-airline/vim-airline-themes`，主题我选择了`let g:airline_theme='luna'`，并且启用了powerline字体，也就是你能看到的三角形符号

因为还在不断的修改中，未来可能会考虑把配色做成插件易于安装吧，目前的安装方式比较麻烦

#### 管理

插件管理上我选用了Vundle，目前一款比较流行的Vim插件管理器，基本上我只使用github上的vim插件

![插件列表](https://wsine.cn-gd.ufileos.com/image/fe535df15cf240c8bc5474da7fcf1b28.png)

#### 按键

一直以来我对于那种秀配置不讲按键绑定的文章比较反感，除非你一个键都没改

|  模式  |      按键      |        映射        | 功能           | 说明                  |
| :--: | :----------: | :--------------: | ------------ | ------------------- |
|  全局  |     `,`      |     `leader`     | `<leader>`   | leader键是vim中的一个特殊键  |
|  正常  |     `j`      |       `gj`       | 下一行          | 视觉上往下移动(行太长导致分行时)   |
|  正常  |     `k`      |       `gk`       | 上一行          | 视觉上往上移动(行太长导致分行时)   |
|  正常  | `<leader>w`  |     `:w<CR>`     | 快速保存         | 没有权限保存的时候也是不行的      |
|  正常  | `<leader>q`  | `:bd<CR>:q<CR>`  | 快速退出         | 前提所有buffer都保存了，防止意外 |
|  正常  |     `K`      |   `:bnext<CR>`   | 切换到右边的buffer | 仿照Vimuim的标签切换       |
|  正常  |     `J`      | `:bprevious<CR>` | 切换到左边的buffer | 仿照Vimuim的标签切换       |
|  正常  | `<leader>bn` |   `:enew<CR>`    | 新开一个buffer   | buffer new          |
|  正常  | `<leader>bd` |    `:bd<CR>`     | 关闭当前buffer   | buffer delete       |
|  正常  |    `空格键`     | `smooth_scroll`  | 向下平滑滚动       | 避免思维跳跃，仿照Chrome的设定  |
|  正常  |    `减号键`     | `smooth_scroll`  | 向上平滑滚动       | 避免思维跳跃              |
|  编辑  |  `Ctrl + b`  |     `方向键-左`      | 向左移动一个字符     | 仿照Bash的控制方式         |
|  编辑  |  `Ctrl + f`  |     `方向键-右`      | 向右移动一个字符     | 仿照Bash的控制方式         |
|  编辑  |  `Ctrl + e`  |     `Home键`      | 跳到行首         | 仿照Bash的控制方式         |
|  编辑  |  `Ctrl + a`  |      `End键`      | 跳到行尾         | 仿照Bash的控制方式         |
|  编辑  |    `Tab键`    |     `方向键-下`      | 选择下一个候选词     | 可连续按                |
|  编辑  |    `Esc键`    |   `Ctrl + 回车`    | 清除菜单         | 无                   |
| 可视化  |     `//`     |  `y/<C-R>"<CR>`  | 快速搜索         | 需要先选择内容             |

其实可以看出我是比较喜欢统一各大软件的按键方式的，主要是可以让自己不用记忆太多，快捷键是效率的主要生产力，所以终端、编辑器、浏览器这三大离不开的软件，我都会尽可能地去统一它们的按键

上面提到的平滑滚动我使用了`lucasicf/vim-smooth-scroll`的插件，其实这个插件来自出名的`terryma`之手，但是如果连续平滑滚动，会连续触发导致控制卡死。而`lucasicf`修复了这个bug并发送了PR，不知道为什么`terryma`大神一直没有理=。=

还有，我想要仿照Chrome使用Shift + 空格键来平滑向上滚动，然后我尝试了很多种方法，并不能捕获`Shift + Space`的状态，如果有大神能做到求教

#### 括号匹配

Vim毕竟是写代码的利器，自动补全括号特别实用且重要，这里我简单的使用了一个插件`jiangmiao/auto-pairs`

#### 多光标编辑

在Sublime中唯一让我留念的就是多光标编辑了，作为被这个装逼大法宠坏的我，没有它感觉断了一臂。多亏了terryma大神将这一功能移植到了vim中，据说，这还是大神在一次航班途中写出来的，我只能打出666并默默地比了一个❤~

插件名称`terryma/vim-multiple-cursors`。在Visual模式下选中所需要改的内容，按Ctrl + n可以选中下一个，然后按下c进入编辑状态，编辑完，Esc，完美

#### 快速打开文件

Sublime还有一个功能是Ctrl + p可以打开文件，这一方式同样也有插件在vim中`ctrlpvim/ctrlp.vim`。更重要的是，该插件同样支持模糊搜索。

#### 快速注释

`scrooloose/nerdcommenter`是一个优秀的插件，默认的注释方式是`<leader>c<Space>`，可以在注释和非注释直接切换。同时，配合Ctrl + v的块选择，能够快速选中自己想要注释的行，然后`<leader>c<Space>`快速批量注释

#### 自动补全

在自动补全的领域下，最好的无疑是`YouCompleteMe`插件了，然而我并没有使用。首先该插件的调用程序太多，消耗资源太多，安装也麻烦，一次安装终身受用这种借口不能作为不简化安装的理由。其次，语义化补全对我来说没有太大的需求，只需要能把变量和函数提示并补全就好了

而Vim在新版中已经原生添加了自动补全的功能。利用按下Ctrl + x, Ctrl + o触发， Ctrl + n, Ctrl + p选择菜单。但是这样未免太麻烦不优雅，我利用了一款插件`vim-scripts/AutoComplPop`，它能够自动弹出补全菜单，使用起来效果还不错。不过它偶尔有一些小bug，我自己还能忍，如果你不喜欢再寻求一款更好的自动补全吧

#### 格式控制

在格式控制的范畴下，我将制表符都转义成了空格，并且在保存的时候自动把行尾的空格都去掉了，这是符合优秀编码规范的格式，希望还是能保持。

有一点，很多人没注意到的，Git管理的文件建议保留文件末尾的一个空行，特意提一下，我没有加入到vim自动添加空行，因为不是所有的文件都被Git管理，无端的空行可能会导致一些未知的错误。所有建议手动添加。

#### 其他

假设你都理解了vim的基础操作，其他的一些配置我也有相应的注释，参考了http://amix.dk/vim/vimrc.html，不愧是被誉为教科书般的vim配置，真是优秀。

阅读.vimrc文件，能开拓你很多的思路，希望能找到你喜欢的

## 安装

参照https://github.com/VundleVim/Vundle.vim，下载Vundle管理器到指定目录

将对应的文件放置在你的家目录`~`下

```
~
├── .vimrc
└── .vim
     ├── bundle
     │   └── Vundle.vim
     └── colors
         └── desert.vim
```

[.vimrc文件下载](https://github.com/Wsine/Backup/blob/master/vim/.vimrc)
[desert.vim文件下载](https://github.com/Wsine/Backup/blob/master/vim/desert.vim)

打开Vim，使用`:PluginInstall`即可

## 配置文件

```
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vundle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'jiangmiao/auto-pairs'
Plugin 'scrooloose/nerdtree'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'terryma/vim-smooth-scroll'
Plugin 'lucasicf/vim-smooth-scroll'
Plugin 'vim-scripts/AutoComplPop'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'vim-python/python-syntax'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Put your non-Plugin stuff after this line

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

" ignore case when searching unless exists one upper case
set ignorecase
set smartcase

" Realtime searching
set incsearch

" hight light searching
set hlsearch

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show number
set number

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Set cmd show
set showcmd

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Set colorscheme
set background=dark
colorscheme desert

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Enable status bar color
set t_Co=256

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

" Intelligence indent
set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Toggle paste mode
set pastetoggle=<leader>p

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Fast saving
nmap <leader>w :w<CR>

" Fast quit
nmap <leader>q :bufdo bd<CR>:q<CR>

" Fast open file tree
map <leader>t :NERDTreeToggle<CR>

" Fast Tab use
noremap <silent> K :bnext<CR>
noremap <silent> J :bprevious<CR>
noremap <silent> <leader>bn :enew<CR>
noremap <silent> <expr> <leader>bd
    \ len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) >= 2 ?
    \ ":bp\|bd #<CR>" : ":bd<CR>"

" Smooth page scroll
nnoremap <silent> = :call smooth_scroll#down(&scroll, 25, 2)<CR>
nnoremap <silent> - :call smooth_scroll#up(&scroll, 25, 2)<CR>
nnoremap <silent> <Space> :call smooth_scroll#down(&scroll, 25, 2)<CR>

" Move in insert mode
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-e> <End>
imap <C-a> <Home>
imap <M-f> <C-o>w
imap <M-b> <C-o>b

" Clear highlight color
nnoremap <Esc> :noh<Return><Esc>
nnoremap <Esc>^[ <Esc>^[

" Popup menu select
inoremap <silent> <expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
inoremap <silent> <expr> <ESC> pumvisible() ? "\<C-E>" : "\<ESC>"

" Visual Mode Search
vnoremap // y/<C-R>"<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Function, Command
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

" Auto open file tree if enter a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin Setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDcommenter
let g:NERDSpaceDelims=1
let g:NERDCommentEmptyLines=1
let g:NERDDefaultAlign='left'

" Vim Airline themes
let g:airline_theme='luna'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1

" Vim Cpp Highlight
let g:cpp_class_scope_highlight=1
let g:cpp_member_variable_highlight=1
let g:cpp_experimental_simple_template_highlight=1
let g:cpp_concepts_highlight=1

" Vim Python Highlight
let python_highlight_all=1
```
