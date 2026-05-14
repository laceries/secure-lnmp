# 08 - HTTPS 配置与证书续期

## 目标

使用 Let's Encrypt 为站点签发 HTTPS 证书，并配置 Nginx 实现：

- HTTP 自动跳转 HTTPS；
- HTTPS 正常访问 WordPress；
- 证书自动续期；
- 续期后自动重载 Nginx。

## 背景

HTTP 是明文传输协议。WordPress 后台登录时会传输用户名、密码和 Cookie，如果不启用 HTTPS，可能存在中间人攻击和信息泄露风险。

本项目部署在境外云服务器，域名无需 ICP 备案，因此可以直接使用 80 / 443 端口，并通过 Let's Encrypt 申请免费证书。

## 为什么需要 HTTPS

HTTPS 主要提供：

1. **加密传输**：防止账号、Cookie 等敏感信息明文传输；
2. **身份认证**：证明当前服务器确实属于该域名；
3. **防中间人攻击**：浏览器会校验证书链、域名、有效期和私钥匹配关系。

对于 Secure-LNMP 项目，HTTPS 是安全加固中不可缺少的一环。

## 证书申请方式

由于 Nginx 是源码编译安装在 `/usr/local/nginx`，不是 apt 默认安装路径，因此没有使用 `certbot --nginx` 自动修改配置，而是采用更可控的方式：

```bash
certbot certonly --webroot \
  -w /usr/local/nginx/html \
  -d example.com \
  --email user@example.com \
  --agree-tos \
  --no-eff-email
```

参数说明：

| 参数 | 含义 |
|---|---|
| `certonly` | 只申请证书，不自动修改 Web 服务配置 |
| `--webroot` | 使用 Web 根目录完成 HTTP-01 验证 |
| `-w` | 指定验证文件所在网站根目录 |
| `-d` | 指定申请证书的域名 |
| `--email` | 证书过期提醒邮箱 |
| `--agree-tos` | 同意 Let's Encrypt 服务条款 |

证书生成后路径：

```text
/etc/letsencrypt/live/example.com/fullchain.pem
/etc/letsencrypt/live/example.com/privkey.pem
```

## ACME 验证路径

Let's Encrypt HTTP-01 验证会访问：

```text
http://example.com/.well-known/acme-challenge/随机文件
```

因此 Nginx 需要放行：

```nginx
location ^~ /.well-known/acme-challenge/ {
    root /usr/local/nginx/html;
    default_type text/plain;
    allow all;
}
```

注意：

项目中同时配置了禁止访问隐藏文件的规则：

```nginx
location ~ /\. {
    deny all;
}
```

如果不单独放行 `.well-known/acme-challenge/`，证书申请或续期会失败。

## Nginx HTTPS 配置摘要

```nginx
server {
    listen 80;
    server_name example.com;

    location ^~ /.well-known/acme-challenge/ {
        root /usr/local/nginx/html;
        default_type text/plain;
        allow all;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/example.com;
    index index.php index.html index.htm;
}
```

## 验证结果

### 1. 检查 443 端口

```bash
ss -tlnp | grep -E ":80|:443"
```

期望：

```text
0.0.0.0:80
0.0.0.0:443
```

### 2. 验证 HTTP 跳转 HTTPS

```bash
curl -I http://example.com/
```

期望：

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/
```

### 3. 验证 HTTPS 正常

```bash
curl -I https://example.com/
```

期望：

```http
HTTP/1.1 200 OK
Server: nginx
```

### 4. 查看证书有效期

```bash
openssl x509 -in /etc/letsencrypt/live/example.com/fullchain.pem -noout -issuer -subject -dates
```

## 自动续期

Let's Encrypt 证书有效期通常为 90 天。安装 certbot 后系统会创建自动续期任务。

查看定时器：

```bash
systemctl list-timers --all | grep -i certbot
```

创建续期后自动 reload Nginx 的 hook：

```bash
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
```

```bash
cat > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh << 'EOF'
#!/bin/bash
/usr/local/nginx/sbin/nginx -t && /usr/local/nginx/sbin/nginx -s reload
EOF
```

```bash
chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

## 续期演练

```bash
certbot renew --dry-run
```

期望：

```text
Congratulations, all simulated renewals succeeded
```

## 安全意义

HTTPS 配置解决了以下问题：

- WordPress 后台登录不再明文传输；
- 浏览器可以校验域名身份；
- HTTP 自动跳转 HTTPS，减少误访问 HTTP；
- 自动续期避免证书过期导致站点不可访问。

## 面试可讲点

可以这样讲：

> 因为我的 Nginx 是源码编译安装，不在 certbot 默认识别路径中，所以我没有使用 `certbot --nginx`，而是使用 `certonly --webroot` 手动申请证书，再自己配置 Nginx 的 80 跳转和 443 SSL server。同时保留 ACME 验证路径，并配置续期后自动 `nginx -t && reload`。

## 注意事项

- `privkey.pem` 是私钥，严禁上传 GitHub；
- 当前 Nginx 未编译 HTTP/2 模块，因此未配置 `http2`；
- 如果后续增加 `www.example.com` 或 `blog.example.com`，需要额外配置 DNS 和证书域名。
