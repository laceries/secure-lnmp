#!/bin/bash

NGINX_BIN="/usr/local/nginx/sbin/nginx"
HTTP_URL="http://127.0.0.1"
PHP_URL="http://127.0.0.1/health.php"

echo "===== LNMP Health Check ====="
echo

echo "[1] Check processes"

if pgrep -x nginx >/dev/null; then
    echo "nginx: running"
else
    echo "nginx: not running"
fi

if pgrep -x php-fpm >/dev/null; then
    echo "php-fpm: running"
else
    echo "php-fpm: not running"
fi

if pgrep -x mysqld >/dev/null; then
    echo "mysqld: running"
else
    echo "mysqld: not running"
fi

echo
echo "[2] Check systemd services"

for service in nginx php-fpm mysqld; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "$service.service: active"
    else
        echo "$service.service: inactive or not found"
    fi
done

echo
echo "[3] Check listening ports"

ss -lntp | grep -E ':(80|443|9000|3306)[[:space:]]' || echo "No LNMP ports found"

echo
echo "[4] Check Nginx config"

if [ -x "$NGINX_BIN" ]; then
    "$NGINX_BIN" -t 2>&1
else
    echo "Nginx binary not found: $NGINX_BIN"
fi

echo
echo "[5] Check HTTP response"

curl -I "$HTTP_URL" 2>/dev/null | head -n 5

echo
echo "[6] Check PHP response"

curl -I "$PHP_URL" 2>/dev/null | head -n 5

echo
echo "===== Check Finished ====="
