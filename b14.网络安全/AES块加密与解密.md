# AES块加密与解密

### 解密目标

在CBC和CTR两种模式下分别给出十篇加密的样例密文，求解密一篇特定的密文

### 解密前提

1. 全部密文及其加密使用的key都已给出
2. 加密的方法遵循AES的标准

### 解密过程分析

实验中给出了密文及其对应Key。

**CBC模式**观察下图：

![](http://images2015.cnblogs.com/blog/701997/201606/701997-20160627154011874-134666816.png)

这幅图就是CBC解密的整个流程图，注意到Key指的是已经给出了的

Key的Expansion形式，也就是经过了扩展成44个Byte的Key，给出的Key是4个Byte的形式。这里的Initialization Vector实际上就是给出的密文中的前16位。Ciphertext的一个单位长度是16个Byte，最后的操作如果不足16个Byte的，需要补足16个Byte，再进行AES块解密操作。中间的Block Cipher Decryption在此处是一个黑盒子，用于AES的解密操作，后面再说AES的认识和理解。注意到，AES算法中的数据类型都是定义好的，详细可以看教材的P194页，总的来说分为四个部分：Byte、Word、Block和State。

![](http://images2015.cnblogs.com/blog/701997/201606/701997-20160627154058249-534691678.png)

在这里，四种数据类型之间是可以转换的，但是遵循一定的规则。
在实验中主要用到了Block转State和State转Block两种数据类型，对应的转换规则为：

![](http://images2015.cnblogs.com/blog/701997/201606/701997-20160627154302140-1578927038.png)

可以看到，Block是按照人类阅读规则，从左往右的顺序排列的，但是State是反人类规则，竖式排列的规则，这个坑好累。

解密的时候，第一个块解密使用的是Initialization Vector进行异或操作，后续的块解密使用的是前一个块的密文来进行异或操作，也就是说CBC模式加密解密是前后文关联的。

**CTR模式**观察下图：

![](http://images2015.cnblogs.com/blog/701997/201606/701997-20160627154344812-112507046.png)

CTR模式与CBC模式相比，不同的地方在于，进行AES解密的时候，使用的是一个Counter来进行AES加密，Counter的初始值就是Initialization Vector，每一轮加密就对Counter的值进行+1操作。最后通过AES加密后的结果，与密文进行异或操作，从而得到对应的原文。注意，这里是解密的过程，但是中间的黑盒子也是使用AES加密操作来进行。

### AES加密解密解析

（证明我有好好学习）
主要就是四个操作：SubBytes、ShiftRows、MixColumns和AddRoundKey
SubBytes：
这个操作就是查表，进行一个新的映射，在一个4x4的State中，每一个格子都是一个Byte，一个Byte由两个16进制字符组成，通过查询一个16x16的表格，将一个Byte映射成另一个Byte。
ShiftRows：
这个操作是对State进行行的移位操作，第n行向左移动n位，循环移动，n大于等于0且n小于4。
MixColumns：
这个操作是有一个固定的4x4矩阵，对于State的每一列都和这个矩阵进行乘法操作，得到一个新的列。最终得到一个新的State。
AddRoundKey：
这个操作是将当前的State与当前这一轮的Key进行异或操作，得到新的State。

整个流程可以看这样一幅图：

![](http://images2015.cnblogs.com/blog/701997/201606/701997-20160627154443906-849166852.png)

### 代码分析

根据流程，将密钥进行扩展，然后按照16分块操作，进行解密，再输出。以CBC解密为栗子：

```cpp
void CBC() {
	// Declare the key and stream
	Byte key[16] = {
        0x14, 0x0b, 0x41, 0xb2, 0x2a, 0x29, 0xbe, 0xb4, 0x06, 0x1b, 0xda, 0x66, 0xb6, 0x74, 0x7e, 0x14
    };
    Byte IV[16] = {
        0x4c, 0xa0, 0x0f, 0xf4, 0xc8, 0x98, 0xd6, 0x1e, 0x1e, 0xdb, 0xf1, 0x80, 0x06, 0x18, 0xfb, 0x28
    };
    Byte stream[100] = {
        0x63, 0xcb, 0x8d, 0x05, 0x3b, 0xe7, 0xfc, 0xf1, 0x11, 0xcf, 0x4a, 0x6e, 0x04, 0x43, 0x01, 0x07,
        0x2a, 0x86, 0x36, 0xca, 0x9b, 0xea, 0x59, 0xa7, 0xb6, 0x50, 0x58, 0xe6, 0x52, 0xe4, 0x8a, 0xbd,
        0xcd, 0x46, 0x1b, 0x97, 0x1b, 0xec, 0xdf, 0xdc, 0xb1, 0xf4, 0x4b, 0x36, 0x02, 0x25, 0x5e, 0x2d,
        0x61, 0x6b, 0xdd, 0x10, 0x71, 0xa5, 0x47, 0x55, 0xc3, 0x06, 0x88, 0x79, 0x3d, 0xbf, 0x1a, 0x4a
    };
    // Decryption
    Byte *fullKey = keyExpansion(key);
    cipherBlockChainingDecryption(stream, IV, fullKey, 16 * 3);
    // Show the result
    for(int i = 0; i < 16 * 3; i++)
        printf("%c", stream[i]);
    printf("\n");
    free(fullKey);
}
```

```
void cipherBlockChainingDecryption(Byte *stream, Byte *IV, Byte *key, int length) {
	int times = length / CIPHERTEXT_LENGTH;
	if (length > times * CIPHERTEXT_LENGTH) {
		times++;
	}
	Byte streamOrgin[100];
	for (int i = 0; i < 100; i++) {
		streamOrgin[i] = stream[i];
	}
	Byte ciphertext[4][4];
	for (int i = 0; i < times; i++) {
		if (i == 0) {
			oneD2twoD(stream + i * CIPHERTEXT_LENGTH, ciphertext);
			AES_Decryption(ciphertext, key);
			twoD2oneD(ciphertext, stream + i * CIPHERTEXT_LENGTH);
			exclusiveOr(stream + i * CIPHERTEXT_LENGTH, IV);
		} else {
			oneD2twoD(stream + i * CIPHERTEXT_LENGTH, ciphertext);
			AES_Decryption(ciphertext, key);
			twoD2oneD(ciphertext, stream + i * CIPHERTEXT_LENGTH);
			exclusiveOr(stream + i * CIPHERTEXT_LENGTH, streamOrgin + (i - 1) * CIPHERTEXT_LENGTH);
		}
	}
}
```

### 后记

在一般情况下，128位的Key加密后的内容，通过暴力的方式进行解密，需要n年的时间才能完全解密(刚才和TA讨论了一下，包括Key和Initialization Vector共32位，枚举每一位0~F共16个变化，大概是10^32次方的数据)，因此才说，暴力破解很难，更何况是如果不是128呢？

加密方式的角度上来说，CBC和CTR在加密方式上来说，最大的区别在于块加密上，前后的块是否关联，关联的块带来的是更好的加密，但同时也带来了性能的开销，如CBC。CTR使用的是计数器模式，块加密前后不关联，能够很好地同时进行加密，大大提高了加密和解密的速度。

传送门：[下载](http://pan.baidu.com/s/1boGWTMR)