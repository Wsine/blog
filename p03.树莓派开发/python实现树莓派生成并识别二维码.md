# python实现树莓派生成并识别二维码

参考来源：http://blog.csdn.net/Burgess_Liu/article/details/40397803

### 设备及环境

- 树莓派2代
- 官方系统Raspbian
- 官方树莓派摄像头模块

### 设备连接

摄像头模块插入到距离网卡口最近的那个接口，板上有Camera的字样，看清楚正反面。

### 启用摄像头

1. `sudo raspi-config`
2. 选项：Camera
3. 选项：Enable
4. 选项：Finish
5. 选项：Reboot

### 关键代码

安装依赖环境：

```
sudo apt-get install python-imaging
sudo apt-get install zbar-tools
sudo apt-get install qrencode
sudo apt-get install python-pygame
```

python代码：

qrcode.py

```
#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import os, signal, subprocess

strfile1 = "qrcode"

def erzeugen():
    text=raw_input(u"enter text QRCode: ")
    os.system("qrencode -o "+strfile1+".png '"+text+"'")
    print u"QRCode in: "+strfile1+".png"
    
def lesen():
    os.system("raspistill -w 320 -h 240 -o /home/pi/cameraqr/image.jpg")
    print u"raspistill finished"
    #zbarcam=subprocess.Popen("zbarcam --raw --nodisplay /dev/video0", stdout=subprocess.PIPE, shell=True, preexec_fn=os.setsid)
    #print u"zbarcam started successfully..."
    #qrcodetext=zbarcam.stdout.readline()
    zbarcam=subprocess.Popen("zbarimg --raw /home/pi/cameraqr/image.jpg", stdout=subprocess.PIPE, shell=True, preexec_fn=os.setsid)
    qrcodetext=zbarcam.stdout.readline()
    if qrcodetext!="":
        print qrcodetext
    else:
        print u"qrcodetext is empty"
        
    #os.killpg(zbarcam.pid, signal.SIGTERM)
    print u"zbarcam stopped successfully..."
    return u"QRCode:  "+qrcodetext

```

main.py

```
#!/usr/bin/env python
#-*- coding: UTF-8 -*-

import qrcode

while (True):
    print u"1: qrcode create"
    print u"2: qrcode identify"
    print u"3: exit"
    select=int(raw_input(u"please choose: "))
    if select == 1:
        qrcode.erzeugen()
    elif select == 2:
        result=qrcode.lesen().strip()
        print result
    elif select == 3:
        print u"programme completed..."
        break

```

### 使用方法

选项1：生成文本二维码，输入文本回车即可，路径在当前路径，文件名: qrcode.png

选项2：识别二维码：摄像头对准二维码即可（无法识别的提示，请摆准摄像头再次运行选项2）