## 目标
从官方源码编译安装 MySQL 8.0.34。

## 操作环境
+ 系统：Ubuntu 24.04 LTS
+ MySQL版本：8.0.34
+ 时间：2026.4.28

## 操作步骤
### 步骤1：安装编译依赖
+ 命令：`apt install -y cmake libncurses-dev libaio-dev libssl-dev pkg-config libtirpc-dev`
+ 解释：
    - `cmake`：MySQL使用的构建工具
    - `libncurses-dev`：终端界面库
    - `libaio-dev`：异步IO库
    - `libssl-dev`：SSL库
    - `pkg-config`：用于查找系统库路径（编译过程中才发现缺失）
    - `libtirpc-dev`：RPC头文件库（编译过程中才发现缺失）

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777326930125-b329ec94-9c68-4490-a1b8-283552909240.png)

### 步骤2：下载源码
+ 命令：`cd /usr/local/src && wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.34.tar.gz`
+ 解释：进入源码目录，从MySQL官网下载8.0.34版本源码包。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777327103406-a670586b-2afd-423b-a9e8-5bd8306e76df.png)

### 步骤3：解压
+ 命令：`tar -xzf mysql-8.0.34.tar.gz && cd mysql-8.0.34`
+ 解释：解压并进入源码目录。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777327138777-54aa7136-da1d-4b7e-8343-bdb77f4b2c5a.png)

### 步骤4：下载Boost库
+ 命令：

```bash
wget https://archives.boost.io/release/1.77.0/source/boost_1_77_0.tar.bz2
tar -xjf boost_1_77_0.tar.bz2
解释：MySQL 8.0 编译依赖 Boost 1.77.0。在国内服务器上使用 archives.boost.io 镜像下载。
```

### <font style="color:rgb(15, 17, 21);">步骤5：创建build目录并配置CMake</font>
<font style="color:rgb(15, 17, 21);">命令：</font>

+ <font style="color:rgb(15, 17, 21);">bash</font>

```plain
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_unicode_ci -DWITH_BOOST=/usr/local/src/mysql-8.0.34/boost_1_77_0 -DWITH_TIRPC=system
```

+ <font style="color:rgb(15, 17, 21);">解释：</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DCMAKE_INSTALL_PREFIX=/usr/local/mysql</font>`<font style="color:rgb(15, 17, 21);">：指定安装路径</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DDEFAULT_CHARSET=utf8mb4</font>`<font style="color:rgb(15, 17, 21);">：设置默认字符集（支持emoji）</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DDEFAULT_COLLATION=utf8mb4_unicode_ci</font>`<font style="color:rgb(15, 17, 21);">：设置默认排序规则</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DWITH_BOOST=路径</font>`<font style="color:rgb(15, 17, 21);">：指定手动下载的Boost路径</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DWITH_TIRPC=system</font>`<font style="color:rgb(15, 17, 21);">：使用系统的libtirpc（Ubuntu 24.04需要）</font>
    - <font style="color:rgb(15, 17, 21);">CMake不允许在源码目录直接编译，需要创建独立的 build 目录</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777328266535-f431a315-725b-40b7-b1b2-860d4999e4c7.png)

### 步骤6：编译并安装（耗时20-40分钟）
#### 命令：`make && make install`
+ 解释：编译源码并安装到指定路径。这一步时间较长，耐心等待。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777402151218-31151403-1bb0-47dd-91f4-8d3afd0b1d82.png)

#### <font style="color:rgb(15, 17, 21);">执行 </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/mysql/bin/mysql --version</font>`<font style="color:rgb(15, 17, 21);"> 看到版本号</font>
+ <font style="color:rgb(15, 17, 21);"> MySQL 编译安装完成后，首先验证 MySQL 客户端程序是否可以正常执行。  </font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777402936619-5e28fc68-1c88-40fa-8411-070b26b162ce.png)

