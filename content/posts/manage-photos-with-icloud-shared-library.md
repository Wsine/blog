---
title: "以 iCloud 共享图库为基础，打造我的照片管理工作流"
date: 2022-11-23
---

# 以 iCloud 共享图库为基础，打造我的照片管理工作流

这篇文章主要来聊聊 iOS 16.1 后我的照片管理工作流的一些变化，我觉得 iCloud 图库的易用性得到了空前的提升，因此特此来分享一下它解决我的哪些痛点，同时也为不少还在观望的同学扫除一下迷雾。

先说一下背景，我日常的主要拍照场景还是和女朋友一起出去游玩的时候用相机拍照。对于照片管理最大的需求就是易于导入 iCloud，且易于分享给对象。但不要小看这个简单的场景，在 iOS 16.1 之前的工作流还是有很多的妥协。

### 导入照片到苹果设备

众所周知，iOS / iPadOS 的设备都没有真正的跨 app 通用文件系统，因此很多人会先入为主地认为如果要导入照片到苹果设备的图库中，如果没有 mac 电脑操作起来会很困难。但其实不然。在 iOS 12 的版本之后苹果公司给照片 app 增加了「导入」的功能，这个功能可以让其直接读取外接设备，然后扫描其中的照片，等待用户的筛选和导入。

我使用的苹果设备主要是 iPad Pro 2018 ，因此很幸运地获得了一个极为先进的 type-C 接口，这给我的操作带来了不少地便利。由于相机主要是将照片存储在 SD 卡中，因此我们需要一个 SD 卡的读卡器。我日常使用的是绿联的 type-A 和 type-C 双接口的读卡器。假如你的 iPad 没有 type-C 接口，使用 lightening 转 USB 的转换器也是可以的。

