# Secure-LNMP

> 基于 Ubuntu 云服务器，从源码编译部署 Nginx、MySQL、PHP，并围绕真实 WordPress 站点完成 HTTPS、安全加固、扫描验证和服务托管的 Linux 运维 / SRE 实践项目。

## 项目简介

Secure-LNMP 是一个面向 Linux 运维 / 初级 SRE 方向的个人实践项目。

项目从一台 Ubuntu 24.04 云服务器开始，不使用一键面板，而是通过源码编译方式部署 Nginx、MySQL、PHP，并以 WordPress 作为真实业务载体，逐步完成 SSH 安全加固、MySQL 本地监听限制、Nginx 安全响应头、HTTPS 证书、WordPress 安全加固、nmap/Nikto 扫描验证以及 systemd 服务管理。

该项目不是单纯搭建一个博客，而是模拟真实生产环境中 Web 服务上线后的安全加固、验证和运维管理流程。

## 在线站点

- 站点地址：<https://zhyru.top/>
- GitHub 仓库：<https://github.com/laceries/secure-lnmp>

## 技术栈

| 组件 | 版本 / 说明 | 安装方式 |
|---|---|---|
| 操作系统 | Ubuntu 24.04.4 LTS | 云服务器 |
| Web 服务 | Nginx 1.24.0 | 源码编译 |
| 数据库 | MySQL 8.0 | 源码编译 |
| 后端运行环境 | PHP 8.2.10 + PHP-FPM | 源码编译 |
| 业务应用 | WordPress | 手动部署 |
| HTTPS | Let's Encrypt | certbot |
| 安全防护 | fail2ban、Nginx 安全规则 | 手动配置 |
| 扫描验证 | nmap、Nikto | apt |
| 服务管理 | systemd | 自定义 unit |
| 版本管理 | Git / GitHub | GitHub Desktop |

## 已完成内容

### 1. LNMP 源码编译

- Nginx 1.24.0 源码编译安装；
- MySQL 8.0 源码编译、初始化和 systemd 管理；
- PHP 8.2.10 源码编译，启用 PHP-FPM；
- 完成 Nginx 与 PHP-FPM 的 FastCGI 对接。

### 2. SSH 安全加固

- 禁止 root 远程登录；
- 限制 SSH 最大认证尝试次数；
- 部署 fail2ban 自动封禁异常 IP；
- 清理云平台安全组，仅保留必要端口；
- 服务器累计检测到 1000+ 次 SSH 登录失败记录。

### 3. MySQL 安全加固

- 将 MySQL 3306 监听地址从 `0.0.0.0` 收缩到 `127.0.0.1`；
- 关闭 MySQL X Protocol 33060 端口；
- WordPress 使用独立数据库和最小权限账户；
- 避免数据库服务直接暴露公网。

### 4. Nginx 安全加固

- 隐藏 Nginx 版本号；
- 添加安全响应头；
- 配置请求限速；
- 拦截隐藏文件、备份文件和敏感路径；
- 隐藏 PHP / WordPress 指纹响应头；
- 关闭 ETag，减少指纹泄露。

### 5. HTTPS 配置

- 使用 Let's Encrypt 申请 HTTPS 证书；
- 配置 HTTP 自动跳转 HTTPS；
- 保留 ACME 验证路径；
- 配置证书自动续期；
- 续期成功后自动 reload Nginx。

### 6. WordPress 业务站点

- 部署 WordPress 作为真实 PHP + MySQL 应用载体；
- 配置独立数据库用户；
- 修改默认 admin 用户名；
- 启用 HTTPS 后台；
- 禁用后台文件编辑；
- 禁用 xmlrpc.php；
- 禁止上传目录执行 PHP；
- 保护 wp-config.php；
- 删除默认文章、页面和评论。

### 7. 安全扫描验证

- 使用 nmap 验证公网仅开放 22 / 80 / 443；
- 验证 MySQL 3306 / 33060 未暴露公网；
- 使用 Nikto 扫描 Web 安全问题；
- 修复 PHP 版本泄露、ETag 指纹泄露、WordPress 响应头泄露等问题；
- 对敏感路径进行复测验证。

### 8. systemd 服务管理

- 为源码编译 Nginx 编写 systemd unit；
- 为源码编译 PHP-FPM 编写 systemd unit；
- 实现统一启停、开机自启、配置预检查和异常自动重启。

## 文档目录

| 编号 | 文档 | 内容 |
|---|---|---|
| 01 | [环境准备](docs/01-环境准备.md) | 系统初始化与依赖安装 |
| 02 | [源码编译 Nginx](docs/02-源码编译Nginx.md) | Nginx 编译安装 |
| 03 | [源码编译 MySQL](docs/03-源码编译MySQL.md) | MySQL 编译、初始化与服务管理 |
| 04 | [源码编译 PHP](docs/04-源码编译PHP.md) | PHP-FPM 编译与 Nginx 对接 |
| 05 | [SSH 安全加固](docs/05-SSH安全加固.md) | SSH 与 fail2ban 加固 |
| 06 | [MySQL 安全加固](docs/06-MySQL安全加固.md) | bind-address 与 33060 关闭 |
| 07 | [Nginx 安全加固](docs/07-Nginx安全加固.md) | 安全响应头、限速、敏感路径 |
| 08 | [HTTPS 配置与证书续期](docs/08-HTTPS配置与证书续期.md) | Let's Encrypt 与自动续期 |
| 09 | [WordPress 部署与安全加固](docs/09-WordPress部署与安全加固.md) | WordPress 业务站点与加固 |
| 10 | [安全扫描验证](docs/10-安全扫描验证.md) | nmap / Nikto 扫描与整改 |
| 11 | [systemd 服务管理](docs/11-systemd服务管理.md) | Nginx / PHP-FPM 服务托管 |

## 后续计划

- Prometheus + Grafana 监控体系；
- Loki + Promtail 日志采集；
- WordPress 数据库与文件备份恢复；
- Ansible 自动化部署；
- MySQL 进程异常、磁盘空间压力、Nginx 配置错误等故障演练。

## 项目亮点

- 不依赖面板，从源码编译部署 LNMP；
- 使用 WordPress 作为真实业务载体，而不是静态页面；
- 覆盖系统、数据库、Web、PHP、WordPress 多层安全加固；
- 使用 nmap / Nikto 完成扫描验证与整改闭环；
- 将源码编译服务纳入 systemd 管理，接近生产环境运维方式。

## 注意事项

本仓库只保存脱敏后的文档和配置示例，不包含：

- 数据库密码；
- WordPress `wp-config.php`；
- 证书私钥；
- 服务器 SSH 私钥；
- 真实邮箱；
- 其他敏感信息。
