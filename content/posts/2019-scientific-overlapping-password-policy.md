---
title: "2019年科学且免费的复合密码管理策略"
date: 2019-06-26
cover_image: https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9.jpg
---

[TOC]

## 前言

今天想要谈谈的是一套我在用的密码管理方案，我认为还是比较安全又易用的。

回想一下，大多数人的密码管理策略可能有如下几个：

1. 纯大脑记忆所有的密码
2. 几乎使用一套密码来注册所有网站
3. 分重要等级用几套密码来注册所有网站
4. 使用记忆因子，实时大脑计算出正确密码
5. 使用流行的密码管理工具，如1password、Lastpass、Keychain等


第一种情况，无疑这样的解决方案十分痛苦，这种情况很常见于不常使用互联网服务的父辈或祖父辈；第二种情况，基本上遇到密码泄露事件，撞库攻击，危险性是最高的；第三种情况，也是我上一种使用策略，虽然减轻的第二种情况的危险性，但还是有一定的危险；第四种情况，我陪朋友去ATM取款的时候，在他旁边陪了10多分钟，才算好密码取出现金🙂；第五种情况，要么太贵，要么平台限制，还不拥有密码的存储权。

本文要解决的就是现有的这些痛点。在2019年的今天，我还是很推荐你尝试一下这套密码管理策略的。

## 我的解决方案

### 密码安全 && 便携