+ `/usr/local/mysql/bin/mysql` 客户端程序已成功生成； 
+  当前安装版本为 MySQL 8.0.34； 
+ `Source distribution` 表示该版本来自源码编译安装； 

#### <font style="color:rgb(15, 17, 21);">执行 </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/mysql/bin/mysqld --version</font>`，验证服务端可以正常执行
<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777403287516-04cf26d4-67ee-4cab-9367-5bd97077caee.png)

### 步骤7.1：创建 MySQL 运行用户和相关目录
MySQL 编译安装完成后，不能仅仅验证 `mysql` 和 `mysqld` 程序是否存在，还需要继续完成服务初始化前的准备工作。

由于当前实验是在 `root` 账户下进行的，因此执行系统管理命令时不需要额外添加 `sudo`。

但需要注意：虽然当前操作用户是 `root`，MySQL 服务本身不应该直接以 `root` 用户身份运行。  
为了降低安全风险，需要创建专门的 `mysql` 系统用户，用于运行 MySQL 服务进程。

#### 1. 创建 mysql 用户组和系统用户
执行命令：

```bash
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
```

命令解释：

+ `groupadd mysql`：创建 `mysql` 用户组； 
+ `useradd`：创建系统用户； 
+ `-r`：创建系统账户； 
+ `-g mysql`：指定该用户属于 `mysql` 用户组； 
+ `-s /bin/false`：禁止该用户直接登录系统； 
+ `mysql` 用户仅用于运行 MySQL 服务进程

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777403957207-04b23ce4-1098-40d7-a1e9-c897989adf5b.png)

创建完成后，使用以下命令验证：

```plain
id mysql
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404132044-15a17309-2bc3-4615-ac5b-c5be17f0eccc.png)

看到 `uid`、`gid` 和 `groups` 信息，说明 `mysql` 系统用户创建成功。

#### 2. 创建 MySQL 相关目录
MySQL 初始化和运行过程中需要使用数据目录、日志目录和运行目录。

执行命令：

```plain
mkdir -p /usr/local/mysql/data
mkdir -p /var/log/mysql
mkdir -p /var/run/mysqld
mkdir -p /usr/local/mysql/mysql-files
```

目录说明：

+ `/usr/local/mysql/data`：MySQL 数据目录，用于存放数据库文件； 
+ `/var/log/mysql`：MySQL 日志目录，用于存放错误日志； 
+ `/var/run/mysqld`：MySQL 运行目录，用于存放 pid 文件等运行时文件； 
+ `/usr/local/mysql/mysql-files`：用于限制 MySQL 文件导入导出操作的安全目录。 

#### 3. 设置目录权限
MySQL 安装目录中的程序文件不应该由 `mysql` 用户随意修改，因此安装目录主体保持 `root:root`。

但数据目录、日志目录、运行目录需要由 `mysql` 用户读写。

执行命令：

```plain
chown -R root:root /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql/data
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /usr/local/mysql/mysql-files
chmod 750 /usr/local/mysql/mysql-files
```

权限说明：

+ `/usr/local/mysql`：MySQL 安装目录，归 `root` 管理； 
+ `/usr/local/mysql/data`：MySQL 数据目录，归 `mysql` 用户管理； 
+ `/var/log/mysql`：MySQL 日志目录，归 `mysql` 用户管理； 
+ `/var/run/mysqld`：MySQL 运行目录，归 `mysql` 用户管理； 
+ `/usr/local/mysql/mysql-files`：MySQL 文件导入导出目录，限制权限为 `750`。 

#### 4. 验证用户和目录权限
执行命令：

```plain
ls -ld /usr/local/mysql
ls -ld /usr/local/mysql/data
ls -ld /var/log/mysql
ls -ld /var/run/mysqld
ls -ld /usr/local/mysql/mysql-files
```

+ `/usr/local/mysql` 属主为 `root root`； 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404310821-f557f8e0-dc9d-410b-bcd0-83fafdb39090.png)

+ `/usr/local/mysql/data` 属主为 `mysql mysql`； 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404332007-f1da6791-eb44-4563-b420-6ad0290b60ed.png)

+ `/var/log/mysql` 属主为 `mysql mysql`； 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404346933-bdc34f1a-d6b3-47ae-8941-0853c55a7cb3.png)

+ `/var/run/mysqld` 属主为 `mysql mysql`； 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404374601-335a53cb-1d34-4aed-9bb7-ef828d9f82f9.png)

+ `/usr/local/mysql/mysql-files` 属主为 `mysql mysql`，权限为 `750`。 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777404390169-5dd27f80-6b8b-40ec-bc20-db65a0de933e.png)

### 步骤7.2：编写 MySQL 配置文件 `/etc/my.cnf`
在创建好 `mysql` 系统用户、数据目录、日志目录和运行目录后，需要继续编写 MySQL 的主配置文件。

MySQL 启动时会读取配置文件中的参数，用于确定安装目录、数据目录、日志路径、socket 文件路径、端口、字符集等核心信息。

本次源码安装的 MySQL 安装路径为：

```bash
/usr/local/mysql
```

因此配置文件中的 `basedir`、`datadir` 等路径需要与实际安装路径保持一致。

#### 1. 编辑 `/etc/my.cnf`
执行命令：

```plain
vim /etc/my.cnf
```

写入以下内容：

```plain
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
pid-file=/var/run/mysqld/mysqld.pid
port=3306
user=mysql

