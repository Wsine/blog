# Ubuntu14.04安装配置ndnSIM

### 预环境
Ubuntu14.04官方系统
请先使用`sudo apt-get update`更新一下源列表

### 安装步骤

#### 安装boost-lib

```
sudo apt-get install build-essential libsqlite3-dev libcrypto++-dev
sudo apt-get install libboost-all-dev
```

其中，build-essential和libboost是目标安装文件，build-essential中包含各种编译工具，其中最主要的是个gcc和g++，这里g++版本要求为4.5.4

libboost会被默认安装在 `/usr/lib/x86_64-linux-gnu` 路径下，如通过源码安装请确认版本至少为1.46，官方要求最低版本号，已知1.59版本编译不成功，这里推荐1.54和1.55版本，在默认路径下可以查看版本号

#### 安装Python bindings 

```
sudo apt-get install python-dev python-pygraphviz python-kiwi
sudo apt-get install python-pygoocanvas python-gnome2
sudo apt-get install python-rsvg ipython
```

强烈建议，python必须是2.7，如果是3.4版本，请手动把每一个`print ''`语句修改为`print()`语句，所以还是老老实实用2.7吧，暂时默认安装就是2.7

命令行敲入python进入python交互环境即可看到版本号，使用exit()退出交互环境
#### 下载ns3、pybindgen和ndnsim

```
mkdir ndnSIM
cd ndnSIM
git clone git://github.com/cawka/ns-3-dev-ndnSIM.git ns-3
(cd ns-3; git checkout -b ndnSIM-0.4.3  ns-3.17-ndnSIM-0.4.3)
git clone git://github.com/cawka/pybindgen.git pybindgen
git clone git://github.com/NDN-Routing/ndnSIM.git ns-3/src/ndnSIM
(cd ns-3/src/ndnSIM; git checkout -b v0.4.3 v0.4.3)
```

ns-3目前的版本更新到了v2.1，但是ndnSIM版本没支持这么高，这些选用论文中相同的版本，都是v0.4.3，使用git版本回退功能到v0.4.3版本的Release，可以使用`git branch`查看当前版本信息，注意使用cd命令改变路径

下载修改完成后目录结构如下
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image437.png)

请主动忽略其余文件夹，关键目录结构树如下
- ndnSIM
	- ns-3
		- src
			- ndnSIM
	- pybindgen

#### 编译ns-3

这里先挖个坑，pybindgen暂时不能成功编译，这里暂时不编译它
将文件夹修改名称，只要不是pybindgen就ok，可以参考我的

/\*\*\*\*\*\*\*\*更新\*\*\*\*\*\*\*\*/
我来填坑了，凭记忆的错了别怪我，编译前先配置好，在pybindgen文件夹里面，修改version.py文件，根据编译结果提示修改，我这里修改后的结果为：
```python
__version__ = [0, 17, 0, 887]
"""[major, minor, micro, revno], revno omitted in official releases"""
```
/\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/

```
CXXFLAGS="-Wall" ./waf configure --boost-libs=/usr/lib/x86_64-linux-gnu -d optimized
./waf -j4
sudo ./waf install
```

这里修改--boost-libs=后面的路径为自己的boost-lib路径，如果已加入环境变量豪华午餐，那就可以不用这个参数了，否则编译工具找不到boost-lib

`CXXFLAGS="-Wall"`语句的作用是修改报错`cc1plus: all warnings being treated as errors`，忽略全部的warning

`-j4`这个参数是使用4核同时编译，加快速度，考虑自己环境实际使用，如果使用不当会更慢，编译过程，对于`make`指令也适用

安装完成后模块信息如图所示
![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image438.png)

注意检查关键模块ndnSIM模块成功安装与否


#### 编译论文代码

```
cd ndnSIM
git clone https://github.com/cawka/ndnSIM-nom-rapid-car2car.git
cd ndnSIM-nom-rapid-car2car
./waf configure --boost-libs=/usr/lib/x86_64-linux-gnu
./waf
```

这步不通过请检查上面的环境和过程

#### 安装R语言

官网网址：https://www.r-project.org/

选择Download R

CRAN列表选择清华大学的镜像源https://mirrors.tuna.tsinghua.edu.cn/CRAN/

选择Download R for Linux

选择ubuntu

选择trusty

64位系统请选择 r-base-core_3.2.2-1trusty0_amd64.deb 下载
32位系统请选择 r-base-core_3.2.2-1trusty0_i386.deb 下载

然后双击安装就可以了

（挖个坑，如果不行再安装一个 r-base_3.2.2-1trusty0_all.deb ，一般这个不用装）

注意，默认使用`sudo apt-get install r-base`安装后的版本为3.0.2，对于后面安装模块ggplot2会不受支持，因此请用安装包安装最新版

#### 给R环境安装模块

```
sudo R
install.packages ('proto')
install.packages ('ggplot2')
install.packages ('doBy')
```

注意查看安装信息

### 运行与测试

```
cd ndnSIM/ndnSIM-nom-rapid-car2car
./run.py -s figure-3-data-propagation-vs-time
./run.py -s figure-4-data-propagation-vs-distance
./run.py -s figure-5-retx-count
```

查看信息即可知道运行情况
进入`ndnSIM/ndnSIM-nom-rapid-car2car/graphs/pdfs`路径可以查看pdf信息情况