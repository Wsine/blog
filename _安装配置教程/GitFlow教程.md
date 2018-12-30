# GitFlow教程

> 这份教程是博主学到的git基础，仅适合小团队使用，仅供参考

### 配置Git

配置github上面的账号，首先需要自己在git上注册一个账号

```bash
git config --global user.name "Your Name in Github"
git config --global user.email "email@domain.com"
```

### 创建仓库

```bash
cd your_project_dir
git init
```

### 克隆仓库

```bash
git clone address
```
address是在github上面显示的克隆地址

### 添加管理

```bash
git status # 随时查看管理的文件状态
git diff file.txt # 查看file.txt这份文件相对于上一次的提交修改了什么
git add file.txt # 确认这份文件的修改
git add . # 可以一次性添加全部文件的修改
git status # 查看状态更新
git commit -m "Modify file.txt" # 提交一版更新
```

### 推送到Github

```bash
git push origin master # 将当前分支推送到远程仓库上的master分支
```
如果没有配置过ssh，需要输入用户账号和密码

### 同步Github

```bash
git pull origin master # 从远程仓库同步代码回来
```

### 分支管理

策略一：
多人协同工作，一个master分支，每一个人一个子分支，完成的子分支merge到master中

```bash
git branch # 查看当前分支
git checkout -b peopleA # 创建peopleA分支并切换到该分支
git checkout peopleA # 切换到peopleA分支
```

策略二：
单人开发，一个master分支，一个dev分支，当通过的代码merge到master分支中，dev分支随意处理

```bash
git branch # 查看当前分支
git checkout -b dev # 创建dev分支并切换到该分支
git checkout dev # 切换到dev分支
```

### 合并分支

```bash
git checkout master # 切换回master分支
git merge --no-diff peopleA # 适合策略一，保留分支历史
git merge dev # 适合策略二,不保留分支历史
```

### 冲突处理

当merge和pull的时候都会有可能遇到冲突，执行相应的命令会有提示。
这时候使用开发工具查看代码中冲突的部分（下面类似的格式）解决冲突。


```
======

>>>>>>abc

<<<<<<

```

执行`git commit`得到解决冲突后的一个提交

解决冲突最后的办法：
回退到稳定的版本，手动合并文件，提交版本，强制覆盖推送

```bash
git log --pretty=oneline # 查看提交日志的commit值
git reset --hard 343n9n # 输入的是需要回退的版本的commit值
# 手动合并文件
git commit -m "a new commit" # 提交新版本
git push origin master --force # 强制覆盖推送
```

### 后记

原则上足够小型开发使用了，有问题可以在评论区说明。