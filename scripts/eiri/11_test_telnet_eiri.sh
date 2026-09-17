#!/bin/sh
echo "[*] No.11 - Test Telnet dari Eiri ke Chisa"
command -v telnet >/dev/null 2>&1 || { command -v apt >/dev/null 2>&1 && apt -o Acquire::ForceIPv4=true update && apt -o Acquire::ForceIPv4=true install telnet -y; }
echo 'Login manual: phantom_user / wired_ghost'
telnet 10.66.2.2
