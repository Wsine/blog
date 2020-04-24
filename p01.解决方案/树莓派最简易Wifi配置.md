# 树莓派最简易Wifi配置

相信我，连博客都会偷懒写个最简易给你看

前提，只有一根网线没有网络的前提下进行的。
基于Win10系统和树莓派2015-05-05-raspbian-wheezy.img测试。

1. 网线连接电脑和树莓派
2. 树莓派供电启动
3. 修改/etc/wpa_supplicant/wpa_supplicant.conf
    添加内容
```
network={
    ssid="Your Wifi name"
    key_mgmt=WPA-PSK
    psk="Your Wifi password"
}
```
4. 关机收工

最终效果：
动态ip连接到自己的AP。

PS（还是想废话一点）
无线网卡我选用的是树莓派系统免驱的
只要我没涉及到的内容就是原生的设置