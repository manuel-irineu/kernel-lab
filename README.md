# Debian 13 Linux Kernel Lab

This repository documents a safe, reversible experiment to build upstream
Linux 7.1.1 as Debian packages on an ASUS VivoBook X512FJ running Debian 13.

The lab does **not** replace the distribution kernel. The working
`6.12.94+deb13-amd64` kernel must remain installed and selectable from GRUB.

## Experiment status

Linux `7.1.1-kernel-lab` compiled successfully and produced Debian packages.
The image and headers were installed for testing, but NVIDIA
`nvidia-current/550.163.01` failed to build through DKMS for that kernel. The
custom image package was left half-configured, so Linux 7.1.1 was not accepted
for daily use. The custom kernel was removed and the notebook was returned to
the Debian `6.12.94+deb13-amd64` daily kernel.

## Safety model

- Never remove the Debian kernel or its matching headers.
- Never automate `sudo`, package installation, `dpkg`, GRUB, initramfs, DKMS,
  or reboot operations.
- Review every printed privileged command before running it manually.
- Treat NVIDIA DKMS support as a required validation gate.
- Keep Intel as the desktop renderer and test the NVIDIA MX230 separately.
- Keep source, packages, logs, and build output in ignored directories.

No kernel source or generated package is stored in this repository.

## Layout and workflow

- `docs/` contains the build, rollback, DKMS, and test procedures.
- `scripts/` contains staged helpers. Mutating helpers preview their work unless
  explicitly invoked with `--execute`.
- Ignored `workspace/`, `artifacts/`, and `logs/` directories hold local data.

Read `docs/rollback.md` first, then follow `docs/build-plan.md`. Use
`docs/nvidia-dkms-validation.md` before trusting the lab kernel and
`docs/test-checklist.md` after any future boot. The scripts deliberately stop
short of installing generated packages.

## Suggested next experiment

- Prefer a newer `6.12.x` longterm kernel or another Debian-supported kernel
  before attempting kernel 7.x again on this daily notebook.
- Treat successful NVIDIA DKMS compilation for the exact target release as a
  release gate, not as a post-boot test.
- Test risky DKMS compatibility patches only in a disposable virtual machine or
  another non-daily environment.
