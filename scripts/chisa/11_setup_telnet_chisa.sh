#!/bin/sh
echo "[*] No.11 - Setup Telnet Server di Chisa"
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
if command -v apt >/dev/null 2>&1; then apt -o Acquire::ForceIPv4=true update; apt -o Acquire::ForceIPv4=true install openbsd-inetd telnetd telnet -y; elif command -v apk >/dev/null 2>&1; then apk add --no-cache busybox-extras; fi
useradd -m -s /bin/bash phantom_user 2>/dev/null || true
echo 'phantom_user:wired_ghost' | chpasswd
TELNETD=''
for f in /usr/sbin/in.telnetd /usr/sbin/telnetd /usr/bin/telnetd /bin/telnetd; do [ -x "$f" ] && TELNETD="$f" && break; done
[ -n "$TELNETD" ] || { echo 'telnetd tidak ditemukan'; exit 1; }
cat > /etc/inetd.conf <<CONF
telnet stream tcp nowait root $TELNETD $(basename "$TELNETD")
CONF
pkill inetd 2>/dev/null || true
if [ -x /usr/sbin/inetd ]; then /usr/sbin/inetd; else inetd; fi
sleep 1
grep '^phantom_user:' /etc/passwd
cat /etc/inetd.conf
ss -lntp | grep ':23' || netstat -lntp 2>/dev/null | grep ':23' || echo 'PORT 23 BELUM LISTEN'
