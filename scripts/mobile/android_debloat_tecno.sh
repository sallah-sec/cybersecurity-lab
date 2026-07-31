#!/bin/bash
# =============================================================================
# Script: android_debloat_tecno.sh
# Description: Disable/remove Transsion bloatware from TECNO devices
# Warning: Review packages before running. Disable first, uninstall after 48h.
# Author: Yumanang Sallah
# Case Ref: TECHNO-LE6-KALI-20260731
# =============================================================================

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}[+] TECNO Debloat Script${NC}"
echo -e "${YELLOW}[!] WARNING: Review packages before execution.${NC}"
echo -e "${YELLOW}[!] This script DISABLES packages. To uninstall, use --uninstall flag.${NC}"
echo ""

# Check device
if ! adb devices -l | grep -q "device usb:"; then
    echo -e "${RED}[-] No ADB device detected.${NC}"
    exit 1
fi

MODE="disable"
if [ "${1:-}" == "--uninstall" ]; then
    MODE="uninstall"
    echo -e "${RED}[!] UNINSTALL MODE: Packages will be permanently removed.${NC}"
    echo -e "${RED}[!] Press Ctrl+C within 5 seconds to cancel...${NC}"
    sleep 5
fi

# Transsion packages to target
TRANSSION_PKGS=(
    "com.transsion.hilauncher.res"
    "com.transsion.magicshow"
    "com.transsion.smartpanel"
    "com.transsion.deskclock"
    "com.transsion.weather"
    "com.transsion.compass"
    "com.transsion.soundrecorder"
    "com.transsion.calculator"
    "com.transsion.filemanagerx"
    "com.transsion.hilauncher"
    "com.transsion.themecenter"
    "com.transsion.oversea customization"
)

# Facebook/Meta packages (common bloat)
META_PKGS=(
    "com.facebook.katana"
    "com.facebook.system"
    "com.facebook.appmanager"
    "com.facebook.services"
    "com.instagram.android"
    "com.whatsapp"  # Careful — may be user-installed
)

# Google apps (optional — uncomment if desired)
# GOOGLE_PKGS=(
#     "com.google.android.apps.youtube.music"
#     "com.google.android.apps.tachyon"
#     "com.google.android.apps.podcasts"
# )

echo -e "${BLUE}[*] Processing Transsion packages...${NC}"
for pkg in "${TRANSSION_PKGS[@]}"; do
    if adb shell pm list packages | grep -q "$pkg"; then
        if [ "$MODE" == "disable" ]; then
            echo -e "  ${YELLOW}Disabling${NC} $pkg"
            adb shell pm disable-user --user 0 "$pkg" || echo -e "  ${RED}Failed${NC} $pkg"
        else
            echo -e "  ${RED}Uninstalling${NC} $pkg"
            adb shell pm uninstall --user 0 "$pkg" || echo -e "  ${RED}Failed${NC} $pkg"
        fi
    else
        echo -e "  ${GREEN}Not found${NC} $pkg (skipped)"
    fi
done

echo ""
echo -e "${BLUE}[*] Processing Meta/Facebook packages...${NC}"
for pkg in "${META_PKGS[@]}"; do
    if adb shell pm list packages | grep -q "$pkg"; then
        if [ "$MODE" == "disable" ]; then
            echo -e "  ${YELLOW}Disabling${NC} $pkg"
            adb shell pm disable-user --user 0 "$pkg" || echo -e "  ${RED}Failed${NC} $pkg"
        else
            echo -e "  ${RED}Uninstalling${NC} $pkg"
            adb shell pm uninstall --user 0 "$pkg" || echo -e "  ${RED}Failed${NC} $pkg"
        fi
    else
        echo -e "  ${GREEN}Not found${NC} $pkg (skipped)"
    fi
done

echo ""
echo -e "${GREEN}[+] Operation complete.${NC}"
echo -e "${YELLOW}[!] Monitor device for 48 hours before running with --uninstall.${NC}"
echo -e "${YELLOW}[!] If system becomes unstable, re-enable packages:${NC}"
echo -e "    adb shell pm enable <package.name>"
echo ""

# Generate report
REPORT_FILE="tecno_debloat_report_$(date +%Y%m%d_%H%M%S).txt"
adb shell pm list packages -d > "$REPORT_FILE"
echo -e "${GREEN}[+] Disabled packages saved to: $REPORT_FILE${NC}"
