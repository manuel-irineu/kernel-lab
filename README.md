# Debian 13 Linux Kernel Lab

This repository documents a safe, reversible experiment to build upstream
Linux kernels as Debian packages on Debian 13.

The lab does **not** replace the distribution kernel. The working
Debian kernel must remain installed and selectable from GRUB.

## Experiment status

The previous ASUS VivoBook experiment proved that Linux `7.1.1-kernel-lab`
could compile and package, but it was blocked by NVIDIA DKMS compatibility.

The current host is `pchome`, running Debian 13.6 with kernel
`6.12.95+deb13-amd64` and Intel HD Graphics 530 through `i915`. No NVIDIA GPU,
`nvidia-smi`, or DKMS registration is present in the current baseline, so the
NVIDIA-specific gate is archival rather than mandatory for this machine.

## Safety model

- Never remove the Debian kernel or its matching headers.
- Never automate `sudo`, package installation, `dpkg`, GRUB, initramfs, DKMS,
  or reboot operations.
- Review every printed privileged command before running it manually.
- Treat out-of-tree modules as optional host-specific gates. On the current
  Intel-only host, there is no NVIDIA DKMS gate.
- Keep Intel `i915` graphics as the recovery path.
- Keep source, packages, logs, and build output in ignored directories.

No kernel source or generated package is stored in this repository.

## Layout and workflow

- `docs/` contains the build, rollback, historical DKMS, and test procedures.
- `scripts/` contains staged helpers. Mutating helpers preview their work unless
  explicitly invoked with `--execute`.
- Ignored `workspace/`, `artifacts/`, and `logs/` directories hold local data.

Read `docs/rollback.md` first, then follow `docs/build-plan.md`. Use
`docs/test-checklist.md` after any future boot. The scripts deliberately stop
short of installing generated packages.

## Current build path

Preview the complete unprivileged build workflow:

```bash
./scripts/10-build-kernel-packages.sh
```

Run it only after reviewing the dependency and rollback docs. The workflow
downloads the tarball/signature, verifies the detached GPG signature using your
existing keyring, prepares the config, and builds `.deb` packages:

```bash
./scripts/10-build-kernel-packages.sh --execute
```

The default target remains `7.1.1-kernel-lab`, but the scripts are portable:

```bash
KERNEL_VERSION=7.1.1 LOCAL_VERSION=-kernel-lab ./scripts/10-build-kernel-packages.sh --execute
```

Generated source, build output, downloads, and logs stay under ignored local
directories in this repository.
