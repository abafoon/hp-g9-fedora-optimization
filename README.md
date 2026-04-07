# HP 250R G9 Fedora Optimization Guide 🚀

This repository contains a comprehensive set of configurations and scripts to resolve standby battery drain and enable hardware-backed disk decryption for Fedora Linux on the HP 250R G9 (Intel 12th/13th Gen Raptor Lake).

## 🔋 The Problem: Overnight Battery Drain
By default, this hardware often loses ~12% battery over 8 hours of sleep. This is caused by:
1. Modern Standby (s2idle): A "light" sleep mode that keeps the CPU semi-active.
2. ACPI Wakeup Triggers: USB/Thunderbolt controllers (XHCI/TXHC) staying powered on, preventing the CPU from reaching deep power-saving states (Package C10).

---

## 🛠️ The Solutions

### 1. Force Deep Sleep (S3)
Override the default s2idle to use the more efficient deep sleep state via Kernel parameters.

* Configuration: Edit /etc/default/grub and add mem_sleep_default=deep to the GRUB_CMDLINE_LINUX line.
* Apply: sudo grub2-mkconfig -o /boot/grub2/grub.cfg

### 2. Disable USB Wakeup (Automated Service)
Even with no devices connected, active USB controllers can "poke" the CPU. We use a Systemd service to toggle these off during the boot sequence.

* Script Path: /usr/local/bin/disable-usb-wake.sh
* Service Path: /etc/systemd/system/disable-usb-wake.service
* Impact: Allows the motherboard's Platform Controller Hub (PCH) to fully power down, reducing drain to ~3% overnight.

### 🛡️ 3. TPM 2.0 Auto-Unlock (LUKS)
Streamline the boot process by linking the LUKS disk encryption key to the hardware TPM 2.0 chip. This removes the need for a secondary password entry at the BIOS level while maintaining high security.

Enrollment Command:
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3

* Integration: Added tpm2-device=auto to /etc/crypttab.
* Deployment: Rebuilt initramfs using sudo dracut -f.

---

## 📈 Technical Background
* Hardware: HP 250R G9 (Intel Raptor Lake-P / Alder Lake PCH)
* OS: Fedora Workstation (Gnome)
* Goal: Maximize portability and battery longevity for university commutes (Orsay/Paris-Saclay/ENSTA).
* Security: Trusted Computing Group (TCG) TPM 2.0 standards.

---

## 📁 Repository Files
* disable-usb-wake.sh: The bash script responsible for the ACPI toggle.
* disable-usb-wake.service: The Systemd unit file that ensures the fix persists across reboots and manages SELinux execution contexts.
