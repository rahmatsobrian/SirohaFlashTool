#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
#   SIROHA FLASH TOOL - All-in-One Qualcomm Flash Tool
#   Gabungan: Termux-QDL + QDL-Flasher + ADBiFY-QDL + TRRT
#   By: Siroha | github.com/rahmatsobrian
# ═══════════════════════════════════════════════════════════════

trap "echo -e '\033[0;31m\n[!] Script dihentikan.\033[0m'; exit 1" INT

# ─── COLORS ────────────────────────────────────────────────────
R='\033[0;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
B='\033[1;34m'
M='\033[1;35m'
W='\033[1;97m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── HELPER FUNCTIONS ──────────────────────────────────────────
die()   { echo -e "${R}[✗] $*${RESET}"; }
ok()    { echo -e "${G}[✓] $*${RESET}"; }
info()  { echo -e "${C}[►] $*${RESET}"; }
warn()  { echo -e "${Y}[!] $*${RESET}"; }
title() { echo -e "${C}╭──────────────────────────────────────────────╮"; \
          echo -e "│${W}  $*${C}"; \
          echo -e "╰──────────────────────────────────────────────╯${RESET}"; }

open_url() {
  local url="$1"
  if command -v termux-open-url &>/dev/null; then
    termux-open-url "$url"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$url"
  else
    am start -a android.intent.action.VIEW -d "$url" &>/dev/null
  fi
}

press_enter() { read -p $'\033[1;36m  Tekan Enter untuk lanjut...\033[0m'; }

ask_file() {
  local prompt="$1" var_name="$2"
  while true; do
    echo -ne "${W}  $prompt: ${RESET}"
    read -e input
    if [ -f "$input" ]; then
      eval "$var_name='$input'"
      return 0
    else
      die "File tidak ditemukan: $input"
      warn "Pastikan path file benar lalu coba lagi."
      echo -ne "${Y}  Coba lagi? (y/n): ${RESET}"
      read yn
      [[ "$yn" != "y" && "$yn" != "Y" ]] && return 1
    fi
  done
}

ask_yn() {
  local prompt="$1"
  echo -ne "${Y}  $prompt (y/n): ${RESET}"
  read yn
  [[ "$yn" == "y" || "$yn" == "Y" ]]
}

# ─── DETECT ARCH ───────────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
  aarch64)   ARCH_DIR="arm64"  ;;
  armv7l)    ARCH_DIR="arm"    ;;
  x86_64)    ARCH_DIR="x86_64" ;;
  i686|i386) ARCH_DIR="x86"    ;;
  *)         ARCH_DIR="arm64"  ;;
esac

# ─── QDL BINARY PATH ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QDL_BIN="$SCRIPT_DIR/bin/$ARCH_DIR/qdl"
if [ ! -f "$QDL_BIN" ]; then
  QDL_BIN="$SCRIPT_DIR/qdl"
fi

