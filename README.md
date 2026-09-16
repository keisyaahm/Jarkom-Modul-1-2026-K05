# Laporan Praktikum Shift Protocol 7

## Dokumentasi Pengerjaan Soal

## Identitas Praktikum

| Keterangan | Isi |
|---|---|
| Praktikum | Komunikasi Data dan Jaringan Komputer |
| Tema | Serial Experiments Lain, Protocol 7 |
| Prefix jaringan | `10.66.x.x` |
| Node utama | Lain, Alice, Mika, Chisa, Knights, Eiri |
| Nomor terdokumentasi | 1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 20 |
| Catatan | Nomor 7 sampai 13 tidak dimasukkan karena pada pengerjaan ini dilewati atau belum selesai didokumentasikan. |

---

## Ringkasan Topologi

Topologi menggunakan satu router utama bernama **Lain** yang terhubung ke NAT dan tiga switch internal. Switch 1 menghubungkan Alice dan Mika, Switch 2 menghubungkan Chisa, sedangkan Switch 3 menghubungkan Knights dan Eiri. Lain berperan sebagai router antarsubnet sekaligus gateway menuju internet.

![Topologi jaringan](assets/01_topologi_final_lain_3switch_5client.png)

**Nama file screenshot:** `assets/01_topologi_final_lain_3switch_5client.png`

---

# Nomor 1

## Inti Soal

Pada nomor ini diminta membuat topologi jaringan sesuai ketentuan soal. Tokoh yang digunakan adalah **Lain** sebagai router utama, **Alice** dan **Mika** sebagai client di Switch 1, **Chisa** sebagai client di Switch 2, serta **Knights** dan **Eiri** sebagai client di Switch 3.

## Cara Pengerjaan

Topologi dibuat di GNS3 dengan susunan berikut.

| Komponen | Fungsi |
|---|---|
| NAT1 | Jalur Lain menuju internet |
| Lain | Router utama antarsubnet internal |
| Switch1 | Menghubungkan Alice dan Mika |
| Switch2 | Menghubungkan Chisa |
| Switch3 | Menghubungkan Knights dan Eiri |
| Alice, Mika, Chisa, Knights, Eiri | Client internal |

Rancangan interface Lain:

| Interface | Koneksi | Alamat IP |
|---|---|---|
| eth0 | NAT1 | DHCP, contoh `192.168.122.4/24` |
| eth1 | Switch1 | `10.66.1.1/24` |
| eth2 | Switch2 | `10.66.2.1/24` |
| eth3 | Switch3 | `10.66.3.1/24` |

## Sintaks atau Langkah Kerja

Nomor 1 dilakukan melalui GUI GNS3, sehingga tidak ada script khusus. Langkahnya adalah membuat node, menambahkan switch, menghubungkan kabel, lalu memastikan setiap interface berada pada switch yang benar.

## Ekspektasi Output

```text
NAT1 terhubung ke Lain eth0.
Lain eth1 terhubung ke Switch1.
Lain eth2 terhubung ke Switch2.
Lain eth3 terhubung ke Switch3.
Alice dan Mika berada pada Switch1.
Chisa berada pada Switch2.
Knights dan Eiri berada pada Switch3.
```

## Output

Topologi berhasil dibuat sesuai susunan tersebut.

## Screenshot

![Topologi final](assets/01_topologi_final_lain_3switch_5client.png)

**Nama file screenshot:** `assets/01_topologi_final_lain_3switch_5client.png`

## Analisis

Topologi sudah sesuai karena seluruh subnet internal dipusatkan ke router Lain. Dengan model ini, komunikasi antarsubnet dan akses internet dapat dikendalikan melalui satu router utama.

## Kendala

Switch1 sempat bermasalah sehingga Alice dan Mika tidak bisa menjangkau Lain. Solusi yang dilakukan adalah membuat ulang Switch1 dan menyambungkan ulang Alice, Mika, serta Lain `eth1`.

---

# Nomor 2

## Inti Soal

Lain sebagai router harus dapat tersambung ke internet melalui NAT1.

## Cara Pengerjaan

Interface `eth0` pada Lain dibuat DHCP agar memperoleh alamat IP dari NAT1. Setelah itu dilakukan pengecekan IP, route, dan koneksi internet.

## Script atau Command yang Digunakan

```bash
ip -br a
ip route
ping -c 3 8.8.8.8
```

Konfigurasi `/etc/network/interfaces` pada Lain:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.66.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.66.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.66.3.1
    netmask 255.255.255.0
