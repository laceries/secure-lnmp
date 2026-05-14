# 07 - Nginx 安全加固

## 目标

对源码编译安装的 Nginx 进行基础安全加固，减少版本指纹暴露，增加安全响应头，限制异常请求，并拦截敏感路径。

## 背景

Nginx 默认配置适合快速验证服务，但不适合直接暴露在公网环境。默认配置可能存在：

- 响应头暴露 Nginx 版本；
- 缺少安全响应头；
- 未限制请求体大小；
- 未配置请求限速；
- 隐藏文件、备份文件可能被直接访问；
- 未知 Host 或 IP 访问可能返回默认页面。

因此需要对 Nginx 进行安全加固。

## 加固内容

### 1. 低权限运行 Worker

```nginx
user www-data;
```

Nginx master 进程需要 root 权限绑定 80/443 端口，但 worker 进程应使用低权限用户运行。

验证：

```bash
ps -eo user,pid,ppid,cmd | grep '[n]ginx'
```

期望：

```text
root      nginx: master process
www-data  nginx: worker process
```

### 2. 隐藏版本号

```nginx
server_tokens off;
```

加固前：

```http
Server: nginx/1.24.0
```

加固后：

```http
Server: nginx
```

### 3. 添加安全响应头

```nginx
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

作用：

| 响应头 | 作用 |
|---|---|
| `X-Content-Type-Options` | 防止 MIME 类型嗅探 |
| `X-Frame-Options` | 降低点击劫持风险 |
| `X-XSS-Protection` | 启用旧浏览器 XSS 防护 |
| `Referrer-Policy` | 控制 Referer 信息泄露 |

### 4. 关闭 ETag

```nginx
etag off;
```

目的：

- 减少文件指纹信息暴露；
- 消除 Nikto 中关于 ETag 信息泄露的提示。

### 5. 隐藏 PHP / WordPress 指纹响应头

```nginx
fastcgi_hide_header X-Powered-By;
fastcgi_hide_header X-Redirect-By;
```

作用：

- 隐藏 `X-Powered-By: PHP/8.2.10`；
- 隐藏 `X-Redirect-By: WordPress`；
- 减少技术栈指纹暴露。

### 6. 限制请求体大小

```nginx
client_max_body_size 20m;
```

作用：

- 防止超大请求体消耗服务器资源；
- 满足 WordPress 上传主题、图片等基础需求。

### 7. 请求限速

```nginx
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req zone=general burst=20 nodelay;
```

作用：

- 按客户端 IP 限速；
- 缓解简单 CC 攻击和异常高频请求。

### 8. 默认拒绝未知 Host

```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
```

`444` 是 Nginx 特有状态码，表示直接断开连接，不返回响应内容。

目的：

- 减少通过 IP 或随机 Host 扫描时的信息暴露；
- 避免默认站点被直接访问。

### 9. 拦截隐藏文件和备份文件

```nginx
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}

location ~* \.(bak|old|orig|save|swp|sql|tar|gz|zip)$ {
    deny all;
    access_log off;
    log_not_found off;
}
```

目的：

- 防止 `.git`、`.env` 等隐藏文件泄露；
- 防止 `.bak`、`.sql`、`.zip` 等备份文件被下载。

## 验证结果

### 配置语法检查

```bash
/usr/local/nginx/sbin/nginx -t
```

期望：

```text
syntax is ok
test is successful
```

### 响应头检查

```bash
curl -I https://example.com/
```

期望：

```http
HTTP/1.1 200 OK
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
```

### 敏感头检查

```bash
curl -I https://example.com/ | grep -Ei "x-powered-by|x-redirect-by|etag" || echo "敏感响应头未发现"
```

期望：

```text
敏感响应头未发现
```

## 安全意义

Nginx 加固解决了以下问题：

- 减少服务端版本指纹泄露；
- 增加浏览器侧基础安全防护；
- 限制异常请求；
- 防止敏感文件直接暴露；
- 为后续 WordPress、日志、监控提供更安全的 Web 入口。

## 面试可讲点

可以这样讲：

> 我没有直接使用默认 Nginx 配置，而是围绕公网 Web 服务做了安全基线：隐藏版本号、添加安全响应头、限制请求体大小和请求速率、拦截隐藏文件和备份文件，并用 curl / Nikto 验证整改效果。Nikto 初扫发现的 PHP 版本、ETag、WordPress 指纹泄露项已被修复。

## 注意事项

- `client_max_body_size` 不宜无限制调大，应结合业务上传需求；
- `limit_req` 参数需要结合真实访问量调优，避免误伤正常用户；
- 当前 Nginx 未编译 HTTP/2 模块，因此未配置 `http2`。
