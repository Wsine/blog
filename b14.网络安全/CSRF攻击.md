# CSRF攻击

### 1. CSRF Attack using GET Request

这个实验只需要让Alice的Session响应/action/friends/add这个Servlet就可以了，所以在Alice的profile中嵌入发送该Servlet的GET请求就好，具体HTML代码如下：

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image242.png)

然后Firefox这个笨蛋浏览器真蠢，渲染很渣(iframe)，但不影响我们的实验，渲染效果居然是这样的，真的太蠢的：

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image243.jpg)

Alice点击了这个链接之后得到的效果是自动添加了Boby为好友

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image244.jpg)

### 2. CSRF Attack using POST Request

这个实验就是用javascript模拟表单发送POST请求，仅此而已。重要的过程如下：
首先是获取一个真实的Profile Edit的Post请求，看看Http Header包里面包含什么内容

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image245.jpg)

这个图显示不太清楚，自己复制下来解析一下，重点在于Post请求中的参数。
用javascript模拟这个请求的过程大概就是这样子的：

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image246.png)

innerHTML是字符串的HTML代码模拟，只要和捕获的LiveHTTP请求一致就好。
可以得到这样的结果：

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image247.jpg)

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image248.jpg)

### 3. Implementing a countermeasure for Elgg

这个实验是恢复CSRF攻击的防御机制，攻击的防御机制是验证session的token和timestamp。
恢复验证函数的原本添加的代码就好：

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image249.jpg)

然后再一次重复上一步的实验可以发现已经不能修改了

![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image250.jpg)