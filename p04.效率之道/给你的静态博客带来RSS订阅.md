# 给你的静态博客带来 RSS 订阅

最近对于千篇一律的科技新闻，感到了一丝的阅读疲倦。因此，想要寻找一些有有趣的灵魂或者独立思考的博文，打发平时无聊的摸鱼时光。但是，随着在互联网上探索有意思的博客，发现绝大部分都没有提供相关的订阅链接，这将很难追踪新博客的发布。这其中，相当一部分博客是通过静态方式发布博客的。

因此，本文的内容就是通过我的实践展示一下如何给静态博客增加 RSS 订阅。

## 什么是 RSS

首先我们来看一下维基百科上面对 RSS 的定义：

> **RSS**（全称：[RDF](https://zh.wikipedia.org/wiki/Resource_Description_Framework) Site Summary；Really Simple Syndication），中文译作**简易信息聚合**，也称**聚合内容**，是一种[消息来源](https://zh.wikipedia.org/wiki/消息來源)格式规范，用以**聚合经常发布更新资料的网站**，例如[博客](https://zh.wikipedia.org/wiki/部落格)文章、新闻、[音频](https://zh.wikipedia.org/wiki/音訊)或[视频](https://zh.wikipedia.org/wiki/視訊)的网摘。RSS文件（或称做摘要、网络摘要、或频更新，提供到频道）包含全文或是节录的文字，再加上发布者所订阅之网摘资料和授权的元数据。简单来说 RSS 能够让用户订阅个人网站个人博客，当订阅的网站有新文章是能够获得通知。

仔细阅读第二个英文全称，它表达的是 RSS 是一个十分简单的聚合技术，最主要的目的就是给个人网站和博客提供信息聚合，并通知所有订阅的阅读者，使信息能够更高效的传播。这正是我们想要的目的。

## RSS 的格式

RSS 的本质其实很简单，只是一份定制化的 XML 文件，我们先来看看该文件的基础定义。这份定义参考自 [RSSBoard](https://www.rssboard.org/rss-specification) 网站对于 RSS 2.0 版本的定义所提供的最简单的版本。

```xml
<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
<channel>
  <title>blog_title</title>
  <atom:link href="blog_link" rel="self" type="application/rss+xml" />
  <link>blog_link</link>
  <description>xxx</description>
  <item>
    <title><![CDATA[article_title]]></title>
    <link>article_link</link>
    <guid isPermaLink="false">article_id</guid>
    <description><![CDATA[article_content]]></description>
    <pubDate>article_date</pubDate>
  </item>
</channel>
</rss>
```

可以看到，这份 XML 文件十分简单，仅包括对于需要阅读的内容的基础信息，并没有增加其他复杂的信息。其中比较特殊的可能是 `guid` 这个标签，它提供对于文章的唯一标识，但由于文章的超链接也是唯一的，因此可以把超链接作为 GUID 的标识。

## 如何生成 RSS

由于需要根据文章内容动态生成该XML文件，因此一般的静态博客没有动态处理的能力，所以提供不了这种功能。但是，现代化的静态服务平台都提供了 Continuous Integration (CI) 的功能，我们可以利用该功能为我们的博客自动化提供该XML文件。

实现的思路总体来说就4步：获取最新的文章，根据内容拼接字符串，输出生成内容到 XML 文件，发布 RSS。

下面，我会以自身为例，在 Github 平台上通过 Travis CI 服务，自动化生成 RSS 文件所应该关注的点进行说明。

**获取最新的文章**

首先我们会遇到第一个问题，该 XML 文件中到底需要包含多少篇文章才算是最新的文章。在这里，我的建议是 10 篇。考虑到个人博客的属性，我们的更新频率不会特别高，10篇文章足以达到人们通常阅读的频率。以 Git 协议管理的时间作为文章的发布时间，是一个不错的选项。

第二个问题是，RSS 如何知道我哪篇文章是新的？这里就需要严格控制文章的生成的 `pubDate`标签。在 RSS 2.0 的协议规范里面，规定了该时间的时间戳使用的是 [RFC 822](http://asg.web.cmu.edu/rfc/rfc822.html) 的规范。否则，该订阅源在阅读器中会出现混乱的排序情况，尤其注意。Git 命令中提供了 format 选项 “%aD” 可以获取该规范下的时间戳。

**根据内容拼接字符串**

这里有两个标签需要特别注意一下的。

其一是`link`标签。由于部分人的文件是以中文命名的，这在RSS中并不能直接访问到正确的内容。正确的做法是自行将 URL 手动 encode 成标准的 unicode 编码，可以仅对中文部分处理，也可以对整个 URL 进行编码。一般来说，仅对中文部分处理会使最终生成的 URL 相对好看一些。

另一是 `description` 标签。由于大部分人现在都是使用 Markdown 语言来写博客，而 markdown 的纯文本并不适合直接阅读，而目前的 RSS 阅读器并不支持渲染 Markdown 语言。我们更希望将它进行解析到 Html 语言，以便后续能够更好的渲染成优秀排版。这里，我们使用万能的瑞士军刀 `Pandoc` 软件即可解析。

但是，由于 Html 语言和 Xml 的语言都是属于标记型语言，混合在一起容易产生歧义解析。因此需要使用 `<![CDATA[  html_content  ]]>` 逃逸字符来控制 html 内容不属于 xml 的一部分。

**输出生成内容到 XML 文件**

通过不同的编程语言控制文件输出到 XML 这不难。根据自己选择的编程语言生成即可。

这里，我建议大家对生成的 XML 进行校验，确保生成的 RSS 是正确并能够解析的。W3C 联盟提供了标准的 RSS 文件校验服务：https://validator.w3.org/feed/，可以在线输入和链接校验两种方式。

**发布 RSS**

对于静态博客，最直接的方法是将 XML 文件推送到静态服务平台，然后以 RAW 格式访问，即为一个合格的 RSS 订阅链接。

更进阶一步的方法，可以利用前端框架里面的静态路由方式，解析通用的 `/feed` 路由到生成的 RSS 文件中，配合标准的图标 ![rss icon](https://www.rssboard.org/images/rss-icon.png)，能够让人清晰直观的发现该博客提供了 RSS 订阅链接。

## 后记

上述的说明只描述了我认为在这个方案中需要注意的事项，隐去了每一步的操作细节。想要抄作业的各位同学，可以移步到 https://github.com/Wsine/blog/blob/master/build.sh 查看具体的实现方法，直接复制到自己的仓库中就可以使用。

具体的展示可以查看我的博客看看具体效果：https://wsine.github.io/blog [![rss icon](https://www.rssboard.org/images/rss-icon.png)](https://wsine.github.io/blog/feed.xml)，也欢迎订阅~

在这里，我也呼吁大家为自己的博客增加 RSS 订阅链接，如想分享可以在评论区留下你的订阅链接~
