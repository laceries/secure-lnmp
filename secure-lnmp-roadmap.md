# Secure-LNMP 项目路线图

## 项目定位

Secure-LNMP 是一个 Linux 运维 / 初级 SRE 方向实践项目。

项目目标不是简单搭建一个博客，而是从裸服务器开始，完成源码级 LNMP 部署，并围绕真实 WordPress 业务站点建设安全加固、HTTPS、扫描验证、服务托管、监控、日志、备份恢复、自动化部署和故障演练能力。

## 当前阶段

当前项目已完成：

```text
LNMP 源码编译
SSH / fail2ban 安全加固
MySQL 本地监听限制
Nginx 安全加固
HTTPS
WordPress 业务站点
安全扫描验证
systemd 服务管理
```

下一阶段重点：

```text
Prometheus + Grafana 可观测性建设
```

## 阶段总览

| 阶段 | 内容 | 状态 |
|---|---|---|
| Phase 1 | LNMP 源码编译 | 已完成 |
| Phase 2 | SSH / MySQL / Nginx 安全加固 | 已完成 |
| Phase 3 | HTTPS 与证书续期 | 已完成 |
| Phase 4 | WordPress 业务站点部署 | 已完成 |
| Phase 5 | nmap / Nikto 安全扫描验证 | 已完成 |
| Phase 6 | systemd 服务管理 | 已完成 |
| Phase 7 | Prometheus + Grafana 监控 | 待开始 |
| Phase 8 | Loki + Promtail 日志采集 | 待开始 |
| Phase 9 | 备份恢复 | 待开始 |
| Phase 10 | Ansible 自动化 | 待开始 |
| Phase 11 | 故障演练与复盘 | 待开始 |

## Phase 1：LNMP 源码编译

### 目标

从源码编译部署 Nginx、MySQL、PHP，掌握 Web 服务基础组件的构建和配置流程。

### 已完成

- Nginx 1.24.0 源码编译；
- MySQL 8.0 源码编译；
- PHP 8.2.10 源码编译；
- PHP-FPM 与 Nginx FastCGI 对接；
- WordPress 基础运行环境验证。

### 文档

- `docs/01-环境准备.md`
- `docs/02-源码编译Nginx.md`
- `docs/03-源码编译MySQL.md`
- `docs/04-源码编译PHP.md`

## Phase 2：安全加固

### 目标

完成服务器公网暴露后的基础安全加固。

### 已完成

#### SSH

- 禁止 root 远程登录；
- 限制最大认证尝试次数；
- 部署 fail2ban；
- 观察到 1000+ SSH 登录失败记录。

#### MySQL

- 3306 仅监听 `127.0.0.1`；
- 关闭 33060；
- WordPress 使用最小权限数据库账户。

#### Nginx

- 隐藏版本号；
- 添加安全响应头；
- 限制请求体大小；
- 配置请求限速；
- 拦截隐藏文件、备份文件和敏感路径。

### 文档

- `docs/05-SSH安全加固.md`
- `docs/06-MySQL安全加固.md`
- `docs/07-Nginx安全加固.md`

## Phase 3：HTTPS

### 目标

为站点启用 HTTPS，保障后台登录、Cookie 和用户请求不再明文传输。

### 已完成

- 使用 Let's Encrypt 申请证书；
- 配置 HTTP 自动跳转 HTTPS；
- 配置 ACME 验证路径；
- 配置证书自动续期；
- 续期后自动 reload Nginx；
- 完成 `certbot renew --dry-run` 演练。

### 文档

- `docs/08-HTTPS配置与证书续期.md`

## Phase 4：WordPress 业务站点

### 目标

部署真实 PHP + MySQL 应用，作为后续监控、日志、备份和故障演练的业务载体。

### 已完成

- WordPress 安装与初始化；
- 独立数据库与最小权限用户；
- 管理员账号修复；
- 修改默认 admin 用户名；
- 删除默认文章、页面和评论；
- 禁用 xmlrpc.php；
- 禁止上传目录执行 PHP；
- 保护 wp-config.php；
- 首页和项目展示页建设中。

### 文档

