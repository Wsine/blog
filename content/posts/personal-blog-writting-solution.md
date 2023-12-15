---
title: "个人博客的方案推荐，你只负责编写"
date: 2019-07-20
cover_image: https://image.wsine.top/df79af2c03cc6570d3e243a22a052abb.jpg
---

今天想要谈谈的是一套我在用的个人博客解决方案，它能带给我最大的便利。

首先我想先插播一个讨论，为什么要写博客？从我上大学开始，我就喜欢上了写博客。这主要是受到了一位前辈说的话而引发的思考：“当你能够将你所学的有条理地写下来成为一篇文章，那么就证明你学会了。” 当我越是实践这一点，我就越能体会到 写与不写 两者之间的差异。

以我的经历来揣测，大多数人的博客方案可能经历如下几个阶段：

- 主流博客网站：需要考虑的因素就比较多，包括Markdown支持、CSS支持、Javascript支持等，更重要的是原始数据不能很容易地访问；
- 私有博客服务器：维护VPS，维护域名，维护流量 是这一方案最大的成本；
- 静态网页托管：`hexo`、`jekyll`、`pelican`都是比较主流的方案，但是对客户端本身比较依赖

直到我遇到了[docsify](https://docsify.js.org/#/zh-cn/)，我更愿意将它称为第四阶段“动态生成网页托管”。

## Docsify是什么

官方的描述是这样子的：一个神奇的文档网站生成工具

> docsify 是一个动态生成文档网站的工具。不同于 GitBook、Hexo 的地方是它不会生成将 `.md` 转成 `.html` 文件，所有转换工作都是在运行时进行。
>
> 这将非常实用，如果只是需要快速的搭建一个小型的文档网站，或者不想因为生成的一堆 `.html` 文件“污染” commit 记录，只需要创建一个 `index.html` 就可以开始写文档而且直接[部署在 GitHub Pages](https://docsify.js.org/#/zh-cn/deploy)。

第一次看到这样的描述的时候，我就觉得它也很适合用来构建一个博客系统，事实证明确实如此。

## Docsify有什么

### Markdown支持

在2019年写博客，几乎主流的选择都是使用 Markdown 标记性语言，它很轻量，能让关注在内容本身而不是调格式上。

但是，Docsify 提供的 Markdown 是原生的美好的感觉，不需要你刻意遵循什么，想怎么写就怎么写的自由；相对的，Hexo 和 Jekyll 都需要遵循一些特殊的格式，比如 {{ 日期 }} 等。这是我很喜爱它的一点。

官方内置的 Markdown 解析器是[marked](https://github.com/markedjs/marked)，如果不喜欢还可以参考[文档](https://docsify.js.org/#/zh-cn/markdown)来自定义。

###CSS支持

docsify 提供了内置的5款主题，分别 `vue.css buble.css dark.css pure.css dolphin.css`，我个人是比较喜欢绿色的主题的，所以选了还是默认的 vue.css 风格。另外，Github 上还有很多优秀的第三方主题可供选择。

当然作为一个开放的系统，它也允许用户自定义，如果有兴趣，撸一个符合自己审美好看的主题也蛮不错的。

详细的主题 Demo 可以看[这里](<https://docsify.js.org/#/zh-cn/themes>)~

### Javascript支持

#### 流程图 & 序列图

有 js 的支持，对我来说意味着能够加入扩展 Markdown 语法，比如流程图、序列图等的支持。我很喜欢 [Typora](<https://typora.io/>) 这款 MD 编辑器，它自身加入了流程图和序列图等的支持，这对于技术博客来说还是很有用的一大功能。而借助 docsify 的插件系统，简单的配置了一下就能加入这些功能，然后就能做到桌面端编辑和网页端展示是完全一样的效果。

![sequence diagram](https://image.wsine.top/7e81db0357153a234f1ed0a8c7b80c02.jpg)

#### 评论系统

docsify 官方支持 Disqus 和 Gitalk 两种评论系统，如果有需要的话也可以很轻易的配置。我个人是比较推荐使用 Gitalk 的，毕竟 Github 账号很多人都有。

![discuss](https://image.wsine.top/7a7280f5f68996d1cf074853a3b1c100.jpg)

还有其他很有用的一下功能官方都提供了，具体可以看这里的[插件列表](<https://docsify.js.org/#/zh-cn/plugins>)。如果需要实现一些特殊的功能也可以自定义，拥有可修改能力就感觉拥有一切一样，这感觉还是很美好的。

### 数据独立

这是我最喜欢也是最重要的一点，它不需要你像 Hexo 等系统一样，编写 md 文件，然后通过工具转化为 html 网页静态托管。在 docsify 你只需要专注编写 md 内容本身，保存的也是 md 文件本身，docsify 就会自己读取 md 文件然后渲染成网页展示。

我认为这是一件很棒的事情，不用再过多的依赖工具本身，编写->部署->托管的三个步骤中，我只需要在意第一个步骤就好了。甚者，由于没有了中间文件，我能直接管理 md 源文件，也相当于一个很好的备份，将数据掌握在自己手中的感觉。

你的整个目录将会很整洁，就像这样：

```bash
.
├── index.html
├── p01.解决方案
│   ├── Markdown标题格式化.md
├── p02.效率之道
│   ├── 2019年科学的复合密码管理策略.md
│   ├── 一个5年工科生的软件解决方案与吐槽.md
│   └── 我的Vim配置.md
├── p03.生活随想
│   └── 给大学新生学子的一个思考.md
└── README.md
```

引入 docsify 后唯一增加的一份文件只是一个 index.html 而已，而你原来管理数据的方式还是完全没变化(๑•̀ㅂ•́)و✧

## Docsify缺什么

事实上，docsify 也不是完美的，它也有一些小缺点，但是我们可以通过自定义来修补它。

### 侧边栏目录

由于 Web 技术本身的限制，docsify 想要读取你服务端的文件需要用户主动提供路径，否则随便就能读取文件，想想还是很可怕的。

要想增加侧边栏显示目录，docsify 需要用户自行提供 `_sidebar.md` 文件，里面用 List 记录着你的目录结构。

但是，很明显，你只想好好写文章，并不想管理这些部署的事情，每新增一篇文章都要同步修改一遍 `_sidebar.md` 文件，还是很麻烦的一件事情。因此，我想到了请一个佣人来帮我完成这件事情，那就是 [Travis CI](<https://travis-ci.com/>)，一个比较流行的 Github 上的自动化部署服务。然后再花 30s 写一行脚本来生成这个目录。

```bash
find . -mindepth 2 -name "*.md" | awk -F'/' 'BEGIN {RS=".md"} {arr[$2]=arr[$2]"\n    - ["$3"](/"$2"/"$3")"} END { num = asorti(arr, indices); for (i=1; i<=num; ++i) if (indices[i]) print "- "indices[i], arr[indices[i]]}' > _sidebar.md
```

具体如何配置 Travis CI 与 Github 之间的联动我这里就不放教程了，官网上有教程，也可以参考仓库里的这个配置：[.travis.yml](<https://github.com/Wsine/blog/blob/master/.travis.yml>)

### 目录折叠

这是一个在 docsify 的仓库 issue 中呼声比较高的一个功能，很遗憾这个功能现在还没有，所以就自己做一个吧。

得益于 docsify 预留了接口给用户自定义插件，借助钩子（hook）的功能，就可以实现目录折叠，文档多了没有折叠功能，浏览起来还是很不方便的。具体的实现可以参考仓库里的这个文件：[index.html](<https://github.com/Wsine/blog/blob/master/index.html>)

## 我的写作流程

首先我的写作工具其实有很多地方，我会用手机随时记录灵感，用 iPad 在咖啡厅稍微写点东西，用笔记本电脑在图书馆认认真真写文章，晚上在家里享受机械键盘的声音~~~；无论我用什么工具编写，写完后我都可以通过 Github 网页上传新建一份 md 文件到一个新分支上；借助 Github  的功能，我可以很好地和朋友一起协作；当终稿完成的时候，只需要发一个 Pull Request 合并到 master 分支上即可；这时候会触发 Travis CI 的自动化，帮我生成一个目录到 gh-pages 分支上；然后文章就展示到博客中了。

如果要用一个流程图来表达会是这个样子的：

```flow
st=>start: 开始
ed=>end: 结束
write=>operation: 写作
cooperation=>operation: 协作
upload=>operation: 上传
merge=>operation: 合并到主分支
generate=>operation: 生成目录
deploy=>operation: 发布
last=>condition: 终稿？

st->write->upload->last
last(yes)->merge->generate->deploy->ed
last(no)->cooperation->upload
```

### 样例Demo

![Demo](https://image.wsine.top/0f23072a7635d7f9925d75b94461b0b0.jpg)

博客地址：https://wsine.github.io/blog

至此，正文部分就结束了，如果还有兴趣的话可以继续阅读下面的部分。docsify 是一块面向文档设计的工具，但是能做成什么取决于使用工具的人，它也不仅仅只能用于说明文档。

## 后记

实际上，我所经历的博客建站总共分为三个阶段，我也曾经不断摸索最后才找到最合适自己的方案。

### 主流博客网站

我最开始的写作是在[博客园](https://www.cnblogs.com/)平台上。它本身很不错，我最开始选择它的理由是相对小众，以及它的slogan`代码改变世界`很抓我的心，博文页完全没有广告阻挡正文，这些都是我选择它的初衷。

还有两点我想说，可定制化的页面与可定制化的插件。我很喜欢其中的一款主题：`Less is more`，它基本完全没有样式，但正是如此才最方便地定制一个符合自己审美的CSS，能让写作更加充满动力。其次，博客园平台允许用户申请 JavaScript 权限，这就相当于你可以自由地动态改变页面的内容，比如增加官方不支持的 flowchart 、隐藏彩蛋、~~删除页面广告(划掉)~~ 等。

后来，它很早开始支持Markdown也是我喜欢它的一点之一。但是，正值移动端崛起，网站本身对移动端的适配不足且我自定义了UI加大了难度，哪怕我辛苦得做了一版本移动端适配，效果也只是差强人意。

![Old](https://image.wsine.top/038adfb2b0b6b9233d75dd323c018cc4.png)

### 私有博客平台

我花了一年的时间折腾在Azure上面搭建了自己的博客平台，我很享受这个过程，完全自定义的过程也能让我学到很多。从购买域名，选择技术栈，搭建测试，维护数据库等，这些其实都是无与伦比的经验。专业相关的也建议折腾一番。

### 静态网页托管

我尝试过用Github Page托管`pelican`构建的静态博客，我选的主题很简洁，也能做到clone即可运行，最低的依赖仅仅是python运行环境，不需要安装package。

好了，回应初心，要不要写博客？我认为是一件值得思考的事情，如果你在犹豫，不妨先写一篇看看~
