# 03 - 源码编译 MySQL

## 目标

从官方源码编译安装 MySQL 8.0.34。

## 操作环境

| 项目       | 值                |
| -------- | ---------------- |
| 系统       | Ubuntu 24.04 LTS |
| MySQL 版本 | 8.0.34           |
| 安装路径     | /usr/local/mysql |
| 时间       | 2026.04.28       |

## 操作步骤

### 步骤 1：安装编译依赖

```bash
apt install -y cmake libncurses-dev libaio-dev libssl-dev pkg-config libtirpc-dev
```

| 包名             | 作用                          |
| -------------- | --------------------------- |
| cmake          | MySQL 使用的构建工具（替代 configure） |
| libncurses-dev | 终端界面库（mysql 客户端依赖）          |
| libaio-dev     | 异步 IO 库（InnoDB 引擎依赖）        |
| libssl-dev     | SSL 库                       |
| pkg-config     | 系统库路径查找工具                   |
| libtirpc-dev   | RPC 头文件库（Ubuntu 24.04 需要）   |

### 步骤 2：下载源码

```bash
cd /usr/local/src
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.34.tar.gz
```

### 步骤 3：解压

```bash
tar -xzf mysql-8.0.34.tar.gz && cd mysql-8.0.34
```

### 步骤 4：下载 Boost 库

```bash
wget https://archives.boost.io/release/1.77.0/source/boost_1_77_0.tar.bz2
tar -xjf boost_1_77_0.tar.bz2
```

MySQL 8.0 编译依赖 Boost 1.77.0，必须手动下载。

### 步骤 5：创建 build 目录并配置 CMake

```bash
mkdir build && cd build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
  -DDEFAULT_CHARSET=utf8mb4 \
  -DDEFAULT_COLLATION=utf8mb4_unicode_ci \
  -DWITH_BOOST=/usr/local/src/mysql-8.0.34/boost_1_77_0 \
  -DWITH_TIRPC=system
```

| 参数                        | 作用                             |
| ------------------------- | ------------------------------ |
| -DCMAKE_INSTALL_PREFIX    | 安装路径                           |
| -DDEFAULT_CHARSET=utf8mb4 | 默认字符集（支持 emoji）                |
| -DDEFAULT_COLLATION       | 默认排序规则                         |
| -DWITH_BOOST              | 指定 Boost 库路径                   |
| -DWITH_TIRPC=system       | 使用系统 libtirpc（Ubuntu 24.04 需要） |

为什么用 mkdir build：CMake 推荐 out-of-source build，不在源码目录直接编译。

### 步骤 6：编译并安装

```bash
make && make install
```

编译耗时约 20-40 分钟。

### 步骤 7：初始化配置

#### 7.1 创建 MySQL 运行用户

```bash
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
```

| 参数            | 含义                 |
| ------------- | ------------------ |
| -r            | 创建系统账户（UID < 1000） |
| -g mysql      | 指定用户组              |
| -s /bin/false | 禁止登录（最小权限原则）       |

为什么不用 root 运行 MySQL：如果 MySQL 被攻破，攻击者获得的是 mysql 用户权限而不是 root，限制了爆炸半径。

#### 7.2 创建目录

```bash
mkdir -p /usr/local/mysql/data
mkdir -p /var/log/mysql
mkdir -p /var/run/mysqld
mkdir -p /usr/local/mysql/mysql-files
```

#### 7.3 设置权限

```bash
chown -R root:root /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql/data
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /usr/local/mysql/mysql-files
chmod 750 /usr/local/mysql/mysql-files
```

权限设计原则：安装目录（二进制文件）归 root 防篡改，数据/日志/运行目录归 mysql 用户读写。

#### 7.4 编写配置文件

/etc/my.cnf：

```ini
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

| 配置项              | 作用                |
| ---------------- | ----------------- |
| basedir          | MySQL 安装目录        |
| datadir          | 数据存储目录            |
| socket           | 本地连接的 socket 文件路径 |
| pid-file         | 进程 ID 文件路径        |
| user=mysql       | 以 mysql 用户身份运行    |
| secure-file-priv | 限制文件导入导出目录（安全措施）  |

#### 7.5 初始化数据目录

```bash
/usr/local/mysql/bin/mysqld --initialize --user=mysql \
  --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
```

获取临时密码：

```bash
cat /var/log/mysql/error.log | grep 'temporary password'
```

#### 7.6 创建 systemd 服务

```bash
cat > /etc/systemd/system/mysqld.service << 'EOF'
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
EOF

systemctl daemon-reload
systemctl start mysqld
systemctl enable mysqld
```

为什么用 systemd：

* 进程崩溃时自动重启（Restart=on-failure）
* 统一管理：systemctl start/stop/status
* 开机自启：systemctl enable

#### 7.7 设置 root 密码

```bash
/usr/local/mysql/bin/mysql -uroot -p
```

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '<新密码>';
FLUSH PRIVILEGES;
exit;
```

#### 7.8 功能验证

```sql
SELECT VERSION();
SHOW DATABASES;
CREATE DATABASE test_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
DROP DATABASE test_db;
```

## 遇到的坑

| # | 问题                                     | 原因                       | 解决                                             |
| - | -------------------------------------- | ------------------------ | ---------------------------------------------- |
| 1 | CMake 报错 Please do not build in-source | CMake 不允许在源码目录编译         | mkdir build && cd build && cmake ..            |
| 2 | CMake 下载 Boost 失败                      | 源访问不稳定                   | 使用 archives.boost.io 镜像                        |
| 3 | 下载的 Boost 是 HTML 而非压缩包                 | 官方源重定向到网页                | 换 archives.boost.io 直链                         |
| 4 | Could NOT find PkgConfig               | 缺少 pkg-config            | apt install -y pkg-config                      |
| 5 | Could not find rpc/rpc.h               | Ubuntu 24.04 RPC 头文件位置变了 | apt install libtirpc-dev + -DWITH_TIRPC=system |
| 6 | mysql 客户端连不上 socket                    | MySQL 服务未启动              | 创建 systemd 服务并启动                               |
| 7 | systemctl enable mysqld 失败             | WantedBy 拼写错误            | 修正为 multi-user.target                          |
