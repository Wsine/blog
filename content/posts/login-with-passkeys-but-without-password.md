---
title: "无密码认证的新方式之通行密钥"
date: 2022-06-22
---

# 无密码认证的新方式 —— 通行密钥

记忆密码总是一件痛苦的事情，对于绝大多数不使用密码管理器的人来说「一个密码走天下」是密码问题上最佳的解决方案了。但一个密码到处用总会带来各式各样的安全问题，比如：这个密码因为其他问题导致了外泄，那么所有的账户都会受到威胁。

为了解决这个情况，日常登录网站和应用程序要你两步验证，比如 SMS 短信验证码、邮箱验证码或是基于时间的一次性密钥等方式加强安全性。从我们日常使用来看，等验证码这个步骤反而可能是整个登陆流程里最麻烦的一件事。

Apple 在 WWDC 2022 中向开发者介绍了「通行密钥（Passkeys） 」这项新的「希望可以替代密码」的新技术，并期望通过这项新技术来解决上面的问题。

看到这里，你可能会担心 Apple 的新技术别的互联网公司可能并不会采纳。但事实上通行密钥是通用技术标准 WebAuthn 下的一个关键技术，不仅可以简化登录的流程，还可以提高安全性和增加跨设备授权登录的功能。只不过 Apple 在今年 WWDC 上高调地宣布了而已，微软、Google 等大公司也已经[宣布](https://fidoalliance.org/apple-google-and-microsoft-commit-to-expanded-support-for-fido-standard-to-accelerate-availability-of-passwordless-sign-ins/)将支持这项 FIDO Standard 技术标准。

那通行密钥是如何替代密码进行身份验证的，Passkeys 能完全取代你的密码吗？本篇文章就来带领大家一探究竟。

## 通行密钥是如何工作的？

目前完整支持通行密钥的应用程序还不多，但我们可以从 WWDC 后续面向开发者的视频中窥探到通行密钥的使用方式。登录界面中只需要用户提供用户名（User name）这一信息，然后点击登录按钮，最后完成生物认证便能完成登录。使用通行密钥整个过程，就和我们目前使用 iCloud 钥匙串或是支持自动填充的密码管理器一样自然、直观。

![passkey_login](https://image.wsine.top/a356411cd47c21a1e85c12da2cae4e18.gif)

在传统登录环节中由短信验证码、两步验证器所扮演的身份验证功能，也将由通行密钥代劳；尽管 通行密钥和登录密码的功能存在差异，但在整个注册和登录的过程中无需我们主动创建、记忆或输入密码。这种一键登录、几乎不会增加学习和使用成本的身份验证机制，显然也要比我们现阶段主要使用的大部分身份验证方式更加无感。

### 用非对称加密证明「你是你」

不过通行密钥并不是什么新鲜的玩意，它其实是密码学中「非对称加密」在登录认证中的一种应用。

单个通行密钥由一对密钥组成，分别是**公钥（Public key）**和**私钥（Private key）**。

我们可以把公钥类比于带「防盗」锁的传统信箱，把私钥类比于信箱的锁的钥匙。邮递员投递的信件就是我们要加密的信息，通过投递到信箱中加密起来，然后也只有信箱的主人才有钥匙能够打开信箱读取信件的内容。如果一个人手上没有钥匙，那就需要用暴力开防盗锁，整个过程不仅耗时耗力，最后也往往没办法打开那把防盗锁。

与之对应的，如果某些内容被公钥加密了，则该内容能且仅能被私钥解密，非对称加密的可靠性正来源于此——若无私钥，在有限的算力和有限的时间内我们一般无法完成极大整数的因数分解；如果加密内容能被解密，则说明对方拥有私钥。

非对称加密的这种唯一对应性，显然是非常适合用于登录认证的。

![image-20220624203244877](https://image.wsine.top/19aebc7df494f17132f0381d9db01759.png)

以 WWDC 中的例子进一步展开说明，在用户完成第一次登录以后，服务端和用户终端分别持有由用户终端生成的公钥和私钥。如果这时用户再需要登录，用户将用户名发送给服务器以后，服务器用用户名对应的公钥创建一个「口令（challenge）」发送给用户终端，放到上面的例子里就是邮件投递到了用户的传统信箱里；用户这时可以使用私钥解答该「口令」并将对应的「答案（solution）」再发送给服务端，放到上面的例子里就是用户取出了这份邮件并根据这份邮件给发信人返回了一个正确的信件。如此，服务端便能通过比对答案是否正确从而验证终端是否为公钥的主人了。当然，上述的通讯过程都是通过 HTTPS 加密的。

所以这也是为什么**通行密钥可以替代各种形式的验证码进行身份验证**。



### 服务端如何获得用户的公钥？

细心的同学可能会疑惑，上述过程中的假设是如何成立的？换句话说，服务端最初是如何获得公钥并与我们手里的私钥产生对应关系的？

目前，从 WWDC 的视频和 Google 开发者文档中的信息来看，我们需要先行通过传统的密码方式注册一个账号，然后再绑定通行密钥到该账号中。

![passkey_setting](https://image.wsine.top/3b17f00cd7f523ce51526f58e67bf3c7.gif)

在完成用密码的登录过程后，账户设置里面会有选项添加通行密钥，且通行密钥完全由用户终端生成、需要经过终端的生物认证，然后公钥上传到服务端，私钥保存在钥匙串里。这样就完成了用户名和通行密钥信息的绑定。

这里打个不完全正确的比喻，和前面所说的一样公钥是传统邮箱的话，我们要向邮政公司提前登记「这个邮箱属于你」，提前登记的过程就是使用传统密码注册账户的过程。

## 通行密钥还有什么优点？

作为一种用于用户身份认证的替代方案，通行密钥最直接的应用场景显然就是跨设备登录了。

上图就是很贴近生活的一个例子，在这类场景中，我们以往一般需要通过短信验证码或两步认证来确认登录者身份，国内比较常见的例子就是：微信登录电脑端时，需要通过已登录的手机进行扫码来完成身份验证。

![image-20220624203452206](https://image.wsine.top/981cdf4ace2d63787af2dd66701a5e7c.png)

而在通行密钥的应用场景中，当用户打算在一个陌生电脑上临时登录自己的账号的时候，也是可以通过手机扫码来安全地授权完成认证登录的。

同样是扫码行为，通行密钥不同的地方在于它可以脱离对具体服务端、客户端的依赖，变成一种纯粹的身份认证工具。因为它本质上是 FIDO 对通行密钥的扩展——客户端到认证器协议规范（Client to Authenticator Protocol，CTAP），也就是外部认证器通过中继网络（Relay Network）向用户的互联网接入设备局部传递认证证书——**我们需要做的，就是通过设备上的生物信息验证机制将 Passkeys 认证结果传递给其他设备。**

![image-20220624203521182](https://image.wsine.top/85ad404bc6e7ce1fef8beff3f843b254.png)

通行密钥的扫码操作的背后，一般则会将手机作为认证器与电脑通过 USB、NFC 或蓝牙等方式进行通讯。具体而言，电脑端会根据 FIDO 的协议生成一个随机字符串并编码为二维码展示，然后手机扫码该二维码获取该随机字符串（key input）并作为对称加密密钥，并建立一个近距离通讯的网络发布，电脑端使用相同的字符串连接上该网络。如此，手机和电脑便能安全地互相通讯。

电脑需要验证时，可以先将口令安全地传递到手机上，再在手机上用私钥解答出有关的答案，最后再将答案安全地传回电脑端，并由电脑端和服务器进行通讯完成上述的认证登录过程。

除了跨设备登录，通行密钥也将为传统的登录验证流程带来额外的安全性保障。

一方面，任何基于物理设备生成的身份验证手段，在设备被盗或丢失后，都将面临密码泄露的风险，但通行密钥要求每次访问私钥的时候都经过设备的生物认证，安全性相对更好。且一个账号可以绑定多个设备的通行密钥，设备丢失后还可以在服务端删除对应的通行密钥以进一步加强安全性。

另一方面，钓鱼网站攻击主要依靠伪装目标网站的方式来骗取用户主动输入账号密码。通行密钥方案的原理则决定了钓鱼网站首先需要拥有用户的公钥——我们在上面已经提到，公钥从生成开始便储存在目标网站的服务器上，除非这些钓鱼网站直接攻破这些网站的服务器，否则无从获取公钥，但如果真的可以攻破服务器为什么又要采用钓鱼手段呢；另外，在通行密钥的认证流程中，我们也从来不需要向任何人发送自己的私钥，仅通过二维码等近场通信手段交换答案，这两点可以在很大程度上阻止当前钓鱼网站的攻击。

## 通行密钥有什么潜在不足？

通过上面的介绍，我们也不难看出通行密钥的不足——它并不能像某些网络报道中所宣称的那样，完全取代你的密码。

在通行密钥的设计中，服务器需要用户先行使用密码创建一个账号，然后才能将用户的公钥绑定到该账号上，当设备损坏或丢失时，密码依然是通行密钥的容灾策略。这一点可以在 Xbox [帮助文档](https://support.xbox.com/zh-CN/help/family-online-safety/passkey-guest-key/create-and-manage-xbox-one-passkey)中「忘记密钥」的部分得到体现。

同时，通行密钥私钥的同步和迁移也存在成本，毕竟我们总有更换设备的那天。而在 FIDO 和 W3C 的标准中，都没有描述当用户打算更换平台的时候如何迁移通行密钥的私钥，比如如何从 Apple 设备换到 Android 设备。当我们保存在手机的密钥数量不断增多，需要在新手机上重新绑定新的公钥也会花费大量的时间。如果操作系统服务商不开放相关权限给第三方服务，那迁移成本肯定不小。

最后则是密码遗忘问题。由于通行密钥本身极大的便利性，人们会很容易使用并依赖它。但别忘记，通行密钥无法完全替代密码本身。年轻人或许能学会使用密码管理器，但是长辈们可能会由于长期没有间歇性使用密码便完全忘记了当初设定的密码，通行密钥的普及将会放大这一现象。



通行密钥很好地解决了记密码的难题，从 Apple 实现的方式上而言也很优雅；虽然目前仍有一些机制上的不足，但随着这项技术的完善还是可以解决的，毕竟谁又能不喜欢一个「无密码」的世界呢。最后，关于通行密钥这项技术你还有什么想讨论的也欢迎在评论区进行讨论。