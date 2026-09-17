#!/bin/sh
echo "[*] No.7 - Test Eiri blacklist"
command -v ftp >/dev/null 2>&1 || { command -v apt >/dev/null 2>&1 && apt -o Acquire::ForceIPv4=true update && apt -o Acquire::ForceIPv4=true install ftp -y; }
ftp -inv 10.66.2.2 <<'FTP'
user eiri eiri123
ls
bye
FTP
echo "Ekspektasi: 530 Permission denied / Login failed"
