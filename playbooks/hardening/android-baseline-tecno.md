# Playbook: Android Baseline Hardening (TECNO/MediaTek)

**ID:** PB-HARDEN-ANDROID-001  
**Target:** TECNO LE6-GL / Similar Transsion devices  
**Analyst:** Yumanang Sallah  
**Tools:** ADB, Kali Linux  

---

## 1. Pre-Configuration

Complete Android setup wizard first:
- [ ] Skip Google account restore (restore selectively later)
- [ ] Set **6-digit minimum PIN** (avoid patterns — smudge attacks)
- [ ] Enable **Secure Start-up** if available (PIN required before boot)
- [ ] Disable **Send diagnostic data** to manufacturer/Google
- [ ] Connect to trusted Wi-Fi only

---

## 2. Enable Developer Options & ADB

```
Settings → About Phone → Tap "Build Number" 7 times
Settings → System → Developer Options → Enable:
  - USB Debugging
  - Stay Awake (optional)
  - Disable "OEM Unlocking" (CRITICAL — anti-tamper)
```

---

## 3. Baseline Capture

Connect to Kali. Authorize RSA key on device when prompted.

### 3.1 Verify Connection
```bash
adb devices -l
```

### 3.2 Capture System Properties
```bash
mkdir -p ~/cases/TECHNO-LE6/baseline
adb shell getprop > ~/cases/TECHNO-LE6/baseline/build.prop.txt
```

**Verify these properties:**

| Property | Expected | Meaning |
|----------|----------|---------|
| `ro.boot.verifiedbootstate` | `green` | AVB chain intact |
| `ro.boot.vbmeta.device_state` | `locked` | Bootloader locked |
| `ro.crypto.state` | `encrypted` | Encryption active |
| `ro.crypto.type` | `file` | File-Based Encryption |

### 3.3 Capture Partitions & Storage
```bash
adb shell cat /proc/partitions > ~/cases/TECHNO-LE6/baseline/partitions.txt
adb shell ls -la /dev/block/by-name/ > ~/cases/TECHNO-LE6/baseline/block_devices.txt
adb shell df -h > ~/cases/TECHNO-LE6/baseline/storage.txt
adb shell mount | grep -E "data|system|vendor|metadata" > ~/cases/TECHNO-LE6/baseline/mounts.txt
```

### 3.4 Capture Package Inventory
```bash
adb shell pm list packages > ~/cases/TECHNO-LE6/baseline/packages_full.txt
adb shell pm list packages -s > ~/cases/TECHNO-LE6/baseline/packages_system.txt
adb shell pm list packages -3 > ~/cases/TECHNO-LE6/baseline/packages_user.txt
```

---

## 4. Attack Surface Reduction (Debloating)

> **SAFETY FIRST:** Disable (`pm disable-user`) for 48h before uninstalling.

### 4.1 Transsion Bloatware
```bash
adb shell pm disable-user --user 0 com.transsion.hilauncher.res
adb shell pm disable-user --user 0 com.transsion.magicshow
adb shell pm disable-user --user 0 com.transsion.smartpanel
adb shell pm disable-user --user 0 com.transsion.deskclock
adb shell pm disable-user --user 0 com.transsion.weather
adb shell pm disable-user --user 0 com.transsion.compass
adb shell pm disable-user --user 0 com.transsion.soundrecorder
adb shell pm disable-user --user 0 com.transsion.calculator
adb shell pm disable-user --user 0 com.transsion.filemanagerx
```

### 4.2 Third-Party Bloat (Verify on your device first)
```bash
adb shell pm disable-user --user 0 com.facebook.katana
adb shell pm disable-user --user 0 com.facebook.system
adb shell pm disable-user --user 0 com.facebook.appmanager
adb shell pm disable-user --user 0 com.facebook.services
```

### 4.3 Verify Stability
After each batch, monitor for:
- System UI crashes
- Bootloop on restart
- Missing core functionality (calls, SMS, camera)

If stable for 48h, escalate to uninstall:
```bash
adb shell pm uninstall --user 0 <package.name>
```

---

## 5. Security Hardening

### 5.1 Disable Auto OTA
Transsion OTA updates are a known corruption vector.
```
Settings → System → System Update → Auto-download → OFF
Settings → System → System Update → Auto-install → OFF
```

### 5.2 Network Hardening
```
Settings → Network & Internet → Wi-Fi → Wi-Fi Preferences → Auto-connect → OFF
Settings → Location → Wi-Fi & Bluetooth scanning → OFF
Settings → Google → Ads → Opt out of Ads Personalization → ON
```

### 5.3 Permission Lockdown
```
Settings → Privacy → Permission Manager:
  - Camera: Whitelist ONLY Camera app
  - Microphone: Whitelist ONLY Phone, Recorder
  - Location: Deny all except Maps (if used)
  - Contacts: Deny all except Phone, Messages
  - SMS: Whitelist ONLY Messages
```

### 5.4 Verify OEM Lock
```bash
adb shell getprop ro.oem_unlock_supported
# Expected: 0
adb shell getprop ro.boot.vbmeta.device_state
# Expected: locked
```

---

## 6. Baseline Archive

```bash
cd ~/cases/TECHNO-LE6/baseline
tar -czvf ../TECNO-LE6_baseline.tar.gz .
sha256sum ../TECNO-LE6_baseline.tar.gz > ../TECNO-LE6_baseline.tar.gz.sha256
```

**Store securely.** This is your known-good reference for future integrity comparisons.

---

## 7. Monitoring

| Check | Frequency | Command / Path |
|-------|-----------|----------------|
| AVB State | Monthly | `adb shell getprop ro.boot.verifiedbootstate` |
| Storage Health | Weekly | `adb shell df -h` |
| Corruption Indicators | During heavy use | `adb logcat -d | grep -iE "corrupt|verity|fsck"` |

---

*Derived from Case TECHNO-LE6-KALI-20260731*
