# Case: TECHNO-LE6-KALI-20260731

**Category:** Mobile Endpoint Incident Response  
**Platform:** Android 11 (TECNO LE6-GL, MediaTek SoC)  
**Date:** 2026-07-31  
**Analyst:** Yumanang Sallah  
**Tools:** Stock Android Recovery, ADB, Kali Linux  

---

## ⚠️ Legal & Ethical Notice

> This case study documents the recovery of a **personally owned device**. All forensic and recovery steps were performed with full legal authority and ownership. No third-party data was accessed, extracted, or exposed.

---

## 1. Executive Summary

A TECNO LE6-GL running Android 11 presented an Android Verified Boot (AVB) integrity failure: **"Device corrupted — may not function properly."** This writeup documents structured triage, containment, eradication, and recovery without firmware reflash.

**Root Cause:** Data-level corruption (`/data` partition or FBE metadata inconsistency), not system partition compromise.

**Outcome:** Device fully operational post-factory reset. All user data cryptographically destroyed via FBE key eviction.

---

## 2. Device Profile

| Attribute | Value |
|-----------|-------|
| Manufacturer | TECNO Mobile (Transsion Holdings) |
| Model | LE6-GL |
| SoC | MediaTek (MTK) |
| Android Version | 11 (API 30) |
| Build ID | `RP1A.200720.011` |
| Build Fingerprint | `TECNO/LE6-GL/TECNO-LE6:11/RP1A.200720.011/230912V577:user/release-keys` |
| Bootloader | Locked |
| Encryption | File-Based Encryption (FBE) v1 |
| Verified Boot | AVB 2.0 (dm-verity) |

---

## 3. Incident Timeline

| Time (EAT) | Phase | Action |
|------------|-------|--------|
| ~12:00 | **Detection** | Device presents "Device corrupted" warning on cold boot |
| ~12:10 | **Triage** | Identified AVB/dm-verity trigger; bootloop risk assessed |
| ~12:14 | **Containment** | Booted to stock Android Recovery (Vol Up + Power) |
| ~12:15 | **Eradication** | Executed *Wipe data/factory reset* |
| ~12:20 | **Recovery** | Selected *Reboot system now* |
| ~12:23 | **Validation** | Device boots to Android setup wizard — operational |

---

## 4. Technical Analysis

### 4.1 Failure Mode Hypotheses

| Hypothesis | Likelihood | Rationale |
|------------|------------|-----------|
| **H1: `/data` or FBE metadata corruption** | **HIGH** | Factory reset resolved it; system partitions intact |
| H2: System partition corruption | LOW | Would require reflash; not resolved by reset |
| H3: Bootloader/preloader corruption | LOW | Recovery access confirmed bootloader functional |

**Conclusion:** H1 confirmed.

### 4.2 Recovery Log Analysis

```
-- Wiping data...
E:Open failed: /metadata/ota: No such file or directory
Formatting /data...
Formatting /metadata...
Data wipe complete.
```

| Entry | Interpretation |
|-------|----------------|
| `E:Open failed: /metadata/ota` | Non-critical. OTA staging dir absent — common on MTK devices. |
| `Formatting /data...` | App data, databases, media destroyed. |
| `Formatting /metadata...` | **FBE metadata wiped. Master encryption keys evicted.** |

### 4.3 Cryptographic Impact

Android 11 FBE uses **Hardware-Backed Keystore**. Factory reset triggered:

1. **Key Eviction:** FBE master key (TEE/StrongBox) cryptographically shredded.
2. **KEK Rotation:** New Key Encryption Key generated for fresh `/data`.
3. **Recovery Status:** Logical data recovery **computationally infeasible** without TEE compromise or brute-force.

---

## 5. Evidence Inventory

| File | Description |
|------|-------------|
| `evidence/recovery_screenshot.png` | Stock recovery menu: build fingerprint, wipe completion, error log |

---

## 6. Lessons Learned

1. **Data ≠ System:** "Device corrupted" does not always mean OS compromise. Data-layer corruption triggers AVB on FBE devices.
2. **FBE is Destructive:** Key eviction makes post-reset recovery impossible — a security feature.
3. **Document Before Action:** Build fingerprint and logs preserved critical evidence.
4. **MTK Quirks:** `/metadata/ota` errors are benign on budget Transsion devices.

---

## 7. Skills Demonstrated

| Certification | Competency Shown |
|---------------|------------------|
| CompTIA CySA+ | IR lifecycle, root cause analysis, containment |
| CEH | Mobile platform security, endpoint assessment |
| IBM Cybersecurity Capstone | Structured documentation, chain of custody |
| Splunk/Wazuh Lab | EDR/MDM awareness for AVB failure detection |

---

## 8. Related Resources

- **IR Playbook:** [`playbooks/incident-response/mobile-avb-failure.md`](../../playbooks/incident-response/mobile-avb-failure.md)
- **Hardening Guide:** [`playbooks/hardening/android-baseline-tecno.md`](../../playbooks/hardening/android-baseline-tecno.md)
- **Baseline Script:** [`scripts/mobile/android_baseline_capture.sh`](../../scripts/mobile/android_baseline_capture.sh)
- **Debloat Script:** [`scripts/mobile/android_debloat_tecno.sh`](../../scripts/mobile/android_debloat_tecno.sh)

---

*Case closed: 2026-07-31*