# ─── SPLASH SCREEN ─────────────────────────────────────────────
splash_screen() {
  clear
  echo -e "${C}"
  echo "  ╔═══════════════════════════════════════════════════╗"
  echo "  ║                                                   ║"
  echo "  ║   ███████╗██╗      █████╗ ███████╗██╗  ██╗        ║"
  echo "  ║   ██╔════╝██║     ██╔══██╗██╔════╝██║  ██║        ║"
  echo "  ║   █████╗  ██║     ███████║███████╗███████║        ║"
  echo "  ║   ██╔══╝  ██║     ██╔══██║╚════██║██╔══██║        ║"
  echo "  ║   ██║     ███████╗██║  ██║███████║██║  ██║        ║"
  echo "  ║   ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝        ║"
  echo -e "  ║${Y}          T O O L   by  S I R O H A                ${C}║"
  echo "  ╚═══════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "${DIM}  Gabungan: Termux-QDL | QDL-Flasher | ADBiFY-QDL | TRRT${RESET}"
  echo ""

  # Loading bar
  for i in 5 15 30 50 70 85 100; do
    bars=$((i/5))
    printf "  ${C}["
    for ((j=0;j<bars;j++)); do printf "█"; done
    for ((j=bars;j<20;j++)); do printf "░"; done
    printf "${C}] ${Y}${i}%%${RESET}\r"
    sleep 0.08
  done
  echo ""
  echo ""
  echo -e "  ${G}Arsitektur terdeteksi: ${W}$ARCH_DIR${RESET}"
  echo -e "  ${G}QDL binary: ${W}$QDL_BIN${RESET}"
  sleep 1
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 1: INSTALASI & CEK REQUIREMENTS
# ═══════════════════════════════════════════════════════════════
# ═══════════════════════════════════════════════════════════════
#   MODUL 1: INSTALASI & CEK REQUIREMENTS
# ═══════════════════════════════════════════════════════════════
menu_install() {
  while true; do
    clear
    title "📦 INSTALASI & CEK REQUIREMENTS"
    echo ""
    echo -e "${B}  ┌───────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  💡 Install semua paket (ADB/Fastboot/API) ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  🔄 Reinstall Termux-API (pkg)             ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  🔄 Reinstall ADB & Fastboot               ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  ⬇️  Install android-tools                  ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  🔍 Cek semua requirements                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${Y}  📱 Panduan: Install Termux & Termux:API   ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${Y}  🔑 Panduan: Root & Izin Root Termux       ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali ke Menu Utama                   ${B}│${RESET}"
    echo -e "${B}  └───────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        title "Install semua paket"
        echo ""
        # Cek root dulu
        if ! su -c "echo root_ok" &>/dev/null 2>&1; then
          die "HP host belum ROOT atau Termux belum diberi izin root!"
          warn "Beberapa fitur (QDL, USB access) butuh root."
          warn "Lihat panduan: opsi 7"
          echo ""
        else
          ok "Root terdeteksi!"
        fi
        info "Update & upgrade Termux..."
        pkg update -y && pkg upgrade -y
        info "Install termux-api (pkg)..."
        pkg install -y termux-api
        info "Install git, libxml2, sudo, curl..."
        pkg install -y git libxml2 sudo curl
        info "Install ADB/Fastboot (termux-adb)..."
        pkg remove -y termux-adb 2>/dev/null
        curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
        ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot" 2>/dev/null
        ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb" 2>/dev/null
        echo ""
        ok "Semua paket berhasil diinstall!"
        echo ""
        warn "PENTING: Pastikan aplikasi Termux:API juga sudah terinstall!"
        warn "Bukan hanya pkg termux-api, tapi APK-nya juga!"
        warn "Lihat panduan: opsi 6"
        press_enter
        ;;

      2)
        title "Reinstall Termux-API (pkg)"
        echo ""
        warn "Ini hanya reinstall paket pkg termux-api di dalam Termux."
        warn "Aplikasi Termux:API (APK) harus diinstall terpisah dari F-Droid!"
        echo ""
        yes | pkg remove termux-api 2>/dev/null
        pkg install -y termux-api
        ok "Termux-API pkg berhasil diinstall ulang!"
        press_enter
        ;;

      3)
        title "Reinstall ADB & Fastboot"
        warn "Menghapus termux-adb..."
        yes | pkg remove termux-adb 2>/dev/null
        info "Install ulang dari nohajc/termux-adb..."
        curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
        ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot" 2>/dev/null
        ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb" 2>/dev/null
        ok "ADB & Fastboot berhasil diinstall ulang!"
        press_enter
        ;;

      4)
        title "Install android-tools"
        info "Install android-tools untuk flash fastboot ROM..."
        yes | pkg install android-tools
        ok "android-tools terinstall!"
        press_enter
        ;;

      5)
        title "Cek Requirements"
        echo ""

        # ── Cek ROOT ──────────────────────────────────────────
        echo -e "${Y}  [ ROOT & IZIN ]${RESET}"
        if su -c "echo ok" &>/dev/null 2>&1; then
          ok "Root (su)          : TERDETEKSI"
          # Cek apakah root bisa dipakai dari Termux
          ROOT_ID=$(su -c "id" 2>/dev/null | grep -o "uid=0")
          if [ -n "$ROOT_ID" ]; then
            ok "Izin root Termux   : SUDAH DIIZINKAN"
          else
            die "Izin root Termux   : BELUM DIIZINKAN → lihat panduan opsi 7"
          fi
        else
          die "Root               : TIDAK ADA / BELUM DIIZINKAN"
          warn "  → HP host wajib root! Lihat panduan: opsi 7"
        fi
        # Cek sudo
        if command -v sudo &>/dev/null; then
          ok "sudo               : TERINSTALL"
          # Cek sudo bisa jalan sebagai root
          if sudo id 2>/dev/null | grep -q "uid=0"; then
            ok "sudo as root       : OK"
          else
            warn "sudo as root       : PERLU KONFIGURASI"
          fi
        else
          die "sudo               : TIDAK ADA  → jalankan opsi 1"
        fi

        echo ""
        # ── Cek TERMUX-API ────────────────────────────────────
        echo -e "${Y}  [ TERMUX-API ]${RESET}"
        if command -v termux-usb &>/dev/null; then
          ok "termux-api (pkg)   : TERINSTALL"
        else
          die "termux-api (pkg)   : TIDAK ADA  → jalankan opsi 1"
        fi
        # Cek APK Termux:API terinstall di system
        if pm list packages 2>/dev/null | grep -q "com.termux.api"; then
          ok "Termux:API (APK)   : TERINSTALL"
        elif su -c "pm list packages" 2>/dev/null | grep -q "com.termux.api"; then
          ok "Termux:API (APK)   : TERINSTALL"
        else
          die "Termux:API (APK)   : TIDAK ADA  → install dari F-Droid! (opsi 6)"
        fi

        echo ""
        # ── Cek ADB/FASTBOOT ──────────────────────────────────
        echo -e "${Y}  [ ADB & FASTBOOT ]${RESET}"
        if command -v termux-adb &>/dev/null || command -v adb &>/dev/null; then
          ok "ADB                : TERINSTALL"
        else
          die "ADB                : TIDAK ADA  → jalankan opsi 1"
        fi
        if command -v termux-fastboot &>/dev/null || command -v fastboot &>/dev/null; then
          ok "Fastboot           : TERINSTALL"
        else
          die "Fastboot           : TIDAK ADA  → jalankan opsi 1"
        fi

        echo ""
        # ── Cek QDL ───────────────────────────────────────────
        echo -e "${Y}  [ QDL BINARY ]${RESET}"
        if [ -f "$QDL_BIN" ]; then
          ok "QDL binary         : ADA ($QDL_BIN)"
          # Cek executable
          if [ -x "$QDL_BIN" ]; then
            ok "QDL executable     : OK"
          else
            warn "QDL executable     : TIDAK ada +x → jalankan: chmod +x $QDL_BIN"
          fi
        else
          die "QDL binary         : TIDAK ADA"
          warn "  → Letakkan file 'qdl' di folder bin/$ARCH_DIR/"
        fi

        echo ""
        # ── Cek USB OTG ───────────────────────────────────────
        echo -e "${Y}  [ USB OTG ]${RESET}"
        USB_DEV=$(termux-usb -l 2>/dev/null | grep -oE '/dev/bus/usb/[0-9]+/[0-9]+')
        if [ -n "$USB_DEV" ]; then
          ok "USB OTG            : TERDETEKSI ($USB_DEV)"
        else
          warn "USB OTG            : Tidak ada perangkat terhubung"
        fi

        echo ""
        press_enter
        ;;

      6)
        clear
        title "📱 PANDUAN INSTALL TERMUX & TERMUX:API"
        echo ""
        echo -e "${R}  ╔══════════════════════════════════════════════════╗"
        echo -e "  ║  [!] JANGAN install dari Google Play Store!      ║"
        echo -e "  ║  Versi Play Store = TIDAK KOMPATIBEL!            ║"
        echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${Y}  ADA 2 KOMPONEN YANG HARUS DIINSTALL:${RESET}"
        echo ""
        echo -e "${W}  [A] Termux (APK) — dari F-Droid${RESET}"
        echo -e "  ${DIM}• Buka: https://f-droid.org"
        echo -e "  • Cari: Termux"
        echo -e "  • Install Termux versi F-Droid (bukan Play Store!)${RESET}"
        echo ""
        echo -e "${W}  [B] Termux:API (APK) — dari F-Droid${RESET}"
        echo -e "  ${DIM}• Di F-Droid cari: Termux:API"
        echo -e "  • Install aplikasi Termux:API"
        echo -e "  • Ini WAJIB agar termux-usb bisa detect USB OTG!${RESET}"
        echo ""
        echo -e "${W}  [C] termux-api (pkg) — di dalam Termux${RESET}"
        echo -e "  ${DIM}• Setelah APK Termux:API terinstall, buka Termux"
        echo -e "  • Jalankan: pkg install termux-api"
        echo -e "  • Ini adalah bridge antara Termux dan APK Termux:API${RESET}"
        echo ""
        echo -e "${Y}  KENAPA HARUS F-DROID?${RESET}"
        echo -e "  ${DIM}• Play Store = signature berbeda = APK tidak bisa"
        echo -e "    saling komunikasi dengan Termux dari F-Droid"
        echo -e "  • Akan muncul error 'signature mismatch'${RESET}"
        echo ""
        echo -e "${Y}  LINK DOWNLOAD F-DROID:${RESET}"
        echo -e "  ${C}  https://f-droid.org/F-Droid.apk${RESET}"
        echo ""
        ask_yn "Buka link F-Droid di browser?" && open_url "https://f-droid.org/F-Droid.apk"
        press_enter
        ;;

      7)
        clear
        title "🔑 PANDUAN ROOT & IZIN ROOT TERMUX"
        echo ""
        echo -e "${R}  ╔══════════════════════════════════════════════════╗"
        echo -e "  ║  [!] HP HOST WAJIB SUDAH ROOT!                   ║"
        echo -e "  ║  Tool ini tidak bisa jalan tanpa root!           ║"
        echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${Y}  KENAPA BUTUH ROOT?${RESET}"
        echo -e "  ${DIM}• Akses USB device langsung (/dev/bus/usb)"
        echo -e "  • Jalankan qdl binary dengan sudo"
        echo -e "  • termux-usb butuh izin system-level${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 1 — Pastikan HP sudah root:${RESET}"
        echo -e "  ${DIM}• Cek lewat aplikasi: Magisk / KernelSU / APatch"
        echo -e "  • Kalau belum root, proses flashing tidak bisa dilakukan${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 2 — Izinkan ROOT untuk Termux:${RESET}"
        echo -e "  ${W}  Via Magisk:${RESET}"
        echo -e "  ${DIM}1. Buka aplikasi Magisk"
        echo -e "  2. Tap Superuser (tab bawah)"
        echo -e "  3. Cari Termux dalam daftar"
        echo -e "  4. Pastikan toggle = ON (diizinkan)${RESET}"
        echo ""
        echo -e "  ${W}  Via KernelSU:${RESET}"
        echo -e "  ${DIM}1. Buka aplikasi KernelSU"
        echo -e "  2. Tap SuperUser"
        echo -e "  3. Cari Termux, pastikan status = Granted${RESET}"
        echo ""
        echo -e "  ${W}  Via APatch:${RESET}"
        echo -e "  ${DIM}1. Buka aplikasi APatch"
        echo -e "  2. Tap SuperUser"
        echo -e "  3. Grant akses untuk Termux${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 3 — Aktifkan di Termux:${RESET}"
        echo -e "  ${DIM}Setelah izin diberikan, jalankan di Termux:"
        echo -e "  ${C}  su${RESET}"
        echo -e "  ${DIM}Akan muncul popup dari Magisk/KSU/APatch."
        echo -e "  Tap 'Grant' / 'Izinkan'.${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 4 — Setup sudo di Termux:${RESET}"
        echo -e "  ${DIM}pkg install sudo"
        echo -e "  Buat file sudoers:"
        echo -e "  ${C}  su -c \"echo 'ALL ALL=(ALL) NOPASSWD:ALL' > \$PREFIX/etc/sudoers.d/termux\"${RESET}"
        echo ""
        echo -e "${Y}  VERIFIKASI:${RESET}"
        echo -e "  ${DIM}sudo id"
        echo -e "  Output harus: uid=0(root)${RESET}"
        echo ""
        # Cek status root sekarang
        echo -e "${Y}  STATUS ROOT SEKARANG:${RESET}"
        if su -c "id" 2>/dev/null | grep -q "uid=0"; then
          ok "Root sudah aktif & Termux sudah diberi izin!"
        else
          die "Root belum aktif atau Termux belum diberi izin!"
          warn "Ikuti langkah di atas lalu coba lagi."
        fi
        echo ""
        press_enter
        ;;

      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 2: QDL FLASH (EDL 9008 MODE)
