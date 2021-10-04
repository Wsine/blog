---
title: "使用 Airtable 构建个人单词本"
date: 2021-05-02
published: true
tags: ['Lexicon', 'Solution']
series: false
canonical_url: false
---


词到用时方恨少，这句话说的就是第一次写论文的时候的我。口语表达需要用到的词，真的比书面表达的词少很多。但是，在平时的论文阅读的过程中，总能发现一些「陌生词」，而这些陌生词往往用得非常的巧妙，在英语语境中，是更能precisely 地表达语义。我就是一直在思考这个问题，如何才能收藏起来以便以后为我所用呢？

本文就是提出这么一个免费的解决方案，来帮助我们摘抄陌生词，形成自己的词典，并能方便地查看和温故。当然，我们的目标还是希望能够多平台覆盖和同步的，不然实用意义就变少了。

## Airtable as a Database

首先要解决的第一个问题，就是如何把想要的单词摘抄并存储起来。这里，很多的单词翻译软件都有自己的单词本功能，但是同步功能基本上都是付费的功能。对我这种低频使用者而言，不太实惠。

我考虑了使用在线表格作为后端的存储，Airtable 就是这个领域的佼佼者了，并且它提供的基于 HTTP 的 API 接口方便和其他的软件交互完成存储和访问，就非常地符合我们的需求。

你需要做的准备有以下的几点：

1. 准备一个 Airtable 的账户，新建一个 Table，并将主 sheet 命名为 Main
2. 根据以下的 scheme 建立表头

```
# Name - Field Type
Query - Long text
Translation - Single line text
isWord - Check box
Explains - Long text
US-Phonetic - Single line text
UK-Phonetic - Single line text
Count - Number - Integer
```

3. 最后，你需要获取 Airtable 相关的 API Token。

访问 https://airtable.com/api，点击对应的 Table，选择左侧的 AUTHENTICATION，点击右上角的 show API key，你就能找到对应的 `<your table id>` 和 `<your app token>`。

