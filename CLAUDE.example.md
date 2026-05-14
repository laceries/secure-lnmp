# Claude Code 鎿嶄綔瑙勫垯

鏈粨搴撴槸 Secure-LNMP 椤圭洰锛岀敤浜庤褰曞熀浜?Ubuntu 浜戞湇鍔″櫒婧愮爜缂栬瘧 LNMP銆侀儴缃?WordPress銆佸畬鎴愬畨鍏ㄥ姞鍥恒€佹壂鎻忛獙璇併€乻ystemd 鏈嶅姟绠＄悊锛屽苟缁х画寤鸿鐩戞帶銆佹棩蹇椼€佸浠藉拰鏁呴殰婕旂粌鑳藉姏銆?
## 浣犵殑涓昏鑱岃矗

浣犲彲浠ュ崗鍔╁畬鎴愪互涓嬩换鍔★細

1. 鏁寸悊 Markdown 鏂囨。
   - README.md
   - secure-lnmp-roadmap.md
   - docs/ 涓嬬殑闃舵鏂囨。
   - troubleshooting 鏂囨。
   - incident report 鏂囨。

2. 鏁寸悊鑴辨晱閰嶇疆绀轰緥
   - configs/nginx/
   - configs/mysql/
   - configs/php/
   - configs/systemd/
   - configs/prometheus/
   - configs/loki/

3. 妫€鏌ヤ粨搴撶粨鏋?   - 鍙戠幇缂哄け鏂囨。
   - 妫€鏌ラ摼鎺ユ槸鍚﹀け鏁?   - 妫€鏌?Markdown 鏍煎紡
   - 妫€鏌ユ槸鍚﹀瓨鍦ㄦ槑鏄炬晱鎰熸枃浠跺悕

4. 杈呭姪鐢熸垚鑴氭湰鑽夌
   - 鍋ュ悍妫€鏌ヨ剼鏈?   - 澶囦唤鑴氭湰
   - 鐩戞帶閮ㄧ讲鑴氭湰
   - 鏃ュ織閲囬泦閰嶇疆
   - Ansible Playbook 鑽夌

5. 杈呭姪鍒嗘瀽鍙鍛戒护杈撳嚭
   - systemctl 鐘舵€?   - ss 绔彛鐩戝惉
   - curl 鍝嶅簲澶?   - nmap / Nikto 鎵弿缁撴灉
   - Prometheus / Grafana 閰嶇疆

## 杩滅▼鏈嶅姟鍣ㄨ闂鍒?
鍏佽閫氳繃浠ヤ笅 SSH Host 璁块棶鏈嶅姟鍣細

```bash
ssh your-readonly-host
```

璇ョ敤鎴锋槸浣庢潈闄愬彧璇荤敤鎴凤紝浠呯敤浜庢煡鐪嬬姸鎬併€?
鍏佽鎵ц鐨勮繙绋嬪彧璇诲懡浠ゅ寘鎷細

```bash
ssh your-readonly-host "whoami; hostname; date; uptime"
ssh your-readonly-host "systemctl is-active nginx php-fpm mysqld fail2ban"
ssh your-readonly-host "systemctl is-enabled nginx php-fpm mysqld fail2ban"
ssh your-readonly-host "ss -tln | grep -E ':22|:80|:443|:9000|:3306|:33060' || true"
ssh your-readonly-host "ps -eo user,pid,cmd | grep -E '[n]ginx|[p]hp-fpm|[m]ysqld'"
ssh your-readonly-host "curl -I -s https://example.com/ | head -30"
ssh your-readonly-host "curl -I -s https://example.com/secure-lnmp/ | head -30"
ssh your-readonly-host "curl -I -s https://example.com/wp-login.php | head -30"
```

鍏佽璇诲彇鐨勫唴瀹逛粎闄愪簬闈炴晱鎰熺姸鎬佷俊鎭紝渚嬪锛?
- 鏈嶅姟鏄惁杩愯
- 鏈嶅姟鏄惁寮€鏈鸿嚜鍚?- 绔彛鐩戝惉鐘舵€?- HTTP 鍝嶅簲澶?- 杩涚▼鍒楄〃
- 缃戠珯鍙揪鎬?
## 涓ョ鎵ц鐨勮繙绋嬪懡浠?
鏃犺浠讳綍鎯呭喌锛屼綘閮戒笉鑳戒富鍔ㄦ墽琛屼互涓嬪懡浠わ細

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

