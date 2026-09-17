#!/bin/sh
echo "[*] Setup router Lain"
ip link set eth0 up; ip link set eth1 up; ip link set eth2 up; ip link set eth3 up
ip addr flush dev eth1 2>/dev/null || true
ip addr flush dev eth2 2>/dev/null || true
ip addr flush dev eth3 2>/dev/null || true
ip addr add 10.66.1.1/24 dev eth1
ip addr add 10.66.2.1/24 dev eth2
ip addr add 10.66.3.1/24 dev eth3
ip addr flush dev eth0 2>/dev/null || true
if command -v udhcpc >/dev/null 2>&1; then udhcpc -i eth0; elif command -v dhclient >/dev/null 2>&1; then dhclient eth0; else ip addr add 192.168.122.10/24 dev eth0; ip route add default via 192.168.122.1 dev eth0 2>/dev/null || true; fi
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -F; iptables -F
iptables -t nat -A POSTROUTING -s 10.66.0.0/16 -o eth0 -j MASQUERADE
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
ip -br a 2>/dev/null || ip a
ip route
sysctl net.ipv4.ip_forward
iptables -t nat -L -v -n
ping -c 3 8.8.8.8
ping -c 3 google.com
