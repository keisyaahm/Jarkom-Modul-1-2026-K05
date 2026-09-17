#!/bin/sh
echo "[*] No.7 - Test Alice upload"
command -v ftp >/dev/null 2>&1 || { command -v apt >/dev/null 2>&1 && apt -o Acquire::ForceIPv4=true update && apt -o Acquire::ForceIPv4=true install ftp -y; }
echo 'signal from alice' > /root/signal_alice.txt
ftp -inv 10.66.2.2 <<'FTP'
user alice 123
binary
put /root/signal_alice.txt signal_alice.txt
ls
bye
FTP
echo "Ekspektasi: 226 Transfer complete"
