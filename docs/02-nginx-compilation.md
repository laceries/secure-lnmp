## 目标
从官方源码编译安装 Nginx，不依赖系统预编译包。

## 操作环境
+ 系统：Ubuntu 24.04 LTS
+ Nginx版本：1.24.0
+ 时间：2026.4.28

## 下载并编译 Nginx
**1. 进入源码目录**

```bash
cd /usr/local/src
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325747336-0662e6e9-a4d4-4083-853b-5d30585c62ea.png)

**2. 从Nginx官网下载稳定版源码**

```bash
wget http://nginx.org/download/nginx-1.24.0.tar.gz
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325783923-e3fae284-781d-40dc-8e10-1e4797bb608a.png)

**3. 解压并进入**

```bash
tar -xzf nginx-1.24.0.tar.gz
cd nginx-1.24.0
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325837876-bb6aebdf-2f03-4f3b-b3d1-12cbafcdedca.png)

**4. 配置编译选项**

```bash
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_gzip_static_module
```

    - `--prefix` 指定安装路径
    - `--with-http_ssl_module` 开启HTTPS支持
    - `--with-http_gzip_static_module` 开启静态文件压缩

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325879893-c82445e6-98a9-4bdf-aa67-3b163fae48a1.png)

**5. 编译并安装**

```bash
make && make install
```

编译源码并安装到指定路径

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325932710-f42349d1-bd54-4c71-965c-9048ea3195ee.png)

**6. 启动 Nginx**

```bash
/usr/local/nginx/sbin/nginx
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777325957997-199841e0-6b2f-4209-8c65-ef90cc06d8e4.png)

**7. 验证**

+ 终端执行 `curl http://localhost`，看到 "Welcome to nginx!" 页面源码

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777326732468-bb7ef324-3dc2-4bda-b3fb-c378abf46487.png)

+ 浏览器访问 `http://你的服务器IP`，看到 "Welcome to nginx!" 

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34893434/1777326002573-f01dd983-7738-4033-b0a9-ae8e9e5d4920.png)

---

## 遇到的坑
+ 无（或记录你实际遇到的问题）

