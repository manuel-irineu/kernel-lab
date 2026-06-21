# Post-Boot Test Checklist

Use this after a future deliberate boot of the lab kernel. Capture read-only
evidence with `scripts/06-post-boot-tests.sh` under ignored `logs/`.

## Identity and recovery

- [ ] `uname -r` is the expected unique Linux 7.1.1 release.
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

