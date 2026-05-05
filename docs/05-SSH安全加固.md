# 05 - SSH 安全加固

## 背景

服务器部署在公网后，SSH 22 端口立即遭到全球扫描器暴力破解。通过 lastb 观察到来自多个国家的 IP 使用 root、admin 等常见用户名持续尝试登录。通过 journalctl 观察到大量 kex_exchange_identification: Connection reset by peer 错误，这是自动化扫描脚本探测 SSH 服务的典型特征。

```
失败登录记录（部分）：
65.49.1.112    ssh:notty  May 5 22:43
61.240.213.113 ssh:notty  May 5 21:03   用户名: root
194.87.216.198 ssh:notty  May 5 20:53   用户名: admin（多次）
47.237.140.122 ssh:notty  May 5 20:10   用户名: root
139.64.10.139  ssh:notty  May 5 19:53   用户名: admin
```

## 加固措施

### 1. SSH 配置加固

修改 /etc/ssh/sshd_config：

| 配置项                  | 修改前   | 修改后 | 目的             |
| -------------------- | ----- | --- | -------------- |
| PermitRootLogin      | yes   | no  | 禁止 root 直接远程登录 |
| MaxAuthTries         | 6（默认） | 3   | 限制每连接认证尝试次数    |
| PubkeyAuthentication | 注释状态  | yes | 确保公钥认证可用       |
| PermitEmptyPasswords | 注释状态  | no  | 禁止空密码登录        |

操作流程：

```bash
# 备份
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)

# 修改配置
# 语法检查
sudo sshd -t

# 重载
sudo systemctl reload sshd
```

铁律：修改 SSH 配置时，永远保持当前终端不关。开新窗口测试。

### 2. fail2ban 自动封禁

fail2ban 监控日志文件，当某个 IP 在短时间内多次认证失败，自动将其加入防火墙黑名单。

```bash
sudo apt update && sudo apt install -y fail2ban
```

创建配置文件 /etc/fail2ban/jail.d/sshd.conf：

```ini
[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
findtime = 600
bantime  = 3600
```

| 参数             | 含义                  |
| -------------- | ------------------- |
| enabled = true | 启用此规则               |
| filter = sshd  | 使用 sshd 过滤器匹配登录失败日志 |
| logpath        | 监控的日志文件路径           |
| maxretry = 3   | 触发封禁的失败次数           |
| findtime = 600 | 检测时间窗口（10 分钟）       |
| bantime = 3600 | 封禁持续时间（1 小时）        |

翻译：某个 IP 10 分钟内 SSH 登录失败 3 次，自动封禁 1 小时。

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. 云平台安全组清理

| 端口    | 操作 | 原因         |
| ----- | -- | ---------- |
| 888   | 删除 | 不必要的管理端口   |
| 8000  | 删除 | 未使用的测试端口   |
| 13626 | 删除 | 未使用        |
| 24020 | 删除 | 未使用        |
| 22    | 保留 | SSH        |
| 80    | 保留 | HTTP       |
| 443   | 保留 | HTTPS（待配置） |

面试知识点：云服务器安全防线是两层叠加——云平台安全组 + 服务器内防火墙。流量必须两层都放行才能进来。

## 验证结果

```
$ sudo sshd -T | grep -E "permitrootlogin|maxauthtries"
permitrootlogin no
maxauthtries 3

$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 1
`- Actions
   |- Currently banned: 0
   |- Total banned: 0
```

## 效果总结

* root 远程登录被完全阻断
* 暴力破解 IP 在 10 分钟内失败 3 次后自动封禁 1 小时
* 攻击面从 7 个开放端口缩减至 3 个（22/80/443）