```

## Ekspektasi Output

```text
eth0 mendapatkan IP dari NAT, misalnya 192.168.122.4/24.
Route default mengarah ke gateway NAT.
ping 8.8.8.8 berhasil dengan 0% packet loss.
```

## Output

Lain memperoleh IP NAT pada `eth0`, memiliki route keluar, dan ping ke internet berhasil.

## Screenshot

![Lain IP route ping internet](assets/02_lain_ip_route_ping_internet.png)

**Nama file screenshot:** `assets/02_lain_ip_route_ping_internet.png`

## Analisis

Ping ke `8.8.8.8` membuktikan bahwa Lain sudah dapat mengakses internet secara IP. Hal ini menjadi dasar agar client lain juga bisa mengakses internet melalui Lain.

## Kendala

Lain sempat mengalami `Destination Host Unreachable` ketika ping internet. Penyebabnya ada pada jalur Lain ke NAT gateway. Solusinya adalah memastikan link `eth0` ke NAT1 aktif dan route default benar.

---

# Nomor 3

## Inti Soal

Setiap client harus memiliki alamat IP statis dan dapat terhubung ke gateway masing-masing melalui Lain.

## Cara Pengerjaan

Setiap client dikonfigurasi dengan IP statis sesuai subnet masing-masing.

| Node | IP | Gateway |
|---|---|---|
| Alice | `10.66.1.2/24` | `10.66.1.1` |
| Mika | `10.66.1.3/24` | `10.66.1.1` |
| Chisa | `10.66.2.2/24` | `10.66.2.1` |
| Knights | `10.66.3.2/24` | `10.66.3.1` |
| Eiri | `10.66.3.3/24` | `10.66.3.1` |

## Script atau Command yang Digunakan

Contoh konfigurasi Alice:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.66.1.2
    netmask 255.255.255.0
    gateway 10.66.1.1
```

Contoh konfigurasi Mika:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.66.1.3
    netmask 255.255.255.0
    gateway 10.66.1.1
```

Command pengecekan:

```bash
ip -br a
ip route
ping -c 3 10.66.1.1
```

## Ekspektasi Output

```text
Setiap client memiliki IP sesuai subnet.
Default gateway client mengarah ke IP interface Lain.
Ping dari client ke gateway berhasil.
```

## Output

Alice dan client lain berhasil menjangkau gateway. Alice dapat ping ke `10.66.1.1`.

## Screenshot

![Konfigurasi client dan ping gateway](assets/03_client_config_ping_gateway.png)

**Nama file screenshot:** `assets/03_client_config_ping_gateway.png`

![Alice ping gateway](assets/03_alice_ping_gateway.png)

**Nama file screenshot:** `assets/03_alice_ping_gateway.png`

## Analisis

Keberhasilan ping ke gateway membuktikan konfigurasi IP, subnet mask, gateway, dan koneksi switch sudah benar.

## Kendala

Alice dan Mika sempat tidak bisa ping ke Lain karena ARP gagal pada Switch1. Setelah Switch1 dibuat ulang, ping gateway berhasil.

---

# Nomor 4

## Inti Soal

Semua client harus bisa mengakses internet melalui Lain.

## Cara Pengerjaan

Routing IP forwarding dan NAT diaktifkan pada Lain. DNS client diarahkan ke DNS publik.

## Script atau Command yang Digunakan

Pada Lain:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -s 10.66.0.0/16 -j MASQUERADE
iptables -t nat -L -v -n
```

Pada client:

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping -c 3 8.8.8.8
ping -c 3 google.com
```

## Ekspektasi Output

```text
iptables menampilkan rule MASQUERADE untuk 10.66.0.0/16.
ping 8.8.8.8 berhasil.
ping google.com berhasil jika DNS sudah benar.
```

## Output

Client berhasil ping ke `8.8.8.8` dan `google.com`.

## Screenshot

![Semua client ping internet](assets/04_all_clients_ping_8.8.8.8_google.png)

**Nama file screenshot:** `assets/04_all_clients_ping_8.8.8.8_google.png`

![Alice ping internet](assets/04_alice_ping_8.8.8.8_google.png)

**Nama file screenshot:** `assets/04_alice_ping_8.8.8.8_google.png`

## Analisis

NAT MASQUERADE membuat trafik dari subnet `10.66.0.0/16` keluar melalui `eth0` Lain. Ping domain membuktikan DNS juga berjalan.

## Kendala

Internet client sempat gagal karena route NAT pada Lain belum stabil. Setelah `ip_forward`, default route, dan MASQUERADE diperiksa ulang, client berhasil mengakses internet.

---

# Nomor 5

## Inti Soal

Konfigurasi jaringan harus tetap dapat dicek setelah node direstart.

## Cara Pengerjaan

Dibuat script pengecekan status pada Lain untuk menampilkan ringkasan interface dan tabel NAT setelah restart.

## Script yang Digunakan

File: `/root/cek_status.sh`

```sh
#!/bin/sh

echo "INTERFACE SUMMARY"
ip -br a

