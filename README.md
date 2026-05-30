<div align="center">

# ⚡ Siroha Flash Tool

**All-in-one Qualcomm Flash Tool untuk Termux**  
Tanpa PC — Flash langsung dari HP ke HP via USB OTG

[![GitHub stars](https://img.shields.io/github/stars/rahmatsobrian/SirohaFlashTool?style=flat-square&color=yellow)](https://github.com/rahmatsobrian/SirohaFlashTool/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/rahmatsobrian/SirohaFlashTool?style=flat-square&color=blue)](https://github.com/rahmatsobrian/SirohaFlashTool/network)

</div>

---

## 📋 Daftar Isi

- [Tentang](#-tentang)
- [Syarat](#-syarat)
- [Instalasi Cepat](#-instalasi-cepat-one-liner)
- [Struktur File](#-struktur-file)
- [Cara Install Manual](#-cara-install-manual)
- [Fitur & Menu](#-fitur--menu)
- [Panduan Lengkap](#-panduan-lengkap)
  - [QDL Flash (EDL)](#1-qdl-flash-edl-9008)
  - [Fastboot Flash](#2-fastboot-flash)
  - [Cek Status UBL](#3-cek-status-ubl)
  - [GSI ROM Flash](#4-gsi-rom-flash)
  - [A/B Partition](#5-ab-partition-tool)
  - [FRP Remove](#6-frp-remove)
  - [Bypass UBL Redmi 4A](#7-bypass-ubl-redmi-4a-rolex)
- [Troubleshooting](#-troubleshooting)
- [Kompatibilitas](#-kompatibilitas)
- [Kredit](#-source--kredit)

---

## 📌 Tentang

**Siroha Flash Tool** adalah gabungan beberapa tool EDL/Fastboot populer yang diport dan diintegrasikan menjadi satu script Bash interaktif dengan tampilan GUI berbasis terminal — bisa dijalankan langsung di Termux **tanpa PC**.

**Gabungan dari:**
| Tool | Fungsi |
|---|---|
| [Termux-QDL](https://github.com/Ishu43642/Termux-QDL) | QDL binary multi-arch |
| [QDL-Flasher](https://github.com/QDL-Flasher) | Flash via EDL 9008 |
| [ADBiFY-QDL](https://github.com/ADBiFY-QDL) | QDL tanpa root |
| [Termux-Root-Recovery-Tool](https://github.com/TRRT) | Flash fastboot, GSI, recovery |
| Bypass UBL Redmi 4A *(Rahmat Sobrian)* | Port dari `.bat` ke Bash |

---

## ✅ Syarat

### HP Host (yang menjalankan tool)

| Syarat | Keterangan |
|---|---|
| **Root** | **Wajib** — akses USB & QDL butuh root |
| **Izin root Termux** | Grant via Magisk / KernelSU / APatch |
| **Termux** | Dari **F-Droid** — BUKAN Play Store! |
| **Termux:API** | APK dari F-Droid + `pkg install termux-api` |
| **Arsitektur** | arm64 / arm / x86_64 / x86 (auto-detect) |
| **USB OTG** | HP host harus support USB Host/OTG |

### HP Target (yang di-flash)

| Syarat | Keterangan |
|---|---|
| **Chipset** | Qualcomm (untuk QDL/EDL) |
| **Mode** | EDL 9008 / Fastboot / Recovery |
| **BL** | Unlock (untuk Fastboot flash) |

> ⚠️ **Termux dari Play Store dan F-Droid tidak kompatibel!** Jika salah satu dari Play Store, uninstall dulu → install ulang semua dari F-Droid.

---

## ⚡ Instalasi Cepat (One-liner)

> Jalankan di Termux setelah grant izin root atau kamu sudah yakin semuanya sudah siap

```bash
# Clone & setup otomatis jika kamu sudah yakin semua bahan sudah terpasang dan terkonfigurasi
git clone https://github.com/rahmatsobrian/SirohaFlashTool && cd SirohaFlashTool && chmod +x flash.sh bin/*/qdl && ./flash.sh
```

Atau step per step:

```bash
# 1. Clone repo
git clone https://github.com/rahmatsobrian/SirohaFlashTool
cd SirohaFlashTool

# 2. Beri izin execute
chmod +x flash.sh
chmod +x bin/arm64/qdl   # cek arch dulu: uname -m

# 3. Install semua dependensi
pkg update && pkg upgrade -y
pkg install -y termux-api git libxml2 sudo curl
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash

# 4. Setup sudo
pkg install sudo
su -c "echo 'ALL ALL=(ALL) NOPASSWD:ALL' > $PREFIX/etc/sudoers.d/termux"

# 5. Jalankan
./flash.sh
```

---

## 📁 Struktur File

```
SirohaFlashTool/
├── flash.sh                          ← Script utama (jalankan ini!)
├── README.md
│
├── bin/                              ← QDL binary (auto-detect arch)
│   ├── arm64/qdl                     ← HP 64-bit (kebanyakan HP modern)
│   ├── arm/qdl                       ← HP 32-bit
│   ├── x86_64/qdl
│   └── x86/qdl
│
└── bypass-ubl/
    └── Redmi4A-rolex/
        ├── rahmatsobrian.mbn         ← Firehose loader Redmi 4A
        ├── devinfo                   ← Partition image (UBL flag)
        ├── emmc_appsboot.mbn         ← Aboot image
        ├── rawprogram0.xml           ← Partition map (dari ROM MIUI 10.2.3.0)
        └── patch0.xml                ← Patch table
```

---

## 🚀 Cara Install Manual

### Langkah 1 — Install Termux & Termux:API dari F-Droid

```
1. Download F-Droid → https://f-droid.org/F-Droid.apk
2. Buka F-Droid → Cari "Termux" → Install
3. Buka F-Droid → Cari "Termux:API" → Install (APK terpisah!)
4. Buka Termux → jalankan: pkg install termux-api
```

> Ada **2 komponen** yang berbeda dan keduanya wajib:
> - **Termux:API (APK)** — dari F-Droid, sebagai bridge sistem
> - **termux-api (pkg)** — `pkg install termux-api`, sebagai CLI

### Langkah 2 — Grant Izin Root ke Termux

**Via Magisk:**
```
Magisk → Superuser → Cari Termux → Toggle ON
```

**Via KernelSU:**
```
KernelSU → SuperUser → Cari Termux → Granted
```

**Via APatch:**
```
APatch → SuperUser → Grant untuk Termux
```

Verifikasi di Termux:
```bash
su          # tap Grant pada popup
id          # harus output: uid=0(root)
sudo id     # harus output: uid=0(root)
```

### Langkah 3 — Clone & Setup

```bash
git clone https://github.com/rahmatsobrian/SirohaFlashTool
cd SirohaFlashTool
chmod +x flash.sh bin/arm64/qdl
```

> Cek arch HP kamu: `uname -m`
> - `aarch64` → gunakan `bin/arm64/qdl`
> - `armv7l` → gunakan `bin/arm/qdl`

### Langkah 4 — Install Dependensi

```bash
pkg update && pkg upgrade -y
pkg install -y termux-api git libxml2 sudo curl
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
```

### Langkah 5 — Setup sudo

```bash
pkg install sudo
su -c "echo 'ALL ALL=(ALL) NOPASSWD:ALL' > $PREFIX/etc/sudoers.d/termux"
sudo id   # verifikasi: uid=0(root)
```

### Langkah 6 — Cek Requirements

```bash
./flash.sh
# Menu 1 → Opsi 5
```

Output yang diharapkan:
```
[ ROOT & IZIN ]
[✓] Root (su)          : TERDETEKSI
[✓] Izin root Termux   : SUDAH DIIZINKAN
[✓] sudo as root       : OK

[ TERMUX-API ]
[✓] termux-api (pkg)   : TERINSTALL
[✓] Termux:API (APK)   : TERINSTALL

[ ADB & FASTBOOT ]
[✓] ADB                : TERINSTALL
[✓] Fastboot           : TERINSTALL

[ QDL BINARY ]
[✓] QDL binary         : ADA (bin/arm64/qdl)
[✓] QDL executable     : OK
```

---

## 🗂️ Fitur & Menu

```
╔═══════════════════════════════════════════════════╗
║      ⚡ SIROHA FLASH TOOL — MAIN MENU ⚡          ║
║    Qualcomm EDL • Fastboot • Recovery • GSI       ║
╚═══════════════════════════════════════════════════╝

  1.  📦 Instalasi & Cek Requirements
  2.  ⚡ QDL Flash (EDL 9008 Mode)
  3.  🔧 Fastboot Flash Tool
  4.  ☯️ GSI ROM Flash Tool
  5.  🆎 A/B Partition Tool
  6.  🔐 FRP Remove Tool
  7.  🔌 USB / OTG Fix Tool
  8.  📖 Panduan Lengkap
  9.  🔓 Bypass UBL Redmi 4A (rolex) MIUI 10
  0.  ✖  Keluar
```

| Menu | Sub-fitur |
|---|---|
| **1 — Instalasi** | Install paket, reinstall API/ADB, cek requirements, panduan root & Termux:API |
| **2 — QDL Flash** | Flash EMMC/UFS via EDL 9008, reboot ke EDL via ADB/Fastboot, manual command |
| **3 — Fastboot Flash** | Flash Recovery/Boot/init_boot/vendor_boot/vbmeta/super, sideload ZIP, **cek status UBL** |
| **4 — GSI ROM** | Flash GSI via FastbootD, erase system, delete logical partition |
| **5 — A/B Partition** | Flash slot _a/_b, set active slot, boot TWRP tanpa flash |
| **6 — FRP Remove** | Reset FRP untuk SPRD / Samsung / MTK |
| **7 — USB/OTG Fix** | Auto-detect device, restart ADB server, reinstall driver |
| **8 — Panduan** | Guide lengkap Bahasa Indonesia |
| **9 — Bypass UBL** | Bypass UBL Redmi 4A (rolex) MIUI 10.2.3.0 via QDL |

---

## 📖 Panduan Lengkap

### 1. QDL Flash (EDL 9008)

#### Persiapan folder firmware

```
/sdcard/qdl-flash/
├── prog_firehose_ddr_XXX.mbn   ← firehose loader
├── rawprogram0.xml              ← partition map
└── patch0.xml                   ← patch table
```

#### Cara masuk EDL

```bash
# Via ADB (HP target masih bisa booting)
adb reboot edl

# Via Fastboot (BL sudah unlock)
fastboot oem edl

# Via hardware: test point sesuai skematik device
```

#### Flash via menu

```
./flash.sh → Menu 2 → Opsi 1 (EMMC) / Opsi 2 (UFS)
```

#### Flash manual langsung

```bash
cd SirohaFlashTool
sudo ./bin/arm64/qdl --debug --storage emmc \
  --include /sdcard/qdl-flash \
  /sdcard/qdl-flash/prog_firehose.mbn \
  /sdcard/qdl-flash/rawprogram0.xml \
  /sdcard/qdl-flash/patch0.xml
```

---

### 2. Fastboot Flash

#### Flash Recovery

```bash
# Via menu
./flash.sh → Menu 3 → Opsi 3

# Manual
fastboot flash recovery /sdcard/recovery.img
```

#### Flash Boot (Magisk patch)

```bash
# Via menu
./flash.sh → Menu 3 → Opsi 4

# Manual
fastboot flash boot /sdcard/boot_patched.img
```

#### Flash vbmeta (disable-verity)

```bash
# Via menu
./flash.sh → Menu 3 → Opsi 7

# Manual
fastboot --disable-verity --disable-verification flash vbmeta /sdcard/vbmeta.img
```

#### ADB Sideload

```bash
# Via menu
./flash.sh → Menu 3 → Opsi 13

# Manual (device harus di Recovery → ADB Sideload)
adb sideload /sdcard/update.zip
```

---

### 3. Cek Status UBL

Cek status bootloader lock/unlock tanpa mengetik manual.

```bash
# Via menu
./flash.sh → Menu 3 → Opsi 15

# Manual
fastboot oem device-info
```

Output yang ditampilkan:

```
  Device tampered:          false

  Device unlocked:          true

  Device critical unlocked: true

  Charger screen enabled:   true

  Display panel:            -

  ────────────────────────────────────
  [✓] Bootloader UNLOCK — siap flash
```

Nilai `true` ditampilkan **hijau**, `false` ditampilkan **merah**, disertai kesimpulan dan saran langkah selanjutnya.

---

### 4. GSI ROM Flash

Urutan wajib untuk flash GSI (Dynamic Partition):

```bash
# 1. Flash vbmeta dulu (dari Fastboot mode)
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img

# 2. Reboot ke FastbootD
fastboot reboot fastboot

# 3. Verifikasi userspace
fastboot getvar is-userspace   # harus: yes

# 4. Hapus system & product
fastboot erase system
fastboot delete-logical-partition product_a
fastboot delete-logical-partition product_b

# 5. Flash GSI
fastboot flash system gsi.img

# 6. Reboot ke recovery → Format data → Reboot
```

Atau lewat menu: `./flash.sh → Menu 4` (tersedia semua langkah di atas)

---

### 5. A/B Partition Tool

```bash
# Flash boot ke slot aktif
./flash.sh → Menu 5 → Opsi 1

# Flash ke slot spesifik
fastboot flash boot_a boot.img
fastboot flash boot_b boot.img

# Set active slot
fastboot --set-active=a
fastboot --set-active=b

# Boot TWRP tanpa flash
fastboot boot twrp.img

# Cek slot aktif
fastboot getvar current-slot
```

---

### 6. FRP Remove

```bash
# SPRD via Fastboot
fastboot erase persist

# Samsung / MTK via ADB
adb shell content insert --uri content://settings/secure \
  --bind name:s:user_setup_complete --bind value:s:1

# Via menu
./flash.sh → Menu 6
```

---

### 7. Bypass UBL Redmi 4A (rolex)

> ⚠️ **KHUSUS** Redmi 4A (codename: **rolex**) — MIUI **V10.2.3.0.NCCMIXM** (Global, build 20190605)  
> Versi MIUI lain = struktur partisi berbeda = **BRICK!**

#### Cek versi MIUI dulu

```
Settings → About Phone → MIUI Version
Harus menampilkan: V10.2.3.0.NCCMIXM
```

#### Partisi yang di-flash

> Data diambil langsung dari `rawprogram0.xml` ROM `rolex_global_images_V10.2.3.0.NCCMIXM_20190605`

| Partisi | Start Sector | Hex Address | Size |
|---|---|---|---|
| `aboot` | 786432 | `0x18000000` | 2048 sectors (1 MB) |
| `abootbak` | 788480 | `0x18100000` | 2048 sectors (1 MB) |
| `devinfo` | 1052672 | `0x20200000` | 2048 sectors (1 MB) |

#### Cara pakai — via menu

```
./flash.sh → Menu 9 → Opsi 1
```

#### Cara pakai — manual (untuk yang paham)

```bash
# Step 1 — Masuk EDL
adb reboot edl
# atau: tahan Vol+ + Vol- → colok kabel (dari kondisi mati)
# atau: bongkar hp , cabut fleksibel baterai, cari titik testpoint, pasang fleksibel baterai, hubungkan kedua titik testpoint menggunakan pinset → colok kabel (dari kondisi mati)

# Step 2 — Flash via QDL
cd SirohaFlashTool

sudo ./bin/arm64/qdl --debug --storage emmc \
  --include bypass-ubl/Redmi4A-rolex \
  bypass-ubl/Redmi4A-rolex/rahmatsobrian.mbn \
  bypass-ubl/Redmi4A-rolex/rawprogram0.xml \
  bypass-ubl/Redmi4A-rolex/patch0.xml
```

#### Setelah bypass berhasil

```bash
# 1. Reboot device
Reboot to system

# 2. Masuk ke fastboot
# Gunakan tombol / adb

# 3. Verifikasi
fastboot oem device-info
# Device unlocked: true
```

---

## 🔧 Troubleshooting

### termux-usb tidak mendeteksi device

```bash
# Cek APK Termux:API terinstall
pm list packages | grep termux.api

# Reinstall via menu
./flash.sh → Menu 1 → Opsi 2

# Manual
yes | pkg remove termux-api && pkg install -y termux-api
```

### QDL gagal / device not found

```bash
# Cek device terdeteksi
termux-usb -l

# Cek USB permission
sudo chmod 666 /dev/bus/usb/*/*

# Cek sudo berjalan
sudo id   # harus: uid=0(root)

# Pastikan device di EDL (layar mati, LED merah/tidak ada tampilan)
```

### ADB device not found

```bash
# Restart ADB server
adb kill-server && adb start-server

# Cek device
adb devices

# Via menu
./flash.sh → Menu 7 → Opsi 4, lalu 5
```

### Fastboot device not found

```bash
# Pastikan device di Fastboot mode
fastboot devices

# Reinstall ADB/Fastboot
./flash.sh → Menu 1 → Opsi 3
```

### sudo: command not found

```bash
pkg install sudo
su -c "echo 'ALL ALL=(ALL) NOPASSWD:ALL' > $PREFIX/etc/sudoers.d/termux"
sudo id
```

### QDL: permission denied

```bash
chmod +x bin/arm64/qdl
sudo bin/arm64/qdl --help
```

### /dev/bus/usb: permission denied

```bash
sudo chmod 666 /dev/bus/usb/*/*
```

---

## 🏗️ Cara Kerja QDL Flash

```
HP Host (Termux + Root)
       │
       │ USB OTG
       ▼
HP Target (EDL 9008)
       │
       ▼
qdl binary membaca:
  ├── firehose.mbn   → diupload ke device sebagai programmer
  ├── rawprogram.xml → instruksi tulis ke setiap partisi
  └── patch.xml      → patch CRC/checksum setelah write
```

Firehose loader diupload ke device via USB, kemudian loader menerima instruksi dari host untuk menulis file ke partisi sesuai `rawprogram.xml`.

---

## 📱 Kompatibilitas

| Fitur | Chipset | Syarat |
|---|---|---|
| QDL Flash | Qualcomm (semua) | Firehose loader + EDL mode |
| Fastboot Flash | Semua | BL unlock |
| Cek Status UBL | Qualcomm / semua | Fastboot mode |
| GSI Flash | Semua (Dynamic Partition) | BL unlock + FastbootD |
| A/B Partition | Semua A/B device | BL unlock |
| FRP Remove | SPRD / Samsung / MTK | ADB / Fastboot |
| Bypass UBL | **Redmi 4A (rolex) ONLY** | **MIUI 10.2.3.0 ONLY** |

---

## 📂 Source & Kredit

| Tool | Source |
|---|---|
| QDL binary | [Ishu43642/Termux-QDL](https://github.com/Ishu43642/Termux-QDL) |
| QDL-Flasher | [QDL-Flasher](https://github.com/QDL-Flasher) (multi-arch binary) |
| ADBiFY-QDL | [ADBiFY-QDL](https://github.com/ADBiFY-QDL) |
| Termux-Root-Recovery-Tool | [TRRT](https://github.com/TRRT) |
| Bypass UBL Redmi 4A | **Rahmat Sobrian** (original `.bat`) |
| Port Bash + integrasi | **[Siroha](https://github.com/rahmatsobrian)** |

---

## 👤 Author

<div align="center">

|---|---|
| **GitHub** | [rahmatsobrian](https://github.com/rahmatsobrian) |
| **Telegram** | [t.me/rahmatsobrian](https://t.me/rahmatsobrian) |
| **YouTube** | [@siroha3352](https://youtube.com/@siroha3352) |
| **Lokasi** | Jawa Tengah, Indonesia |

</div>

---

## ⚠️ Disclaimer

Tool ini dibuat untuk tujuan edukasi dan keperluan pribadi. Segala risiko yang timbul — termasuk brick, kehilangan data, atau kerusakan perangkat — menjadi tanggung jawab pengguna sepenuhnya.  
**Selalu backup data sebelum melakukan flashing apapun.**

---

<div align="center">

**⚡ Siroha Flash Tool** — Made with ❤️ by [Siroha](https://github.com/rahmatsobrian)

[⭐ Star repo ini](https://github.com/rahmatsobrian/SirohaFlashTool) jika bermanfaat!

</div>
