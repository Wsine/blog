# 智能小车识别图像中的文字

[TOC]

## 运行平台
这次的内容是基于Xilinx公司的Zybo开发板以及其配套的Zrobot套件开发
Zybo上面的sd卡搭载了Ubuntu12.04LTS的linux版本，预装配置了opencv2.4.9和python2.7.3。

## 开发内容
> 注意：以下内容均是两个人在一天之内完成的，略有不足。后续会有修改版。特别声明队友为tt_leader大大。

### java串流stream到网页
由于网页端java的安全机制问题，想要从网页端读取到摄像头的实时内容，需要安装一个java插件，并设置java的安全权限为低（具体搜索显示信息即可得到答案）。这里推荐使用ie浏览器（别打···没写错 是ie···

### 安卓app小车控制器
由于开发时间的局限，因此选择了安卓读取浏览器内容的方式，同时修改样式使其具备控制器的功能。
控制端实现的方式是cgi的action方式。
源代码在最后会有超链接。

### python配置
开发板中的python所需的库是没配置的，因此需要为其配置所需的库。并且，开发板不支持pip和easy_install命令。

由于开发板的系统是嵌入式系统，只能通过命令行的方式进行交互，因此使用SCP协议传输文件。

Windows下可以使用Winscp软件传文件，linux下使用scp命令传文件。
需要对开发板上的系统设置root用户密码。

另外也需要一台ubuntu机器安装python2.7，并能跑通程序。所需的库为requests、urllib2、json。

### OCR光学字符识别
python程序如下：
``` python
import requests,json
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
print sys.getdefaultencoding()

print('\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n')
print('OCR running')
print('-------- -------------------')
print('The programme is to identify the text in the picture')
print('Let us appreciate it')
print('\n\n\n\n\n\n')

header = {
	'Content-type': 'application/json'
}

op1 = {
	'subscription-key': 'your_subscription_key',
	'language':'unk',
	'detectOrientation':'true'
}

op2 = {
	#'Url': 'http://ww2.sinaimg.cn/bmiddle/6a6a6ffdjw1evhnx9hb3ij20hs0np40m.jpg'
	#'Url': 'http://ww3.sinaimg.cn/bmiddle/6a6a6ffdjw1evhlb459dfj20hs0npdha.jpg'
	'Url': 'http://ww4.sinaimg.cn/bmiddle/6a6a6ffdjw1evi6s14no4j20hs0npq43.jpg'
}

r = requests.get('http://api.projectoxford.ai/vision/v1/ocr',params=op1, timeout=15)
myUrl = r.url
r = requests.post(myUrl,data=json.dumps(op2),headers=header, timeout=15)
j = r.json()
for x in j['regions']:
	lines = x['lines']
	for y in lines:
		words = y['words']
		for z in words:
			#g = z['text']
			print z['text'],
			#print z['text'].decode('ascii').encode('utf-8'),
			#print json.dumps(z['text'], encoding='UTF-8', ensure_ascii=False),
			#print z['text'].encoding
			#print unicode(z['text'], encoding='utf-8'),
		print('\n')

```
在程序中，不能实时从摄像头读取内容识别。只能分两步完成，先拍摄图片在云端存储，然后对图像进行文字识别。图像识别方面使用的是微乳的图像库api，需要申请订阅，程序中的your_subscription_key需要修改为自己的订阅。
另外，中文字符输出在嵌入式ubuntu编码中产生问题，桌面版ubuntu无这个问题。程序中试图修复也花了很久的时间，最终无果，留待后期改进。
具体原因是ASCII码不支持中文但嵌入式ubuntu的python编码修改utf8码没有效果。

## 后期改进
python程序修改后如下：

``` python
import requests,json,base64
import cv2

print('OCR...')

header = {
	'Content-type': 'application/octet-stream'
}

op1 = {
	'subscription-key': 'your_subscription_key',
	'language':'unk',
	'detectOrientation':'true'
}

capture = cv2.VideoCapture(0)
frame = capture.read()
Assert frame is not None
cv2.imwrite('/home/xxx/screenshot.jpg', frame)

myData = open('./screenshot.jpg','rb').read()

r = requests.get('https://api.projectoxford.ai/vision/v1/ocr',params=op1, timeout=15)
myUrl = r.url
r = requests.post(myUrl,data=myData,headers=header, timeout=15)
j = r.json()
for x in j['regions']:
	lines = x['lines']
	for y in lines:
		words = y['words']
		for z in words:
			print(z['text'],end="")
		print('\n')
```
另，升级开发板的python2.7为python3即可解决编码问题。
需要手动打开开发板的摄像头。开发板默认配置好opencv2.4.9。
存储路径根据自己情况修改。
由于是后期改进，没有办法在Zybo板子上测试，但在其他平台上面测试通过。

## 传送门
安卓工程[下载](http://pan.baidu.com/s/1dD12SO5)









## 课程后记
我个人接受不了有人一边过来示好一边在展示的时候故意刁难，我可真没办法信守与这种人的承诺。