# ═══════════════════════════════════════════════════════════════
menu_qdl() {
  while true; do
    clear
    title "⚡ QDL FLASH — Qualcomm EDL 9008 Mode"
    echo ""
    echo -e "${DIM}  Gunakan kabel USB OTG untuk menghubungkan HP target (EDL mode)${RESET}"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  📀 Flash EMMC Storage                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  💿 Flash UFS Storage                     ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  🔍 Cek device EDL (9008)                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  🔍 Cek device ADB                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  🔃 Reboot Fastboot → EDL                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  🔃 Reboot ADB → EDL                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  📝 Command manual QDL                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${Y}  📖 Panduan cara pakai QDL                ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1|2)
        [ "$choice" = "1" ] && storage="emmc" || storage="ufs"
        title "Flash $storage"
        echo ""
        if [ ! -f "$QDL_BIN" ]; then
          die "QDL binary tidak ditemukan di: $QDL_BIN"
          die "Letakkan file 'qdl' di folder bin/$ARCH_DIR/ lalu coba lagi."
          press_enter; continue
        fi
        info "Masukkan path file firmware:"
        echo ""
        ask_file "Path firehose (.mbn)" firehose || { press_enter; continue; }
        ask_file "Path rawprogram (.xml)" rawprogram || { press_enter; continue; }
        ask_file "Path patch (.xml)" patchxml || { press_enter; continue; }
        echo ""
        info "Masukkan path folder firmware (untuk --include):"
        echo -ne "${W}  Path folder firmware: ${RESET}"
        read -e fw_folder
        [ -z "$fw_folder" ] && fw_folder="/storage/emulated/0/qdl-flash"
        echo ""
        warn "Hubungkan HP target ke EDL mode via OTG SEKARANG, lalu tekan Enter..."
        press_enter
        info "Menjalankan QDL flash ($storage)..."
        echo ""
        sudo "$QDL_BIN" --debug --storage "$storage" --include "$fw_folder" \
          "$firehose" "$rawprogram" "$patchxml"
        if [ $? -eq 0 ]; then
          ok "Flash berhasil selesai!"
        else
          die "Flash gagal! Cek log di atas."
        fi
        press_enter
        ;;
      3)
        title "Cek EDL Device (9008)"
        info "Mencari USB device..."
        termux-usb -l
        press_enter
        ;;
      4)
        title "Cek ADB Device"
        info "Mencari ADB device..."
        termux-adb devices 2>/dev/null || adb devices
        press_enter
        ;;
      5)
        title "Reboot Fastboot → EDL"
        warn "Pastikan device sudah di Fastboot mode!"
        info "Mengirim perintah reboot ke EDL..."
        termux-fastboot oem edl 2>/dev/null || fastboot oem edl
        ok "Perintah terkirim!"
        press_enter
        ;;
      6)
        title "Reboot ADB → EDL"
        info "Mengirim perintah reboot ke EDL via ADB..."
        termux-adb reboot edl 2>/dev/null || adb reboot edl
        ok "Perintah terkirim!"
        press_enter
        ;;
      7)
        title "Command Manual QDL"
        echo -e "${DIM}  Contoh: --debug --storage emmc --include /sdcard/rom file.mbn raw.xml patch.xml${RESET}"
        echo ""
        echo -ne "${W}  Argumen QDL: ${RESET}"
        read -e manual_args
        echo ""
        warn "Hubungkan HP target ke EDL mode, lalu tekan Enter..."
        press_enter
        eval "sudo \"$QDL_BIN\" $manual_args"
        press_enter
        ;;
      8)
        clear
        title "📖  PANDUAN QDL FLASH"
        echo ""
        echo -e "${Y}  ╔══════════════════════════════════════════════╗"
        echo -e "  ║           CARA PAKAI QDL FLASH               ║"
        echo -e "  ╚══════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${W}  SYARAT:${RESET}"
        echo -e "  ${G}✓${RESET} HP host (yang menjalankan tool): rooted, arm64, Termux"
        echo -e "  ${G}✓${RESET} HP target (yang di-flash): Qualcomm, sudah EDL mode"
        echo -e "  ${G}✓${RESET} Kabel USB OTG (HP host ← → HP target)"
        echo -e "  ${G}✓${RESET} File firmware: firehose .mbn + rawprogram.xml + patch.xml"
        echo ""
        echo -e "${W}  CARA MASUK EDL TANPA TEST POINT:${RESET}"
        echo -e "  ${C}1.${RESET} Via ADB (HP target masih bisa booting):"
        echo -e "     ${DIM}adb reboot edl${RESET}"
        echo -e "  ${C}2.${RESET} Via Fastboot (BL sudah unlock):"
        echo -e "     ${DIM}fastboot oem edl${RESET}"
        echo -e "  ${C}3.${RESET} Test point (hardware - terakhir)"
        echo ""
        echo -e "${W}  STRUKTUR FOLDER FIRMWARE:${RESET}"
        echo -e "  ${DIM}/storage/emulated/0/qdl-flash/"
        echo -e "  ├── prog_firehose_ddr_XXX.mbn   ← loader"
        echo -e "  ├── rawprogram0.xml              ← partition map"
        echo -e "  └── patch0.xml                  ← patch${RESET}"
        echo ""
        echo -e "${W}  PERINTAH LENGKAP (manual):${RESET}"
        echo -e "  ${DIM}sudo ./qdl --debug --storage emmc \\"
        echo -e "    --include /sdcard/qdl-flash \\"
        echo -e "    prog_firehose.mbn rawprogram0.xml patch0.xml${RESET}"
        echo ""
        press_enter
        ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 3: FASTBOOT FLASH TOOL
# ═══════════════════════════════════════════════════════════════
flash_partition() {
  local part="$1" label="$2" extra_args="${3:-}"
  title "Flash $label"
  ask_file "Path file $label" romfile || return
  info "Flashing $label..."
  eval "termux-fastboot $extra_args flash $part \"$romfile\""
  [ $? -eq 0 ] && ok "Flash $label berhasil!" || die "Flash $label gagal!"
  # Tawaran flash vbmeta
  if ask_yn "Flash vbmeta.img juga?"; then
    ask_file "Path vbmeta.img" vbfile || return
    termux-fastboot --disable-verity --disable-verification flash vbmeta "$vbfile"
    [ $? -eq 0 ] && ok "Flash vbmeta berhasil!" || die "Flash vbmeta gagal!"
  fi
  press_enter
}

