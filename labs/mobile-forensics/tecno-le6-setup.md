# Lab Setup: Mobile Forensics Workstation

**Lab ID:** mobile-forensics  
**Primary Device:** TECNO LE6-GL  
**Host OS:** Kali Linux  
**Analyst:** Yumanang Sallah  

---

## 1. Lab Purpose

Dedicated workspace for mobile endpoint incident response, forensic baseline capture, and Android security research. Complements existing network/SIEM labs (Splunk, Wazuh, Suricata).

---

## 2. Hardware Inventory

| Item | Spec | Role |
|------|------|------|
| TECNO LE6-GL | Android 11, MTK SoC, 2GB RAM | Target device for IR exercises |
| USB-A to Micro-USB cable | OEM | ADB/fastboot connection |
| Faraday bag (small) | Generic | Evidence isolation (future cases) |
| Kali host | Existing lab machine | ADB host, script execution, evidence storage |

---

## 3. Software Stack

### 3.1 Kali Packages
```bash
sudo apt update
sudo apt install -y android-tools-adb android-tools-fastboot
sudo apt install -y libusb-1.0-0 python3-pip
pip3 install mtkclient  # For MediaTek advanced operations
```

### 3.2 Android Platform Tools (if not in repos)
```bash
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip -d ~/tools/
export PATH="$HOME/tools/platform-tools:$PATH"
```

### 3.3 SP Flash Tool (MediaTek)
```bash
# Download from trusted source (e.g., XDA, manufacturer)
# Extract to ~/tools/sp-flash-tool/
# Run via Wine or native Linux build if available
```

---

## 4. Device Preparation

### 4.1 Initial State (Post-Reset)
After Case TECHNO-LE6-KALI-20260731, the device is at factory state.

### 4.2 ADB Enablement
```
Settings → About Phone → Build Number (tap 7x)
Settings → System → Developer Options:
  - USB Debugging: ON
  - OEM Unlocking: OFF (locked)
  - Stay Awake: ON
```

### 4.3 Trust Relationship
First ADB connection will prompt for RSA fingerprint authorization. **Check "Always allow"** only if this is your dedicated lab device.

---

## 5. Evidence Handling Protocol

| Scenario | Action |
|----------|--------|
| Personal device (your own) | Full authority to modify, image, reset |
| Enterprise device (MDM enrolled) | Contact IT before ANY action |
| Third-party device (friend/family) | Written authorization required |
| Legal/HR hold | Do NOT power on. Faraday bag → legal contact |

---

## 6. Case Directory Structure

```
~/cases/
└── <CASE-ID>/
    ├── baseline/          # Pre-incident or post-reset baseline
    ├── evidence/          # Screenshots, logs, photos
    ├── acquisition/       # ADB backups, logical extractions
    ├── reports/           # Analysis writeups
    └── scripts/           # Case-specific automation
```

---

## 7. Related Resources

- **Case Writeup:** [`writeups/incident-response/TECHNO-LE6-KALI-20260731/`](../writeups/incident-response/TECHNO-LE6-KALI-20260731/)
- **IR Playbook:** [`playbooks/incident-response/mobile-avb-failure.md`](../playbooks/incident-response/mobile-avb-failure.md)
- **Baseline Script:** [`scripts/mobile/android_baseline_capture.sh`](../scripts/mobile/android_baseline_capture.sh)

---

*Lab established: 2026-07-31*
