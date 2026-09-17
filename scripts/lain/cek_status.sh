#!/bin/sh
echo "INTERFACE SUMMARY"
ip -br a 2>/dev/null || ip a
echo
echo "ROUTE TABLE"
ip route
echo
echo "IP FORWARD"
sysctl net.ipv4.ip_forward
echo
echo "NAT TABLE"
iptables -t nat -L -v -n
echo
echo "TEST INTERNET IP"
ping -c 3 8.8.8.8
echo
echo "TEST INTERNET DOMAIN"
ping -c 3 google.com
