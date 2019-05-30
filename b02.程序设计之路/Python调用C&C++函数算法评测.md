# Python调用C/C++函数算法评测

> reference: <https://docs.python.org/2.7/extending/extending.html>

## 背景

关于静态语言和动态语言，我认为他们各有好处：

动态语言的优势在于灵活处理数据，开发快速，很适合一些变动高的场景。假如使用C/C++来实现，开发效率先不提，如果对map/reduce等操作不熟悉的话，你甚至没有办法超越Python原生的效率，当然前提是你使用Python的高级语法。

静态语言的优势在于运行效率，资源节省，很适合高并发的场景。大量的底层技术和中间件都是使用C/C++语言来实现的。

结合这两者的优点和现在大热的人工智能方向，大量的神经网络需要完成算法评测来评估一个模型的好坏。使用Python完成测试数据读取，使用C/C++来完成底层AI引擎的实现，既满足了业务代码的复用，又快速完成算法评测的需求。但这里最大的障碍，莫过于跨语言调用，本文就是来解决这个问题的。

## 代码实现

首先声明一下，本文的实现是基于Python2.7版本的，众所周知Python2和Python3有明显的不同，实现上也略有区别，自己注意一下就好。

首先需要的是安装Python的开发环境

```bash
sudo apt-get install python2.7-dev
```

假设你已经有了自己的算法库了，我这里直接给出整体目录：

```plain
.
├── CMakeLists.txt
├── include
│   ├── algorithm.hpp
└── src
    ├── algorithm.cpp
    └── pywrapper.cpp

2 directories, 5 files
```

算法部分我直接用一个函数代替了

```c++
// algorithm.hpp
#ifndef ALGORITHM_HPP_
#define ALGORITHM_HPP_

int BaseAlgorithm(int n);

#endif
```

```c++
// algorithm.cpp
#include "algorithm.hpp"

int BaseAlgorithm(int n) {
    return n + 1;
}
```

然后由于Python是一个动态语言，所有的对象表征都是一个PyObject，因此需要一个wrapper来做转换封装。这里需要主要的地方有三点：

- 对于算法的调用，必须从PyObject里面解析得到输入和输出，具体的API可以参考我文首的官方参考
- 对于算法的调用，必须考虑异常情况，必要时抛出NULL或者PyError也是可以的，否则容易得到segmentation fault
- 对于PyMODINIT_FUNC的函数签名，不同版本的Python中有固定的签名，在python2.7中为`init<libname>`，因此这个函数签名不能任意改变

```c++
// pywrapper.cpp
#include <Python.h>
#include "algorithm.hpp"

PyObject* BaseAlgorithm(PyObject *self, PyObject *args) {
    int n;
    if (!PyArg_ParseTuple(args, "i", &n)) return NULL;
    int result = BaseAlgorithm(n);
    return Py_BuildValue("i", result);
}

PyMODINIT_FUNC initlibpywrapper(void) {
    static PyMethodDef py_methods[] = {
        {"BaseAlgorithm", BaseAlgorithm, METH_VARARGS, "Plus 1"},
        {NULL, NULL, 0, NULL}
    };
    Py_InitModule("libpywrapper", py_methods);
}
```

剩下的内容就很简单了，随意编译一下就好

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(python-cpp-module)

find_package(PythonLibs REQUIRED)

add_library(algorithm SHARED ${CMAKE_SOURCE_DIR}/src/algorithm.cpp)
target_include_directories(algorithm PUBLIC ${CMAKE_SOURCE_DIR}/include)

add_library(pywrapper SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/pywrapper.cpp)
target_include_directories(pywrapper PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${PYTHON_INCLUDE_DIRS})
target_link_libraries(pywrapper algorithm ${PYTHON_LIBRARIES})
```

## 运行方式

假设你在当前的目录下：

```
.
├── CMakeCache.txt
├── cmake_install.cmake
├── libalgorithm.so
├── libpywrapper.so
└── Makefile
```

执行方式也异常简单，如下即可

```python
~/Workspace/python-cpp-module/build$ python
Python 2.7.12 (default, Nov 12 2018, 14:36:49)
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from libpywrapper import *
>>> BaseAlgorithm(1)
2
>>> exit()
```

## 后记

我知道目前的实现方式比较多，包括但不限于`boost.python`、`pybind11`、`SWIG`、`ctypes`，但是从维护性和易用性上来说，还是直接调用dev包只取自己所需更为实用一些
