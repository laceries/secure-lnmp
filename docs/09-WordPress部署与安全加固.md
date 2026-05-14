# 09 - WordPress 部署与安全加固

## 目标

部署 WordPress 作为真实业务载体，并完成基础安全加固，使 Secure-LNMP 不停留在静态页面，而是具备真实 PHP + MySQL 应用场景。

## 为什么选择 WordPress

本项目使用 WordPress 并不是为了单纯搭建博客，而是为了提供真实业务负载。

相比静态页面，WordPress 可以覆盖更多真实运维场景：

- PHP-FPM 动态请求处理；
- MySQL 数据库读写；
- 后台登录；
- 文件上传；
- 主题与插件管理；
- Web 访问日志；
- 错误排查；
- 备份恢复；
- 安全扫描；
- 后续监控与日志分析。

因此 WordPress 是 LNMP 运维实践中较合适的业务载体。

## 部署架构

```text
用户浏览器
   ↓ HTTPS
Nginx
   ↓ FastCGI
PHP-FPM
   ↓
WordPress
   ↓
MySQL 127.0.0.1:3306
```

## 数据库配置

为 WordPress 创建独立数据库和最小权限用户：

```sql
CREATE DATABASE IF NOT EXISTS wordpress
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'wp_user'@'127.0.0.1'
IDENTIFIED BY 'strong_password';

GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'127.0.0.1';

FLUSH PRIVILEGES;
```

安全点：

- 不使用 MySQL root 用户连接业务；
- 用户仅允许从 `127.0.0.1` 连接；
- 权限仅限 `wordpress` 数据库；
- 不使用 `'wp_user'@'%'`。

## WordPress 文件目录

网站目录：

```text
/var/www/example.com
```

使用 `/var/www/域名` 而不是 `/usr/local/nginx/html`，便于后续多站点管理。

## wp-config.php 配置

配置数据库连接：

```php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wp_user' );
define( 'DB_PASSWORD', 'strong_password' );
define( 'DB_HOST', '127.0.0.1' );
```

配置安全项：

```php
define( 'FORCE_SSL_ADMIN', true );
define( 'DISALLOW_FILE_EDIT', true );
define( 'WP_AUTO_UPDATE_CORE', 'minor' );
define( 'FS_METHOD', 'direct' );
```

含义：

| 配置 | 作用 |
|---|---|
| `FORCE_SSL_ADMIN` | 强制后台使用 HTTPS |
| `DISALLOW_FILE_EDIT` | 禁止后台直接编辑主题/插件代码 |
| `WP_AUTO_UPDATE_CORE` | 自动安装小版本安全更新 |
| `FS_METHOD` | 使用本地文件系统安装主题/插件 |

## 文件权限设计

核心原则：

- WordPress 核心文件尽量由 root 管理；
- `wp-content` 允许 PHP-FPM 用户写入；
- `wp-config.php` 权限更严格。

示例：

```bash
find /var/www/example.com -type d -exec chmod 755 {} \;
find /var/www/example.com -type f -exec chmod 644 {} \;

chown -R root:www /var/www/example.com
chown -R www:www /var/www/example.com/wp-content

chmod 640 /var/www/example.com/wp-config.php
```

说明：

| 目录 / 文件 | 权限策略 |
|---|---|
| WordPress 核心文件 | root 管理，减少被篡改风险 |
| `wp-content` | PHP-FPM 用户可写，用于上传、主题、插件 |
| `wp-config.php` | root 可写，www 可读，其他用户无权限 |

## WordPress 后台安全处理

已完成：

- 修改默认 `admin` 用户名；
- 使用强密码；
- 修正错误邮箱；
- 删除默认文章、页面和评论；
- 设置固定链接；
- 禁止开放用户注册。

检查是否允许用户注册：

```sql
SELECT option_name, option_value
FROM wp_options
WHERE option_name IN ('users_can_register','default_role');
```

期望：

```text
users_can_register = 0
```

## Nginx 层面 WordPress 安全规则

```nginx
location = /wp-config.php {
    deny all;
}

location = /xmlrpc.php {
    return 403;
}

location ~* ^/wp-content/uploads/.*\.php$ {
    deny all;
}

location ~* ^/(readme\.html|license\.txt)$ {
    deny all;
}
```

作用：

| 规则 | 作用 |
|---|---|
| 禁止访问 `wp-config.php` | 防止数据库密码泄露 |
| 禁用 `xmlrpc.php` | 减少暴力破解和 Pingback 滥用 |
| 禁止 uploads 执行 PHP | 防止上传 WebShell 后执行 |
| 禁止 readme/license | 减少 WordPress 指纹暴露 |

## 验证结果

### 首页

```bash
curl -I https://example.com/
```

期望：

```http
HTTP/1.1 200 OK
```

### 登录页

```bash
curl -I https://example.com/wp-login.php
```

期望：

```http
HTTP/1.1 200 OK
```

### xmlrpc.php

```bash
curl -I https://example.com/xmlrpc.php
```

期望：

```http
HTTP/1.1 403 Forbidden
```

### wp-config.php

```bash
curl -I https://example.com/wp-config.php
```

期望：

```http
HTTP/1.1 403 Forbidden
```

## 安全意义

WordPress 是常见攻击目标。基础加固可以降低以下风险：

- 默认 admin 用户被爆破；
- `xmlrpc.php` 被滥用；
- `wp-config.php` 泄露数据库密码；
- 上传目录执行 WebShell；
- 版本和指纹信息泄露；
- 后台文件编辑被用于植入恶意代码。

## 面试可讲点

可以这样讲：

> 我选择 WordPress 作为真实业务载体，是为了让 LNMP 平台具备真实的 PHP-FPM、MySQL、后台登录、文件上传、权限管理和安全扫描场景。部署时我没有使用 MySQL root 账户，而是创建独立数据库和最小权限用户；同时从 Nginx 和 WordPress 配置两层加固，包括禁用 xmlrpc、保护 wp-config、禁止 uploads 执行 PHP、修改默认 admin 用户和强制后台 HTTPS。

## 注意事项

- 不要上传 `wp-config.php` 到 GitHub；
- 不要安装来源不明的破解主题或插件；
- 插件数量越多，攻击面越大；
- 后续需要加入定期备份和更新策略。