**首先要解决的第一个痛点是密码安全的问题。**我找的解决方案是[花密](https://flowerpassword.com/)，引用一下官方的宣传语

> 不一样的密码管理工具：可记忆、非存储、更安全
>
> 跨平台应用支持：桌面版、移动版，随处方便使用
>
> 无需存储密码：计算获得最终密码，没有存储过程，更安全

它的工作原理大概是这样子的：输入一个"记忆密码"+“区分代号”，然后经过一个特定的Hash算法，获得一个“最终密码”。这个Hash算法主体是由多个md5算法混淆而来，重复概率极其低，而且具有不可逆推导的特性。由于不同的网站使用不同的密码，因此安全性大大提高。

但是，花密本身还有一定的缺陷。首先，它的网页版工具没有做移动端适配，而我并不想在每个平台多装一个软件来实现这个小的功能。其次，它的密码输出位数强制为16位，仅包含英文字母和数字，很多时候会超出网站的密码位数限制，而且评估的密码强度只能达到中等。

因此，我决定自己写一个小工具来改进这些问题。

#### 觅密

受到花密的启发，我实现的工具名为[觅密](https://github.com/Wsine/seekpassword)，并且开源在Github中，在此再次感谢花密的idea。

该工具的整体思路如下：第一部分，基本上是复刻花密的思路，在此就不再复述了。第二部分，我加入了特殊字符进行混淆，基本上评估的密码强度能够达到强级别。第三部分，我将密码长度默认10，暂时没遇到密码长度限制不包含10的网站。第四部分，考虑到部分网站的密码内容限制，我增加了选项去除特殊字符的加入。一键复制密码也有实现，但是由于精简体积和不同的浏览器特性不一样，并没有加入弹窗功能提示复制成功，知道有复制功能就行了。

因此该工具拥有如下的特性：

- 完全开源
- 移动端适配
- 高强度密码
- 更友好的密码长度

这个只是一个小网页，依托Github Page运行，采用纯本地端计算，不涉及与服务器的交互，因此密码安全有保证，且开源。网页链接：[https://wsine.github.io/seekpassword/](https://wsine.github.io/seekpassword/)。

P.S. 如果你也会编程的话，完全可以fork一份后修改来定制自己的安全策略。普通用户直接使用这个网页也完全没有问题。

这里顺便提醒一下，"记忆密码"和“区分代码”并不一定要恒定。记忆密码还是很推荐使用等级策略来记忆，简单分2~3级我觉得就足够了，毕竟安全性已经大大提高了，也就是说你仅需要记忆2~3个短密码即可。区分代码其实可以根据自己对网站的第一反应来记忆，比如昵称、别称、域名、拼音缩写等等，按照自己的喜欢即可。

**这个网页其实也解决了一个便携性的痛点**。

不知道各位有没有这样的痛苦，当你临时来到一个新的机器想要登陆一个账号，但是由于是复杂的强密码完全无法记忆，所以你得要么得重新安装密码管理软件同步过来，或者用手机查看密码后手动输入，这种体验本身都不友好。由于觅密它本身只是一个网页，保存为浏览器书签即可快速使用查看，或直接在新电脑打开网页输入一下就得到最终密码了。

![seekpass](https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9459.jpg)

### 密码存储

密码的安全性是提高了，**下一个点要解决的是所有权的问题。**

无论是笔记还是其他东西，我都希望我的数据能够掌握在我的手里。我来讨论一下极端的几种情况：

1. 哪天我发疯了，将整个软件仓库删了，你不记得算法的流程了怎么办
2. 哪天Github服务被block了或者倒下了，你不知道我将新的网站部署在哪了怎么办
3. 哪天1password / Lasspass等服务倒下了，你的高强度密码都丢失了怎么办
4. 哪天你更换了常用平台不用Apple的硬件了，你存储在keychain的密码怎么导出呢

虽然这些情况都比较难达到，但我依然将这种情况考虑进去了

#### KeePass

我采用的密码管理软件是[KeePass](https://keepass.info/)，首先引用一下的它的官方介绍：

> KeePass is a free open source password manager, which helps you to manage your passwords in a secure way. You can put all your passwords in one database, which is locked with one master key or a key file. So you only have to remember one single master password or select the key file to unlock the whole database. The databases are encrypted using the best and most secure encryption algorithms currently known (AES and Twofish). For more information, see the [features page](https://keepass.info/features.html).
>
> 我知道部分人可能看不懂，没关系，我大发慈悲来做一下简短的翻译：
>
> KeePass是一个开源的密码管理器。你可以存储你的密码到一个数据库中，并通过一个主密码或密钥文件加密（或一起用），同理解锁也需要他们。该数据库是使用当今已知最安全的加密算法AES和Twofish来加密的。

首先安全性，采用的是最好的算法加密，只需要记忆一个主密码就好了，各大密码管理器均需要用户记忆主密码。

其次所有权，所有密码都存储在一个数据库文件中，而这个文件完全掌握在你自己手中。

然后可持续性，开源的算法及软件，完全不用担心服务提供商倒下，你总能找到方法从数据库文件中提取出你自己的密码。

还有多样性，Keepass不仅能存储密码，还能存储notes和文件等等，像我将数字密码锁和路由器管理密码丢到这里真的好实用，我经常不用就忘记了。

最后但也是最重要的一点是，它是免费的。无论1password还是Lastpass，价格基本都是3刀每个月，两百多一年吧，作为密码数据存储服务提供商，承担的风险不小，这个价格其实也合理。

KeePass的官网下载为：[https://keepass.info/download.html](https://keepass.info/download.html)，通过一步一步创建一个本地数据库，我个人推荐同时使用 主密码 (Master Password) 和密钥文件 (Key File) 来加密，十分不推荐启用微软账户 (Windows User Account) 来加密。然后你就能得到如下两个文件：

```
~
├── PasswordDatabase.kdbx
└── PasswordDatabase.key
```

主密码建议记忆在你的大脑中，或通过纸质方式存储；密钥文件建议存储多份，至少有一份在云盘有一份在移动硬盘中。

#### WebDAV

但是，KeePass仅是一个算法/软件，并不包含云服务，不像1Password / Lasspass等提供多平台密码同步功能。但这明显是刚需啊，因此我找到的方案是WebDAV，惯例引用一下它的官方描述：

> Web Distributed Authoring and Versioning (**WebDAV**) is an extension of the Hypertext Transfer Protocol (HTTP) that allows clients to perform remote Web content authoring operations. **WebDAV** is defined in RFC 4918 by a working group of the Internet Engineering Task Force.

简单点来说WebDAV仅是一个扩展的HTTP协议，允许客户端授权并远程访问和修改服务端的内容。这正是我们所需要的功能。

2019年的各大网盘服务提供商中，支持WebDAV协议仅有[坚果云](https://www.jianguoyun.com/)和[Dropbox](https://www.dropbox.com/)两家，后者由于众所周知的原因，本文仅讨论前者。

坚果云的官网为：[https://www.jianguoyun.com](https://www.jianguoyun.com/)，注册并登陆后，通过下面如下的步骤，添加一个授权的应用密码

![WebDAV](https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9460.jpg)

然后创建你喜欢的路径，并将刚刚得到的两份文件上传到坚果云中，文件路径和文件名都可以自定义

![jianguo_file](https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9461.jpg)

顺带一提，坚果云的免费版本每个月限制上传和下载流量，如图片左下角显示，但如果你看我实际的数据库大小其实也只有几kb（当然如果你要用keepass存储大文件当我没说），所以我认为流量是完全不用担心的，而且由于服务器在国内且没有限制可以跑满带宽，作为常用云存储也不错。

### 密码易用

如果仅仅保证安全不考虑方便使用，我觉得也是很痛苦的一件事情。**所以该章节要介绍的就是如何提高易用性。**

之所以引入WebDAV，就是希望我们的数据库存储在云端，可以通过客户端随时访问并新增新密码，但又可以多平台同步。

#### Windows官方客户端KeePass

在windows下面的话使用官方的客户端是比较好的选择。有下面的参数你是需要注意的：

- URL：这个URL是根据坚果云提供的服务器地址+你存储数据库的相对路径而来的，对比这图和上面的两幅图你就能发现规律了
- User name：就是上上图中的账号
- Password：注意这个并不是你登陆坚果云的密码，而是上上图中的显示密码里面的密码
- Remember：这个看你的喜好，我在我常用电脑上都是选择记住的，这样每次打开就只需要输入Master Password即可
- Master Password：根据自己设定的密码填写即可
- Key File：保存在本地的密钥文件路径

填好这5个参数后你就可以直接打开远端的数据库了，每次编辑完之后记得点保存就好，它就会同步到远端的数据库了~

![Keepass](https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9462.jpg)

#### Web客户端Tusk

介绍链接：[https://subdavis.com/Tusk/](https://subdavis.com/Tusk/)，支持Chrome和Firefox，也是支持WebDAV的，非常棒(๑•̀ㅂ•́)و✧，不过我自己没有需求没用过就不截图了。

####iOS客户端Fantasy Pass

好了，接下来就到这篇的其中一个重点了！我尝试过官方推荐下载列表中的多个iOS平台的客户端，并没有一个是支持WebDAV协议的，这意味着我将不能跟远端的数据库双向同步。但是，在2019年我很幸运地在V2EX上面发现了一款新应用[FantasyPass](http://www.fantasypass.cn)，首先也是引用一下它的官方简介：

> 一个功能强大、便捷的Keepass的IOS客户端。
>
> 简介的UI和流畅的动画，支持多密码文件、自动填充、附件添加和查看、JS自定义功能、常用通知栏插件和自定义键盘。让一切尽可能的奇幻!

这款应用应该也是在2019年才上线的，而我也算是它的早期用户了，加入了官方的QQ群讨论。开发者是利用自己的业余时间独立开发的这款应用，也很积极听取用户的各种反馈。由于是业余时间独立开发，因此各种东西包括官网也还在建设中，所以介绍会略显不足。

但是没关系，我来总结一下现有的一些优秀的功能：

- 精美的UI设计，对刘海屏和2018版iPad Pro均有适配，常见网站的图标支持
- 多种云平台同步，包括但不限于WebDAV，iCloud，Onedrive，Dropbox，GoogleDrive
- 支持iOS12的AutoFill功能
- 支持FaceID和TouchID
- 支持附件的预览
- 支持备份通讯录

上述的每一个功能，我认为都是优胜于官方下载页面推荐的iOS客户端miniKeepass的。作为日常稳定使用的app，是完全没有问题的。使用上只要明白了上面的5个参数，那么这个app的使用也不会遇到什么问题就不再赘述了。

![fantasypass](https://image.wsine.top/001cbe85e3702d136293e4e2df25b9f9463.jpg)

目前在App Store中的售价为一次性买断制12元，我认为这个app还是非常值得的。

下载链接：[https://apps.apple.com/cn/app/fantasypass-ikeepass/id1357961740](https://apps.apple.com/cn/app/fantasypass-ikeepass/id1357961740)

## 后记

以上，就是我目前使用的密码管理方案了，免费，易用又安全。美中不足的可能在于生成密码这一步没有办法完美集成在别人开发的软件中，但是fantasypass有计划实现js extension，目前对我自己的使用来说也很知足了。

都2019年了，何不找个时间试试更新一下自己的密码管理策略呢？