character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

log-error=/var/log/mysql/error.log
secure-file-priv=/usr/local/mysql/mysql-files

[client]
socket=/tmp/mysql.sock
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4
```

#### 2. 配置项说明
+ `basedir=/usr/local/mysql`：指定 MySQL 的安装目录； 
+ `datadir=/usr/local/mysql/data`：指定 MySQL 的数据目录； 
+ `socket=/tmp/mysql.sock`：指定本地连接使用的 socket 文件； 
+ `pid-file=/var/run/mysqld/mysqld.pid`：指定 MySQL 运行时 pid 文件路径； 
+ `port=3306`：指定 MySQL 默认监听端口； 
+ `user=mysql`：指定 MySQL 服务进程以 `mysql` 用户身份运行； 
+ `character-set-server=utf8mb4`：设置服务端默认字符集为 `utf8mb4`； 
+ `collation-server=utf8mb4_unicode_ci`：设置默认排序规则； 
+ `log-error=/var/log/mysql/error.log`：指定 MySQL 错误日志文件； 
+ `secure-file-priv=/usr/local/mysql/mysql-files`：限制 MySQL 文件导入导出目录，提高安全性； 
+ `[client]`：客户端连接配置； 
+ `[mysql]`：MySQL 命令行客户端配置。 

#### 3. 验证配置文件内容
保存配置文件后，执行命令查看：

```plain
cat /etc/my.cnf
```

如果能够看到刚才写入的配置内容，说明 `/etc/my.cnf` 配置文件创建成功。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777405316044-1cb099d7-1ca0-43c1-aaf1-9a808c7c4383.png)

### 步骤7.3：初始化 MySQL 数据目录，并获取 root 临时密码。
#### 1. 执行初始化命令
初始化 MySQL 数据目录：

```plain
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
```

命令说明：

+ `mysqld --initialize`：初始化 MySQL 数据目录； 
+ `--user=mysql`：指定初始化过程以 `mysql` 用户身份执行； 
+ `--basedir=/usr/local/mysql`：指定 MySQL 安装目录； 
+ `--datadir=/usr/local/mysql/data`：指定 MySQL 数据目录。 

初始化成功后，MySQL 会在错误日志中生成 root 用户的临时密码。

#### 2. 获取临时密码
执行以下命令查看 MySQL 错误日志并找到临时密码：

```plain
sudo cat /var/log/mysql/error.log | grep 'temporary password'
```

root@localhost: Y6bvfD;kFlfy

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777406396614-006bb853-9b71-4557-bc9b-a79f0008dddb.png)

#### 3. 检查目录内容
在继续之前，我们确认数据目录已经初始化：

```plain
ls -lh /usr/local/mysql/data
```

### 步骤7.4：创建 systemd 服务文件
源码编译安装的 MySQL 不会自动生成 systemd 服务文件，因此需要手动创建 `mysqld.service`，方便后续使用 `systemctl` 管理 MySQL 服务。

创建服务文件：

```bash
vim /etc/systemd/system/mysqld.service
```

写入以下内容：

```plain
[Unit]
Description=MySQL Server
After=network.target

