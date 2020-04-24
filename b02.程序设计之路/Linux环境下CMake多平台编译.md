# Linux环境下CMake多平台编译

本文的教程十分简单，单纯地记录一下学到的内容，仅此而已

由于不同的平台架构不一样，也就是ABI（Application Binary Interface）不同，因此同样的程序不能直接拷贝运行，当然还有依赖等相关的因素。

但是通过良好适配的交叉编译工具，可以将同一份代码一次编译多处运行，这在实际嵌入式开发中十分常见。

#### 测试平台

采用的平台是Ubuntu16.04，默认编译器为gcc 5.4.0，手动编译安装了cmake版本3.6.3

#### 目录结构

```
.
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   ├── cmake_install.cmake
│   ├── Makefile
│   ├── runnable-Android-aarch64
│   ├── runnable-Android-armv7-a
│   ├── runnable-Android-i686
│   ├── runnable-Android-mips
│   ├── runnable-Android-mips64
│   ├── runnable-Android-x86_64
│   ├── runnable-Linux-aarch64
│   ├── runnable-Linux-arm
│   └── runnable-Linux-x86_64
├── build.sh
├── CMakeLists.txt
├── main.cpp
└── toolchains
    ├── android-ndk-r16b
    │   ├── ...
```

#### 测试代码

写一个最简单的入门程序，不影响本文的目的

```c++
// main.cpp
#include <iostream>

int main() {
    std::cout << "Hello World!" << std::endl;
    return 0;
}
```

编译构建也是采用最简单的方式

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.6)

add_executable(runnable-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR} main.cpp)
```

#### 编译工具链

##### 安卓平台

这里其实有两种方式，第一种是独立制作standalone_toolchain，第二种是使用ndk。

第一种方式其实也是从ndk中提取出来的，指定好特定的目标机器环境；本文采用第二种，能够一次编译多平台，实际情况下可能需要的配置的参数更多一些，这里很多参数都是缺省状态。

ndk的下载链接可以从这里获取：[https://developer.android.google.cn/ndk/downloads/](https://developer.android.google.cn/ndk/downloads/)

在ndk中已经提供了一份通用的`android.toolchain.cmake`文件，用户提供少量参数即可，最关键的参数可以参考cmake中的[说明](https://cmake.org/cmake/help/v3.6/manual/cmake-toolchains.7.html#cross-compiling-for-linux)，其中比较重要的是目标机器的架构，可选的有{ armeabi-v7a, arm64-v8a, x86, x86_64, mips, mips64 }，mips指令集在安卓平台上已经不是很常用了。一般情况下，如果你使用到了android平台底层的接口，你是应该要指定最低的安卓API要求的，但我这程序比较简单就不需要了。

##### Linux平台

Linux平台上面的交叉编译工具的提供商比较少，大概划分有这几种

> 从授权上，分为免费授权版和付费授权版。
>
> **免费版**目前有三大主流工具商提供，**第一是GNU（提供源码，自行编译制作），第二是 Codesourcery，第三是Linora。**
>
> **收费版**有ARM原厂提供的armcc、IAR提供的编译器等等，因为这些价格都比较昂贵，不适合学习用户使用，所以不做讲述。
>
> - **arm-none-linux-gnueabi-gcc：**是 Codesourcery 公司（目前已经被Mentor收购）基于GCC推出的的ARM交叉编译工具。可用于交叉编译ARM（32位）系统中所有环节的代码，包括裸机程序、u-boot、Linux kernel、filesystem和App应用程序。
> - **arm-linux-gnueabihf-gcc：**是由 Linaro 公司基于GCC推出的的ARM交叉编译工具。可用于交叉编译ARM（32位）系统中所有环节的代码，包括裸机程序、u-boot、Linux kernel、filesystem和App应用程序。
> - **aarch64-linux-gnu-gcc：**是由 Linaro 公司基于GCC推出的的ARM交叉编译工具。可用于交叉编译ARMv8 64位目标中的裸机程序、u-boot、Linux kernel、filesystem和App应用程序。
> - **arm-none-elf-gcc：**是 Codesourcery 公司（目前已经被Mentor收购）基于GCC推出的的ARM交叉编译工具。可用于交叉编译ARM MCU（32位）芯片，如ARM7、ARM9、Cortex-M/R芯片程序。
> - **arm-none-eabi-gcc：**是 GNU 推出的的ARM交叉编译工具。可用于交叉编译ARM MCU（32位）芯片，如ARM7、ARM9、Cortex-M/R芯片程序。

本来我应该下载独立的toolchain的，但是由于网络原因尝试了大半天，因此选择通过包管理工具下载，效果是一样的，只是可移植性低一些，但不影响本文目的。

下载命令：`sudo apt-get install apt-get install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-aarch64-linux-gnu g++-aarch64-linux-gnu`

部分arm平台上会使用hard float，用芯片硬件能力运算浮点数，此类的编译器和这里不一致，注意甄别

由于CMake的仅为单一平台设计，因此我们需要通过一些脚本语言来多次调用cmake，示例如下

```bash
#!/bin/bash

