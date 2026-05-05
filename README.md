# Secure-LNMP

> 从零构建安全加固的 LNMP Web 平台，覆盖源码编译、安全基线、监控告警、自动化部署全流程。

## 项目背景

基于 Ubuntu 24.04 云服务器，以源码编译方式部署 Nginx 1.24 + MySQL 8.0 + PHP 8.2，在此基础上实施系统级安全加固、可观测性建设和自动化运维，模拟真实生产环境的 SRE 工作流程。

## 架构图

[用户] --HTTPS--> [Nginx:443] --> [PHP-FPM:9000] --> [MySQL:3306(仅本机)]
                       |
                       ├── [Prometheus] --> [Grafana]
                       ├── [Loki] <-- [Promtail]
                       └── [fail2ban] <-- /var/log/auth.log

## 技术栈

| 组件 | 版本 | 安装方式 | 状态 |
|------|------|----------|------|
| Ubuntu | 24.04.4 LTS | 云服务器 | ✅ |
| Nginx | 1.24.0 | 源码编译 | ✅ |
| MySQL | 8.0.34 | 源码编译 | ✅ |
| PHP | 8.2.10 | 源码编译 | ✅ |
| OpenSSL | 3.0.13 | 系统自带 | ✅ |
| fail2ban | 最新 | apt | ✅ |

## 已完成进度

- [x] Phase 1：LNMP 源码编译
- [x] Phase 2：SSH 安全加固 + fail2ban 自动封禁 + 安全组清理
- [ ] Phase 2 续：MySQL 加固 + Nginx 加固 + HTTPS
- [ ] Phase 3：WordPress 双站点部署
- [ ] Phase 4：Prometheus + Grafana 监控体系
- [ ] Phase 5：Loki + Promtail 日志采集
- [ ] Phase 6：Ansible 自动化部署
- [ ] Phase 7：故障演练与收尾

## 文档目录

| # | 文档 | 内容 |
|---|------|------|
| 01 | [环境准备](docs/01-环境准备.md) | 系统初始化、依赖安装 |
| 02 | [源码编译 Nginx](docs/02-源码编译Nginx.md) | Nginx 编译参数与验证 |
| 03 | [源码编译 MySQL](docs/03-源码编译MySQL.md) | MySQL 编译、初始化与 systemd 配置 |
| 04 | [源码编译 PHP](docs/04-源码编译PHP.md) | PHP-FPM 编译与 Nginx 对接 |
| 05 | [SSH 安全加固](docs/05-SSH安全加固.md) | SSH 配置加固 + fail2ban 部署 |

## License

MIT
