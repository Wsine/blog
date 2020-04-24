# arm-elf-gcc汇编代码个人理解

有关arm-elf-gcc的安装使用问题请参照本人博客的另一篇文章[http://www.cnblogs.com/wsine/p/4664503.html](http://www.cnblogs.com/wsine/p/4664503.html)

由于各种对齐问题，cnblogs的格式难以控制，故贴图片，谅解。

![111](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image139.jpg)
![222](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image140.jpg)
![333](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image141.jpg)
![444](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image142.jpg)

分析：第三份代码Clear3.c的效率是最快的。在Clear1中，要获得array[i]这个变量的值，就需要多花几部去计算从&array[0]开始，偏移i位之后的地址，然后才能得到array[i]这个地址，效率慢。在Clear2中，用了指针，修复了取地址的这个问题，但是也产生了另一个问题，&array[size]的获得也是类似与Clear1中的array[i]的获得，也是需要每次都计算偏移量，才能比较，效率慢。而在Clear3中，也是用了指针，虽然多使用了一个栈的空间，但是用了保存了&array[size]这个变量，因此只需要计算一次就可以，每次需要比较的时候再从栈中读取，不用每次计算，大大节省的重复运算的消耗。综上所述，Clear3.c的效率是最快的。

刚开头的栈指针和帧指针尤其不懂编译器为何要这样做。通过搜索，我发现了答案。

![666](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image143.jpg)
注：图片来自51CTO.com

这个是我对栈指针和帧指针的最大的理解。两者虽然指向同一片区域，但是一个是栈的起始位置，一个栈顶，不一样的，访问的时候通过fp指针的偏移量来访问。