![](https://image.wsine.top/73381f126a067d0f82dadf615f608c38.png)

「导入」功能以设备为划分依据且提供了简单的按照片的日期分组排序的功能，而这恰巧也是我们出去游玩的时候分组的重要依据。「导入」提供了「导入全部」的功能，它会自动记住哪些照片之前已经被导入到照片 app 了，哪怕你又把那些照片删除了。

由于我使用的是富士相机，偶尔会有一些测试滤镜用的废片，因此我一般不用这个导入全部的功能。我会按日期手动选择那一天的照片，然后新建一个「相簿」，直接将选择的照片导入到新建的相簿。这样，从相机到 iCloud 图库到过程就完成了。

![](https://image.wsine.top/724e8eaa757738c68ab0a107ddd16603.png)

### 完善照片的 Exif 信息

对于单张的照片管理，我们最关心的是照片的 Exif 信息，Exif 信息越是完整，我们搜索/筛选/分组照片就更是得心应手。对于相机拍摄的照片，一般情况下只有相机相关的信息，例如相机型号、镜头型号、光圈快门 ISO 这类信息。对于比较新的相机机型，也会有相对一定的时间信息，但由于更换电池等操作且没有联网同步时间的功能，实际记录下来的时间并不一定是准确的。

但是好在照片 app 都提供了批量更新的操作来修改照片的 Exif 信息。

![](https://image.wsine.top/36c302b30f07f0060cfeb6933f213e59.png)

关于拍摄地点的更新，我一般采用一个「相簿」一个地点的方式来管理，这也很贴合日常的出门游玩拍照的场景。在照片 app 中，只需要在相簿中全部选择照片，选择三个点调出菜单，然后选择「调整地点」就可以搜索地点并批量更新到该相簿的所有照片中了，十分方便。

![](https://image.wsine.top/7d6453afd20cd943c78d5e1e4f623d60.png)

而更新拍摄时间的话就稍微需要一丢丢的小技巧。我们知道相机记录的拍摄时间不一定是准确的，但是相机记录的照片之间的相对时间是准确的。那么该技巧就很显而易见了，只需要在到达游玩地点后习惯性地拍摄一张手机屏幕包含具体详细时间的照片即可。

![](https://image.wsine.top/f470c1c30b1dfacf2af6839e8465f827.png)

当回到住所准备更新拍摄时间的时候，将该时间照片也收纳到该地点的相簿中，然后就可以调整拍摄时间为照片中的具体详细时间了。照片 app 中的调整逻辑为只显示第一张照片的时间，调整第一张照片的拍摄时间会相对地一起调整批量选择的照片的拍摄时间。这样操作后，所有的拍摄时间都变得准确无误了。

### 加入相簿到共享图库

在加入共享图库之前，首先需要创建一个共享图库。该选项在设置 app 的照片选项中，打开 iCloud 照片选项，然后就能发现下面出现了共享图库的选项了，由一个人创建然后通过 iMessage 邀请另一个人加入即可。一个人只能同时加入一个共享图库。

![](https://image.wsine.top/ec6bdc6101b73f1f54861e621dd06f0d.png)

在前面的步骤中，照片们都已经整整齐齐地在不同的本地相簿中分类好了。在这一步中其实就很简单，全选相簿的照片然后选择「移动到共享图库」。这样子，只需要等在 WiFi 环境下设备自动同步照片到 iCloud 中就好了，然后在对象的手机中也能看到同一份照片。

![](https://image.wsine.top/6d024f4445a1de80870c090f5f5c6b60.png)

但是使用「共享图库」相比之前使用「共享相簿」有什么优缺点呢？

第一点我觉得最重要的就是「同一份照片」。之前使用共享相簿的时候，还需要多一步操作就是创建一个共享相簿并拷贝照片到共享相簿中然后再分享该相簿到对象的 iCloud 账号，光是听起来就是很冗余的操作。现在使用了共享图库，我可以一键移动，甚至在导入的时候就可以选择共享图库为导入的目的地。而共享相簿就可以回到了它原本设计的初衷，在三五好友一起约着出去玩的时候，创建一个共享相簿大家都把需要共享的照片上传到该相簿，大家各自挑选自己想要的拷贝到自己的 iCloud 图库中。

而由于使用共享图库实打实地消耗了 iCloud 的空间，苹果公司就没有理由压缩照片的画质了。这给后期修图提供了更丰富的空间，毕竟对着一张压缩的照片，无论是修图还是分享总是会觉得差了一点意思。而现在使用共享图库就没有这样的问题。

至于缺点我认为无法共享每个相簿的分类信息是我觉得不太满意的一点。在共享图库中，图库是共享的，但图库中的相簿分类不是，一个人明明已经都分类好了，在另一个人的设备中却还要在分类一遍，不太合理。幸好的是 Exif 信息是共享的，因此筛选照片二次创建相簿也不是那么困难。

### 不同出发点的修图逻辑

由于共享图库中的照片都是同一张照片，因此如果 A 对照片进行了修图，则 B 也可以共享得到修好的图片，且可以二次加工。在这之前只通过共享相簿的话是不可实现的。

在我和女朋友的修图角度来说，大家的侧重点非常不一样的。对于我来说，我更关注后期构图和调色，因此我会优先使用照片 app 中自带的功能进行简单的修图。对于照片的裁剪，照片 app 提供了常见的图片比例，可以很方便地套用，并同时调整照片的角度偏移。

![](https://image.wsine.top/2bbf39fd26dad48a90bfe67cf495a8d9.png)

调色的话，照片 app 也有基础的功能，对于常见的曝光对比度等参数化的，可以直接在照片 app 中修改。更重要的是它还有一个 AI 加持的「自动」的参数选项，对于不太会调色但想让照片更加风格化的用户来说也是很棒的功能。

如果需要进一步修图，一般情况下我们需要使用更强大的 app。在之前使用共享相簿的时候，第三方 app 无法读取共享相簿中的照片，因此就无法修改了，这迫使我们得先下载一份到本地图库，修改好再替换，抑或是修图完再上传共享相簿，十分麻烦。

![](https://image.wsine.top/b00f1e45050915d1571c913dc58c4b91.png)

使用共享图库后，所有的第三方 app 都能如常访问照片，只要授权了照片权限，就和访问本地图库一样。因此，在我的日常进阶修图，我可以打开「Pixelmator Photo」应用然后直接打开一张照片进行编辑，编辑完成后可以直接覆盖原来的图片，十分方便。一般情况下，我会用 Pixelmator Photo 来进行去除游客和调整色阶曲线之类的，这个应用能够用 AI 帮助你调整到一个较好的初始值，自己再进行微调，非常推荐~

![](https://image.wsine.top/9270a6da5c8f5ba3d96fb3f4491297ce.png)

从我女朋友出发的修图逻辑和我基本上完全不一样的，就是美图秀秀你懂吧。日常的拍照会有很多怼脸照、全身照、半身照呀这种个人照或者合照，基本上我都没有「权利」去修（因为无论怎么努力都不好看=。=）。现在有了共享图库，我们都可以从这种小争吵中解放出来，各司其职，其乐融融。

最后，千辛万苦修图完毕，肯定是要和家人朋友分享分享的，和之前所说使用共享图库可以以完整的画质分享照片，而共享相簿的话获取到的照片画质是会压缩的。虽然分享到微信的时候会被压缩得很厉害，但是分享到其它在线社交平台就可以很明显地感受到差异。

### 总结

共享图库的便利性极大地改变了我之前的照片管理工作流，从上面的展示中可以看到共享图库带来的利远大于弊，因此，我还是十分推荐在用共享相簿的朋友们去尝试一下转移到共享图库的，希望上述的展示能给你扫除一下迷雾，以上。
