# Openwrt无线中继设置并访问外网

> 本篇博文参考来自：http://blog.csdn.net/pifangsione/article/details/13162023

### 配置目标

1. 主路由器使用AP模式发射Wifi
2. 从路由器使用Client模式接受Wifi
3. 从路由器使用Master模式发射Wifi
4. 连入从路由器的设备也能访问外网
5. 只需要设置从路由器即可

### 配置环境

1. 主路由器已经能够访问外网
2. 从路由器的内部系统是Openwrt

（从界面显示来说我已经配置成功了）

### 配置步骤

**设置从路由器LAN口**

设置从路由器的LAN口所在的IP网段，只要和主路由器所在网段不一样就可以了

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image427.png)

**设置被桥接路由器**

设置从路由器加入到主路由器所在的网络，并设置该网络为从路由器的WAN网络，这里WPA密钥为主路由器的Wifi密码，新网络的名称只要自己记得就好，我这里使用了Openwrt默认给的wwan

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image428.png)
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image429.png)
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image430.png)

设置接口配置，信道为主路由器发送AP所在的信道，ESSID为主路由器发送AP的ssid，选择模式为客户端Client，BSSID为主路由器的bssid，网络的选择上面是刚才设置的wwan。这里Openwrt会根据主路由器的信息自动帮你填充，一般来说不用自己填多少内容。

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image431.png)
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image432.png)

当回到总览界面，看到wwan接口那里获取到IPv4地址的时候，就说明接口的配置已经成功了

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image433.png)

**设置无线网络**

从路由器发送AP，添加一个网络。信道一般会锁定为主路由器的信道了，ESSID请自己自定义一个名称就好，模式用接入点AP，网络选择LAN接口，无线安全选项卡里面可以给这个Wifi加密。
注意：如果从路由器的ESSID设置为和主路由器ssid一致，从路由器的密码设置为和主路由器一致，可以做到在两个路由器间无缝漫游。

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image434.png)
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image435.png)

**检查无线配置**

最后的配置效果应该如图所示，Enjoy your network。

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image436.png)