menu_fastboot() {
  while true; do
    clear
    title "🔧 FASTBOOT FLASH TOOL"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}──${Y}  🔌 CEK DEVICE${B}                            │${RESET}"
    echo -e "${B}  │ ${W}1.${G}  Cek Fastboot device                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  Cek ADB device                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}──${Y}  ⚡ FLASH PARTITION${B}                       │${RESET}"
    echo -e "${B}  │ ${W}3.${G}  Flash Recovery                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  Flash Boot                               ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  Flash init_boot                          ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  Flash vendor_boot                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  Flash vbmeta (disable-verity)            ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${G}  Flash super_empty (wipe-super)           ${B}│${RESET}"
    echo -e "${B}  │ ${W}──${Y}  🔃 REBOOT${B}                                │${RESET}"
    echo -e "${B}  │ ${W}9.${G}  Reboot → Fastboot                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}10.${G} Reboot → Recovery                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}11.${G} Reboot → System                          ${B}│${RESET}"
    echo -e "${B}  │ ${W}12.${G} Reboot → FastbootD                       ${B}│${RESET}"
    echo -e "${B}  │ ${W}──${Y}  📁 LAINNYA${B}                               │${RESET}"
    echo -e "${B}  │ ${W}13.${G} ADB Sideload (flash ZIP)                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}14.${G} Manual command fastboot                  ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1) title "Cek Fastboot Device" ; termux-fastboot devices ; press_enter ;;
      2) title "Cek ADB Device" ; termux-adb devices 2>/dev/null || adb devices ; press_enter ;;
      3)  flash_partition "recovery"    "Recovery"    "" ;;
      4)  flash_partition "boot"        "Boot"        "" ;;
      5)  flash_partition "init_boot"   "init_boot"   "" ;;
      6)  flash_partition "vendor_boot" "vendor_boot" "" ;;
      7)
        title "Flash VBMETA"
        ask_file "Path vbmeta.img" vbfile || { press_enter; continue; }
        termux-fastboot --disable-verity --disable-verification flash vbmeta "$vbfile"
        [ $? -eq 0 ] && ok "Flash vbmeta berhasil!" || die "Gagal!"
        press_enter
        ;;
      8)
        title "Flash super_empty (Wipe Super)"
        ask_file "Path super_empty.img" sfile || { press_enter; continue; }
        termux-fastboot wipe-super "$sfile"
        [ $? -eq 0 ] && ok "Wipe super berhasil!" || die "Gagal!"
        press_enter
        ;;
      9)
        title "Reboot → Fastboot"
        termux-adb reboot bootloader 2>/dev/null || adb reboot bootloader
        ok "Perintah reboot terkirim!" ; press_enter
        ;;
      10)
        title "Reboot → Recovery"
        termux-adb reboot recovery 2>/dev/null || adb reboot recovery
        ok "Perintah reboot terkirim!" ; press_enter
        ;;
      11)
        title "Reboot → System"
        termux-fastboot reboot 2>/dev/null || fastboot reboot
        ok "Perintah reboot terkirim!" ; press_enter
        ;;
      12)
        title "Reboot → FastbootD"
        termux-fastboot reboot fastboot
        ok "Perintah reboot terkirim!" ; press_enter
        ;;
      13)
        title "ADB Sideload"
        ask_file "Path file ZIP" zipfile || { press_enter; continue; }
        info "Menjalankan sideload..."
        termux-adb sideload "$zipfile" 2>/dev/null || adb sideload "$zipfile"
        [ $? -eq 0 ] && ok "Sideload berhasil!" || die "Gagal!"
        press_enter
        ;;
      14)
        title "Manual Fastboot Command"
        echo -ne "${W}  Command (tanpa 'fastboot'): ${RESET}"
        read -e mcmd
        eval "termux-fastboot $mcmd"
        press_enter
        ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 4: GSI FLASH TOOL
# ═══════════════════════════════════════════════════════════════
menu_gsi() {
  while true; do
    clear
    title "🔮 GSI ROM FLASH TOOL (Dynamic Partition)"
    echo ""
    echo -e "${DIM}  Urutan: Fastboot → FastbootD → Erase System → Flash GSI${RESET}"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  Cek Fastboot device                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  Flash VBMETA (disable-verity)            ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  Reboot Fastboot → FastbootD              ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  Cek userspace (is-userspace)             ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  Erase system partition                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  Delete logical partition product_a       ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  Delete logical partition product_b       ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${G}  Flash GSI system image                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}9.${G}  Reboot → Recovery                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}10.${Y} Reset device (BUKAN untuk Xiaomi!)       ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        title "Cek Fastboot Device"
        termux-fastboot devices ; press_enter ;;
      2)
        title "Flash VBMETA"
        ask_file "Path vbmeta.img" vbf || { press_enter; continue; }
        termux-fastboot --disable-verity --disable-verification flash vbmeta "$vbf"
        [ $? -eq 0 ] && ok "Berhasil!" || die "Gagal!" ; press_enter ;;
      3)
        title "Reboot → FastbootD"
        termux-fastboot reboot fastboot
        ok "Perintah terkirim!" ; press_enter ;;
      4)
        title "Cek is-userspace"
        termux-fastboot getvar is-userspace ; press_enter ;;
      5)
        title "Erase System"
        warn "PERINGATAN: Ini akan menghapus system partition!"
        ask_yn "Lanjutkan?" && termux-fastboot erase system
        [ $? -eq 0 ] && ok "Erase berhasil!" || die "Gagal!"
        press_enter ;;
      6)
        title "Delete product_a"
        termux-fastboot delete-logical-partition product_a
        [ $? -eq 0 ] && ok "Berhasil!" || die "Gagal!" ; press_enter ;;
      7)
        title "Delete product_b"
        termux-fastboot delete-logical-partition product_b
        [ $? -eq 0 ] && ok "Berhasil!" || die "Gagal!" ; press_enter ;;
      8)
        title "Flash GSI System Image"
        ask_file "Path GSI .img" gsifile || { press_enter; continue; }
        info "Flashing GSI..."
        termux-fastboot flash system "$gsifile"
        [ $? -eq 0 ] && ok "Flash GSI berhasil!" || die "Gagal!" ; press_enter ;;
      9)
        title "Reboot → Recovery"
        termux-fastboot reboot recovery
        ok "Perintah terkirim!" ; press_enter ;;
      10)
        title "Reset Device"
        die "PERINGATAN: Jangan gunakan untuk Xiaomi!"
        ask_yn "Tetap lanjutkan?" && {
          termux-fastboot -w
          [ $? -eq 0 ] && ok "Reset berhasil!" || die "Gagal!"
        }
        press_enter ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 5: A/B PARTITION TOOL
