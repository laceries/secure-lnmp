## 目标
将全新 Ubuntu 24.04 服务器准备好，安装编译 LNMP 所需的基础工具。

## 操作环境
+ 系统：Ubuntu 24.04 LTS
+ 用户：root
+ 时间：2026.4.28

## 操作步骤
### 步骤1：更新系统
+ 命令：`apt update && apt upgrade -y`
+ 解释：同步软件源并升级所有包，确保系统处于最新状态。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325251695-aace2a83-32e8-4165-a59c-2c4a4e1f474f.png)

### 步骤2：安装编译依赖
+ 命令：`apt install -y build-essential libpcre2-dev libssl-dev zlib1g-dev wget`
+ 解释：安装编译工具链和 Nginx 必须的三个库。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325298586-5e491282-b156-4ebe-bcf5-1046facc4fdd.png)

## 验证
执行 `gcc --version`，看到版本号说明编译工具链就绪。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325333443-af0df5de-3173-47d1-8ea7-385ef042716b.png)

## 遇到的坑
+ <font style="color:rgb(15, 17, 21);">更新后终端提示 </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">outdated binaries</font>`<font style="color:rgb(15, 17, 21);">，重新登录即可，不影响后续操作。</font>

