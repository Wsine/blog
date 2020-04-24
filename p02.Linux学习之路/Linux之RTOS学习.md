# RTOS Research Route

> RTOS: Real time operating system

[TOC]

## 系统选型

### 可选方案

- RTLinux - FSMLabs, [WindRiver Systems](https://en.wikipedia.org/wiki/Wind_River_Systems) - http://www.rtlinux.org/
- ChronOS - [Systems Software Research Group](http://www.ssrg.ece.vt.edu/) - http://chronoslinux.org
- OSADLinux - [Open Source Automation Development Lab](https://www.osadl.org/) - https://www.osadl.org/Realtime-Linux.projects-realtime-linux.0.html



### 特性分析

|                  | RTLinux  | ChronOS |  OSADL  |
| :--------------: | :------: | :-----: | :-----: |
|   Open Source    |    No    |   Yes   |   Yes   |
|     License      | GPL-2.0  |  GPLv2  |    /    |
|  Kernel Version  |  4.8.12  | 3.4.82  | 4.11.12 |
|     Platform     |  Linux   |  Linux  |  Linux  |
|   Architecture   | x86[^1]  | x86/Arm | x86/Arm |
|   File System    | full[^2] |  full   |  full   |
|  Device Drivers  | inherit  | inherit | inherit |
|  C/C++ Library   | inherit  | inherit | inherit |
|    Networking    | inherit  | inherit | inherit |
|  Flash Support   | inherit  | inherit | inherit |
|   USB Support    | inherit  | inherit | inherit |
| Graphics Support | inherit  | inherit | inherit |
|   GPU Support    | inherit  | inherit | inherit |

- Additional
  - RTLinux
    - 官方文档齐全
    - 付费订阅后可以获得支持
  - ChronOS
    - O(1)算法复杂度的实时调度算法
  - OSADL
    - 和Linux内核社区结合很紧密，同步最新的内核版本
    - Patch是直接放在kernel.org，说明了其地位
    - 部分特性已经合在Linux内核的mainline上，说明了其贡献

注：inherit代表原生linux内核支持，上述三个系统均基于原生内核，原则上支持上述特性，暂无官方文档说明，文件系统上支持RTOS的preempt_rt特性的会有所不同



### 选择结果

根据上述的对比，我觉得选择OSADL作为本次详细调研的对象会比较好。理由有三：

1. OSADL在Real Time Operating System上作为kernel.org的首选，有其优越的地方
2. OSADL背后有Open Source Automation Development Lab长期支持，遇到特别难的问题可以发mail issue寻求解决方案
3. OSADL的内核版本较新，且持续更新中，自动驾驶是一个5年到10年的发展期，选择有未来的项目会更好，比如致命的内核错误通过更新内核能解决也能保证自动驾驶的安全

**下文的内容均基于OSADL展开**



## 文档阅读

>  OSADL Recommended Reading
>
>  - [A realtime preemption overview](https://lwn.net/Articles/146861/)
>
>  - [SMP and Embedded Real Time](http://www.linuxjournal.com/article/9361)

### 功能分析

PREEMPT_RT的特性：

1. Preemptible critical sections
2. Preemptible interrupt handlers
3. Preemptible "interrupt disable" code sequences
4. Priority inheritance for in-kernel spinlocks and semaphores
5. Deferred operations
6. Latency-reduction measures

信号量临界区原理：

严格来说，抢占原本不能发生在一个非可抢占的内核。但是，由于访问用户数据的时候会发生类似页错误的事情可以显式地访问调度器，则抢占功能可以在这里加入。

优先级继承原理：（writer和多个reader之间）

实现了一个reader-writer lock， writer和reader共享，这个lock的状态可以被reader访问，但无法被reader访问write-acquire方法。多reader优先级继承花费的时间会影响到调度延迟上。

事件机制不适用优先级继承原理：

引入事件机制，任何的任务都有可能调用down()方法，这样会导致高优先级的任务被唤醒(有可能在休眠状态)



### 注意事项

**Warning :** raw_spinlock_t和raw_rwlock_t的非正确使用都会破坏PREEMPT_RT的实时机制，请注意

实时任务使用上的编码注意事项，可以通过spinlock_t等非raw形式访问，或根据需求封装raw，尽量避免原生使用raw_lock。



## 编译和安装

### 源码编译

```bash
# Download linux souce code
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.11.12.tar.xz
xz -cd linux-4.11.12.tar.xz | tar xvf -
cd linux-4.11.12
# patch rt to kernel
xzcat ../patch-4.11.12-rt10.patch.xz | patch -p1
make defconfig # default is x86_64_config
make
```

至此，新的kernel编译成功



### 安装内核

```
sudo make modules_install install
remove the GRUB_HIDDEN_TIMEOUT_QUIET line from /etc/default/grub
increase the GRUB_DEFAULT timeout from 0 to 15 seconds
sudo update-grub2
```



### 虚拟机安装测试

虚拟机硬盘配置：

- 处理器 i7-6700K中的2个核心处理器
- 内存 3G
- 硬盘 50G

系统配置：

- Ubuntu14.04

启动配置：

- GRUB，多内核选择启动
  - 4.4.0-31-generic
  - 4.4.79-rt92



## 运行和测试

### 测试场景思考

**方案一：Kernel.org上的Realtime测试方法**

在kernel.org上的官方测试方法，Thomas Gleixner撰写了一个测试负载系统的实时能力的工具*cyclictest*。对于每一个CPU逻辑核心，都跑一个单独的线程，每个线程都在一个独立的进程当中，测试内核的线程调度能力。

注意，*cyclictest*需要运行持续一段时间，等待调度算法稳定后的结果才能说明当前系统的调度时延，短时间内的调度快慢不足以说明系统的实时性，非RT系统有可能在短时间内恰好快于RT系统。



**方案二：opersys.com/lrtbf/上的Linux RT Benchmarking Framework**

该实验需要三台机器

- Target机器：测试不同的kernel的运行情况
- Logger机器：发送/接收/记录来自Target机器的数据，最后生成报表
- Host机器：主控制机器，存储发送的数据和Ping Flood的发送源，压力测试的来源

可生成的报表内容包括

数据积累的实现消耗，中断的响应时间

[报告样式传送门](http://www.opersys.com/lrtbf/?#LatestResults)

由于该实验需要三台机器来进行，目前条件下不可进行，且结果预估也是RT系统比非RT系统性能更好，所以暂时决定先不进行该实验，如有需要，后续再进行实验测试。



### 通用测试脚本

**方案一：**

```bash
git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
cd rt-tests
sudo apt-get install libnuma-dev # acquired
make
```



### 测试脚本运行

**方案一**

```
#################### non-RT OS ####################
>> sudo ./cyclictest -a -t -n -p99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 0.25 0.11 0.04 1/299 1856

T: 0 (1853) P:99 I:1000 C:  20832 Min:      5 Act:  232 Avg:  425 Max:   23436
T: 1 (1854) P:99 I:1500 C:  13988 Min:      9 Act:  297 Avg:  427 Max:   25291

####################   RT OS   ####################
>> sudo ./cyclictest -a -t -n -p99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 0.18 0.19 0.18 1/353 9062

T: 0 (9061) P:99 I:1000 C:  9087 Min:      7 Act:  328 Avg:  406 Max:   4636
T: 1 (9062) P:99 I:1500 C:  6118 Min:     10 Act:  367 Avg:  410 Max:   1366
```

最右边的那一列代表着最重要的测试结果，最大值比平均值重要，评价实时系统的最重要指标。



### 常用平台对比

上述测试是在常用的平台Ubuntu14.04下进行的，两个内核分别是官方内核4.4.0-31-generic和实时内核4.4.79-rt92

最大值对比：

|                  | CPU0  | CPU1  |
| :--------------: | :---: | :---: |
| 4.4.0-31-generic | 23436 | 25291 |
|   4.4.79-rt92    | 4636  | 1366  |

从上述结果的最差情况分析，官方内核跑出来的成绩是25.291毫秒，而实时内核跑出来的成绩达到了4.636毫秒，是前者的1/4的时间延迟。



平均值对比：

|                  | CPU0 | CPU1 |
| :--------------: | :--: | :--: |
| 4.4.0-31-generic | 425  | 427  |
|   4.4.79-rt92    | 406  | 410  |

从上述结果的平均值情况分析，官方内核跑出来的成绩是0.426毫秒，而实时内核跑出来的成绩达到了0.408毫秒，两者之间的区别相差不大。原因是测试平台基本都处于空闲的状态中，多次运行结果都在空闲状态所以平均值相差不大，评价实时系统的关键参数依然是最大值。



## 结论分析

RTOS的实现原理是给线程增加了一个priority参数，允许抢占式优先调度该线程，以达到调度时延最低。

上述实验结果中，可以很明显的看出，RTOS的实时性比原生的OS有明显的性能体现，最大时延上是原生的1/4时间。

在调研的过程中发现百度的Apollo内核中，也是使用了这个RT patch，并百度优化了以太网的驱动和解决了Nvidia驱动的bug。[^4] 之后可以使用Apollo调整过的内核。

----

[^1]: RTLinux Supported Machines, refer to [here](https://knowledge.windriver.com/en-us/000_Products/000/010/050/000/000_Wind_River_Linux_Getting_Started%2C_9/000/010)
[^2]: RTLinux Combinations of File System and Kernel Feature Profiles, refer to [here](https://knowledge.windriver.com/en-us/000_Products/000/010/050/000/000_Wind_River_Linux_Getting_Started%2C_9/010/000)
[^3]: ChronOS Linux File System, 查看patch发现仅修改任务调度算法来提供实时性，理论上不影响文件系统
[^4]: apollo kernel, refer to [here](https://github.com/ApolloAuto/apollo-kernel)
