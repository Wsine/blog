# Ubuntu14.04下中山大学锐捷上网设置

----------
> 打开终端后的初始目录是 ～，Ubuntu安装完毕默认路径，不是的请自行先运行`cd ~`
> 非斜体字命令行方法，斜体字是图形管理方法，二选一即可
> 记得善用Tab键补全命令

### 有线上网设置

- 建立Software文件夹

Ctrl + Alt + T 打开终端，输入`mkdir ~/Software`

*双击桌面主文件夹，右键新建文件夹Software*

- 下载锐捷客户端

Ctrl + Alt + T 打开终端，输入`Wget -P ～/Software/ http://helpdesk.sysu.edu.cn/images/downloads/ruijietest/RG_SU_For_Linux_4_90_Setup1.zip`

*打开网站[中大信息与服务技术中心](http://helpdesk.sysu.edu.cn)，点击下载，找到 Ruijie Supplicant 4.90 认证客户端 Linux 版,点击立即下载*

- 解压文档

Ctrl + Alt + T 打开终端，输入`unzip ～/Software/RG_SU_For_Linux_4_90_Setup1.zip`

*右击压缩包，解压到当前文件夹*

- 写启动脚本

Ctrl + Alt + T 打开终端，输入`gedit`打开文档编辑器，输入以下内容
```
#!/bin/sh
cd ~/Software/rjsupplicant/
chmod +x rjsupplicant.sh
sudo ./rjsupplicant.sh -u your_user_name -p your_password -d 1
```
your_user_name改为你锐捷上网的用户名，your_password改为你锐捷上网的密码
文档命名为 runRG.sh 保存到 Software 文件夹

#### 一键登录锐捷
Ctrl + Alt + T 打开终端，输入`sh ./Software/runRG.sh`
然后输入密码（看不见有输入但其实已经输入了）回车即可成功上网
最小化终端即可，关闭视为退出锐捷登录

### 无线上网设置

##### 登录锐捷同时发射WiFi

- 安装 ap-hotspot

Ctrl + Alt + T 打开终端，输入`sudo apt-get install ap-hotspot`安装 ap-hotspot 软件

- 配置 ap-hotspot

Ctrl + Alt + T 打开终端，输入`sudo ap-hotspot configure`

根据提示设置：
第一步设置网络来源，单有线网卡默认回车即可；
第一步设置使用那个硬件发射WiFi，双无线网卡自己输入wlan0，wlan1自行选择，单无线网卡默认回车即可；
第二步设置WiFi的ssid，即WiFi的名称；
第三步设置WiFi的password，即WiFi的密码；

- 一键发射WiFi

Ctrl + Alt + T 打开终端，输入`sudo ap-hotspot start`

- 一键关闭WiFi

关闭WiFi输入`sudo ap-hotspot stop`

##### 配置 SYSU-SECURE 无线上网

右击右上角网络图标，连接 SYSU-SECURE ，或者编辑连接，找到 SYSU-SECURE
配置参数说明：

- Wi-Fi
SSID：SYSU-SECURE
模式：架构
MTU：自动

- Wi-Fi安全性
安全：WPA 及 WAP2 企业
认证：受保护的EAP(PEAP)
匿名身份：锐捷用户名
CA证书：无
PEAP版本：自动
内部认证：MSCHAPv2
用户名：锐捷用户名
密码：锐捷密码
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
最后，一张图也没有，哼唧，这是我的习惯，懒～