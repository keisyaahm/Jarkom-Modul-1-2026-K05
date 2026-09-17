#!/bin/sh
echo "[*] No.12 - Setup Knights services"
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
if command -v apt >/dev/null 2>&1; then apt -o Acquire::ForceIPv4=true update; apt -o Acquire::ForceIPv4=true install openssh-server netcat-openbsd -y; elif command -v apk >/dev/null 2>&1; then apk add --no-cache openssh netcat-openbsd; fi
mkdir -p /run/sshd /var/run/sshd 2>/dev/null || true
ssh-keygen -A 2>/dev/null || true
pkill sshd 2>/dev/null || true
/usr/sbin/sshd 2>/tmp/sshd.log || /usr/sbin/sshd -D 2>/tmp/sshd.log &
pkill -f 'nc.*80' 2>/dev/null || true
nohup sh -c 'while true; do printf "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nKnights HTTP\n" | nc -l -p 80; done' >/tmp/knights_http.log 2>&1 &
pkill -f '7777' 2>/dev/null || true
sleep 1
ss -lntp 2>/dev/null | grep -E ':22|:80|:7777' || netstat -lntp 2>/dev/null | grep -E ':22|:80|:7777'
echo 'Ekspektasi: 22 LISTEN, 80 LISTEN, 7777 tidak ada'
