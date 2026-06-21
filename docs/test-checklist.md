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
