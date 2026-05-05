## 目标
从官方源码编译安装 PHP 8.2，并与 Nginx、MySQL 联动。

## 操作环境
+ 系统：Ubuntu 24.04 LTS
+ PHP版本：8.2.10
+ Nginx版本：1.24.0
+ MySQL版本：8.0.34
+ 时间：2026.5.2

## 操作步骤
### 步骤1：安装编译依赖
+ 命令：`apt install -y libxml2-dev libsqlite3-dev libcurl4-openssl-dev libonig-dev libsodium-dev libargon2-dev`
+ 解释：
    - `libxml2-dev`：XML解析库
    - `libsqlite3-dev`：SQLite数据库库
    - `libcurl4-openssl-dev`：HTTP请求库
    - `libonig-dev`：正则表达式库（mbstring依赖）
    - `libsodium-dev`：现代加密库
    - `libargon2-dev`：密码哈希库
+ 截图：<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777716645520-87f6bad1-a499-44d8-ae94-e889fbb1b470.png)

### 步骤2：下载源码
+ 命令：

```bash
cd /usr/local/src
wget https://www.php.net/distributions/php-8.2.10.tar.gz
```

+ <font style="color:rgb(15, 17, 21);">解释：从PHP官网下载8.2.10版本源码包。</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777716692214-cdcc975f-0881-43c1-b5c5-22609ae74ab5.png)

### <font style="color:rgb(15, 17, 21);">步骤3：解压</font>
+ <font style="color:rgb(15, 17, 21);">命令：</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">tar -xzf php-8.2.10.tar.gz && cd php-8.2.10</font>`
+ <font style="color:rgb(15, 17, 21);">解释：解压并进入源码目录。</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777716715299-555bcbd9-f0ba-4791-be2c-a095f62132e8.png)

### <font style="color:rgb(15, 17, 21);">步骤4：配置编译选项</font>
<font style="color:rgb(15, 17, 21);">命令：</font>

+ <font style="color:rgb(15, 17, 21);">./configure --prefix=/usr/local/php --enable-fpm --with-mysqli --with-pdo-mysql --with-openssl --with-zlib --with-curl --enable-mbstring</font>
+ <font style="color:rgb(15, 17, 21);">解释：</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--prefix=/usr/local/php</font>`<font style="color:rgb(15, 17, 21);">：指定安装路径</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--enable-fpm</font>`<font style="color:rgb(15, 17, 21);">：启用PHP-FPM，Nginx通过它处理PHP</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--with-mysqli</font>`<font style="color:rgb(15, 17, 21);">：启用MySQLi扩展</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--with-pdo-mysql</font>`<font style="color:rgb(15, 17, 21);">：启用PDO MySQL驱动</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--with-openssl</font>`<font style="color:rgb(15, 17, 21);">：启用SSL支持</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--with-zlib</font>`<font style="color:rgb(15, 17, 21);">：启用gzip压缩</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--with-curl</font>`<font style="color:rgb(15, 17, 21);">：启用HTTP请求</font>
    - `<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">--enable-mbstring</font>`<font style="color:rgb(15, 17, 21);">：启用多字节字符串（UTF-8等）</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777716875468-46b32682-ab73-4e05-94ae-97a2d5dfbd61.png)

### <font style="color:rgb(15, 17, 21);">步骤5：编译并安装</font>
+ <font style="color:rgb(15, 17, 21);">命令：</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">make && make install</font>`
+ <font style="color:rgb(15, 17, 21);">解释：编译源码并安装到</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/php</font>`<font style="color:rgb(15, 17, 21);">。</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777717816140-e5b111fc-299f-40e3-96e3-89781f1baecc.png)

### <font style="color:rgb(15, 17, 21);">步骤6：配置PHP-FPM</font>
<font style="color:rgb(15, 17, 21);">命令：</font>

+ <font style="color:rgb(15, 17, 21);">bash</font>

```plain
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
```

+ <font style="color:rgb(15, 17, 21);">解释：复制生产环境的推荐配置文件。</font>
+ <!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777717966908-b6191c1c-495b-4974-accb-7c3fbb888c32.png)

### <font style="color:rgb(15, 17, 21);">步骤7：启动PHP-FPM</font>
+ <font style="color:rgb(15, 17, 21);">命令：</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/php/sbin/php-fpm</font>`
+ <font style="color:rgb(15, 17, 21);">解释：启动PHP-FPM进程管理器，默认监听9000端口。</font>
+ <!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777718225325-42c66e95-fe1b-4d1d-ab43-74019b082c61.png)

### <font style="color:rgb(15, 17, 21);">步骤8：配置Nginx对接PHP</font>
<font style="color:rgb(15, 17, 21);">编辑</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/nginx/conf/nginx.conf</font>`<font style="color:rgb(15, 17, 21);">，找到 server 块，修改为：</font>

+ <font style="color:rgb(15, 17, 21);">nginx</font>

```plain
server {
    listen       80;
    server_name  localhost;

    root   /usr/local/nginx/html;
    index  index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

+ <font style="color:rgb(15, 17, 21);">重载Nginx：</font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/nginx/sbin/nginx -s reload</font>`

### <font style="color:rgb(15, 17, 21);">步骤9：验证LNMP联通</font>
<font style="color:rgb(15, 17, 21);">创建</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">/usr/local/nginx/html/info.php</font>`<font style="color:rgb(15, 17, 21);">，写入：</font>

+ <font style="color:rgb(15, 17, 21);">php</font>

```plain
<?php
phpinfo();
?>
```

+ <font style="color:rgb(15, 17, 21);">浏览器访问</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">http://<服务器IP>/info.php</font>`<font style="color:rgb(15, 17, 21);">，看到PHP信息页即成功。</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777718772169-a3af6a4a-3030-4f52-9a61-7d7b9daee05e.png)

## <font style="color:rgb(15, 17, 21);">验证</font>
+ <font style="color:rgb(15, 17, 21);">PHP信息页显示正常</font>
+ <font style="color:rgb(15, 17, 21);">在PHP信息页中能找到</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">mysqli</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">和</font><font style="color:rgb(15, 17, 21);"> </font>`<font style="color:rgb(15, 17, 21);background-color:rgb(235, 238, 242);">pdo_mysql</font>`<font style="color:rgb(15, 17, 21);"> </font><font style="color:rgb(15, 17, 21);">模块</font>
+ <font style="color:rgb(15, 17, 21);">截图：</font><!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777718835020-816e6a0e-28b1-4427-9fe2-9952ecaa3daf.png)
+ <!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777718851860-b4501988-ea6e-409c-b1d1-ab10b15ec668.png)

## <font style="color:rgb(15, 17, 21);">遇到的坑</font>
+ PHP-FPM 报错 "cannot get gid for group 'nobody'" 且不允许以 root 运行：创建了专用系统用户 `www`（`groupadd www && useradd -r -g www -s /bin/false www`），修改 `www.conf` 中 user/group 为 `www` 解决。这也是安全加固中“最小权限原则”的实践——Web 服务不以 root 身份运行。

