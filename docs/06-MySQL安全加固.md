# 06 - MySQL 安全加固

## 目标

对源码编译安装的 MySQL 进行基础安全加固，避免数据库服务直接暴露在公网，并关闭项目暂不使用的 MySQL X Protocol 端口。

## 背景

服务器安全检查时发现 MySQL 初始状态监听在所有网卡地址：

```text
*:3306
*:33060
```

这意味着如果云平台安全组或主机防火墙被误配置，数据库可能直接暴露到公网。

对于当前单机 LNMP 架构，PHP-FPM 和 MySQL 部署在同一台服务器上，WordPress 只需要从本机连接数据库，因此 MySQL 没有必要监听公网地址。

## 加固措施

### 1. 限制 MySQL 监听地址

在 `/etc/my.cnf` 的 `[mysqld]` 段中增加：

```ini
bind-address=127.0.0.1
```

作用：

- 让 MySQL 只监听本机回环地址；
- 只有本机进程可以连接数据库；
- 外部公网无法直接访问 MySQL 3306。

### 2. 关闭 MySQL X Protocol

在 `[mysqld]` 段中增加：

```ini
mysqlx=0
```

作用：

- 关闭 MySQL X Protocol；
- 关闭 33060 端口；
- 减少不必要攻击面。

## 关键配置

```ini
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
pid-file=/var/run/mysqld/mysqld.pid
port=3306
bind-address=127.0.0.1
mysqlx=0
user=mysql

character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

log-error=/var/log/mysql/error.log
secure-file-priv=/usr/local/mysql/mysql-files
```

## 操作摘要

```bash
cp /etc/my.cnf /etc/my.cnf.bak.$(date +%Y%m%d)

sed -i '/^port=3306/a bind-address=127.0.0.1\nmysqlx=0' /etc/my.cnf

systemctl restart mysqld
```

## 验证结果

检查端口监听：

```bash
ss -tlnp | grep -E "3306|33060"
```

期望结果：

```text
LISTEN 0 151 127.0.0.1:3306 0.0.0.0:* users:(("mysqld",...))
```

验证点：

- 3306 仅监听 `127.0.0.1`；
- 33060 不再出现；
- 从公网使用 nmap 扫描时，3306 / 33060 不应为 open。

## 安全意义

该加固体现了纵深防御思想：

- 即使云安全组被误开放，MySQL 仍不接受公网连接；
- WordPress 通过本机地址访问数据库，不影响业务；
- 关闭不使用的 33060 端口，减少攻击面；
- 业务数据库账户也只授权本机访问，避免使用 `%` 作为来源。

## 面试可讲点

可以这样讲：

> 我检查端口时发现 MySQL 默认监听在所有网卡地址。虽然云安全组没有放行 3306，但这属于纵深防御不足。因此我将 `bind-address` 改为 `127.0.0.1`，并关闭 MySQL X Protocol 的 33060 端口。加固后公网扫描无法访问数据库，WordPress 仍能通过本机正常连接。

## 注意事项

- 如果未来 MySQL 独立部署到其他服务器，需要改为内网 IP，并配合安全组限制来源；
- 不建议使用 `'user'@'%'` 这类任意来源账户；
- 数据库密码和 WordPress `wp-config.php` 不应上传 GitHub。
