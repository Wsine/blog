# Chrome 在 Windows 找回熟悉的 Alt + Num 切换标签页

在不同的系统和软件中，我都喜欢尽可能用同一套快捷键方案去完成相同的功能，以减少自己的学习和记忆成本，最大化效率。但是，哪怕是同一个应用，由于不同平台的默认快捷键不一样，频繁切换平台的迁移学习也很辛苦。

比如 Chrome 浏览器中，切换标签页的方式在不同的平台上不一样：

- Windows：Ctrl + Num
- Linux：Alt + Num
- Mac：Cmd + Num

后两者由于键位所处的位置大致相同，所以哪怕没有记忆也不会造成多大的割裂感。但是，Windows 下面的这套快捷键实在是太难受了，本文就是教你如何找回熟悉的感觉。

![FF5B74693EE093B3A0810E93810F336D](http://wsine.cn-gd.ufileos.com/image/FF5B74693EE093B3A0810E93810F336D.png)

这里我们需要借助的软件是 Vimium，相信已经有不少文章介绍过它了。在这里我们需要用到它 Custom key mappings 的功能。Vimium 本身提供很多优秀的内建功能。而我们这里需要用到的是 `firstTab` 的功能。

![72B87484BA371209846EF02C6B381FE9](http://wsine.cn-gd.ufileos.com/image/72B87484BA371209846EF02C6B381FE9.png)

你可能会觉得这个功能并不足够完成 `Alt + 2`或 `Alt + 3` 等映射，其实不然，仔细阅读它的开源代码你会发现它本身还提供 option 的功能，简单点来说配置方案是酱紫的。

![939C6CA558E0E7230390D3763ED98731](http://wsine.cn-gd.ufileos.com/image/939C6CA558E0E7230390D3763ED98731.png)

这里我把映射也一并附上。我个人只习惯用前面几个固定的标签页，你可以根据自己习惯增减。

```
map <a-1> firstTab
map <a-2> firstTab count=2
map <a-3> firstTab count=3
map <a-4> firstTab count=4
```

有了这套方案，我可以很容易的快速回到长期放在第一个标签的 Gmail 页面或者从 Jupyter Notebook 的编程页面中跳出去快速搜索一些东西，而不用借助鼠标，从而提高效率。
