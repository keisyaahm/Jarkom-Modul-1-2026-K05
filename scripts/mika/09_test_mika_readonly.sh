#!/bin/sh
echo "[*] No.9 - Test Mika read-only FTP"
command -v ftp >/dev/null 2>&1 || { command -v apt >/dev/null 2>&1 && apt -o Acquire::ForceIPv4=true update && apt -o Acquire::ForceIPv4=true install ftp -y; }
echo 'test upload mika' > /root/test_mika.txt
ftp -inv 10.66.2.2 <<'FTP'
user mika mika123
binary
ls
get signal_alice.txt
put /root/test_mika.txt test_mika.txt
bye
FTP
echo "Ekspektasi: get berhasil, put gagal 550/553"
