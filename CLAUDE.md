# Claude Code 操作规则

本仓库是 Secure-LNMP 项目，用于记录基于 Ubuntu 云服务器源码编译 LNMP、部署 WordPress、完成安全加固、扫描验证、systemd 服务管理，并继续建设监控、日志、备份和故障演练能力。

## 你的主要职责

你可以协助完成以下任务：

1. 整理 Markdown 文档
   - README.md
   - secure-lnmp-roadmap.md
   - docs/ 下的阶段文档
   - troubleshooting 文档
   - incident report 文档

2. 整理脱敏配置示例
   - configs/nginx/
   - configs/mysql/
   - configs/php/
   - configs/systemd/
   - configs/prometheus/
   - configs/loki/

3. 检查仓库结构
   - 发现缺失文档
   - 检查链接是否失效
   - 检查 Markdown 格式
   - 检查是否存在明显敏感文件名

4. 辅助生成脚本草稿
   - 健康检查脚本
   - 备份脚本
   - 监控部署脚本
   - 日志采集配置
   - Ansible Playbook 草稿

5. 辅助分析只读命令输出
   - systemctl 状态
   - ss 端口监听
   - curl 响应头
   - nmap / Nikto 扫描结果
   - Prometheus / Grafana 配置

## 远程服务器访问规则

允许通过以下 SSH Host 访问服务器：

```bash
ssh secure-lnmp-read
```

该用户是低权限只读用户，仅用于查看状态。

允许执行的远程只读命令包括：

```bash
ssh secure-lnmp-read "whoami; hostname; date; uptime"
ssh secure-lnmp-read "systemctl is-active nginx php-fpm mysqld fail2ban"
ssh secure-lnmp-read "systemctl is-enabled nginx php-fpm mysqld fail2ban"
ssh secure-lnmp-read "ss -tln | grep -E ':22|:80|:443|:9000|:3306|:33060' || true"
ssh secure-lnmp-read "ps -eo user,pid,cmd | grep -E '[n]ginx|[p]hp-fpm|[m]ysqld'"
ssh secure-lnmp-read "curl -I -s https://zhyru.top/ | head -30"
ssh secure-lnmp-read "curl -I -s https://zhyru.top/secure-lnmp/ | head -30"
ssh secure-lnmp-read "curl -I -s https://zhyru.top/wp-login.php | head -30"
```

允许读取的内容仅限于非敏感状态信息，例如：

- 服务是否运行
- 服务是否开机自启
- 端口监听状态
- HTTP 响应头
- 进程列表
- 网站可达性

## 严禁执行的远程命令

无论任何情况，你都不能主动执行以下命令：

```bash
sudo
su
rm
mv
cp
chmod
chown
vim
nano
sed -i
systemctl start
systemctl stop
systemctl restart
systemctl reload
kill
pkill
mysql
mysqldump
certbot
ufw
iptables
apt install
apt remove
```

也不能执行任何会修改服务器状态的命令。

## 严禁读取的远程文件

你不能读取以下路径或文件：

```text
/root/*
/etc/shadow
/etc/sudoers
/home/*/.ssh/*
/var/www/*/wp-config.php
/etc/letsencrypt/*
*.pem
*.key
*.crt
/root/wordpress-db.txt
/root/wp-admin-login.txt
```

如果需要分析相关配置，只能要求用户提供脱敏后的片段。

## 敏感信息规则

你不能要求用户提供：

- SSH 私钥
- 数据库密码
- WordPress 管理员密码
- 证书私钥
- API Token
- 真实邮箱完整内容
- 云厂商 SecretId / SecretKey

如果发现仓库中疑似存在敏感文件，应提醒用户删除并加入 .gitignore。

## 修改仓库文件规则

你可以修改本地仓库文件，但需要遵守：

1. 不生成真实密码、私钥、证书；
2. 不生成 wp-config.php；
3. 配置示例必须使用 example.com、xxx.top、[your_email@example.com](mailto:your_email@example.com) 等占位符；
4. 所有配置文件必须脱敏；
5. 修改前先说明计划；
6. 修改后总结变更列表。

## 服务器修改规则

如果你判断服务器需要修改配置，只能输出建议命令，例如：

```bash
# 建议用户人工执行
sudo nginx -t
sudo systemctl reload nginx
```

你不能通过 SSH 自行执行这些修改命令。

## 当前项目状态摘要

已完成：

- Nginx 1.24.0 源码编译
- MySQL 8.0 源码编译
- PHP 8.2.10 源码编译
- WordPress 业务站点部署
- SSH 禁 root 与 MaxAuthTries 加固
- fail2ban 自动封禁
- MySQL bind-address=127.0.0.1
- 关闭 MySQL 33060
- Nginx 安全响应头
- HTTPS 与证书自动续期
- WordPress 基础安全加固
- nmap / Nikto 扫描验证
- Nginx / PHP-FPM systemd 管理

下一阶段：

- Prometheus + Grafana 监控
- Loki + Promtail 日志
- 备份恢复
- Ansible 自动化
- 故障演练

## 工作风格

回答时请：

- 先给结论；
- 再给操作步骤；
- 对命令进行简要解释；
- 不要一次性给过多危险命令；
- 对服务器修改保持保守；
- 对 GitHub 文档保持结构化、简洁、脱敏。