# ═══════════════════════════════════════════════════════════════
menu_ab() {
  while true; do
    clear
    title "🆎 A/B PARTITION TOOL"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  Flash boot (auto slot aktif)             ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  Flash boot_a                             ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  Flash boot_b                             ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  Flash init_boot_a                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  Flash init_boot_b                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  Flash recovery (auto)                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  Flash recovery_a                         ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${G}  Flash recovery_b                         ${B}│${RESET}"
    echo -e "${B}  │ ${W}9.${G}  Flash vendor_boot_a                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}10.${G} Flash vendor_boot_b                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}11.${G} Flash vbmeta_a                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}12.${G} Flash vbmeta_b                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}13.${G} Cek slot aktif                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}14.${G} Set active slot_a                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}15.${G} Set active slot_b                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}16.${G} Boot TWRP (tanpa flash)                  ${B}│${RESET}"
    echo -e "${B}  │ ${W}17.${G} ADB Sideload ZIP                         ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)  flash_partition "boot"         "boot"         "" ;;
      2)  flash_partition "boot_a"       "boot_a"       "" ;;
      3)  flash_partition "boot_b"       "boot_b"       "" ;;
      4)  flash_partition "init_boot_a"  "init_boot_a"  "" ;;
      5)  flash_partition "init_boot_b"  "init_boot_b"  "" ;;
      6)  flash_partition "recovery"     "recovery"     "" ;;
      7)  flash_partition "recovery_a"   "recovery_a"   "" ;;
      8)  flash_partition "recovery_b"   "recovery_b"   "" ;;
      9)  flash_partition "vendor_boot_a" "vendor_boot_a" "" ;;
      10) flash_partition "vendor_boot_b" "vendor_boot_b" "" ;;
      11)
        title "Flash vbmeta_a"
        ask_file "Path vbmeta.img" vbf || { press_enter; continue; }
        termux-fastboot --disable-verity --disable-verification flash vbmeta_a "$vbf"
        ask_yn "Flash vbmeta_b juga?" && {
          ask_file "Path vbmeta_b.img" vbf2 && \
          termux-fastboot --disable-verity --disable-verification flash vbmeta_b "$vbf2"
        }
        [ $? -eq 0 ] && ok "Berhasil!" || die "Gagal!" ; press_enter ;;
      12)
        title "Flash vbmeta_b"
        ask_file "Path vbmeta.img" vbf || { press_enter; continue; }
        termux-fastboot --disable-verity --disable-verification flash vbmeta_b "$vbf"
        [ $? -eq 0 ] && ok "Berhasil!" || die "Gagal!" ; press_enter ;;
      13)
        title "Cek Slot Aktif"
        termux-fastboot getvar current-slot ; press_enter ;;
      14)
        title "Set Active Slot A"
        termux-fastboot --set-active=a
        [ $? -eq 0 ] && ok "Slot A aktif!" || die "Gagal!" ; press_enter ;;
      15)
        title "Set Active Slot B"
        termux-fastboot --set-active=b
        [ $? -eq 0 ] && ok "Slot B aktif!" || die "Gagal!" ; press_enter ;;
      16)
        title "Boot TWRP (tanpa flash)"
        ask_file "Path TWRP .img" twrpf || { press_enter; continue; }
        termux-fastboot boot "$twrpf"
        [ $? -eq 0 ] && ok "TWRP boot berhasil!" || die "Gagal!" ; press_enter ;;
      17)
        title "ADB Sideload"
        ask_file "Path ZIP" zipf || { press_enter; continue; }
        termux-adb sideload "$zipf" 2>/dev/null || adb sideload "$zipf"
        [ $? -eq 0 ] && ok "Sideload berhasil!" || die "Gagal!" ; press_enter ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 6: FRP REMOVE TOOL
# ═══════════════════════════════════════════════════════════════
menu_frp() {
  while true; do
    clear
    title "🔐 FRP REMOVE TOOL"
    echo ""
    echo -e "${B}  ┌────────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  SPRD FRP Reset via Fastboot (erase persist)${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  Samsung FRP Reset via ADB                  ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  SPRD/MTK FRP Reset via ADB                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  Cek ADB device                             ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  Cek Fastboot device                        ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                  ${B}│${RESET}"
    echo -e "${B}  └────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        title "SPRD FRP via Fastboot"
        warn "Hapus partisi persist (FRP SPRD)..."
        termux-fastboot erase persist
        [ $? -eq 0 ] && ok "FRP berhasil dihapus!" || die "Gagal!" ; press_enter ;;
      2)
        title "Samsung FRP via ADB"
        info "Mengirim intent setup GSF..."
        termux-adb shell am start -n com.google.android.gsf.login/ 2>/dev/null || \
          adb shell am start -n com.google.android.gsf.login/
        termux-adb shell am start -n com.google.android.gsf.login.LoginActivity 2>/dev/null || \
          adb shell am start -n com.google.android.gsf.login.LoginActivity
        info "Set user_setup_complete = 1..."
        termux-adb shell content insert --uri content://settings/secure \
          --bind name:s:user_setup_complete --bind value:s:1 2>/dev/null || \
          adb shell content insert --uri content://settings/secure \
          --bind name:s:user_setup_complete --bind value:s:1
        [ $? -eq 0 ] && ok "FRP Samsung berhasil direset!" || die "Gagal!" ; press_enter ;;
      3)
        title "SPRD/MTK FRP via ADB"
        info "Set user_setup_complete = 1..."
        termux-adb shell content insert --uri content://settings/secure \
          --bind name:s:user_setup_complete --bind value:s:1 2>/dev/null || \
          adb shell content insert --uri content://settings/secure \
          --bind name:s:user_setup_complete --bind value:s:1
        [ $? -eq 0 ] && ok "FRP berhasil direset!" || die "Gagal!" ; press_enter ;;
      4)
        title "Cek ADB Device"
        termux-adb devices 2>/dev/null || adb devices ; press_enter ;;
      5)
        title "Cek Fastboot Device"
        termux-fastboot devices ; press_enter ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 7: USB / OTG FIX TOOL
# ═══════════════════════════════════════════════════════════════
menu_usbfix() {
  while true; do
    clear
    title "🔌 USB / OTG FIX TOOL"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  Cek device OTG (termux-usb -l)           ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  Reinstall Termux-API                     ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  Reinstall ADB/Fastboot                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  Stop ADB Server                          ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  Start ADB Server                         ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  Cek ADB device                           ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  Cek Fastboot device                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${G}  Install android-tools                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}9.${Y}  Auto-detect & connect device             ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        title "Cek OTG Device"
        termux-usb -l ; press_enter ;;
      2)
        title "Reinstall Termux-API"
        yes | pkg remove termux-api && pkg install -y termux-api
        ok "Berhasil!" ; press_enter ;;
      3)
        title "Reinstall ADB/Fastboot"
        yes | pkg remove termux-adb 2>/dev/null
        curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
        ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot" 2>/dev/null
        ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb" 2>/dev/null
        ok "Berhasil!" ; press_enter ;;
      4)
        title "Stop ADB Server"
        termux-adb kill-server 2>/dev/null || adb kill-server
        ok "ADB server dihentikan!" ; press_enter ;;
      5)
        title "Start ADB Server"
        termux-adb start-server 2>/dev/null || adb start-server
        ok "ADB server berjalan!" ; press_enter ;;
      6)
        title "Cek ADB Device"
        termux-adb devices 2>/dev/null || adb devices ; press_enter ;;
      7)
        title "Cek Fastboot Device"
        termux-fastboot devices ; press_enter ;;
      8)
        title "Install android-tools"
        yes | pkg install android-tools
        ok "Berhasil!" ; press_enter ;;
      9)
        title "Auto-detect Device"
        info "Mencari USB device via OTG..."
        for i in 1 2 3 4 5; do
          USB_DEV=$(termux-usb -l 2>/dev/null | grep -oE '/dev/bus/usb/[0-9]+/[0-9]+')
          if [ -n "$USB_DEV" ]; then
            ok "USB terdeteksi: $USB_DEV"
            # Cek ADB
            ADB_DEV=$(termux-adb devices 2>/dev/null | awk 'NR>1 && $2=="device"{print $1}')
            if [ -n "$ADB_DEV" ]; then
              ok "ADB device: $ADB_DEV"
              break
            fi
            # Cek Fastboot
            FB_DEV=$(termux-fastboot devices 2>/dev/null | awk 'NR>0{print $1}')
            if [ -n "$FB_DEV" ]; then
              ok "Fastboot device: $FB_DEV"
              break
            fi
            warn "USB terdeteksi tapi ADB/Fastboot belum. Coba aktifkan USB debugging..."
          else
            info "Percobaan $i/5... tidak ada USB. Pastikan OTG terhubung."
            sleep 2
          fi
        done
        press_enter ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 8: PANDUAN LENGKAP
