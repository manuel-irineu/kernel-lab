# Post-Boot Test Checklist

Use this after a future deliberate boot of the lab kernel. Capture read-only
evidence with `scripts/06-post-boot-tests.sh` under ignored `logs/`.

## Preparation completed

- [x] The Linux 7.1.1 tarball was downloaded to
  `/home/manuel/Downloads/kernel`.
- [x] The detached signature was verified with Greg Kroah-Hartman's key,
  fingerprint `647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E`.
- [x] The source was extracted to
  `/home/manuel/build/kernel/src/linux-7.1.1`.
- [x] The out-of-tree build directory was created at
  `/home/manuel/build/kernel/build/linux-7.1.1`.
- [x] The running config was copied from `/boot/config-$(uname -r)`.
- [x] `olddefconfig` completed successfully with non-fatal warnings.
- [x] The final kernel release was configured as `7.1.1-kernel-lab`.
- [x] `make bindeb-pkg` generated the image, headers, libc headers, and debug
  image packages.

## Mandatory pre-reboot gate

After installing a custom image and headers, inspect the exact target release
before rebooting:

```bash
dkms status
sudo dkms autoinstall -k <kernel-release>
grep -R "<kernel-release>" /boot/grub/grub.cfg
ls -lh /boot | grep "<kernel-release>"
```

The DKMS autoinstall command changes system state and must be run manually only
after reviewing the target release. **Do not reboot into the custom kernel if
any required DKMS module fails to build or install.** A generated image,
initramfs, and GRUB entry do not prove that NVIDIA is compatible.

For `7.1.1-kernel-lab`, NVIDIA `550.163.01` failed this gate during package
post-installation. The image package remained half-configured, the custom kernel
was removed, and no post-boot acceptance test was performed.

## Identity and recovery

- [ ] `uname -r` reports exactly `7.1.1-kernel-lab`.
- [ ] The Debian kernel still appears in `/boot` and GRUB.
- [ ] The Wayland session starts normally.
- [ ] Logs contain no unexplained panic, oops, lockup, or module failure.

## Hardware

- [ ] Storage and filesystems operate normally.
- [ ] Keyboard, touchpad, USB, audio, webcam, and brightness work.
- [ ] Wi-Fi, Bluetooth, and suspend/resume work.
- [ ] Battery, charging, thermals, and fan behavior are plausible.

## Graphics and compute

- [ ] Intel remains the desktop renderer and Wayland is stable.
- [ ] NVIDIA modules exist for this exact kernel and load cleanly.
- [ ] `nvidia-smi` detects the MX230.
- [ ] A small Ollama test completes on the NVIDIA GPU.

## Rollback proof

- [ ] The Debian kernel package has not been removed.
- [ ] The exact known-good GRUB entry is known.
- [ ] Failures are documented before package changes are attempted.
- [ ] `sudo dpkg --audit` reports no half-configured custom kernel package after
  cleanup.
- [ ] GRUB and `/boot` no longer contain an unintended custom-kernel entry after
  rollback.
