#!/bin/sh
echo "[*] No.7 - Setup FTP Server Chisa"
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
ping -c 3 8.8.8.8
ping -c 3 google.com
if ! command -v vsftpd >/dev/null 2>&1; then
  if command -v apt >/dev/null 2>&1; then apt -o Acquire::ForceIPv4=true update; apt -o Acquire::ForceIPv4=true install --no-install-recommends vsftpd -y; elif command -v apk >/dev/null 2>&1; then apk add --no-cache vsftpd; fi
fi
useradd -m -s /bin/bash alice 2>/dev/null || true
useradd -m -s /bin/bash mika 2>/dev/null || true
useradd -m -s /bin/bash eiri 2>/dev/null || true
echo 'alice:123' | chpasswd
echo 'mika:mika123' | chpasswd
echo 'eiri:eiri123' | chpasswd
mkdir -p /var/wired/data
chown alice:alice /var/wired/data
chmod 755 /var/wired/data
echo 'FTP Server Chisa ready' > /var/wired/data/readme.txt
chown alice:alice /var/wired/data/readme.txt
chmod 644 /var/wired/data/readme.txt
echo eiri > /etc/vsftpd.userlist
cat > /etc/vsftpd.conf <<'CONF'
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
local_root=/var/wired/data
userlist_enable=YES
userlist_deny=YES
userlist_file=/etc/vsftpd.userlist
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
CONF
pkill vsftpd 2>/dev/null || true
/usr/sbin/vsftpd /etc/vsftpd.conf &
sleep 1
ss -lntp | grep ':21' || netstat -lntp 2>/dev/null | grep ':21' || echo 'PORT 21 BELUM LISTEN'
grep -E '^(alice|mika|eiri):' /etc/passwd
ls -ld /var/wired/data
ls -lh /var/wired/data
cat /etc/vsftpd.userlist
