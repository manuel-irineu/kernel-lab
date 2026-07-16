# Post-Boot Test Checklist

Use this after a future deliberate boot of the lab kernel on the current
Intel-only host. Capture read-only evidence with `scripts/06-post-boot-tests.sh`
under ignored `logs/`.

## Preparation for the current host

- [ ] `scripts/00-check-system.sh` was saved under `logs/`.
- [ ] The Linux tarball and detached signature were downloaded under
  `workspace/downloads/`.
- [ ] The detached signature was verified by
  `scripts/02-verify-kernel-signature.sh --execute`.
- [ ] The source was extracted under `workspace/build/src/`.
- [ ] The out-of-tree build directory was created under `workspace/build/out/`.
- [ ] The running config was copied from `/boot/config-$(uname -r)`.
- [ ] `olddefconfig` completed successfully.
- [ ] The final kernel release includes the configured `LOCAL_VERSION`.
- [ ] `make bindeb-pkg` generated image and headers packages.

## Mandatory pre-reboot gate

After installing a custom image and headers, inspect the exact target release
before rebooting:

```bash
grep -R "<kernel-release>" /boot/grub/grub.cfg
ls -lh /boot | grep "<kernel-release>"
```

The main pre-reboot gate is package state, GRUB/initramfs presence, and
known-good Debian fallback. Do not reboot into the custom kernel if any required
host-specific component fails to build, install, or initialize.

## Identity and recovery

- [ ] `uname -r` reports the intended lab kernel release.
- [ ] The Debian kernel still appears in `/boot` and GRUB.
- [ ] The Wayland session starts normally.
- [ ] Logs contain no unexplained panic, oops, lockup, or module failure.

## Hardware

- [ ] Storage and filesystems operate normally.
- [ ] Keyboard, touchpad, USB, audio, webcam, and brightness work.
- [ ] Wi-Fi, Bluetooth, and suspend/resume work.
- [ ] Battery, charging, thermals, and fan behavior are plausible.

## Graphics

- [ ] Intel remains the desktop renderer and Wayland is stable.
- [ ] `i915` is loaded and bound to the Intel integrated GPU.
- [ ] Display output, acceleration, suspend/resume, and session switching work.
- [ ] No external module check is required unless such a module is added later.

## Rollback proof

- [ ] The Debian kernel package has not been removed.
- [ ] The exact known-good GRUB entry is known.
- [ ] Failures are documented before package changes are attempted.
- [ ] `sudo dpkg --audit` reports no half-configured custom kernel package after
  cleanup.
- [ ] GRUB and `/boot` no longer contain an unintended custom-kernel entry after
  rollback.
