#!/bin/sh
echo "[*] No.13 - Setup SSH key auth di Knights"
[ -s /root/mika_admin.pub ] || { echo '/root/mika_admin.pub belum ada'; exit 1; }
grep -q '^ssh-' /root/mika_admin.pub || { echo 'bukan public key SSH'; cat /root/mika_admin.pub; exit 1; }
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
if command -v apt >/dev/null 2>&1; then apt -o Acquire::ForceIPv4=true update; apt -o Acquire::ForceIPv4=true install openssh-server -y; elif command -v apk >/dev/null 2>&1; then apk add --no-cache openssh; fi
useradd -m -s /bin/bash mika_admin 2>/dev/null || true
echo 'mika_admin:mika_admin123' | chpasswd
mkdir -p /home/mika_admin/.ssh
cat /root/mika_admin.pub > /home/mika_admin/.ssh/authorized_keys
chown -R mika_admin:mika_admin /home/mika_admin
chmod 755 /home/mika_admin
chmod 700 /home/mika_admin/.ssh
chmod 600 /home/mika_admin/.ssh/authorized_keys
mkdir -p /run/sshd /var/run/sshd 2>/dev/null || true
ssh-keygen -A 2>/dev/null || true
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak 2>/dev/null || true
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config
grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config || echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
grep -q '^PubkeyAuthentication yes' /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
grep -q '^PermitRootLogin no' /etc/ssh/sshd_config || echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
grep -q '^AuthorizedKeysFile .ssh/authorized_keys' /etc/ssh/sshd_config || echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config
pkill sshd 2>/dev/null || true
/usr/sbin/sshd
sleep 1
grep '^mika_admin:' /etc/passwd
grep -E 'PasswordAuthentication|PubkeyAuthentication|PermitRootLogin|AuthorizedKeysFile' /etc/ssh/sshd_config
cat /home/mika_admin/.ssh/authorized_keys
ls -ld /home/mika_admin /home/mika_admin/.ssh
ls -l /home/mika_admin/.ssh/authorized_keys
ss -lntp | grep ':22' || netstat -lntp 2>/dev/null | grep ':22'
