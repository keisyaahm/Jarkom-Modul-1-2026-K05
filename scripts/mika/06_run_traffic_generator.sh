#!/bin/sh
echo "[*] No.6 - Run traffic generator dari file soal"
cat > /etc/resolv.conf <<'DNS'
nameserver 1.1.1.1
nameserver 8.8.8.8
DNS
ping -c 3 8.8.8.8
ping -c 3 google.com
if [ -f /root/traffic_protocol7.zip ]; then
  command -v unzip >/dev/null 2>&1 || { echo "unzip belum ada"; exit 1; }
  unzip -o /root/traffic_protocol7.zip -d /root/traffic_protocol7
fi
GEN=""
for f in /root/traffic_protocol7.sh /root/traffic.sh /root/traffic_protocol7/*.sh /root/traffic/*.sh; do
  [ -f "$f" ] || continue
  case "$f" in */06_run_traffic_generator.sh) ;; *) GEN="$f"; break;; esac
done
[ -n "$GEN" ] || { echo "Script generator soal belum ditemukan di /root"; exit 1; }
chmod +x "$GEN"
echo "Menjalankan $GEN"
sh "$GEN"
echo "Filter Wireshark: dns || icmp"
