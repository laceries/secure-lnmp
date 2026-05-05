# 02 - 源码编译 Nginx

## 目标

从官方源码编译安装 Nginx，不依赖系统预编译包，实现版本与模块完全可控。

## 操作环境

| 项目       | 值                |
| -------- | ---------------- |
| 系统       | Ubuntu 24.04 LTS |
| Nginx 版本 | 1.24.0           |
| 安装路径     | /usr/local/nginx |
| 时间       | 2026.04.28       |

## 为什么源码编译而不是 apt install

1. 模块可控：可以精确选择需要的模块（如 --with-http_ssl_module），不装不需要的
2. 版本锁定：不被系统 apt 升级意外覆盖，生产环境版本一致性有保障
3. 安全审计：编译参数可追溯，符合等保/合规要求
4. 学习价值：理解 configure → make → make install 的标准构建流程

## 操作步骤

### 步骤 1：进入源码目录

```bash
cd /usr/local/src
```

/usr/local/src 是 Linux 约定俗成存放手动下载源码的目录。

### 步骤 2：下载源码

```bash
wget http://nginx.org/download/nginx-1.24.0.tar.gz
```

### 步骤 3：解压并进入

```bash
tar -xzf nginx-1.24.0.tar.gz && cd nginx-1.24.0
```

* tar：解压工具
* -x：解压（extract）
* -z：通过 gzip 解压（.gz 格式）
* -f：指定文件名
* &&：前一条成功后才执行后一条

### 步骤 4：配置编译选项

```bash
./configure \
  --prefix=/usr/local/nginx \
  --with-http_ssl_module \
  --with-http_gzip_static_module
```

| 参数                             | 作用                      |
| ------------------------------ | ----------------------- |
| --prefix=/usr/local/nginx      | 指定安装路径                  |
| --with-http_ssl_module         | 启用 HTTPS 支持（依赖 OpenSSL） |
| --with-http_gzip_static_module | 启用预压缩静态文件支持             |

configure 做什么：检测系统环境（编译器、库文件路径等），生成 Makefile。

### 步骤 5：编译并安装

```bash
make && make install
```

* make：按 Makefile 编译源码，生成二进制文件
* make install：把编译好的文件复制到 --prefix 指定的目录

### 步骤 6：启动 Nginx

```bash
/usr/local/nginx/sbin/nginx
```

### 步骤 7：验证

```bash
curl http://localhost
/usr/local/nginx/sbin/nginx -V
```

浏览器访问 [http://服务器IP，看到](http://服务器IP，看到) Welcome to nginx! 页面即成功。

## 编译参数记录

```
nginx version: nginx/1.24.0
built by gcc 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1)
built with OpenSSL 3.0.13 30 Jan 2024
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --with-http_ssl_module --with-http_gzip_static_module
```

## 遇到的坑

无