set -e

TOOLCHAIN_DIR="$PWD/toolchains/"

# Make Output Directory
mkdir -p build
cd build

# Build Android
NDK_DIR="$TOOLCHAIN_DIR/android-ndk-r16b/"
AVALIABLE_ABI=(
    "armeabi-v7a"
    "arm64-v8a"
    "x86"
    "x86_64"
    "mips"
    "mips64"
)
for ABI in ${AVALIABLE_ABI[*]}; do
    rm -rf *make* *Make*
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$NDK_DIR/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$ABI \
        -DANDROID_TOOLCHAIN=gcc # or clang
    make
done

# Build Linux
COMPONENTS=(
    "x86_64,gcc,g++"
    "arm,arm-linux-gnueabi-gcc,arm-linux-gnueabi-g++"
    "aarch64,aarch64-linux-gnu-gcc,aarch64-linux-gnu-g++"
)
for line in ${COMPONENTS[*]}; do
    rm -rf *make* *Make*
    IFS=',' read processor c cpp <<< "$line"
    cmake .. \
        -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_SYSTEM_PROCESSOR=$processor \
        -DCMAKE_C_COMPILER=$c \
        -DCMAKE_CXX_COMPILER=$cpp
    make
done
```

#### 实验结果

通过linux下面的file命令查看ABI情况，就能看到各种的端倪

```
~/Workspace/cmake-cross-compile/build$ file runnable-*
runnable-Android-aarch64: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /system/bin/linker64, BuildID[sha1]=4d353c9715d0a9a04c18aa60faba1b8ce7e350bd, not stripped
runnable-Android-armv7-a: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /system/bin/linker, BuildID[sha1]=6d05509c61cafc508b2c21ba58ae65aeaee7d5b6, not stripped
runnable-Android-i686:    ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /system/bin/linker, BuildID[sha1]=3b39ccfecdccad0334746e9f0b3b2fea44736aac, not stripped
runnable-Android-mips:    ELF 32-bit LSB executable, MIPS, MIPS32 version 1 (SYSV), dynamically linked, interpreter /system/bin/linker, BuildID[sha1]=65f54857c4c5ea90c2febc616a27d772e3512c97, not stripped
runnable-Android-mips64:  ELF 64-bit LSB shared object, MIPS, MIPS64 rel6 version 1 (SYSV), dynamically linked, interpreter /system/bin/linker64, BuildID[sha1]=971c4f554211fe12c4046210fc700c63f4b5d9e1, not stripped
runnable-Android-x86_64:  ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /system/bin/linker64, BuildID[sha1]=68b2394972e0af4d48f2940c3dccf0cde42e2c36, not stripped
runnable-Linux-aarch64:   ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, BuildID[sha1]=56591d98a080951d1563b5f38b331735e4d29764, not stripped
runnable-Linux-arm:       ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=80132c78325bae70063897c3d75f17ca7b6887fb, not stripped
runnable-Linux-x86_64:    ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=48c955698c5d0542ce97a8d1f943f40277e25504, not stripped
```

