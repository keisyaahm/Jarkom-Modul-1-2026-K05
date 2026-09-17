#!/bin/sh
echo "[*] Setup Alice"
ip link set eth0 up
ip addr flush dev eth0 2>/dev/null || true
ip addr add 10.66.1.2/24 dev eth0
ip route del default 2>/dev/null || true
ip route add default via 10.66.1.1 dev eth0
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
ip -br a 2>/dev/null || ip a
ip route
ping -c 3 10.66.1.1
ping -c 3 10.66.2.2
ping -c 3 8.8.8.8
ping -c 3 google.com
