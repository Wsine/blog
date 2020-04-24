# Debian系统下实现通过wpa_config连接WPA-PSK加密的Wifi连接

> 文章参考：[BASST | BLOG : Setting up Wifi - Debian Wheezy](http://www.basst.nl/?p=624)

### 预环境

Debian系的Linux系统
一般当代的Debian系的Linux都自带了wap_config工具

我的测试平台：树莓派2，Udoo板子
使用的是官方系统

### 配置过程

**配置网络参数**

`sudo nano /etc/wpa.conf`

将以下内容填入到该文件中

```
network={
	ssid="YOUR SSID"
	proto=RSN
	key_mgmt=WPA-PSK
	pairwise=CCMP TKIP
	group=CCMP TKIP
	psk="YOUR WPA PASSWORD"
}
```

注意：引号内容替换为自己的Wifi网络环境，引号保留

**配置网络接口**

`sudo nano /etc/network/interfaces`

将以下内容填入到该文件中

```
auto lo

iface lo inet loopback
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa.conf
```

**重启网络**

`sudo /etc/init.d/networking restart`