echo
echo "NAT TABLE"
iptables -t nat -L -v -n
```

Command menjalankan script:

```bash
chmod +x /root/cek_status.sh
/root/cek_status.sh
```

## Ekspektasi Output

```text
INTERFACE SUMMARY
lo      UNKNOWN    127.0.0.1/8 ...
eth0    UP/UNKNOWN 192.168.122.x/24
eth1    UP/UNKNOWN 10.66.1.1/24
eth2    UP/UNKNOWN 10.66.2.1/24
eth3    UP/UNKNOWN 10.66.3.1/24

NAT TABLE
Chain POSTROUTING ...
MASQUERADE  all  --  10.66.0.0/16  0.0.0.0/0
```

## Output

Script berhasil menampilkan interface Lain dan rule NAT setelah restart.

## Screenshot

![Script cek status](assets/05-script-cek-status.png)

**Nama file screenshot:** `assets/05-script-cek-status.png`

![Output cek status](assets/05-output-cek-status.png)

**Nama file screenshot:** `assets/05-output-cek-status.png`

![Status Lain setelah restart](assets/05_lain_cek_status_after_restart.png)

**Nama file screenshot:** `assets/05_lain_cek_status_after_restart.png`

## Analisis

Script membantu memastikan interface dan NAT masih tersedia setelah restart. Status `UNKNOWN` pada interface container tidak selalu berarti error selama IP, route, dan ping tetap berjalan.

## Kendala

Beberapa node berbasis container tidak sepenuhnya persisten. Package dan file dapat hilang setelah node dihentikan. Solusi sementara adalah mengambil bukti screenshot segera setelah konfigurasi berhasil.

---

# Nomor 6

## Inti Soal

Mika menjalankan traffic generator untuk menghasilkan trafik DNS dan ICMP. Trafik tersebut kemudian dicapture dan dianalisis dengan Wireshark.

## Cara Pengerjaan

Script traffic generator dibuat di Mika dan dijalankan saat Wireshark melakukan capture pada link Mika ke Switch1.

## Script yang Digunakan

File: `/root/traffic_protocol7.sh`

```bash
#!/bin/bash
# Traffic Generator - Protocol 7 Network
# Serial Experiments Lain - Modul 1 Jarkom 2026
# Jalankan di node MIKA untuk generate traffic DNS & ICMP

echo "============================================"
echo "  Protocol 7 Traffic Generator v2026"
echo "  Node: Mika Iwakura"
echo "============================================"
echo "[*] Generating DNS & ICMP traffic..."

ping -c 5 8.8.8.8 &
ping -c 5 1.1.1.1 &
ping -c 3 its.ac.id &

nslookup google.com 8.8.8.8 &
nslookup its.ac.id 8.8.8.8 &
nslookup github.com 1.1.1.1 &
dig @8.8.8.8 example.com A &
dig @1.1.1.1 cloudflare.com AAAA &

wait
echo "[*] Traffic generation complete."
echo "[*] Check Wireshark for captured packets."
```

Command menjalankan script:

```bash
chmod +x /root/traffic_protocol7.sh
/root/traffic_protocol7.sh
```

Filter Wireshark:

```wireshark
dns || icmp
```

## Ekspektasi Output

```text
============================================
  Protocol 7 Traffic Generator v2026
  Node: Mika Iwakura
