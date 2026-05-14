# 11 - systemd 服务管理

## 目标

将源码编译安装的 Nginx 和 PHP-FPM 纳入 systemd 管理，实现：

- `systemctl` 统一启停；
- 启动前配置语法检查；
- 服务异常退出后自动重启；
- 开机自启；
- 更接近生产环境的服务托管方式。

## 背景

Nginx 和 PHP-FPM 均为源码编译安装，默认不会像 apt 安装的软件一样自动生成 systemd 服务文件。

如果仅使用以下方式手动启动：

```bash
/usr/local/nginx/sbin/nginx
/usr/local/php/sbin/php-fpm
```

会存在问题：

- 服务器重启后服务不会自动恢复；
- 无法统一使用 systemctl 管理；
- 服务异常退出后不一定自动拉起；
- 缺少启动前配置检查；
- 运维可维护性较差。

因此需要手动编写 systemd unit。

## Nginx systemd 服务

服务文件路径：

```text
/etc/systemd/system/nginx.service
```

示例：

```ini
[Unit]
Description=NGINX HTTP Server (source compiled)
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

关键项说明：

| 配置 | 作用 |
|---|---|
| `Type=forking` | Nginx 启动后会进入后台 |
| `PIDFile` | 指定 Nginx master PID 文件 |
| `ExecStartPre` | 启动前执行 `nginx -t` |
| `ExecReload` | 支持 `systemctl reload nginx` |
| `ExecStop` | 使用 QUIT 信号优雅停止 |
| `Restart=on-failure` | 异常退出时自动重启 |
| `WantedBy` | 支持开机自启 |

## PHP-FPM PID 配置

为了让 systemd 正确识别 PHP-FPM master 进程，需要在：

```text
/usr/local/php/etc/php-fpm.conf
```

中配置：

```ini
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
```

并创建目录：

```bash
mkdir -p /usr/local/php/var/run /usr/local/php/var/log
```

## PHP-FPM systemd 服务

服务文件路径：

```text
/etc/systemd/system/php-fpm.service
```

示例：

```ini
[Unit]
Description=PHP FastCGI Process Manager (source compiled)
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/php/var/run/php-fpm.pid
ExecStartPre=/usr/local/php/sbin/php-fpm -t
ExecStart=/usr/local/php/sbin/php-fpm --fpm-config /usr/local/php/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
PrivateTmp=true
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

关键项说明：

| 配置 | 作用 |
|---|---|
| `Type=forking` | PHP-FPM 启动后进入后台 |
| `PIDFile` | 指定 PHP-FPM master PID 文件 |
| `ExecStartPre` | 启动前检查 PHP-FPM 配置 |
| `ExecReload` | 使用 USR2 平滑重载 |
| `ExecStop` | 使用 QUIT 优雅停止 |
| `Restart=on-failure` | 异常退出自动拉起 |

## systemd 加载与启动

创建 service 文件后执行：

```bash
systemctl daemon-reload
```

启动服务：

```bash
systemctl start php-fpm
systemctl start nginx
```

设置开机自启：

```bash
systemctl enable php-fpm
systemctl enable nginx
```

## 验证结果

### 1. 查看运行状态

```bash
systemctl status nginx --no-pager -l
systemctl status php-fpm --no-pager -l
```

期望：

```text
Active: active (running)
```

### 2. 查看是否开机自启

```bash
systemctl is-enabled nginx
systemctl is-enabled php-fpm
```

期望：

```text
enabled
enabled
```

### 3. 查看 MainPID

```bash
systemctl show nginx -p MainPID -p ActiveState -p SubState
systemctl show php-fpm -p MainPID -p ActiveState -p SubState
```

期望：

```text
ActiveState=active
SubState=running
MainPID=非0
```

### 4. 查看端口

```bash
ss -tlnp | grep -E ":80|:443|:9000"
```

期望：

```text
0.0.0.0:80
0.0.0.0:443
127.0.0.1:9000
```

### 5. 验证网站

```bash
curl -I https://example.com/
curl -I https://example.com/wp-login.php
```

期望：

```http
HTTP/1.1 200 OK
Server: nginx
```

## 安全与运维意义

将源码编译服务纳入 systemd 后，具备：

- 标准化启停；
- 开机自启；
- 配置错误预检查；
- 异常退出自动恢复；
- 与系统日志集成；
- 更方便后续 Ansible 自动化。

## 面试可讲点

可以这样讲：

> 因为 Nginx 和 PHP-FPM 都是源码编译安装，默认没有 systemd unit。我手动编写了 nginx.service 和 php-fpm.service，配置 PIDFile、ExecStartPre、ExecReload、Restart 等参数，实现 systemctl 统一管理、开机自启、启动前配置检查和异常自动重启。这让源码编译服务更接近生产环境管理方式。

## 注意事项

- `PIDFile` 必须和服务实际生成的 PID 文件一致；
- 修改 service 文件后必须执行 `systemctl daemon-reload`；
- 不要在已有手动启动进程未停止时重复启动多个实例；
- 如果服务启动失败，应使用 `journalctl -u 服务名` 查看日志。