- `docs/09-WordPress部署与安全加固.md`

## Phase 5：安全扫描验证

### 目标

使用工具验证安全加固效果，形成“发现 → 整改 → 复扫”的闭环。

### 已完成

- nmap 关键端口扫描；
- nmap Top 100 常见端口扫描；
- Nikto Web 安全扫描；
- 修复 PHP 版本泄露；
- 修复 WordPress 指纹响应头；
- 关闭 ETag；
- 验证敏感路径拦截效果。

### 文档

- `docs/10-安全扫描验证.md`

## Phase 6：systemd 服务管理

### 目标

将源码编译安装的 Nginx 和 PHP-FPM 纳入 systemd 管理。

### 已完成

- 编写 `nginx.service`；
- 编写 `php-fpm.service`；
- 配置 PID 文件；
- 配置启动前语法检查；
- 配置异常退出自动重启；
- 配置开机自启；
- 验证 80 / 443 / 9000 端口正常。

### 文档

- `docs/11-systemd服务管理.md`

## Phase 7：Prometheus + Grafana 监控

### 目标

建设基础可观测性能力，使站点状态可视化。

### 计划内容

- 部署 Prometheus；
- 部署 Grafana；
- 部署 node_exporter；
- 接入 Nginx 指标；
- 接入 MySQL 指标；
- 配置基础告警规则；
- 制作 Grafana Dashboard。

### 预期产出

- `docs/12-Prometheus与Grafana监控.md`
- `configs/prometheus/prometheus.yml`
- `configs/prometheus/rules/lnmp-alerts.yml`
- Grafana Dashboard 截图

## Phase 8：Loki + Promtail 日志采集

### 目标

集中采集 Nginx、PHP-FPM、MySQL、SSH 等日志，支持问题追踪。

### 计划内容

- 部署 Loki；
- 部署 Promtail；
- 采集 Nginx access/error log；
- 采集 PHP-FPM 日志；
- 采集 MySQL error log；
- 采集 SSH / fail2ban 日志；
- 在 Grafana 中查询 4xx/5xx、慢请求、异常 IP。

### 预期产出

- `docs/13-Loki与Promtail日志采集.md`
- `configs/loki/loki-config.yml`
- `configs/loki/promtail-config.yml`

## Phase 9：备份与恢复

### 目标

实现 WordPress 数据库、上传文件和配置文件的自动备份，并完成恢复演练。

### 计划内容

- 编写 MySQL 备份脚本；
- 备份 `wp-content/uploads`；
- 备份 Nginx / MySQL / PHP 配置；
- 配置 cron 定时任务；
- 设置备份保留策略；
- 进行数据库误删恢复演练。

### 预期产出

- `scripts/backup-wordpress.sh`
- `docs/14-备份与恢复演练.md`

## Phase 10：Ansible 自动化

### 目标

将配置下发、安全加固和服务管理流程剧本化。

### 计划内容

- 编写 inventory；
- 编写基础 playbook；
- 管理 Nginx 配置；
- 管理 PHP-FPM 配置；
- 管理 MySQL 配置；
- 管理 systemd unit；
- 管理备份脚本。

### 预期产出

- `ansible/site.yml`
- `ansible/roles/`

## Phase 11：故障演练与复盘

### 目标

通过故障注入验证监控、日志、恢复和回滚能力。

### 计划演练

| 故障 | 验证目标 |
|---|---|
| kill MySQL 进程 | 验证 systemd / 监控 / 业务异常表现 |
| 磁盘空间压力 | 验证磁盘告警和备份保留策略 |
| Nginx 配置错误 | 验证 `nginx -t` 预检查和回滚流程 |

### 预期产出

- `reports/incidents/01-mysql-process-killed.md`
- `reports/incidents/02-disk-pressure.md`
- `reports/incidents/03-nginx-config-error.md`

## 简历叙事主线

项目可以概括为：

> 基于 Ubuntu 云服务器源码编译 LNMP，部署 WordPress 真实业务站点，并围绕公网安全加固、HTTPS、扫描验证、服务托管和后续可观测性建设，模拟生产环境 Linux 运维 / SRE 工作流程。
