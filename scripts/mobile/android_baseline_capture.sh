#!/bin/bash
# =============================================================================
# Script: android_baseline_capture.sh
# Description: Capture forensic baseline from Android device via ADB
# Platform: TECNO LE6-GL / Generic Android 9+ with ADB enabled
# Author: Yumanang Sallah
# Case Ref: TECHNO-LE6-KALI-20260731
# =============================================================================

set -euo pipefail

# Configuration
DEVICE_NAME="TECNO-LE6"
CASE_ID="TECHNO-LE6-KALI-20260731"
OUTPUT_DIR="$HOME/cases/$CASE_ID/baseline"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+] Android Baseline Capture Script${NC}"
echo -e "${GREEN}[+] Case: $CASE_ID${NC}"
echo -e "${GREEN}[+] Timestamp: $TIMESTAMP${NC}"
echo ""

# Check ADB
if ! command -v adb &> /dev/null; then
    echo -e "${RED}[-] adb not found. Install Android platform-tools.${NC}"
    exit 1
fi

# Check device connection
DEVICE_COUNT=$(adb devices -l | grep -c "device usb:")
if [ "$DEVICE_COUNT" -ne 1 ]; then
    echo -e "${RED}[-] Expected 1 ADB device, found $DEVICE_COUNT.${NC}"
    adb devices -l
    exit 1
fi

echo -e "${GREEN}[+] Device detected:${NC}"
adb devices -l | grep "device usb:"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo -e "${YELLOW}[*] Capturing system properties...${NC}"
adb shell getprop > "build.prop.txt"
adb shell getprop | grep -E "ro\.boot|ro\.build|ro\.product|ro\.vendor|security|verity|encryption|crypto" > "build.prop.security.txt"

echo -e "${YELLOW}[*] Capturing partition tables...${NC}"
adb shell cat /proc/partitions > "partitions.txt"
adb shell ls -la /dev/block/by-name/ > "block_devices.txt"

echo -e "${YELLOW}[*] Capturing storage layout...${NC}"
adb shell df -h > "storage.txt"
adb shell mount | grep -E "data|system|vendor|metadata|cache" > "mount_points.txt"

echo -e "${YELLOW}[*] Capturing package inventory...${NC}"
adb shell pm list packages > "packages_full.txt"
adb shell pm list packages -s > "packages_system.txt"
adb shell pm list packages -3 > "packages_user.txt"
adb shell pm list packages -d > "packages_disabled.txt"

echo -e "${YELLOW}[*] Capturing network state...${NC}"
adb shell ifconfig > "network_interfaces.txt"
adb shell ip route > "network_routes.txt"
adb shell netstat -tuln 2>/dev/null > "network_listeners.txt" || true

echo -e "${YELLOW}[*] Capturing running processes...${NC}"
adb shell ps -A > "processes.txt"

echo -e "${YELLOW}[*] Capturing log snippets...${NC}"
adb logcat -d -t 500 > "logcat_recent.txt" || true

echo -e "${YELLOW}[*] Generating manifest...${NC}"
cat > "MANIFEST.txt" << EOF
Android Forensic Baseline Manifest
==================================
Case ID: $CASE_ID
Device: $DEVICE_NAME
Timestamp: $TIMESTAMP
Analyst: Yumanang Sallah

Files:
EOF
ls -la >> "MANIFEST.txt"

echo -e "${YELLOW}[*] Generating integrity hashes...${NC}"
sha256sum *.txt > "baseline.sha256"

echo ""
echo -e "${GREEN}[+] Baseline capture complete.${NC}"
echo -e "${GREEN}[+] Output: $OUTPUT_DIR${NC}"
echo -e "${GREEN}[+] Verify AVB state:${NC}"
echo -n "    ro.boot.verifiedbootstate = "
adb shell getprop ro.boot.verifiedbootstate
echo -n "    ro.boot.vbmeta.device_state = "
adb shell getprop ro.boot.vbmeta.device_state
echo ""
echo -e "${YELLOW}[!] Next steps:${NC}"
echo "    1. Review build.prop.security.txt for anomalies"
echo "    2. Archive: tar -czvf ${CASE_ID}_baseline_${TIMESTAMP}.tar.gz ."
echo "    3. Store securely as known-good reference"
