# linux系统下sd卡的备份与恢复

现在各种的开发板都是从sd卡上面启动的，因此大修改工作之前很有必要备份一下。

### 备份

1. 在linux系统下用读卡器读取sd卡
2. 用`df -h`命令看分区的路径
	一般都是/dev/sdb1或者/dev/sdc2之类的
3. 备份命令为
`sudo dd if=/dev/sdb of=/home/Rpi_backup.img`
这里根据自己的实际情况修改命令，sdb即为整个sd卡，后面不带数字

### 恢复

在Windows系统下用Win32DiskImager烧写sd卡

在Linux系统下用命令恢复
`sudo dd if=/home/Ppi_backup.img of=/dev/sdb`

### 后注

无论是备份还是恢复，速度都是根据自己的硬盘读写速度，只要命令没报错，那么就是命令正在运行，只是没有提示语，耐心等等就好