# ═══════════════════════════════════════════════════════════════
menu_panduan() {
  while true; do
    clear
    title "📖 PANDUAN LENGKAP"
    echo ""
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${Y}  Setup awal (install & persiapan)         ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${Y}  Cara flash EDL (QDL)                     ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${Y}  Cara flash Fastboot                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${Y}  Cara flash GSI ROM                       ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${Y}  Cara pasang QDL binary                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${Y}  Troubleshooting USB/OTG                  ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  📋 SETUP AWAL — PERSIAPAN${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 1: Install Termux dari F-Droid (BUKAN Play Store!)${RESET}"
        echo -e "  ${DIM}→ https://f-droid.org/repo/com.termux_1021.apk${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 2: Install Termux:API dari F-Droid${RESET}"
        echo -e "  ${DIM}→ https://f-droid.org/repo/com.termux.api_1000.apk${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 3: Di Termux, jalankan:${RESET}"
        echo -e "  ${DIM}  pkg update && pkg upgrade -y"
        echo -e "  pkg install -y termux-api git libxml2 sudo${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 4: Install ADB/Fastboot:${RESET}"
        echo -e "  ${DIM}  curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 5: Clone/salin tool ini:${RESET}"
        echo -e "  ${DIM}  mkdir -p ~/siroha-flash/bin/arm64"
        echo -e "  cp siroha-flashtool.sh ~/siroha-flash/"
        echo -e "  chmod +x ~/siroha-flash/siroha-flashtool.sh${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH 6: Salin QDL binary (lihat panduan 5)${RESET}"
        echo ""
        echo -e "${G}  Syarat HP host: rooted, arm64, Termux dari F-Droid${RESET}"
        press_enter ;;
      2)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  ⚡ CARA FLASH EDL (QDL) — STEP BY STEP${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  PERSIAPAN:${RESET}"
        echo -e "  ${DIM}• Siapkan folder firmware di /sdcard/qdl-flash/"
        echo -e "  • Isi folder: prog_firehose_*.mbn, rawprogram0.xml, patch0.xml"
        echo -e "  • Kabel USB OTG + data cable${RESET}"
        echo ""
        echo -e "${Y}  CARA MASUK EDL (pilih salah satu):${RESET}"
        echo -e "  ${G}[A]${RESET} Via ADB (HP target masih bisa booting):"
        echo -e "      ${DIM}adb reboot edl${RESET}"
        echo -e "  ${G}[B]${RESET} Via Fastboot (BL unlock):"
        echo -e "      ${DIM}fastboot oem edl${RESET}"
        echo -e "  ${G}[C]${RESET} Test point (hardware, terakhir)"
        echo ""
        echo -e "${Y}  LANGKAH FLASH:${RESET}"
        echo -e "  ${DIM}1. Siapkan command di Termux dulu (menu QDL)"
        echo -e "  2. Masukkan path firehose, rawprogram, patch"
        echo -e "  3. Hubungkan HP target (EDL mode) via OTG"
        echo -e "  4. Tekan Enter untuk mulai flash${RESET}"
        echo ""
        echo -e "${W}  PERINTAH MANUAL:${RESET}"
        echo -e "  ${DIM}sudo ./qdl --debug --storage emmc \\"
        echo -e "    --include /sdcard/qdl-flash \\"
        echo -e "    prog_firehose.mbn rawprogram0.xml patch0.xml${RESET}"
        press_enter ;;
      3)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  🔧 CARA FLASH FASTBOOT${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  SYARAT:${RESET}"
        echo -e "  ${DIM}• HP target: Bootloader UNLOCK"
        echo -e "  • Di Fastboot mode${RESET}"
        echo ""
        echo -e "${Y}  URUTAN FLASH RECOVERY + MAGISK:${RESET}"
        echo -e "  ${DIM}1. Flash recovery.img"
        echo -e "  2. Flash vbmeta.img (--disable-verity)"
        echo -e "  3. Reboot ke recovery"
        echo -e "  4. Sideload/install Magisk ZIP${RESET}"
        echo ""
        echo -e "${Y}  URUTAN FLASH BOOT (Magisk patch):${RESET}"
        echo -e "  ${DIM}1. Flash boot.img (yang sudah di-patch Magisk)"
        echo -e "  2. Reboot system${RESET}"
        press_enter ;;
      4)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  🔮 CARA FLASH GSI ROM${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  URUTAN LENGKAP:${RESET}"
        echo -e "  ${DIM}1. Pastikan BL unlock + Fastboot mode"
        echo -e "  2. Flash vbmeta (--disable-verity --disable-verification)"
        echo -e "  3. Reboot ke FastbootD (fastboot reboot fastboot)"
        echo -e "  4. Cek is-userspace = yes"
        echo -e "  5. Erase system"
        echo -e "  6. Delete logical partition product_a & product_b"
        echo -e "  7. Flash GSI .img ke system"
        echo -e "  8. Reboot ke recovery"
        echo -e "  9. Format data (factory reset)"
        echo -e "  10. Reboot system${RESET}"
        press_enter ;;
      5)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  🗂️ CARA PASANG QDL BINARY${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  QDL binary adalah file executable untuk flash EDL.${RESET}"
        echo -e "${Y}  Source: https://github.com/Ishu43642/Termux-QDL${RESET}"
        echo ""
        echo -e "${Y}  LANGKAH:${RESET}"
        echo -e "  ${DIM}1. Download Termux-QDL-main.zip dari GitHub"
        echo -e "  2. Extract & ambil file 'qdl' sesuai arch HP kamu:"
        echo -e "     arm64/ → untuk HP 64-bit (kebanyakan HP modern)"
        echo -e "     arm/   → untuk HP 32-bit"
        echo -e "  3. Buat folder struktur:${RESET}"
        echo -e "  ${G}  ~/siroha-flash/"
        echo -e "  ├── siroha-flashtool.sh"
        echo -e "  └── bin/"
        echo -e "      ├── arm64/qdl"
        echo -e "      ├── arm/qdl"
        echo -e "      ├── x86_64/qdl"
        echo -e "      └── x86/qdl${RESET}"
        echo ""
        echo -e "  ${DIM}4. chmod +x ~/siroha-flash/bin/arm64/qdl"
        echo -e "  (sesuaikan dengan arch kamu: $ARCH_DIR)${RESET}"
        echo ""
        echo -e "${Y}  Cek arch HP kamu:${RESET}"
        echo -e "  ${DIM}  uname -m${RESET}"
        echo -e "  ${DIM}  Hasil: $ARCH (= $ARCH_DIR)${RESET}"
        press_enter ;;
      6)
        clear
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo -e "${W}  🔌 TROUBLESHOOTING USB/OTG${RESET}"
        echo -e "${C}══════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${Y}  MASALAH: USB tidak terdeteksi${RESET}"
        echo -e "  ${DIM}→ Pastikan HP host support USB Host/OTG"
        echo -e "  → Coba kabel OTG yang berbeda"
        echo -e "  → Grant permission termux-usb via Settings"
        echo -e "  → Reinstall termux-api (menu USB Fix → opsi 2)${RESET}"
        echo ""
        echo -e "${Y}  MASALAH: ADB tidak terdeteksi${RESET}"
        echo -e "  ${DIM}→ Aktifkan USB Debugging di HP target"
        echo -e "  → Allow USB Debugging dari notifikasi HP target"
        echo -e "  → Restart ADB server (menu USB Fix → opsi 4 → 5)${RESET}"
        echo ""
        echo -e "${Y}  MASALAH: Fastboot tidak terdeteksi${RESET}"
        echo -e "  ${DIM}→ Pastikan HP target di fastboot mode"
        echo -e "  → Coba reinstall ADB/Fastboot (menu Install → opsi 3)${RESET}"
        echo ""
        echo -e "${Y}  MASALAH: QDL gagal flash${RESET}"
        echo -e "  ${DIM}→ Pastikan HP target benar-benar di EDL mode (9008)"
        echo -e "  → Pastikan path firehose/rawprogram/patch benar"
        echo -e "  → Coba tambah sudo di depan command"
        echo -e "  → Gunakan storage yang benar (emmc vs ufs)${RESET}"
        press_enter ;;
      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MAIN MENU
# ═══════════════════════════════════════════════════════════════
main_menu() {
  while true; do
    clear
    echo -e "${C}"
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo -e "  ║${Y}      ⚡ SIROHA FLASH TOOL — MAIN MENU ⚡          ${C}║"
    echo -e "  ║${DIM}    Qualcomm EDL • Fastboot • Recovery • GSI       ${C}║"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${C}  📦 Instalasi & Cek Requirements          ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${G}  ⚡ QDL Flash (EDL 9008 Mode)             ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  🔧 Fastboot Flash Tool                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${G}  🔮 GSI ROM Flash Tool                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}5.${G}  🆎 A/B Partition Tool                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}6.${G}  🔐 FRP Remove Tool                       ${B}│${RESET}"
    echo -e "${B}  │ ${W}7.${G}  🔌 USB / OTG Fix Tool                    ${B}│${RESET}"
    echo -e "${B}  │ ${W}8.${Y}  📖 Panduan Lengkap                       ${B}│${RESET}"
    echo -e "${B}  │ ${W}9.${M}  🔓 Bypass UBL Redmi 4A (rolex) MIUI 10   ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ✖  Keluar                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "${DIM}  Arch: $ARCH_DIR | QDL: $([ -f "$QDL_BIN" ] && echo "${G}✓ Ada${DIM}" || echo "${R}✗ Tidak ada${DIM}")${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1) menu_install ;;
      2) menu_qdl ;;
      3) menu_fastboot ;;
      4) menu_gsi ;;
      5) menu_ab ;;
      6) menu_frp ;;
      7) menu_usbfix ;;
      8) menu_panduan ;;
      9) menu_bypass_ubl ;;
      0)
        clear
        echo -e "${G}"
        echo "  ╔═══════════════════════════════════════════════════╗"
        echo "  ║          Terima kasih telah menggunakan           ║"
        echo -e "  ║${Y}            SIROHA FLASH TOOL  ⚡                  ${G}║"
        echo "  ║                                                   ║"
        echo -e "  ║${C}  GitHub : github.com/rahmatsobrian                ${G}║"
        echo -e "  ║${C}  TG     : t.me/rahmatsobrian                      ${G}║"
        echo "  ╚═══════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        exit 0
        ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