[Service]
Type=forking
User=mysql
Group=mysql
PIDFile=/var/run/mysqld/mysqld.pid
ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecStop=/usr/local/mysql/support-files/mysql.server stop
ExecReload=/usr/local/mysql/support-files/mysql.server restart
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

配置说明：

+ `Description=MySQL Server`：服务描述； 
+ `After=network.target`：表示网络服务启动后再启动 MySQL； 
+ `Type=forking`：MySQL 启动脚本会以 fork 方式启动后台进程； 
+ `User=mysql`、`Group=mysql`：指定 MySQL 服务以 `mysql` 用户和用户组运行； 
+ `PIDFile`：指定 MySQL pid 文件路径； 
+ `ExecStart`：指定 MySQL 启动命令； 
+ `ExecStop`：指定 MySQL 停止命令； 
+ `Restart=on-failure`：服务异常退出时自动重启； 
+ `WantedBy=multi-user.target`：设置服务开机自启时挂载到多用户运行级别。 

重新加载 systemd 配置：

```plain
systemctl daemon-reload
```

启动 MySQL：

```plain
systemctl start mysqld
```

查看服务状态：

```plain
systemctl status mysqld
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777407178984-29bfca47-1891-467e-be11-cdb973445a94.png)

### 步骤7.5：设置 root 密码并启动 MySQL 服务
使用临时密码登录 MySQL，设置 root 密码。

1. **登录 MySQL**  
使用临时密码登录：

```plain
/usr/local/mysql/bin/mysql -uroot -p
```

输入在 **步骤7.3** 中获取的临时密码。

2. **修改 root 密码**  
登录后，执行以下 SQL 命令来修改 root 密码：

```plain
ALTER USER 'root'@'localhost' IDENTIFIED BY '新的密码';
```

注意：

+  密码需要使用英文单引号包裹； 
+  不要在密码前添加 `*`； 
+  文档中不要记录真实密码，可以使用 `<root_password>` 代替。
3. **刷新权限**  
执行完修改后，刷新权限：

```plain
FLUSH PRIVILEGES;
```

4. **退出 MySQL**  
完成后，退出 MySQL：

```plain
exit;
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777408119337-f4297a8f-c15a-44f8-86e0-f7ca6a9a5ef7.png)

使用新密码重新登录验证：

```plain
/usr/local/mysql/bin/mysql -uroot -p
```

如果能够正常进入 MySQL 命令行，说明 root 密码修改成功。

### 步骤7.6：设置 MySQL 开机自启并重启验证
为了让 MySQL 在服务器重启后自动启动，需要启用 `mysqld` 服务。

执行命令：

```bash
systemctl enable mysqld
```

如果命令执行成功，说明 MySQL 已经设置为开机自启。

随后重启服务器进行验证：

```plain
reboot
```

服务器重启后，查看 MySQL 服务状态：

```plain
systemctl status mysqld
```

如果看到：

```plain
Active: active (running)
```

说明 MySQL 服务已经成功实现开机自启。

至此，MySQL 源码编译安装、初始化、服务管理和开机自启配置完成。