============================================
[*] Generating DNS & ICMP traffic...
...
[*] Traffic generation complete.
[*] Check Wireshark for captured packets.
```

Pada Wireshark diharapkan muncul paket DNS dan ICMP dari atau menuju Mika.

## Output

Script berjalan sampai selesai dan trafik DNS serta ICMP berhasil terlihat pada Wireshark.

## Screenshot

![Isi script traffic generator Mika](assets/06_mika_script_traffic_protocol7_content.png)

**Nama file screenshot:** `assets/06_mika_script_traffic_protocol7_content.png`

![Output traffic generator Mika](assets/06_mika_run_traffic_protocol7_output.png)

**Nama file screenshot:** `assets/06_mika_run_traffic_protocol7_output.png`

![Traffic generator selesai](assets/06_mika_traffic_generator_complete.png)

**Nama file screenshot:** `assets/06_mika_traffic_generator_complete.png`

## Analisis

Trafik DNS muncul dari command `nslookup` dan `dig`, sedangkan trafik ICMP muncul dari command `ping`. Filter `dns || icmp` digunakan agar paket yang dianalisis fokus pada dua protokol tersebut.

## Kendala

Mika sempat terdampak masalah Switch1. Setelah Switch1 dibuat ulang dan koneksi ke gateway kembali normal, script dapat berjalan.

---

# Nomor 14

## Inti Soal

Eiri melakukan brute-force terhadap form login web Alice. Dari file `wired_bruteforce.pcapng`, diminta mengidentifikasi IP penyerang, IP target beserta port yang diserang, password user `lain_admin` yang berhasil ditembus, serta web server software dan versinya dari response header.

## Cara Pengerjaan

Capture dianalisis dengan filter HTTP POST untuk melihat percobaan login berulang.

## Filter dan Langkah yang Digunakan

```wireshark
http.request.method == "POST"
```

```wireshark
http.response.code != 401 && http.response
```

```text
Klik response sukses -> Right click -> Follow -> TCP Stream
```

## Ekspektasi Output

```text
Banyak packet POST /login.php dari satu source IP ke target IP port 8080.
Response gagal biasanya HTTP/1.1 401 Unauthorized.
Response sukses biasanya bukan 401, lalu TCP Stream memperlihatkan username lain_admin dan password yang berhasil.
Header Server memperlihatkan software dan versi web server.
```

## Output

Dari screenshot yang tersedia terlihat pola brute-force:

```text
Source attacker : 172.26.7.50
Target IP       : 172.26.7.100
Target port     : 8080
Endpoint        : /login.php
```

Password `lain_admin`, header server, dan validasi socket belum terdokumentasi pada screenshot yang tersedia.

## Screenshot

![Capture brute force dibuka](assets/14_01_wireshark_capture_opened.png)

**Nama file screenshot:** `assets/14_01_wireshark_capture_opened.png`

## Analisis

Banyak request `POST /login.php` dari `172.26.7.50` menuju `172.26.7.100:8080` menunjukkan aktivitas brute-force. Banyak response `401 Unauthorized` menunjukkan sebagian besar percobaan login gagal. Untuk menyelesaikan nomor ini sepenuhnya masih diperlukan TCP Stream dari percobaan yang berhasil dan header `Server`.

## Kendala

Nomor ini belum selesai divalidasi. Bukti yang kurang adalah screenshot TCP Stream yang memperlihatkan password `lain_admin`, screenshot header `Server`, dan screenshot validasi socket `3401`.

---

# Nomor 15

## Inti Soal

Penyerang memasang perangkat USB HID untuk mencuri keystroke. Dari file `wired_usb_hid.pcap`, diminta mengidentifikasi Vendor ID, Product ID, alamat device USB, serta pesan rahasia yang dicuri dari keystroke.

## Cara Pengerjaan

Analisis dilakukan dengan mencari USB Device Descriptor untuk identitas perangkat dan packet `URB_INTERRUPT in` untuk data keystroke.

## Filter yang Digunakan

```wireshark
usb.idVendor || usb.idProduct
```

```wireshark
usb.transfer_type == 0x01
```

```wireshark
usb.transfer_type == 0x01 && usb.capdata != 00:00:00:00:00:00:00:00
```

## Script Python yang Digunakan

File: `decode_hid.py`

```python
hid_map = {
    0x04: 'a', 0x05: 'b', 0x06: 'c', 0x07: 'd', 0x08: 'e',
    0x09: 'f', 0x0a: 'g', 0x0b: 'h', 0x0c: 'i', 0x0d: 'j',
    0x0e: 'k', 0x0f: 'l', 0x10: 'm', 0x11: 'n', 0x12: 'o',
    0x13: 'p', 0x14: 'q', 0x15: 'r', 0x16: 's', 0x17: 't',
    0x18: 'u', 0x19: 'v', 0x1a: 'w', 0x1b: 'x', 0x1c: 'y',
    0x1d: 'z',
    0x1e: '1', 0x1f: '2', 0x20: '3', 0x21: '4', 0x22: '5',
    0x23: '6', 0x24: '7', 0x25: '8', 0x26: '9', 0x27: '0',
    0x28: '\n', 0x2c: ' ', 0x2d: '-', 0x2e: '=',
    0x2f: '[', 0x30: ']', 0x31: '\\', 0x33: ';',
    0x34: "'", 0x36: ',', 0x37: '.', 0x38: '/'
}

shift_map = {
    '1': '!', '2': '@', '3': '#', '4': '$', '5': '%',
    '6': '^', '7': '&', '8': '*', '9': '(', '0': ')',
    '-': '_', '=': '+', '[': '{', ']': '}', '\\': '|',
    ';': ':', "'": '"', ',': '<', '.': '>', '/': '?'
}

result = ""

