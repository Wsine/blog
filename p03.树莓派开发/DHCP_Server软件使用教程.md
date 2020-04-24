# DHCP Server软件使用教程

### 前提网络环境配置

1. 电脑连接上wifi
2. 网络和共享中心中更改适配器，共享无线网卡给以太网网卡
3. 手动设置以太网网卡ipv4地址为192.168.1.1，子网掩码为255.255.255.0

### 正文（基本为图片）

首先以管理员权限打开 dhcpwiz.exe 这个软件

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image418.png)

这里以太网的IP-Adress应显示为上面配置的192.168.1.1

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image419.png)

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image420.png)

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image421.png)

这里点击一下Write INI file再下一步

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image422.png)

这里依次点击Configure->Install-> Start，勾选Run DHCP server immediatly，如下图显示，点击完成

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image423.png)

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image424.png)

这是选择Continue as tray app，然后DHCP服务启动，右下角任务栏有图标显示

接着树莓派上电开机进入系统（耐心等一会儿，开机要时间），然后用网线连接树莓派和电脑（多试几次，知道为什么要完全开机了没）

然后你会看到这个显示（这是Win10界面，不同的系统不同，就是一个系统通知

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image425.png)

上图就是ip地址了

然后用Putty软件进入即可

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image426.png)

### 后记

不使用DHCP Server之前记得关掉，然后恢复适配器的修改，不然作大死喔（笑脸