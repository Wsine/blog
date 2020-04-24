# Linux命令——用户和用户组管理

### 命令groupadd

> 作用：新增组
> 格式：`groupadd [-g GID] groupname`
> 参数：`-g`，指定GID，一般从500开始
> 说明：一般不必加-g参数；信息保存在`/etc/group`

### 命令groupdel

> 作用：删除组
> 格式：`groupdel groupname`
> 说明：信息保存在`/etc/group`

### 命令useradd

> 作用：增加用户
> 格式：`useradd [选项] username`
> 参数：`-u UID`，自定义UID
> 参数：`-g GID`，自定义GID
> 参数：`-d`，自定义home目录
> 参数：`-M`，不建立home目录
> 参数：`-s`，自定义shell

### 命令userdel

> 作用：删除用户
> 格式：`userdel [-r] username`
> 参数：`-r`，同时删除home目录

### 命令passwd

> 作用：修改用户密码
> 格式：`passwd [username]`
> 说明：默认修改当前用户密码；root账户可修改任意账户密码

### 命令su

> 作用：切换为root用户
> 说明：使用命令`exit`退出root用户

### 命令sudo

> 作用：临时获得root权限
> 用法：在任意命令前添加`sudo`即可
> 说明：能够使用`sudo`的用户信息保存`/etc/sudoers`文件中，格式为`root ALL=(ALL) ALL`，第一项是用户名

### 不允许root远程登陆Linux

打开`/etc/sshd/sshd_config`文件，修改`#PermitRootLogin yes`为`PermitRootLogin no`，保存配置文件后，`service sshd restart`重启sshd服务