#   MODUL 9: BYPASS UBL REDMI 4A (ROLEX) — MIUI 10
#   Port dari: RahmatSobrian.bat by Rahmat Sobrian
#   Menggunakan QDL (qdl binary) via EDL 9008
# ═══════════════════════════════════════════════════════════════
menu_bypass_ubl() {
  local TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local UBL_DIR="$TOOL_DIR/bypass-ubl/Redmi4A-rolex"
  local FIREHOSE="$UBL_DIR/rahmatsobrian.mbn"
  local DEVINFO="$UBL_DIR/devinfo"
  local ABOOT="$UBL_DIR/emmc_appsboot.mbn"
  local RAW_FULL="$UBL_DIR/rawprogram0.xml"
  local PATCH_FULL="$UBL_DIR/patch0.xml"

  # ── Data partisi dari rawprogram0.xml ROM ──────────────────
  # ROM: rolex_global_images_V10.2.3.0.NCCMIXM_20190605
  # aboot    : start=786432,  size=2048 sectors (0x18000000)
  # abootbak : start=788480,  size=2048 sectors (0x18100000)
  # devinfo  : start=1052672, size=2048 sectors (0x20200000)
  local ABOOT_START=786432
  local ABOOT_SIZE=2048
  local ABOOTBAK_START=788480
  local ABOOTBAK_SIZE=2048
  local DEVINFO_START=1052672
  local DEVINFO_SIZE=2048

  while true; do
    clear
    echo -e "${C}"
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo -e "  ║${Y}   🔓 BYPASS UBL — Redmi 4A (rolex) MIUI 10        ${C}║"
    echo -e "  ║${DIM}        by Rahmat Sobrian | Port to Bash           ${C}║"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    # Cek file UBL
    local files_ok=true
    for f in "$FIREHOSE" "$DEVINFO" "$ABOOT"; do
      if [ -f "$f" ]; then
        ok "Ada     : $(basename $f)"
      else
        die "MISSING : $(basename $f)"
        files_ok=false
      fi
    done

    # Cek qdl binary
    echo ""
    if [ -f "$QDL_BIN" ]; then
      ok "qdl     : $QDL_BIN"
    else
      die "qdl     : TIDAK ADA — cek menu Instalasi"
    fi
    echo ""

    echo -e "${B}  ┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${B}  │ ${W}1.${G}  🔓 Jalankan Bypass UBL                   ${B}│${RESET}"
    echo -e "${B}  │ ${W}2.${Y}  📖 Panduan & Syarat                      ${B}│${RESET}"
    echo -e "${B}  │ ${W}3.${G}  🔍 Cek EDL device (9008)                 ${B}│${RESET}"
    echo -e "${B}  │ ${W}4.${Y}  [i] Lihat rawprogram & patch XML         ${B}│${RESET}"
    echo -e "${B}  │ ${W}0.${R}  ← Kembali                                ${B}│${RESET}"
    echo -e "${B}  └──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -ne "${C}  Pilih: ${RESET}"
    read choice

    case "$choice" in
      1)
        if [ "$files_ok" = false ]; then
          die "File UBL tidak lengkap!"
          press_enter; continue
        fi
        if [ ! -f "$QDL_BIN" ]; then
          die "QDL binary tidak ditemukan: $QDL_BIN"
          press_enter; continue
        fi

        clear
        title "🔓 Bypass UBL Redmi 4A (rolex) MIUI 10"
        echo ""

        # ══════════════════════════════════════════════════════
        echo -e "${R}  ╔══════════════════════════════════════════════════╗"
        echo -e "  ║  [!!!] PERINGATAN WAJIB BACA [!!!]               ║"
        echo -e "  ╠══════════════════════════════════════════════════╣"
        echo -e "  ║                                                  ║"
        echo -e "  ║  Tool ini HANYA untuk MIUI versi:                ║"
        echo -e "  ║${W}  rolex_global_images_V10.2.3.0.NCCMIXM           ${R}║"
        echo -e "  ║${W}  (Global 10.2.3.0 — Build 20190605)              ${R}║"
        echo -e "  ║                                                  ║"
        echo -e "  ║  Menggunakan versi MIUI lain = BRICK!            ║"
        echo -e "  ║  Cek: Settings → About Phone → MIUI Version      ║"
        echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${Y}  Syarat lain:${RESET}"
        echo -e "  ${G}✓${RESET} Device: Redmi 4A (codename: rolex)"
        echo -e "  ${G}✓${RESET} Device sudah di EDL mode (9008)"
        echo -e "  ${G}✓${RESET} Kabel USB OTG terhubung"
        echo ""
        echo -e "  ${R}Partisi yang akan di-flash:${RESET}"
        echo -e "  ${DIM}aboot    → start: $ABOOT_START  (0x18000000)"
        echo -e "  abootbak → start: $ABOOTBAK_START  (0x18100000)"
        echo -e "  devinfo  → start: $DEVINFO_START (0x20200000)${RESET}"
        echo ""

        ask_yn "Saya sudah baca peringatan, lanjutkan?" || { press_enter; continue; }

        # Konfirmasi versi MIUI
        echo ""
        echo -ne "${Y}  Ketik versi MIUI kamu (contoh: V10.2.3.0.NCCMIXM): ${RESET}"
        read user_miui
        if [[ "$user_miui" != *"10.2.3.0"* && "$user_miui" != *"NCCMIXM"* ]]; then
          warn "Versi MIUI yang kamu masukkan: $user_miui"
          warn "Tidak cocok dengan V10.2.3.0.NCCMIXM!"
          ask_yn "Tetap lanjutkan? (RISIKO BRICK TINGGI)" || { press_enter; continue; }
        else
          ok "Versi MIUI cocok: $user_miui"
        fi

        echo ""
        warn "Hubungkan Redmi 4A ke EDL mode (9008) via OTG, lalu tekan Enter..."
        press_enter

        # Buat tmpdir, symlink file, generate rawprogram UBL saja (bukan full rom)
        local TMPDIR=$(mktemp -d)
        ln -sf "$DEVINFO" "$TMPDIR/devinfo"
        ln -sf "$ABOOT"   "$TMPDIR/emmc_appsboot.mbn"

        # rawprogram khusus UBL: hanya flash aboot, abootbak, devinfo
        cat > "$TMPDIR/rawprogram_ubl.xml" << XMLEOF