with open("hid_data.txt", "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        parts_line = line.split()
        if len(parts_line) == 2:
            data = parts_line[1]
        else:
            data = parts_line[-1]

        bytes_data = data.replace(":", "")
        if len(bytes_data) < 6:
            continue

        modifier = int(bytes_data[0:2], 16)
        keycode = int(bytes_data[4:6], 16)

        if keycode == 0:
            continue

        char = hid_map.get(keycode, "")

        if modifier in [0x02, 0x20]:
            if char.isalpha():
                char = char.upper()
            elif char in shift_map:
                char = shift_map[char]

        result += char

print("Secret Message:")
print(result)
```

Command ekstraksi `tshark`:

```bash
tshark -r soal15_wired_usb_hid.pcap -Y "usb.transfer_type == 0x01 && usb.capdata != 00:00:00:00:00:00:00:00" -T fields -e frame.number -e usb.capdata > hid_data.txt
python decode_hid.py
```

## Ekspektasi Output

```text
Secret Message:
Wired_Protocol_7_is_alive_2026
```

## Output

```text
Vendor ID      : 0x046d
Product ID     : 0xc31c
Device Address : 7
Secret Message : Wired_Protocol_7_is_alive_2026
```

## Screenshot

![File USB HID terbuka](assets/15_01_wired_usb_hid_opened.png)

**Nama file screenshot:** `assets/15_01_wired_usb_hid_opened.png`

![Vendor ID dan Product ID USB](assets/15_02_usb_vendor_product_id.png)

**Nama file screenshot:** `assets/15_02_usb_vendor_product_id.png`

![Device address USB](assets/15_03_usb_device_address.png)

**Nama file screenshot:** `assets/15_03_usb_device_address.png`

![Data keystroke non-zero](assets/15_04_usb_keystroke_nonzero_data.png)

**Nama file screenshot:** `assets/15_04_usb_keystroke_nonzero_data.png`

![Detail capdata keystroke](assets/15_05_usb_capdata_keystroke_detail.png)

**Nama file screenshot:** `assets/15_05_usb_capdata_keystroke_detail.png`

![Filter keystroke non-zero](assets/15_06_filtered_nonzero_keystrokes.png)

**Nama file screenshot:** `assets/15_06_filtered_nonzero_keystrokes.png`

![Hasil decode pesan rahasia](assets/15_07_decode_secret_message_result.png)

**Nama file screenshot:** `assets/15_07_decode_secret_message_result.png`

## Analisis

Device Descriptor menunjukkan perangkat Logitech Keyboard K120 dengan Vendor ID `0x046d` dan Product ID `0xc31c`. Packet `URB_INTERRUPT in` dari source `2.7.1` menunjukkan Bus 2, Device 7, Endpoint 1 sehingga device address adalah `7`.

Data keystroke diambil dari `Leftover Capture Data` yang tidak bernilai nol semua. Contoh `02001a0000000000` berarti Shift dan keycode `1a`, sehingga menghasilkan huruf `W`. Setelah seluruh data non-zero didekode, pesan rahasia yang ditemukan adalah `Wired_Protocol_7_is_alive_2026`.

## Kendala

Awalnya packet `0000000000000000` sempat dianggap sebagai tombol. Packet tersebut sebenarnya hanya idle atau key release. Solusinya adalah hanya menganalisis data non-zero.

---

# Nomor 16

## Inti Soal

Dari file `wired_ftp_theft.pcapng`, diminta menganalisis lalu lintas FTP untuk mengidentifikasi IP server FTP penyerang, banner software FTP, kredensial login penyerang, dan ukuran file malware `knights_payload.exe` yang diunduh.

## Cara Pengerjaan

Filter FTP digunakan untuk melihat control connection dan proses pengunduhan file.

## Filter yang Digunakan

```wireshark
ftp || ftp-data
```

```wireshark
ftp.response.code == 220
```

```wireshark
ftp.request.command == "USER" || ftp.request.command == "PASS"
```

```wireshark
ftp contains "knights_payload.exe"
```

```wireshark
ftp.response.code == 150
```

## Ekspektasi Output

```text
Response 220 memperlihatkan banner server.
Command USER dan PASS memperlihatkan kredensial login.
Command RETR memperlihatkan file yang diunduh.
Response 150 memperlihatkan ukuran file dalam bytes.
Socket 3403 memberikan Congratulations atau flag.
```

## Output

```text
FTP Server IP : 198.51.100.7
FTP Banner    : vsftpd 3.0.5
Credential    : knights_agent:N4v1_s3cur3_2026
File malware  : knights_payload.exe
File size     : 524288 bytes
Flag          : KOMJAR26{FTP_Th3ft_qD5Dtocvo9lO5rGC3Gip2kohC}
```

## Screenshot

![Capture FTP theft terbuka](assets/16_01_wired_ftp_theft_opened.png)

**Nama file screenshot:** `assets/16_01_wired_ftp_theft_opened.png`

![IP server dan banner FTP](assets/16_02_ftp_server_ip_banner_packet.png)

**Nama file screenshot:** `assets/16_02_ftp_server_ip_banner_packet.png`

![Kredensial login FTP](assets/16_04_ftp_login_credentials.png)

**Nama file screenshot:** `assets/16_04_ftp_login_credentials.png`

![Ukuran file malware](assets/16_06_ftp_file_size_response_150.png)

**Nama file screenshot:** `assets/16_06_ftp_file_size_response_150.png`

![Validasi socket FTP theft](assets/16_09_socket_validation_ftp_theft_success.png)

**Nama file screenshot:** `assets/16_09_socket_validation_ftp_theft_success.png`

## Analisis

Packet `220` menunjukkan banner FTP server. Source packet tersebut adalah `198.51.100.7`, sehingga IP tersebut adalah server FTP. Banner yang diterima socket adalah `vsftpd 3.0.5`.

Kredensial terlihat langsung pada command `USER` dan `PASS` karena FTP tidak mengenkripsi isi komunikasinya. Credential yang digunakan adalah `knights_agent:N4v1_s3cur3_2026`.

File malware diunduh menggunakan command `RETR knights_payload.exe`. Response `150 Opening BINARY mode data connection for knights_payload.exe (524288 bytes)` menunjukkan ukuran file adalah `524288` bytes.

## Kendala

Saat validasi, input banner lengkap `Welcome to Wired FTP Server (vsftpd 3.0.5)` sempat ditolak. Socket meminta software dan versinya saja, yaitu `vsftpd 3.0.5`.

---

# Nomor 17

## Inti Soal

Dari file `wired_http_c2.pcapng`, diminta mengidentifikasi domain Host tempat malware diunduh, alamat IP server penyerang, nama file executable malware, dan kode status HTTP yang dikembalikan.

## Cara Pengerjaan

Filter HTTP digunakan untuk menemukan request `.exe` dan response server yang berpasangan dengan request tersebut.

## Filter yang Digunakan

```wireshark
http
```

```wireshark
http.request
```

```wireshark
http.request.uri contains ".exe"
```

```wireshark
http.response
```

## Ekspektasi Output

```text
Muncul request GET /navi_agent.exe HTTP/1.1.
Header Host menunjukkan wired-update.net.
Destination IP request menunjukkan server 203.0.113.42.
Response frame berikutnya menunjukkan HTTP/1.1 200 OK.
```

## Output

```text
Host domain        : wired-update.net
IP server attacker : 203.0.113.42
File malware       : navi_agent.exe
HTTP status code   : 200
```

## Screenshot

![Capture HTTP C2 terbuka](assets/17_01_wired_http_c2_opened.png)

**Nama file screenshot:** `assets/17_01_wired_http_c2_opened.png`

![HTTP GET executable malware](assets/17_02_http_get_executable_malware.png)

**Nama file screenshot:** `assets/17_02_http_get_executable_malware.png`

![Host domain HTTP](assets/17_03_http_host_domain.png)

**Nama file screenshot:** `assets/17_03_http_host_domain.png`

![HTTP status code response](assets/17_05_http_status_code_response.png)

**Nama file screenshot:** `assets/17_05_http_status_code_response.png`

## Analisis

Request penting adalah `GET /navi_agent.exe HTTP/1.1` pada Frame 30. Request berasal dari `10.7.1.50` menuju `203.0.113.42`, sehingga IP server penyerang adalah `203.0.113.42`. Header `Host: wired-update.net` menunjukkan domain tempat malware diunduh.

Response berada pada Frame 31 dengan status `HTTP/1.1 200 OK`. Header `Content-Disposition: attachment; filename="navi_agent.exe"` memperkuat bahwa file yang diunduh adalah `navi_agent.exe`.

## Kendala

Tidak ada kendala besar. Hal yang perlu diperhatikan adalah memilih request `.exe`, bukan request normal seperti `/` atau `/style.css`.

---

# Nomor 18

## Inti Soal

Dari file `wired_smb_transfer.pcapng`, diminta mengidentifikasi protokol jaringan yang dieksploitasi, IP pengirim, IP penerima, folder tujuan penyimpanan malware pada sistem korban, dan nama file executable malware yang ditransfer.

## Cara Pengerjaan

Filter SMB digunakan untuk menemukan aktivitas file sharing dan penulisan file `.exe`.

## Filter yang Digunakan

```wireshark
smb || smb2
```

```wireshark
smb2.filename contains ".exe"
```

```wireshark
smb2.cmd == 5 || smb2.cmd == 9
```

## Ekspektasi Output

```text
Protocol SMB2 terlihat pada kolom Protocol.
Create Request memperlihatkan path System32\wired_trojan_payload.exe.
Write Request memperlihatkan proses penulisan file ke korban.
Socket 3405 memberikan Congratulations atau flag.
```

## Output

```text
Protocol exploited : SMB2
Source host IP     : 10.7.3.100
Victim host IP     : 10.7.1.50
Target directory   : System32
Malware filename   : wired_trojan_payload.exe
Flag               : KOMJAR26{SMB_Tr4nsf3r_z1i0KTe8evjV0f9eM5RnIsD3V}
```

## Screenshot

![Capture SMB transfer terbuka](assets/18_01_wired_smb_transfer_opened.png)

**Nama file screenshot:** `assets/18_01_wired_smb_transfer_opened.png`

![File executable SMB ditemukan](assets/18_03_smb_executable_file_found.png)

**Nama file screenshot:** `assets/18_03_smb_executable_file_found.png`

![Write Request malware transfer](assets/18_04_smb_sender_receiver_ip_smb_write_request_malware_transfer.png)

**Nama file screenshot:** `assets/18_04_smb_sender_receiver_ip_smb_write_request_malware_transfer.png`

![Folder tujuan SMB](assets/18_05_smb_destination_folder_path.png)

**Nama file screenshot:** `assets/18_05_smb_destination_folder_path.png`

![Validasi socket SMB transfer](assets/18_08_socket_validation_smb_transfer_success.png)

**Nama file screenshot:** `assets/18_08_socket_validation_smb_transfer_success.png`

## Analisis

Capture menunjukkan protokol `SMB2`. Filter `smb2.filename contains ".exe"` menampilkan file `System32\wired_trojan_payload.exe`. Bagian `System32` adalah folder tujuan, sedangkan `wired_trojan_payload.exe` adalah nama file malware.

Packet `Write Request Len: 1028 Off: 0` menunjukkan bahwa file benar-benar ditulis ke sistem korban. Pada packet request, source adalah `10.7.3.100` dan destination adalah `10.7.1.50`, sehingga IP pengirim adalah `10.7.3.100` dan IP korban adalah `10.7.1.50`.

## Kendala

Pada validasi, input pertama sempat salah untuk pertanyaan protokol. Setelah mengikuti prompt socket dan memasukkan data sesuai format, validasi berhasil.

---

# Nomor 19

## Inti Soal

Dari file `wired_smtp_threat.pcapng`, diminta menganalisis TCP Stream SMTP untuk mengidentifikasi alamat email korban, password korban yang diklaim bocor, jenis malware, batas waktu dalam hari, dan MailClientID.

## Cara Pengerjaan

Filter SMTP digunakan untuk mencari email ancaman. Packet email ancaman kemudian dibuka dengan fitur Follow TCP Stream.

## Filter dan Langkah yang Digunakan

```wireshark
smtp
```

```wireshark
smtp contains "URGENT"
```

```wireshark
frame contains "MailClientID"
```

```text
Klik packet email ancaman -> Right click -> Follow -> TCP Stream
```

## Ekspektasi Output

```text
TCP Stream memperlihatkan MAIL FROM, RCPT TO, Subject, body email ancaman, password, jenis malware, deadline, dan MailClientID.
```

## Output

```text
Victim email    : victim@protocol7.co.jp
Leaked password : protocol_7_user
Malware type    : ransomware
Deadline days   : 3
MailClientID    : 7719980706
```

## Screenshot

![Capture SMTP threat terbuka](assets/19_01_wired_smtp_threat_opened.png)

**Nama file screenshot:** `assets/19_01_wired_smtp_threat_opened.png`

![Follow TCP Stream SMTP](assets/19_02_smtp_follow_tcp_stream.png)

**Nama file screenshot:** `assets/19_02_smtp_follow_tcp_stream.png`

![Detail email threat SMTP](assets/19_03_07_smtp_threat_details.png)

**Nama file screenshot:** `assets/19_03_07_smtp_threat_details.png`

## Analisis

Email ancaman berada pada stream dengan pengirim `attacker@darkwired.net` dan penerima `victim@protocol7.co.jp`. Subject email adalah `URGENT: Your Wired account has been compromised`.

Isi email menyebut password korban sebagai `protocol_7_user`. Malware yang disebut adalah `ransomware`. Batas waktu ancaman tertulis `72 hours (3 days)`, sehingga jawaban dalam satuan hari adalah `3`. Pada bagian akhir pesan tercantum `MailClientID: 7719980706`.

## Kendala

Terdapat beberapa email normal dan spam lain pada capture. Email yang relevan adalah email dengan subject `URGENT: Your Wired account has been compromised`.

---

# Nomor 20

## Inti Soal

Dari file `wired_tls_decrypt.pcapng` dan `keylogfile.txt`, diminta mendekripsi lalu lintas TLS untuk mengidentifikasi versi TLS yang dinegosiasikan, nama domain SNI, IP server HTTPS penyerang, User-Agent, HTTP request method, dan path tersembunyi.

## Cara Pengerjaan

File keylog dimasukkan ke Wireshark melalui TLS Preferences agar isi HTTPS dapat didekripsi.

## Langkah Konfigurasi Keylogfile

```text
Edit -> Preferences -> Protocols -> TLS -> (Pre)-Master-Secret log filename -> pilih keylogfile.txt -> Apply -> OK
```

## Filter yang Digunakan

```wireshark
tls
```

```wireshark
tls.handshake.type == 2
```

```wireshark
tls.handshake.extensions_server_name
```

```wireshark
http || http2
```

```wireshark
http.request
```

## Ekspektasi Output

```text
Sebelum keylogfile, packet terlihat sebagai TLS Application Data.
Setelah keylogfile, filter http || http2 menampilkan HEAD / HTTP/1.1.
Client Hello menunjukkan SNI example.com.
Server Hello menunjukkan TLSv1.2.
HTTP Stream menunjukkan User-Agent curl/7.62.0, method HEAD, dan path /.
```

## Output

```text
TLS Version      : TLSv1.2
SNI domain       : example.com
HTTPS server IP  : 93.184.216.34
User-Agent       : curl/7.62.0
HTTP Method      : HEAD
HTTP Path        : /
```

## Screenshot

![Capture TLS terbuka](assets/20_01_wired_tls_decrypt_opened.png)

**Nama file screenshot:** `assets/20_01_wired_tls_decrypt_opened.png`

![Keylogfile TLS dikonfigurasi](assets/20_02_tls_keylogfile_configured.png)

**Nama file screenshot:** `assets/20_02_tls_keylogfile_configured.png`

![HTTP hasil dekripsi terlihat](assets/20_03_decrypted_http_visible.png)

**Nama file screenshot:** `assets/20_03_decrypted_http_visible.png`

![TLS negotiated version](assets/20_04_tls_negotiated_version.png)

**Nama file screenshot:** `assets/20_04_tls_negotiated_version.png`

![SNI domain TLS](assets/20_05_tls_sni_domain.png)

**Nama file screenshot:** `assets/20_05_tls_sni_domain.png`

![IP server HTTPS](assets/20_06_https_attacker_server_ip.png)

**Nama file screenshot:** `assets/20_06_https_attacker_server_ip.png`

![User-Agent HTTP hasil dekripsi](assets/20_07_decrypted_http_user_agent.png)

**Nama file screenshot:** `assets/20_07_decrypted_http_user_agent.png`

![HTTP stream hasil dekripsi](assets/20_09_decrypted_http_stream_evidence.png)

**Nama file screenshot:** `assets/20_09_decrypted_http_stream_evidence.png`

## Analisis

Sebelum keylogfile dimasukkan, komunikasi hanya terlihat sebagai TLS Application Data. Setelah `keylogfile.txt` dimasukkan ke TLS Preferences, Wireshark dapat menampilkan HTTP yang tersembunyi dalam sesi TLS.

Versi TLS yang dinegosiasikan adalah `TLSv1.2`. SNI pada Client Hello menunjukkan domain `example.com`. Destination IP pada Client Hello adalah `93.184.216.34`, sehingga alamat tersebut adalah IP server HTTPS tujuan. Setelah dekripsi, request HTTP yang terlihat adalah `HEAD / HTTP/1.1` dengan header `User-Agent: curl/7.62.0`.

## Kendala

Pada awalnya isi HTTP tidak terbaca karena masih terenkripsi sebagai TLS Application Data. Setelah `keylogfile.txt` dimasukkan pada kolom `(Pre)-Master-Secret log filename`, HTTP request berhasil didekripsi.

---

# Kesimpulan Umum

Berdasarkan pengerjaan ini, Wireshark dapat digunakan untuk menganalisis berbagai jenis lalu lintas jaringan, mulai dari routing dasar, DNS dan ICMP, brute-force HTTP, USB HID keystroke, pencurian kredensial FTP, HTTP C2, transfer malware melalui SMB, ancaman SMTP, hingga dekripsi TLS menggunakan keylogfile.

Protokol yang tidak terenkripsi seperti FTP dan SMTP memperlihatkan kredensial serta isi pesan secara langsung. Pada TLS, isi komunikasi baru dapat dianalisis setelah `keylogfile.txt` dimasukkan ke Wireshark.

---

# Rekap Hasil Analisis

| Nomor | Topik | Temuan Utama | Status |
|---|---|---|---|
| 1 | Topologi | Lain sebagai router, 3 switch, 5 client | Selesai |
| 2 | Internet router | Lain mendapat internet dari NAT | Selesai |
| 3 | IP client | Client terhubung ke gateway | Selesai |
| 4 | Internet client | Client dapat ping internet dan DNS | Selesai |
| 5 | Restart check | Script cek interface dan NAT | Selesai |
| 6 | Traffic generator | DNS dan ICMP dari Mika | Selesai |
| 14 | HTTP brute-force | Attacker `172.26.7.50`, target `172.26.7.100:8080` | Parsial |
| 15 | USB HID | `0x046d`, `0xc31c`, device `7`, pesan `Wired_Protocol_7_is_alive_2026` | Selesai |
| 16 | FTP theft | `198.51.100.7`, `vsftpd 3.0.5`, `knights_agent:N4v1_s3cur3_2026`, `524288` | Valid |
| 17 | HTTP C2 | `wired-update.net`, `203.0.113.42`, `navi_agent.exe`, `200` | Belum ada SS validasi socket |
| 18 | SMB transfer | `SMB2`, `10.7.3.100`, `10.7.1.50`, `System32`, `wired_trojan_payload.exe` | Valid |
| 19 | SMTP threat | `victim@protocol7.co.jp`, `protocol_7_user`, `ransomware`, `3`, `7719980706` | Belum ada SS validasi socket |
| 20 | TLS decrypt | `TLSv1.2`, `example.com`, `93.184.216.34`, `curl/7.62.0`, `HEAD`, `/` | Belum ada SS validasi socket |
