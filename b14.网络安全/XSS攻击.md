# XSS攻击

> Linux系统下的实验，配置了elgg服务

### 1. Posting a Malicious Message to Display an AlertWindow

这一步是在Profile中嵌入javascript代码，使得浏览该profile的用户都会引发弹窗。太简单了不细说

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102342280-2114108598.jpg)

### 2. Posting a Malicious Message to Display Cookies

这一步和上一步的区别就是弹窗的内容不一样了而已，也不解释，看图。

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102344077-1447200425.jpg)

### 3. Stealing Cookies from the Victim’s Machine

这一步是将上一步中获得的cookie使用GET请求发送到Attacker中，Attacker只需要一直在抓包就可以了，这里我使用了wireshark作为抓包工具。

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102421858-462173297.jpg)

### 4. Session Hijacking using the Stolen Cookies

这里必须假设Attacker已经知道了victim的elgg_ts和elgg_token参数，这两个参数从WebBrower的Console中获取，分别是elgg.security.token.\_\_elgg_ts;和elgg.security.token.\_\_elgg_token;
别忘了配置Attacker的Web Server是指向Victim机器上面的Web Server。

Java代码模拟发包过程如下：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102423905-1476292895.png)

结果能够使得Boby被迫添加Alice为好友

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102425452-8757168.jpg)

### 5. Writing an XSS Worm

这一步需要在profile中注入完整的攻击，使得访问该profile的都是受害者。
主要目的就是调用js文件，主要过程如下：
在Attacker机器上多配置一台Web服务器用于保存.js文件

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102427077-1960120365.jpg)

在根据ip地址配置好hosts文件，注意需要修改为新配置的domain

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102428624-513370731.jpg)

但是由于默认设置不能直接访问服务器的文件，所以需要配置apache允许这一操作，同时提高/var/www/路径下新Web服务器的文件权限，使得其可以被直接访问

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102430483-361082719.jpg)

在代码中可以判断一下看看是谁访问，如果是自己访问就不要攻击了，只攻击外人，避免麻烦的事情。可以看看下面三张图：
用户访问Alice的Profile：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102432077-1854121302.jpg)

用户的Profile被莫名修改：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102433796-1648261812.jpg)

用户的好友列表莫名添加了新好友：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102436186-211185890.jpg)

### 6. Writing a Self-Propagating XSS Worm

这一步需要在上一步的基础上添加传播性，因此修改profile的时候不再修改为任意内容，同样修改为带XSS注入攻击的内容就好。具体修改为这样：

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102438436-1720647371.png)

得到的结果为
当Charlie去访问已经被感染的Boby页面的时候，也被感染了

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102441202-1697249974.png)

### 7. Countermeasures

根据文档修改这个配置，主要是对profile中的各字段进行了非法验证，只通过合法的字段从而防止了XSS的攻击问题。

第一步，启用HTMLawed模块
用管理员账号登陆之后，启用里面的HTMLawed模块就好

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102443592-1096860616.png)

得到的结果是这样子的

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102447499-1172598414.png)

这种方式是把用户输入的script标签转换为a标签，避免了被动触发js代码造成的感染

第二步是启用htmlspecialchars()字符判断转义
根据文档说明修改相应的代码，去掉注释就好了
修改后的效果为

![](http://images2015.cnblogs.com/blog/701997/201607/701997-20160710102455514-1875264417.png)

主要功能为，将方括号转义为html的字符渲染形式，从而避免了被当作一个脚本去运行