<?xml version="1.0" ?>
<data>
  <!--NOTE: Bypass UBL Redmi 4A (rolex)-->
  <!--NOTE: ROM: rolex_global_images_V10.2.3.0.NCCMIXM_20190605-->
  <!--NOTE: Sector size is 512 bytes-->

  <!-- aboot: 0x18000000, start_sector=786432, size=2048 -->
  <program SECTOR_SIZE_IN_BYTES="512"
    file_sector_offset="0"
    filename="emmc_appsboot.mbn"
    label="aboot"
    num_partition_sectors="$ABOOT_SIZE"
    physical_partition_number="0"
    size_in_KB="1024.0"
    sparse="false"
    start_byte_hex="0x18000000"
    start_sector="$ABOOT_START"/>

  <!-- abootbak: 0x18100000, start_sector=788480, size=2048 -->
  <program SECTOR_SIZE_IN_BYTES="512"
    file_sector_offset="0"
    filename="emmc_appsboot.mbn"
    label="abootbak"
    num_partition_sectors="$ABOOTBAK_SIZE"
    physical_partition_number="0"
    size_in_KB="1024.0"
    sparse="false"
    start_byte_hex="0x18100000"
    start_sector="$ABOOTBAK_START"/>

  <!-- devinfo: 0x20200000, start_sector=1052672, size=2048 -->
  <program SECTOR_SIZE_IN_BYTES="512"
    file_sector_offset="0"
    filename="devinfo"
    label="devinfo"
    num_partition_sectors="$DEVINFO_SIZE"
    physical_partition_number="0"
    size_in_KB="1024.0"
    sparse="false"
    start_byte_hex="0x20200000"
    start_sector="$DEVINFO_START"/>
</data>
XMLEOF

        # patch0.xml kosong, tidak ada patch untuk partisi ini
        cat > "$TMPDIR/patch_ubl.xml" << XMLEOF
<?xml version="1.0" ?>
<patches/>
XMLEOF

        echo ""
        info "Menjalankan QDL flash (3 partisi)..."
        echo ""

        sudo "$QDL_BIN" --debug --storage emmc \
          --include "$TMPDIR" \
          "$FIREHOSE" \
          "$TMPDIR/rawprogram_ubl.xml" \
          "$TMPDIR/patch_ubl.xml"

        local exit_code=$?
        rm -rf "$TMPDIR"

        echo ""
        if [ $exit_code -eq 0 ]; then
          ok "═══════════════════════════════════════"
          ok "  Bypass UBL BERHASIL!"
          ok "  Reboot device."
          ok "  Settings → Dev Options → OEM Unlock ON"
          ok "═══════════════════════════════════════"
        else
          die "Flash gagal (exit: $exit_code)"
          warn "Tips:"
          warn "  Pastikan device di EDL mode (9008)"
          warn "  Reconnect kabel OTG lalu ulangi"
        fi
        echo ""
        press_enter
        ;;

      2)
        clear
        title "📖 PANDUAN BYPASS UBL REDMI 4A"
        echo ""
        echo -e "${R}  ╔══════════════════════════════════════════════════╗"
        echo -e "  ║  [!!!] WAJIB BACA SEBELUM FLASH [!!!]            ║"
        echo -e "  ╠══════════════════════════════════════════════════╣"
        echo -e "  ║  Hanya untuk MIUI:                               ║"
        echo -e "  ║${W}  rolex_global_images_V10.2.3.0.NCCMIXM           ${R}║"
        echo -e "  ║${W}  Global 10.2.3.0 — Build date: 20190605          ${R}║"
        echo -e "  ║  MIUI lain = PARTISI BEDA = BRICK!               ║"
        echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${Y}  CARA CEK VERSI MIUI:${RESET}"
        echo -e "  ${DIM}  Settings → About Phone → MIUI Version${RESET}"
        echo ""
        echo -e "${Y}  CARA MASUK EDL (tanpa test point):${RESET}"
        echo -e "  ${DIM}  1. Matikan HP Redmi 4A"
        echo -e "  2. Tahan Vol+ + Vol- lalu colokkan kabel"
        echo -e "  3. Atau: adb reboot edl${RESET}"
        echo ""
        echo -e "${Y}  PARTISI (dari rawprogram0.xml ROM asli):${RESET}"
        echo -e "  ${G}aboot${RESET}     sector: 786432  hex: 0x18000000"
        echo -e "  ${G}abootbak${RESET}  sector: 788480  hex: 0x18100000"
        echo -e "  ${G}devinfo${RESET}   sector: 1052672 hex: 0x20200000"
        echo ""
        echo -e "${Y}  SETELAH BERHASIL:${RESET}"
        echo -e "  ${DIM}  1. Reboot device"
        echo -e "  2. Settings → About → tap MIUI Version 7x"
        echo -e "  3. Developer Options → OEM Unlocking = ON"
        echo -e "  4. fastboot oem unlock${RESET}"
        echo ""
        press_enter
        ;;

      3)
        title "Cek EDL Device (9008)"
        info "Mencari USB device..."
        termux-usb -l 2>/dev/null || warn "termux-api tidak tersedia"
        press_enter
        ;;

      4)
        clear
        title "[i] Preview rawprogram & patch XML"
        echo ""
        echo -e "${Y}  rawprogram_ubl.xml (generated saat flash):${RESET}"
        echo -e "${DIM}  aboot    → start_sector=786432  (0x18000000), size=2048"
        echo -e "  abootbak → start_sector=788480  (0x18100000), size=2048"
        echo -e "  devinfo  → start_sector=1052672 (0x20200000), size=2048${RESET}"
        echo ""
        echo -e "${Y}  Source data:${RESET}"
        echo -e "  ${DIM}Diambil langsung dari rawprogram0.xml ROM asli:"
        echo -e "  rolex_global_images_V10.2.3.0.NCCMIXM_20190605${RESET}"
        echo ""
        echo -e "${Y}  patch_ubl.xml:${RESET}"
        echo -e "  ${DIM}<?xml version=\"1.0\" ?><patches/>"
        echo -e "  (kosong — tidak ada patch untuk 3 partisi ini)${RESET}"
        echo ""
        echo -e "${Y}  Full rawprogram0.xml ROM tersedia di:${RESET}"
        echo -e "  ${DIM}bypass-ubl/Redmi4A-rolex/rawprogram0.xml${RESET}"
        press_enter
        ;;

      0) return ;;
      *) warn "Pilihan tidak valid!" ; sleep 1 ;;
    esac
  done
}

# ─── ENTRY POINT ───────────────────────────────────────────────
splash_screen
main_menu
