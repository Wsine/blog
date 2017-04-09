# DNS攻击

> 实验是基于Linux系统，配置了bind9服务的机器

## 大纲

1. 本地修改Host文件重定向路径到指定地址
2. 对User的DNS查询进行欺骗攻击
3. 在同一局域网下，对DNS服务器的DNS查询进行欺骗攻击
4.  不在同一局域网下，对DNS服务器的DNS查询进行欺骗攻击

## 环境配置

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710094924092-948049719.png)

首先三台虚拟机分别给它们分配ip，如图，User为192.168.0.100，DNS Server为192.168.0.10，Attacker为192.168.0.200，对三台机器的代称为图中所示，下同。

**DNS Server的配置：**
-	修改/etc/bind/named.conf.options文件，增加dump.db作为DNS缓存的文件，使用chmod提高dump.db的文件权限(777)
-	设置DNS Server的本地zone为example.com和192.168.0.x两个域
-	重启bind9服务

**User的配置：**
-	设置User的默认DNS服务器为192.168.0.10
Attacker的配置：
-	设置Attacker的默认DNS服务器为192.168.0.10

三台机器的外部网关设置为VMware的NAT模式的虚拟网卡默认分配的网关，我这里是192.168.139.2

DNS Server设置后的网络配置：(其它类似)

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095112577-1790055532.jpg)

## 内容

### 修改本地host文件

这里主要就是修改User本地的Host文件，增加www.example.com一项，定向为127.0.0.1

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095231999-1694077574.jpg)

如图，成功ping www.example.com得到自己设置的1.2.3.4的DNS解析ip地址

### 欺骗回复User的DNS查询

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095349592-1742402146.png)

当User向DNS Server发送DNS查询的时候，Attacker监听了这个DNS查询请求，然后在DNS Server回复正确的DNS Response之前，先回复一个伪造欺骗的DNS Response给User，从而达到了DNS欺骗的效果。

实验中我们借用了Netwox/Netwag tool 105来进行DNS欺骗，具体的设置如下

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095353124-1677753877.jpg)

得到的实验效果为

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095355639-492519436.jpg)

### Local DNS Attack

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095534358-1435059323.png)

当DNS Server对Root DNS Server询问的时候，Attacker监听了DNS Server对外发出的DNS Query，伪造了一个DNS Response给DNS Server，从而让DNS Server中有了DNS Cache，且设置的ttl很长，因此就能够达到高效的DNS Attack。

实验中我们借用了Netwox/Netwag tool 105来进行DNS欺骗，具体的设置如下

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095536671-1543487967.jpg)

得到的实验结果为

DNS Server中的DNS Cache：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095542952-247270508.jpg)

User中使用Dig命令得到的结果：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710095545186-1988315713.jpg)

### Remote DNS Attack

正常情况下的DNS查询是这样子的

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100006421-1825846432.png)

但是我们可以将它简化成下面这样

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100008374-1703447607.png)

由于不在同一局域网内，Attacker不能监听DNS Server的DNS Query包，所以采用的方法是对transaction ID进行全枚举，而且必须在真正的DNS Response到来之前枚举成功这个transaction ID，为了简化实验，我们将UDP port设置为33333，所以就不用枚举UDP port这个变量。

但是ns.dnslabattacker.net不是一个合法的域名，因此DNS Server需要对它进行验证，否则不会将它保存在DNS Cache中，所以需要在Attacker机器中配置DNS服务，将ns.dnslabattacker.net作为该DNS的本地zone就好。

查看一下实验结果：

首先是Attacker对DNS发DNS Query和DNS Respose包：


![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100010358-1991375318.jpg)

然后在DNS Server中用Wireshark查看收到的包：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100012811-542109668.jpg)
![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100014999-2107971662.jpg)

查看一下DNS Server中的Cache：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100151264-1971893577.jpg)

在User中Dig一下aaaaa.example.edu

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710100016374-1513314141.jpg)