### 步骤7.7：MySQL 功能验证
MySQL 服务启动并设置开机自启后，还需要进一步验证数据库功能是否正常。

登录 MySQL：

```bash
/usr/local/mysql/bin/mysql -uroot -p
```

进入 MySQL 后执行：

```plain
SELECT VERSION();
SHOW DATABASES;
CREATE DATABASE test_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
DROP DATABASE test_db;
SHOW DATABASES;
```

验证内容：

+ `SELECT VERSION()`：确认当前 MySQL 版本； 
+ `SHOW DATABASES`：查看系统数据库； 
+ `CREATE DATABASE test_db`：测试数据库创建功能； 
+ `DROP DATABASE test_db`：测试数据库删除功能。 

如果以上命令均能正常执行，说明 MySQL 服务已经可以正常使用。

## <font style="color:rgb(15, 17, 21);">遇到的坑</font>
1. **<font style="color:rgb(15, 17, 21);">CMake报错“Please do not build in-source”</font>**<font style="color:rgb(15, 17, 21);">：CMake不允许直接在源码目录编译。解决方法是创建独立的 build 目录（</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">mkdir build && cd build</font>`<font style="color:rgb(15, 17, 21);">），然后用</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">cmake ..</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">指向上级目录的源码。</font>
2. **<font style="color:rgb(15, 17, 21);">CMake下载Boost失败</font>**<font style="color:rgb(15, 17, 21);">：国内服务器访问 Boost 官方源超时。尝试了多个镜像后发现腾讯云404、官方源下载的是假HTML文件。最终使用</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">https://archives.boost.io/release/1.77.0/source/boost_1_77_0.tar.bz2</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">下载成功。</font>
3. **<font style="color:rgb(15, 17, 21);">Boost文件是HTML而非压缩包</font>**<font style="color:rgb(15, 17, 21);">：官方源下载的</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">.tar.bz2</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">文件被</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">file</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">命令识别为</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">HTML document</font>`<font style="color:rgb(15, 17, 21);">，说明官方源重定向到了网页。用</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">archives.boost.io</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">镜像解决。</font>
4. **<font style="color:rgb(15, 17, 21);">cmake报错“Could NOT find PkgConfig”</font>**<font style="color:rgb(15, 17, 21);">：编译过程中发现缺少 pkg-config 工具。</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">apt install -y pkg-config</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">解决。</font>
5. **<font style="color:rgb(15, 17, 21);">cmake报错“Could not find rpc/rpc.h”</font>**<font style="color:rgb(15, 17, 21);">：Ubuntu 24.04 中 RPC 头文件需要安装 </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">libtirpc-dev</font>`<font style="color:rgb(15, 17, 21);">，并用 </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">-DWITH_TIRPC=system</font>`<font style="color:rgb(15, 17, 21);"> 指定路径。</font>
6. **MySQL 客户端无法连接 socket**

执行：

```bash
/usr/local/mysql/bin/mysql -uroot -p
```

报错：

```plain
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)
```

原因：

MySQL 服务还没有启动，且源码编译安装后并不会自动创建 systemd 服务文件。

解决：

手动创建 `/etc/systemd/system/mysqld.service`，然后执行：

```plain
systemctl daemon-reload
systemctl start mysqld
systemctl status mysqld
```

确认服务为 `active (running)` 后，再重新连接 MySQL。

7. **systemctl enable mysqld 失败**

执行：

```plain
systemctl enable mysqld
```

报错：

```plain
Failed to enable unit: "multi-user.targ" is not a valid unit name.
```

原因：

`mysqld.service` 文件中 `[Install]` 部分的 `WantedBy` 写错，将 `multi-user.target` 误写成了 `multi-user.targ`。

解决：

修改服务文件：

```plain
[Install]
WantedBy=multi-user.target
```

然后重新加载 systemd：

```plain
systemctl daemon-reload
systemctl enable mysqld
```

再次执行后成功设置开机自启。

