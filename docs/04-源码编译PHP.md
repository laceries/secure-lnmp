# 04 - 源码编译 PHP

## 目标

从官方源码编译安装 PHP 8.2，启用 FPM 模式，与 Nginx 和 MySQL 联动。

## 操作环境

| 项目     | 值                |
| ------ | ---------------- |
| 系统     | Ubuntu 24.04 LTS |
| PHP 版本 | 8.2.10           |
| 安装路径   | /usr/local/php   |
| Nginx  | 1.24.0（已安装）      |
| MySQL  | 8.0.34（已安装）      |
| 时间     | 2026.05.02       |

## 操作步骤

### 步骤 1：安装编译依赖

```bash
apt install -y libxml2-dev libsqlite3-dev libcurl4-openssl-dev \
  libonig-dev libsodium-dev libargon2-dev
```

| 包名                   | 作用                  |
| -------------------- | ------------------- |
| libxml2-dev          | XML 解析库             |
| libsqlite3-dev       | SQLite 数据库库         |
| libcurl4-openssl-dev | HTTP 请求库（curl 扩展依赖） |
| libonig-dev          | 正则表达式库（mbstring 依赖） |
| libsodium-dev        | 现代加密库               |
| libargon2-dev        | 密码哈希库               |

### 步骤 2：下载源码

```bash
cd /usr/local/src
wget https://www.php.net/distributions/php-8.2.10.tar.gz
```

### 步骤 3：解压

```bash
tar -xzf php-8.2.10.tar.gz && cd php-8.2.10
```

### 步骤 4：配置编译选项

```bash
./configure \
  --prefix=/usr/local/php \
  --enable-fpm \
  --with-mysqli \
  --with-pdo-mysql \
  --with-openssl \
  --with-zlib \
  --with-curl \
  --enable-mbstring
```

| 参数                      | 作用                                  |
| ----------------------- | ----------------------------------- |
| --prefix=/usr/local/php | 安装路径                                |
| --enable-fpm            | 启用 PHP-FPM（FastCGI Process Manager） |
| --with-mysqli           | 启用 MySQLi 扩展（PHP 连接 MySQL）          |
| --with-pdo-mysql        | 启用 PDO MySQL 驱动                     |
| --with-openssl          | 启用 SSL 支持                           |
| --with-zlib             | 启用 gzip 压缩                          |
| --with-curl             | 启用 HTTP 请求（WordPress 等应用依赖）         |
| --enable-mbstring       | 启用多字节字符串处理（UTF-8 支持）                |

为什么用 FPM 模式：Nginx 本身不能执行 PHP，需要通过 FastCGI 协议把 .php 请求转发给 PHP-FPM 处理。这是 Nginx + PHP 的标准架构。

### 步骤 5：编译并安装

```bash
make && make install
```

### 步骤 6：配置 PHP-FPM

```bash
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
```

为什么用 php.ini-production 而不是 development：

* production 版本关闭了错误显示（display_errors = Off），防止泄露代码路径
* production 版本日志更严格，适合线上环境

### 步骤 7：启动 PHP-FPM

```bash
/usr/local/php/sbin/php-fpm
```

PHP-FPM 默认监听 127.0.0.1:9000。

### 步骤 8：配置 Nginx 对接 PHP

编辑 /usr/local/nginx/conf/nginx.conf，在 server 块中添加：

```nginx
location ~ \.php$ {
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include        fastcgi_params;
}
```

重载 Nginx：

```bash
/usr/local/nginx/sbin/nginx -s reload
```

### 步骤 9：验证 LNMP 联通

```bash
cat > /usr/local/nginx/html/info.php << 'EOF'
<?php
phpinfo();
?>
EOF
```

浏览器访问 [http://服务器IP/info.php，看到](http://服务器IP/info.php，看到) PHP 信息页即成功。

验证要点：

* PHP 版本显示 8.2.10
* 能找到 mysqli 和 pdo_mysql 模块
* Server API 显示 FPM/FastCGI

安全提醒：验证完成后必须删除 info.php！

```bash
rm /usr/local/nginx/html/info.php
```

## 遇到的坑

| # | 问题                                         | 原因                      | 解决                                                                                                     |
| - | ------------------------------------------ | ----------------------- | ------------------------------------------------------------------------------------------------------ |
| 1 | PHP-FPM 报错 cannot get gid for group nobody | 默认配置使用 nobody 用户但系统中不可用 | 创建专用用户 groupadd www && useradd -r -g www -s /bin/false www，修改 [www.conf](http://www.conf) 中 user/group |
