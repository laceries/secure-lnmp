# Nginx 502 Bad Gateway 故障排查：PHP-FPM 异常

## 1. 故障背景

本项目使用源码编译方式部署 LNMP 环境：

- Nginx：监听 80 端口
- PHP-FPM：监听 127.0.0.1:9000
- MySQL：监听 3306 端口

Nginx 通过 FastCGI 将 PHP 请求转发给 PHP-FPM。

测试页面：

    /usr/local/nginx/html/health.php

页面内容：

    <?php
    echo "PHP-FPM OK\n";

## 2. 正常状态验证

首先检查 PHP-FPM 配置文件语法：

    /usr/local/php/sbin/php-fpm -t

输出结果：

    configuration file /usr/local/php/etc/php-fpm.conf test is successful

访问 PHP 健康检查页面：

    curl -i http://127.0.0.1/health.php

正常返回：

    HTTP/1.1 200 OK
    PHP-FPM OK

说明 Nginx 与 PHP-FPM 联调正常。

## 3. 故障模拟

为了模拟 PHP-FPM 异常，向 PHP-FPM master 进程发送 QUIT 信号：

    kill -QUIT $(pgrep -xo php-fpm)

命令说明：

- `pgrep -xo php-fpm`：查找最早启动的 php-fpm 进程，通常是 master 进程
- `kill -QUIT`：发送平滑退出信号，让 PHP-FPM 正常停止

停止后检查 PHP-FPM 进程：

    ps -ef | grep '[p]hp-fpm'

无输出，说明 PHP-FPM 进程已经停止。

检查 9000 端口：

    ss -lntp | grep ':9000'

无输出，说明 PHP-FPM 监听端口已经消失。

## 4. 故障现象

再次访问 PHP 页面：

    curl -i http://127.0.0.1/health.php

返回结果：

    HTTP/1.1 502 Bad Gateway

说明 Nginx 能接收请求，但无法连接后端 PHP-FPM，因此返回 502。

## 5. 排查过程

检查 Nginx 进程：

    pgrep -a nginx

输出显示 Nginx master 和 worker 进程仍然存在，说明 Nginx 本身没有停止。

检查 PHP-FPM 进程：

    pgrep -a php-fpm

无输出，说明 PHP-FPM 未运行。

检查端口监听：

    ss -lntp | grep -E ':(80|9000|3306)'

结果显示：

- 80 端口仍由 Nginx 监听
- 3306 端口仍由 MySQL 监听
- 9000 端口消失

因此可以判断，故障点集中在 PHP-FPM。

查看 Nginx 错误日志：

    tail -n 30 /usr/local/nginx/logs/error.log

关键错误：

    connect() failed (111: Connection refused) while connecting to upstream
    upstream: "fastcgi://127.0.0.1:9000"

该日志说明 Nginx 在访问 FastCGI 后端 127.0.0.1:9000 时连接被拒绝，原因是 PHP-FPM 未运行或端口未监听。

## 6. 故障恢复

重新启动 PHP-FPM：

    /usr/local/php/sbin/php-fpm

检查 PHP-FPM 进程：

    ps -ef | grep '[p]hp-fpm'

检查 9000 端口：

    ss -lntp | grep ':9000'

再次访问 PHP 页面：

    curl -i http://127.0.0.1/health.php

恢复后返回：

    HTTP/1.1 200 OK
    PHP-FPM OK

## 7. 故障总结

本次故障原因为 PHP-FPM 服务停止，导致 Nginx 无法连接 FastCGI 后端 127.0.0.1:9000，从而返回 502 Bad Gateway。

排查思路：

1. 先确认 Nginx 是否正常运行
2. 再确认 PHP-FPM 进程是否存在
3. 检查 9000 端口是否监听
4. 查看 Nginx error.log
5. 根据日志定位 upstream 连接失败
6. 重启 PHP-FPM 并重新验证访问结果
