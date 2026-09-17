#!/bin/sh
echo "[*] No.8 - Upload knights_report.zip mode passive"
command -v ftp >/dev/null 2>&1 || { command -v apt >/dev/null 2>&1 && apt -o Acquire::ForceIPv4=true update && apt -o Acquire::ForceIPv4=true install ftp -y; }
[ -f /root/8/knights_report.zip ] || { echo 'File /root/8/knights_report.zip tidak ditemukan'; exit 1; }
ls -lh /root/8/knights_report.zip
ftp -pinv 10.66.2.2 <<'FTP'
user alice 123
binary
put /root/8/knights_report.zip knights_report.zip
ls
bye
FTP
echo "Wireshark: STOR, 226, 229 EPSV/PASV port"
