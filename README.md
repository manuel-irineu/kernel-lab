# Debian 13 Linux Kernel Lab

This repository documents a safe, reversible experiment to build upstream
Linux 7.1.1 as Debian packages on an ASUS VivoBook X512FJ running Debian 13.

The lab does **not** replace the distribution kernel. The working
`6.12.90+deb13.1-amd64` kernel must remain installed and selectable from GRUB.

## Safety model

- Never remove the Debian kernel or its matching headers.
- Never automate `sudo`, package installation, `dpkg`, GRUB, initramfs, DKMS,
  or reboot operations.
- Review every printed privileged command before running it manually.
- Treat NVIDIA DKMS support as a required validation gate.
- Keep Intel as the desktop renderer and test the NVIDIA MX230 separately.
- Keep source, packages, logs, and build output in ignored directories.

No kernel source is included or downloaded by this initial setup.

## Layout and workflow

- `docs/` contains the build, rollback, DKMS, and test procedures.
- `scripts/` contains staged helpers. Mutating helpers preview their work unless
  explicitly invoked with `--execute`.
- Ignored `workspace/`, `artifacts/`, and `logs/` directories hold local data.

Read `docs/rollback.md` first, then follow `docs/build-plan.md`. Use
`docs/nvidia-dkms-validation.md` before trusting the lab kernel and
`docs/test-checklist.md` after any future boot. The scripts deliberately stop
short of installing generated packages.

