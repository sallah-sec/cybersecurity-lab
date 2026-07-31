# Playbook: Mobile AVB Integrity Failure Response

**ID:** PB-MOBILE-AVB-001  
**Platform:** Android 9+ with AVB 2.0 / dm-verity  
**Severity:** High (device unusable until resolved)  
**Analyst:** Yumanang Sallah  
**Version:** 1.0  

---

## 1. Trigger

Device displays on boot:
> "Your device is corrupt. It can't be trusted and may not work properly."

Or:
> "Device corrupted — may not function properly"

---

## 2. Triage (5 min)

### 2.1 Determine Boot State

| Observation | Meaning | Next Action |
|-------------|---------|-------------|
| Warning shown, but boots to lock screen | Soft AVB failure; `/data` likely corrupted | Proceed to **Containment** |
| Warning shown, bootloops to warning | Hard AVB failure; system partition suspect | Proceed to **Option B** |
| Warning shown, enters recovery automatically | Bootloader triggered recovery | Document, then assess |

### 2.2 Gather Intel (Before Touching Device)

- Device model & Android version
- Last known good state (what changed? update? app install? force shutdown?)
- Is the device enrolled in MDM/enterprise policy?
- Is there a recent backup (Google Drive, local, SD card)?

---

## 3. Containment

### Option A: Soft Failure (Boots to OS)

1. **Do NOT unlock the device yet.**
2. If ADB is enabled and trusted:
   ```bash
   adb shell getprop > case_<id>_pre_reset.prop
   adb shell dmesg > case_<id>_pre_reset_dmesg.log
   adb logcat -d > case_<id>_pre_reset_logcat.log
   ```
3. Power off cleanly: hold Power → Power off.

### Option B: Hard Failure (Bootloop or Will Not Boot)

1. Boot to stock recovery:
   - **Most devices:** Power off → Hold **Volume Up + Power**
   - **Some Samsung:** Volume Up + Bixby + Power
   - **Some Google:** Volume Down + Power → Select Recovery
2. In recovery, if "No command" appears, press **Power + Volume Up** briefly.
3. Document the recovery menu (photo/screenshot if possible).

---

## 4. Eradication

### 4.1 Preferred: Factory Reset via Recovery

1. In stock recovery, navigate with **Volume Up/Down**, select with **Power**.
2. Select: **`Wipe data/factory reset`**
3. Confirm when prompted.
4. Observe the wipe log. Document any errors (e.g., `/metadata/ota` missing).
5. Wait for: **"Data wipe complete."**

### 4.2 Alternative: ADB Sideload (If System Partition is Intact)

If you have a known-good OTA package:
```bash
adb sideload update.zip
```
> Only use signed OTA packages from the manufacturer.

### 4.3 Last Resort: Firmware Reflash

If factory reset does NOT resolve the corruption warning:

1. Identify exact build fingerprint from recovery or bootloader.
2. Download matching firmware from manufacturer or trusted source (e.g., XDA, official support).
3. Use SP Flash Tool (MediaTek), Odin (Samsung), or fastboot (Google/Pixel).
4. **Warning:** Reflash wipes all data including factory partition layout.

---

## 5. Recovery & Validation

1. Select **`Reboot system now`** from recovery.
2. Observe boot sequence:
   - ✅ **Android setup wizard** → Success. System partitions intact.
   - ❌ **Returns to recovery** → System partition damaged. Reflash required.
   - ❌ **Red corruption warning persists** → Bootloader/boot partition damaged. Requires manufacturer tools.

3. If successful, complete setup with minimal configuration (do not restore from backup yet — verify stability first).

---

## 6. Post-Incident

1. **Capture baseline** using [`scripts/mobile/android_baseline_capture.sh`](../../scripts/mobile/android_baseline_capture.sh)
2. **Apply hardening** per [`playbooks/hardening/android-baseline-tecno.md`](../hardening/android-baseline-tecno.md)
3. **Document evidence:** build fingerprint, wipe logs, pre/post state.
4. **Root cause analysis:** What triggered the corruption? (OTA interruption? Storage full? Malware?)

---

## 7. Escalation Matrix

| Scenario | Escalation Path |
|----------|-----------------|
| Enterprise/MDM device | Contact IT/Security team before reset |
| Potential malware rootkit | Do NOT reset. Preserve for advanced forensic imaging |
| Legal/HR hold on device | Do NOT alter state. Secure in Faraday bag, contact legal |
| Bootloader unlocked (unauthorized) | Treat as compromise. Full reflash + investigation |

---

*Playbook derived from Case TECHNO-LE6-KALI-20260731*
