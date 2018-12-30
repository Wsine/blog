# CSS选择器

> 以下大部分内容摘自[张永民老师](http://sdcs.sysu.edu.cn/?p=811)的课堂课件，也有对[w3school.com.cn](http://www.w3school.com.cn/cssref/css_selectors.asp)的参考，做了一定的整理和添加了一些自己的内容

## 选择器

### 基本选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 标签选择器|   `p {font-size: 14px;}`|  选择所有p元素|
| ID选择器|   `#start {font-weight: bold;}`|  选择id为start的元素|
| 类选择器|   `.even {font-style: italic;}`|  选择所有类为even的元素|

### 复合选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 派生选择器|   `p span {font-size: 14px;}`|  选择p元素的所有子孙元素中的span元素|
| 子女选择器|   `p>span {font-size: 14px;}`|  选择p元素的所有子女元素中的span元素|
| 组合选择器|   `p#start {font-size: 14px;}`|  选择id为start的p元素|
| 群组选择器|   `em, .even {font-size: 14px;}`|  选择em元素或者类名为even的元素|
| 相邻兄弟选择器|   `h1 + p {color:red;}`|  如果紧接着h1元素之后的h1的兄弟元素是p元素，它才会被选中|
| 后续兄弟选择器|   `h1 ~ p {color:red;}`|  选择在 h1 元素之后所有h1的兄弟元素中的p元素|
| 否定选择器|   `p:not(#start){ font-size:36px;}`|  选择所有id不是start的p元素|

### 属性选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 属性存在选择器|   `[alt] { width:200px; }`|  选择所有具有属性alt的元素|
| 元素属性选择器|   `img[alt] { width:200px; }`|  选择所有具有属性alt的img元素|
| 属性值选择器|   `[alt="fig 2-1"] { width:20px; }`|  选择所有属性alt的值等于"figure 2-1"的元素|
| 属性开头选择器|   `img[alt^="fig"] { width:20px; }`|  选择alt值以“figure”开头的所有img元素|
| 属性结尾选择器|   `img[alt$="2-1"] { width:20px; }`|  选择alt值以“2-1”结尾的所有img元素|
| 属性字符选择器|   `img[alt*="5-"] { width:20px; }`|  选择alt值包含字符串“5-”的所有img元素|
| 属性单词选择器|   `img[alt~="fig"] { width:20px; }`|  选择alt值包含单词“figure”的所有img元素|

### nth-child子女选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 首位子女选择器|   `p:first-child {color:red;}`|  p的双亲的第一个子女|
| 末位子女选择器|   `p:last-child {color:red;}`|  p的双亲的最后一个子女|
| 特定子女选择器|   `p:nth-child(5) {color:red;}`|  p的双亲的第5个子女|
| 偶数子女选择器|   `p:nth-child(even) color:red;}`|  p的双亲的第偶数个子女|
| 奇数子女选择器|   `p:nth-child(odd) {color:red;}`|  p的双亲的第奇数个子女|
| 公式子女选择器|   `p:nth-child(3n+1) {color:red;}`|  p的双亲的选择第3n+1(n>=0)个子女|

**双亲的各种类型的子女元素均参与计数，但是只有相应位置为元素p才会被选中**

### nth-of-type选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 首位子女选择器|   `p:first-type {color:red;}`|  p的双亲的第一个子女|
| 末位子女选择器|   `p:last-type {color:red;}`|  p的双亲的最后一个子女|
| 特定子女选择器|   `p:nth-type(5) {color:red;}`|  p的双亲的第5个子女|
| 偶数子女选择器|   `p:nth-type(even) color:red;}`|  p的双亲的第偶数个子女|
| 奇数子女选择器|   `p:nth-type(odd) {color:red;}`|  p的双亲的第奇数个子女|
| 公式子女选择器|   `p:nth-type(3n+1) {color:red;}`|  p的双亲的选择第3n+1(n>=0)个子女|

**双亲的子女元素中只有p元素参与计数**

### 伪元素选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 首字母选择器|   `p:first-letter {font-size:2em;}`|  p元素内容的第一个字母|
| 首行选择器|   `p:first-line {color:red;}`|  p元素内容的第一行|
| 末尾选择器|   `p:after {content:"...";}`|  在p元素内容之后插入内容`...`|
| 开头选择器|   `p:before {content:"***";}`|  在p元素内容之前插入内容`***`|

**插入后的内容也算作p元素的内容，能够被javascript代码控制**

### 伪类选择器

| 名称|     例子|   作用|
| :-------- | :--------| :------ |
| 链接选择器|   `a:link {color:blue;}`|  没有访问过的链接|
| 历史选择器|   `a:visited {color:red;}`| 访问过的链接 |
| 悬浮选择器|   `a:hover {font-size:2em;}`| 鼠标悬浮下的元素 |
| 点击选择器|   `a:active {color:green;}`| 鼠标摁下时的链接 |
| 焦点选择器|   `input:focus {background-color:red;}`| 获得焦点的元素 |
| 已选选择器|   `::selection`| 为选中的文本设置样式 |
| 全局选择器|   `*`| 所有元素 |

## 样式层叠

选择器的特殊性的值可以由下面规则确定：
1. 对于ID选择器，每个特殊性加(0，1，0，0)
2. 对于类选择器、属性选择器、伪类选择器，每个特殊性加(0，0，1，0)
3. 对于标签选择器和伪元素选择器，每个特殊性加(0，0，0，1)
4. 每个元素只能定义一个行内样式，行内样式的特殊性为(1，0，0，0)
5. 结合符和通配选择器，对特殊性没有任何贡献，即其特殊性为(0，0，0，0)
6. 继承得来的选择器没有任何特殊性，即其特殊性为(0，0，0，0)
7. 加上!important的样式具有最高特殊性

特殊性比较：
( 0，1，0，0 ) > ( 0，0，2，0 )
( 0，0，2，1 ) > ( 0，0，2，0 )

例子：

| 样式|     特殊性|
| :-------- | :--------|
| `p {color:blue}`|   (0，0，0，1)|
| `body p {color:red}`|   (0，0，0，2)|
| `h1.hot {color:green}`|   (0，0，1，1)|
| `p#start {color:black}`|   (0，1，0，1)|
| `body>div ul li[id="files"] ul li:hover {color:yellow}`|   (0，0，2，6)|
| `p {color:blue!important;}`|   (inf, inf, inf, inf)|