![image-20210418170007299](https://image.wsine.top/be43f6cae2b8bfe861c079839a5e484f.png)

4. (可选) 在 Airtable 里增加 Gallery View，制作你自己的单词卡片，点击 Share View 可获取访问链接

## Youdao as a Translator

当选择了「陌生词」后，我们需要做的是存储它原词的同时，存储其对应的中文翻译。当然，这个版本也可以离线完成，通过 Airtable Automation 或者 Serverless Function 可以做到。但是前者需要付费订阅 Pro，后者使得平台更复杂化了。后来实际考虑，其实这个也放在本地完成就是可以的，从某种程度上来说也更简单一些。

首先，要做的获取有道智云 AI 开放平台的接口密钥。你需要访问：https://ai.youdao.com/doc.s#guide ，根据上述的指南注册开发者账号并获取密钥，上述官方有详细的图解步骤，我在这里就不重复了。关于价格，有道云文本翻译服务是48元/百万字符，每月调用量清零。换句话说，每月100万字符以下翻译免费，对于我们翻译几个单词来说，实在是绰绰有余。更详细的价格可以参考[官方定价文档](https://ai.youdao.com/DOCSIRMA/html/自然语言翻译/产品定价/文本翻译服务/文本翻译服务-产品定价.html)。

最终你获得的有两个关键的字符串：`<your app key>` and `your app scret`, 这里的 app 指的是有道智云 AI 开放平台上面的一个实例。

![image-20210418163029079](https://image.wsine.top/4a795606d3a43f92ce84c18e620967ed.png)

## JSBox as a Client

好了，万事俱备，只欠东风。接下来，就是通过 HTTP 接口，把「陌生词」存储到 Airtable 中。

这里，由于选择了本地调用有道云的接口，因此需要比较复杂的 JS 代码才能构建出 API 访问的参数，否则其实可以使用更轻量级的 捷径app 来完成这样的动作的。所以，我终于不得不选择 JSBox 作为 Client 调用接口。对于读者来说的好消息是，JSBox 免费下载且 1.x 版本的功能免费且我们只需要用到 1.x 版本的功能。对于我来说，我开发这个 workflow 专门买了JSBox，—_—

关于调用的代码，我已经全部开源并放到这个 [Gist](https://gist.github.com/Wsine/4d68c4c0a06cc9219a79fc9d169b07ab) 里面了，文末我也放置了一份相同的作为附录，以便不方便访问 Gist 的读者们访问。

在 JSBox 里面，选择 New Project，名称可以自定义，Type 选择 JSBox script 即可，把开源的代码粘贴到里面，并替换其中的对应的密钥即可。

```
<your app key> -> 你的有道云应用ID
<your app secret> -> 你的有道云应用密钥
<your table id> -> 你的Airtable的表格ID
<your app token> -> 你的Airtable的API Token
```

为了在调用菜单里简化一级跳转逻辑，我们还需要借助 捷径APP 调用 JSBox

![IMG_67ECF7225B1E-1](https://image.wsine.top/4b9f5491dfbe2b491043598ba06d2a4f.jpeg)

## Workflow Demo

由于我阅读论文的设备是 iPad，因此这里用 iPad 做个演示。在你喜欢的论文阅读软件中选中相应的单词/短语，通过系统分享菜单选择对应的捷径。

![ezgif-3-a15650ace542](https://image.wsine.top/73fbf90a6725cf9bb97918582be0d916.gif)

对应的 Gallery View 的单词卡效果是这样子的，而且对响应式网站有适配，写论文的时候它给了我很大的帮助。

![image-20210418173436005](https://image.wsine.top/2f2fd4042d29293dd78df86a9653b11c.png)

理论上，这个 worflow 也支持句子摘抄和翻译，新增一个 Gallery View 和 Filtering 就可以，只不过我没有这个需求而已。



好了，以上就是全部的内容。感谢阅读。



## 附录

[**lexicon.js**](https://gist.github.com/Wsine/4d68c4c0a06cc9219a79fc9d169b07ab#file-lexicon-js)

```js
const CryptoJS = require("crypto-js")

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

var entrance = null
var query = null
if ($context.text) {
  query = $context.text
  entrance = 'jsbox'
} else if (Object.keys($context.query).length) {
  query = $context.query.word
  entrance = 'shortcut'
} else {
  console.log('Please execute via share sheet')
  $context.close()
  $app.close()
}
console.log('query', query)

const appkey = '<your app key>'
const salt = uuidv4()
console.log('salt:', salt)
const curtime = (Math.round(new Date().getTime() / 1000)).toString()
console.log('curtime:', curtime)
const appsecret = '<your app secret>'
var input = query
if (query && query.length > 20) {
  input = query.slice(0, 10) + query.length + query.slice(query.length - 10, query.length)
}
console.log('input:', input)
var concat = appkey + input + salt + curtime + appsecret
console.log('concat:', concat)
const sign = CryptoJS.SHA256(concat).toString()
console.log('sign:', sign)

var formData = {
  q: query,
  from: 'en',
  to: 'zh-CHS',
  appKey: appkey,
  salt: salt,
  sign: sign,
  signType: 'v3',
  curtime: curtime,
  strict: 'true'
}

if (query) {
  $http.post({
    url: "https://openapi.youdao.com/api",
    form: formData,
    handler: function (resp) {
      var ydreq = resp.data
      console.log(ydreq)
      var field = {
        Query: ydreq['query'],
        Translation: ydreq['translation'].join('\n'),
        isWord: ydreq['isWord'],
        Count: 1
      }
      if (ydreq['isWord']) {
        field['Explains'] = ydreq['basic']['explains'].join('\n')
        field['US-Phonetic'] = ydreq['basic']['us-phonetic']
        field['UK-Phonetic'] = ydreq['basic']['uk-phonetic']
      }
      $http.post({
        url: "https://api.airtable.com/v0/<your table id>/Main",
        header: {
          'Authorization': 'Bearer <your app token>',
          'Content-Type': 'application/json'
        },
        body: {
          records: [{
            fields: field
          }]
        },
        handler: function(resp) {
          var atreq = resp.data
          console.log(atreq)
          var display = 'Created: ' + atreq.records[0].id
          if (entrance === 'shortcut') {
            $intents.finish(display)
          } else if (entrance === 'jsbox') {
            $ui.preview({
              title: "AirTable API Response",
              text: display
            });
          }
        }
      });
    }
  })
}
```