涔熶笉鑳芥墽琛屼换浣曚細淇敼鏈嶅姟鍣ㄧ姸鎬佺殑鍛戒护銆?
## 涓ョ璇诲彇鐨勮繙绋嬫枃浠?
浣犱笉鑳借鍙栦互涓嬭矾寰勬垨鏂囦欢锛?
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

濡傛灉闇€瑕佸垎鏋愮浉鍏抽厤缃紝鍙兘瑕佹眰鐢ㄦ埛鎻愪緵鑴辨晱鍚庣殑鐗囨銆?
## 鏁忔劅淇℃伅瑙勫垯

浣犱笉鑳借姹傜敤鎴锋彁渚涳細

- SSH 绉侀挜
- 鏁版嵁搴撳瘑鐮?- WordPress 绠＄悊鍛樺瘑鐮?- 璇佷功绉侀挜
- API Token
- 鐪熷疄閭瀹屾暣鍐呭
- 浜戝巶鍟?SecretId / SecretKey

濡傛灉鍙戠幇浠撳簱涓枒浼煎瓨鍦ㄦ晱鎰熸枃浠讹紝搴旀彁閱掔敤鎴峰垹闄ゅ苟鍔犲叆 .gitignore銆?
## 淇敼浠撳簱鏂囦欢瑙勫垯

浣犲彲浠ヤ慨鏀规湰鍦颁粨搴撴枃浠讹紝浣嗛渶瑕侀伒瀹堬細

1. 涓嶇敓鎴愮湡瀹炲瘑鐮併€佺閽ャ€佽瘉涔︼紱
2. 涓嶇敓鎴?wp-config.php锛?3. 閰嶇疆绀轰緥蹇呴』浣跨敤 example.com銆亁xx.top銆乕your_email@example.com](mailto:your_email@example.com) 绛夊崰浣嶇锛?4. 鎵€鏈夐厤缃枃浠跺繀椤昏劚鏁忥紱
5. 淇敼鍓嶅厛璇存槑璁″垝锛?6. 淇敼鍚庢€荤粨鍙樻洿鍒楄〃銆?
## 鏈嶅姟鍣ㄤ慨鏀硅鍒?
濡傛灉浣犲垽鏂湇鍔″櫒闇€瑕佷慨鏀归厤缃紝鍙兘杈撳嚭寤鸿鍛戒护锛屼緥濡傦細

```bash
# 寤鸿鐢ㄦ埛浜哄伐鎵ц
sudo nginx -t
sudo systemctl reload nginx
```

浣犱笉鑳介€氳繃 SSH 鑷鎵ц杩欎簺淇敼鍛戒护銆?
## 褰撳墠椤圭洰鐘舵€佹憳瑕?
宸插畬鎴愶細

- Nginx 1.24.0 婧愮爜缂栬瘧
- MySQL 8.0 婧愮爜缂栬瘧
- PHP 8.2.10 婧愮爜缂栬瘧
- WordPress 涓氬姟绔欑偣閮ㄧ讲
- SSH 绂?root 涓?MaxAuthTries 鍔犲浐
- fail2ban 鑷姩灏佺
- MySQL bind-address=127.0.0.1
- 鍏抽棴 MySQL 33060
- Nginx 瀹夊叏鍝嶅簲澶?- HTTPS 涓庤瘉涔﹁嚜鍔ㄧ画鏈?- WordPress 鍩虹瀹夊叏鍔犲浐
- nmap / Nikto 鎵弿楠岃瘉
- Nginx / PHP-FPM systemd 绠＄悊

涓嬩竴闃舵锛?
- Prometheus + Grafana 鐩戞帶
- Loki + Promtail 鏃ュ織
- 澶囦唤鎭㈠
- Ansible 鑷姩鍖?- 鏁呴殰婕旂粌

## 宸ヤ綔椋庢牸

鍥炵瓟鏃惰锛?
- 鍏堢粰缁撹锛?- 鍐嶇粰鎿嶄綔姝ラ锛?- 瀵瑰懡浠よ繘琛岀畝瑕佽В閲婏紱
- 涓嶈涓€娆℃€х粰杩囧鍗遍櫓鍛戒护锛?- 瀵规湇鍔″櫒淇敼淇濇寔淇濆畧锛?- 瀵?GitHub 鏂囨。淇濇寔缁撴瀯鍖栥€佺畝娲併€佽劚鏁忋€?
