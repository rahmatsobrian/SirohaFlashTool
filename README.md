# ⚡ Siroha Flash Tool

> All-in-one Qualcomm Flash Tool untuk Termux — tanpa PC, langsung dari HP ke HP via USB OTG.

**Gabungan dari:**
- [Termux-QDL](https://github.com/Ishu43642/Termux-QDL)
- [QDL-Flasher](https://github.com/QDL-Flasher)
- [ADBiFY-QDL](https://github.com/ADBiFY-QDL)
- [Termux-Root-Recovery-Tool](https://github.com/TRRT)
- Bypass UBL Redmi 4A by Rahmat Sobrian (port ke Bash)

---

## 📋 Daftar Isi

- [Syarat](#-syarat)
- [Struktur File](#-struktur-file)
- [Cara Install](#-cara-install)
- [Fitur & Menu](#-fitur--menu)
- [Panduan Lengkap](#-panduan-lengkap)
  - [Setup Awal](#1-setup-awal)
  - [QDL Flash (EDL)](#2-qdl-flash-edl-9008)
  - [Fastboot Flash](#3-fastboot-flash)
  - [GSI ROM Flash](#4-gsi-rom-flash)
  - [A/B Partition](#5-ab-partition-tool)
  - [FRP Remove](#6-frp-remove)
  - [USB/OTG Fix](#7-usb--otg-fix)
  - [Bypass UBL Redmi 4A](#8-bypass-ubl-redmi-4a-rolex)
- [Troubleshooting](#-troubleshooting)
- [Author](#-author)

---

## ✅ Syarat

### HP Host (yang menjalankan tool)

| Syarat | Keterangan |
|---|---|
| **Root** | Wajib — akses USB device butuh root |
| **Termux** | Dari **F-Droid** (BUKAN Play Store!) |
| **Termux:API** | APK dari **F-Droid** + `pkg install termux-api` |
| **Arsitektur** | arm64 / arm / x86_64 / x86 (auto-detect) |
| **USB OTG** | HP host harus support USB Host/OTG |

### HP Target (yang di-flash)

| Syarat | Keterangan |
|---|---|
| **Chipset** | Qualcomm (untuk QDL/EDL) |
| **Mode** | EDL (9008) / Fastboot / Recovery — tergantung fitur |
| **BL Status** | Unlock (untuk Fastboot flash) |

> **⚠️ PENTING:** Termux dari Play Store dan F-Droid **tidak kompatibel** satu sama lain. Jika ada salah satu dari Play Store, uninstall dulu lalu install semua dari F-Droid.

---

## 📁 Struktur File

```
SirohaFlashTool/
├── flash.sh                          ← Script utama (jalankan ini!)
├── README.md
│
├── bin/                              ← QDL binary (auto-detect arch)
│   ├── arm64/
│   │   └── qdl                      ← Untuk HP 64-bit (kebanyakan HP modern)
│   ├── arm/
│   │   └── qdl                      ← Untuk HP 32-bit
│   ├── x86_64/
│   │   └── qdl
│   └── x86/
│       └── qdl
│
└── bypass-ubl/
    └── Redmi4A-rolex/               ← File khusus Bypass UBL Redmi 4A
        ├── rahmatsobrian.mbn        ← Firehose loader Redmi 4A (rolex)
        ├── devinfo                  ← Partition image (UBL flag)
        ├── emmc_appsboot.mbn        ← Aboot image
        ├── rawprogram0.xml          ← Partition map (dari ROM MIUI 10.2.3.0)
        └── patch0.xml               ← Patch table (dari ROM MIUI 10.2.3.0)
```

---

## 🚀 Cara Install

### Langkah 1 — Install Termux & Termux:API dari F-Droid

1. Download F-Droid: https://f-droid.org/F-Droid.apk
2. Install **Termux** dari F-Droid
3. Install **Termux:API** dari F-Droid (APK terpisah!)

> Kedua APK harus dari sumber yang sama (F-Droid) agar bisa saling berkomunikasi.

### Langkah 2 — Grant Izin Root ke Termux

Buka aplikasi root manager di HP host:

**Magisk:**
> Magisk → Superuser → Cari Termux → Toggle ON

**KernelSU:**
> KernelSU → SuperUser → Cari Termux → Grant

**APatch:**
> APatch → SuperUser → Grant untuk Termux

Lalu verifikasi di Termux:
```bash
su
# Harus muncul popup izin, tap Grant
id
# Output harus: uid=0(root)
```

### Langkah 3 — Extract & Setup Tool

```bash
# Extract zip ke internal storage
# Buka Termux, lalu:

cd /sdcard/SirohaFlashTool

# Beri permission execute
chmod +x flash.sh
chmod +x bin/arm64/qdl    # sesuaikan dengan arch HP kamu
# cek arch: uname -m
# aarch64 = arm64, armv7l = arm
```

### Langkah 4 — Install Paket yang Dibutuhkan

```bash
# Jalankan script dulu untuk akses menu install
./flash.sh
# Pilih: 1 (Instalasi & Cek Requirements) → 1 (Install semua paket)
```

Atau manual:
```bash
pkg update && pkg upgrade -y
pkg install -y termux-api git libxml2 sudo curl

# Install ADB & Fastboot
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
```

### Langkah 5 — Setup sudo

```bash
pkg install sudo
su -c "echo 'ALL ALL=(ALL) NOPASSWD:ALL' > $PREFIX/etc/sudoers.d/termux"

# Verifikasi
sudo id
# Output: uid=0(root)
```

### Langkah 6 — Jalankan

```bash
./flash.sh
```

---

## 🗂️ Fitur & Menu

```
╔═══════════════════════════════════════════════════╗
║      ⚡ SIROHA FLASH TOOL — MAIN MENU ⚡          ║
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

| Menu | Fungsi Utama |
|---|---|
| 1 — Instalasi | Install ADB/Fastboot/termux-api, cek requirements, panduan root & Termux:API |
| 2 — QDL Flash | Flash Qualcomm via EDL 9008 (EMMC/UFS), reboot ke EDL via ADB/Fastboot |
| 3 — Fastboot Flash | Flash Recovery/Boot/init_boot/vendor_boot/vbmeta/super, sideload ZIP |
| 4 — GSI ROM | Flash Generic System Image via FastbootD, erase system, delete logical partition |
| 5 — A/B Partition | Flash slot _a/_b, set active slot, boot TWRP tanpa flash |
| 6 — FRP Remove | Reset FRP untuk SPRD / Samsung / MTK via ADB & Fastboot |
| 7 — USB/OTG Fix | Auto-detect device, restart ADB server, reinstall driver |
| 8 — Panduan | Guide lengkap step-by-step dalam Bahasa Indonesia |
| 9 — Bypass UBL | Bypass UBL Redmi 4A (rolex) khusus MIUI 10.2.3.0 via QDL |

---

## 📖 Panduan Lengkap

### 1. Setup Awal

#### Install Termux:API dengan benar

Ada **2 komponen** yang berbeda dan keduanya wajib:

| Komponen | Cara Install | Fungsi |
|---|---|---|
| **Termux:API (APK)** | Download dari F-Droid | Aplikasi Android yang menjadi bridge |
| **termux-api (pkg)** | `pkg install termux-api` di Termux | Package CLI untuk memanggil API |

Jika salah satu tidak ada, perintah seperti `termux-usb -l` akan gagal.

#### Cek semua requirements

```bash
./flash.sh → Menu 1 → Opsi 5
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

### 2. QDL Flash (EDL 9008)

Gunakan untuk flash firmware Qualcomm lengkap via EDL mode.

#### Persiapan file firmware

```
/sdcard/qdl-flash/
├── prog_firehose_ddr_XXX.mbn   ← loader (firehose)
├── rawprogram0.xml              ← partition map
└── patch0.xml                   ← patch table
```

#### Cara masuk EDL (pilih salah satu)

**Via ADB** (HP target masih bisa booting):
```bash
adb reboot edl
```

**Via Fastboot** (BL sudah unlock):
```bash
fastboot oem edl
```

**Via hardware** (test point — terakhir):
- Short test point sesuai skematik device

#### Cara flash

```
./flash.sh → Menu 2 → Opsi 1 (EMMC) atau 2 (UFS)
```

1. Masukkan path firehose `.mbn`
2. Masukkan path `rawprogram0.xml`
3. Masukkan path `patch0.xml`
4. Masukkan path folder firmware (untuk `--include`)
5. Hubungkan HP target ke EDL mode via OTG
6. Tekan Enter

**Perintah manual (jika ingin langsung):**
```bash
sudo ./bin/arm64/qdl --debug --storage emmc \
  --include /sdcard/qdl-flash \
  prog_firehose.mbn rawprogram0.xml patch0.xml
```

---

### 3. Fastboot Flash

#### Flash Recovery

```
./flash.sh → Menu 3 → Opsi 3
```

Masukkan path `recovery.img` → otomatis tawari flash `vbmeta.img` setelahnya.

#### Flash Boot (Magisk patch)

```
./flash.sh → Menu 3 → Opsi 4
```

Masukkan path `boot.img` yang sudah di-patch Magisk.

#### ADB Sideload

```
./flash.sh → Menu 3 → Opsi 13
```

Device harus dalam Recovery mode dengan sideload aktif.

---

### 4. GSI ROM Flash

Urutan yang benar untuk flash GSI:

```
Menu 4 → ikuti urutan:
1. Flash vbmeta (--disable-verity)
2. Reboot → FastbootD
3. Cek is-userspace = yes
4. Erase system
5. Delete logical partition product_a & product_b
6. Flash GSI system image
7. Reboot → Recovery → Format data
8. Reboot system
```

---

### 5. A/B Partition Tool

Untuk device dengan A/B slot (kebanyakan device Android 10+):

- Flash ke slot spesifik: `boot_a`, `boot_b`, `recovery_a`, dst
- Set active slot: `--set-active=a` atau `b`
- Boot TWRP tanpa flash: `fastboot boot twrp.img`

---

### 6. FRP Remove

| Metode | Target Device |
|---|---|
| SPRD via Fastboot | `fastboot erase persist` |
| Samsung via ADB | Intent + `user_setup_complete=1` |
| SPRD/MTK via ADB | `user_setup_complete=1` |

---

### 7. USB / OTG Fix

Jika device tidak terdeteksi:

```
Menu 7 → Opsi 9 (Auto-detect & connect device)
```

Langkah manual:
```bash
# Restart ADB server
adb kill-server
adb start-server

# Cek USB
termux-usb -l

# Cek ADB
adb devices

# Cek Fastboot
fastboot devices
```

---

### 8. Bypass UBL Redmi 4A (rolex)

> ⚠️ **KHUSUS** untuk Redmi 4A (codename: **rolex**) dengan MIUI **V10.2.3.0.NCCMIXM** (Global, build 20190605)

#### Mengapa hanya MIUI 10.2.3.0?

File `devinfo` dan `emmc_appsboot.mbn` dibuat khusus untuk struktur partisi MIUI 10.2.3.0. Versi MIUI lain memiliki layout partisi yang berbeda — menggunakan tool ini pada versi lain **akan menyebabkan BRICK**.

#### Partisi yang di-flash (dari rawprogram0.xml ROM asli)

| Partisi | Start Sector | Hex Address | Size |
|---|---|---|---|
| `aboot` | 786432 | `0x18000000` | 2048 sectors (1MB) |
| `abootbak` | 788480 | `0x18100000` | 2048 sectors (1MB) |
| `devinfo` | 1052672 | `0x20200000` | 2048 sectors (1MB) |

#### Cara pakai

**Step 1 — Cek versi MIUI**
```
Settings → About Phone → MIUI Version
Harus: V10.2.3.0.NCCMIXM
```

**Step 2 — Masuk EDL**
```bash
# Dari ADB:
adb reboot edl

# Atau hardware:
# Bongkar HP → Cari titik tespoint & hubungkan kedua titik menggunakan pinset →Colokkan kabel
```

**Step 3 — Flash**
```
./flash.sh → Menu 9 → Opsi 1 → Ikuti instruksi
```

Script akan:
1. Generate `rawprogram_ubl.xml` secara otomatis dengan sector address yang tepat
2. Flash `aboot` → `abootbak` → `devinfo` via QDL

**Step 4 — Setelah berhasil**
```
1. Reboot device
2. Masuk Fastboot
3. fastboot oem device-info
```

---

## 🔧 Troubleshooting

### termux-usb tidak mendeteksi device

- Pastikan APK Termux:API terinstall (bukan hanya pkg)
- Coba cabut-colokan kabel OTG
- Reinstall: `Menu 1 → Opsi 2`
- Pastikan kabel OTG support USB Host

### QDL gagal / device not found

- Pastikan HP target benar-benar di EDL mode (LED merah/tidak ada tampilan)
- Coba `Menu 2 → Opsi 6` (reboot via ADB ke EDL) terlebih dahulu
- Cek `termux-usb -l` apakah device terdeteksi
- Pastikan `sudo` berfungsi: `sudo id` harus output `uid=0(root)`

### ADB device not found

- Aktifkan USB Debugging di HP target
- Tap "Allow" saat muncul popup USB Debugging
- Restart ADB server: `Menu 7 → Opsi 4 → 5`

### Fastboot device not found

- Pastikan HP target di Fastboot mode (layar fastboot)
- Coba reinstall ADB/Fastboot: `Menu 1 → Opsi 3`

### sudo: command not found

```bash
pkg install sudo
su -c "echo 'ALL ALL=(ALL) NOPASSWD:ALL' > $PREFIX/etc/sudoers.d/termux"
```

### QDL binary permission denied

```bash
chmod +x bin/arm64/qdl   # sesuaikan arch
sudo bin/arm64/qdl --help  # test
```

### Termux: permission denied untuk /dev/bus/usb

```bash
# Grant akses USB manual
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
  ├── firehose.mbn  → upload ke device sebagai programmer
  ├── rawprogram.xml → instruksi tulis setiap partisi
  └── patch.xml     → patch CRC/checksum setelah write
```

Firehose loader diupload ke device via USB, kemudian loader tersebut menerima instruksi dari host untuk menulis file ke setiap partisi sesuai rawprogram.xml.

---

## 📱 Kompatibilitas

| Fitur | Chipset | Syarat |
|---|---|---|
| QDL Flash | Qualcomm semua | Firehose loader + EDL mode |
| Fastboot Flash | Semua | BL unlock |
| GSI Flash | Semua (Dynamic Partition) | BL unlock + FastbootD |
| A/B Partition | Semua A/B device | BL unlock |
| FRP Remove | SPRD / Samsung / MTK | ADB / Fastboot |
| Bypass UBL | Redmi 4A (rolex) ONLY | MIUI 10.2.3.0 ONLY |

---

## 📂 Source & Kredit

| Tool | Source |
|---|---|
| QDL binary | [Ishu43642/Termux-QDL](https://github.com/Ishu43642/Termux-QDL) |
| QDL-Flasher | QDL-Flasher (multi-arch binary) |
| ADBiFY-QDL | ADBiFY-QDL |
| Termux-Root-Recovery-Tool | TRRT |
| Bypass UBL Redmi 4A | **Rahmat Sobrian** (original `.bat`) |
| Port Bash + integrasi | **Siroha** (github.com/rahmatsobrian) |

---

## 👤 Author

```
Siroha — RahmatSobrian
GitHub   : github.com/rahmatsobrian
Telegram : t.me/rahmatsobrian
YouTube  : @siroha3352
Lokasi   : Jawa Tengah, Indonesia
```

---

## ⚠️ Disclaimer

Tool ini dibuat untuk tujuan edukasi dan keperluan pribadi. Segala risiko yang timbul akibat penggunaan tool ini — termasuk brick, kehilangan data, atau kerusakan perangkat — menjadi tanggung jawab pengguna sepenuhnya. Selalu backup data sebelum melakukan flashing apapun.

---

<div align="center">

**⚡ Siroha Flash Tool** — Made with ❤️ by [Siroha](https://github.com/rahmatsobrian)

</div>
