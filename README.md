# Debian Kernel Build Lab

Safe, reproducible tooling for building upstream Linux kernels as Debian
packages on Debian 13.

This project is intentionally conservative: it builds custom kernel packages
alongside the distribution kernel and does not automate installation, GRUB
changes, initramfs generation, package removal, or reboot operations.

## Purpose

The goal is to make upstream kernel experiments repeatable without putting the
daily Debian kernel at risk. The workflow:

- downloads an upstream Linux release and detached signature;
- verifies the kernel.org GPG signature with the user's existing keyring;
- prepares an out-of-tree build configuration from the running Debian kernel;
- builds Debian `.deb` packages as an unprivileged user;
- leaves package installation and boot testing as explicit manual steps.

No kernel source, generated package, or build artifact is committed to this
repository.

## Current target

Default build target:

```text
Linux 7.1.1 with local version suffix -kernel-lab
```

The target can be overridden without editing scripts:

```bash
KERNEL_VERSION=7.1.1 LOCAL_VERSION=-kernel-lab ./scripts/10-build-kernel-packages.sh --execute
```

## Current host baseline

Captured on `2026-07-15` using read-only inventory commands.

| Component | Current value |
| --- | --- |
| Hostname | `pchome` |
| Operating system | Debian GNU/Linux 13.6 (`trixie`) |
| Current Debian kernel | `6.12.95+deb13-amd64` |
| CPU | Intel Core i5-6500T, 4 cores / 4 threads, 2.50 GHz base, 3.10 GHz max |
| Architecture | `x86_64` |
| Integrated GPU | Intel HD Graphics 530, driver `i915` |
| Dedicated GPU | none detected |
| Memory | 30 GiB RAM, no swap |
| Root storage | Asgard AS960GS3-S7, 894.3G SATA SSD |
| Root filesystem | Btrfs on `/dev/sda2`, approximately 877G free |
| EFI system partition | `/dev/sda1`, vfat, mounted at `/boot/efi` |
| Ethernet | Intel Ethernet Connection I219-LM, driver `e1000e` |
| Wi-Fi | Intel Wireless 8260, driver `iwlwifi` |
| Audio | Intel 100 Series/C230 HD Audio, driver `snd_hda_intel` |
| Desktop session | Wayland |
| Out-of-tree modules | no `dkms` command detected |

The current machine uses Intel integrated graphics only. The previous NVIDIA
DKMS compatibility blocker is preserved in the documentation as historical
context, but it is not a release gate for this host.

## Safety guarantees

Repository scripts follow these rules:

- no `sudo`;
- no `apt install`;
- no `dpkg` package installation or removal;
- no GRUB updates;
- no initramfs updates;
- no DKMS build or module installation;
- no reboot operation;
- no writes outside ignored local workspace/log directories during the build
  workflow.

The known-good Debian kernel and its matching headers must remain installed and
selectable from GRUB at all times.

## Quick start

Review the build dependency suggestion:

```bash
./scripts/01-install-build-deps.sh
```

Preview the full unprivileged build workflow:

```bash
./scripts/10-build-kernel-packages.sh
```

Run the build workflow:

```bash
./scripts/10-build-kernel-packages.sh --execute
```

The workflow downloads sources, verifies the detached signature, prepares the
configuration, and runs `make bindeb-pkg`. It does not install the generated
packages.

## Workflow stages

The staged scripts can be run individually when more control is useful:

| Stage | Script | Scope |
| --- | --- | --- |
| 0 | `scripts/00-check-system.sh` | collect read-only host inventory |
| 1 | `scripts/01-install-build-deps.sh` | print a dependency command for manual review |
| 2 | `scripts/02-download-kernel.sh` | download upstream tarball and signature |
| 3 | `scripts/02-verify-kernel-signature.sh` | verify the detached kernel.org signature |
| 4 | `scripts/03-prepare-config.sh` | prepare out-of-tree kernel configuration |
| 5 | `scripts/04-build-deb.sh` | build Debian packages without root |
| 6 | `scripts/05-check-dkms.sh` | collect optional external module inventory |
| 7 | `scripts/06-post-boot-tests.sh` | collect post-boot evidence after manual testing |

Most scripts default to preview mode and require `--execute` before performing
local write or build actions.

## Repository layout

```text
docs/       build plan, rollback procedure, hardware notes, and test checklist
scripts/    staged automation helpers
workspace/  ignored local downloads, sources, and build directories
logs/       ignored local inventory and build logs
artifacts/  ignored generated package output, if copied there manually
```

Default local paths:

```text
workspace/downloads/                 tarball and detached signature
workspace/build/src/linux-<version>/ extracted source tree
workspace/build/out/linux-<version>/ out-of-tree build directory
logs/                                build and boot evidence
```

## Manual installation and rollback

Installation of generated kernel packages is intentionally outside the scripted
workflow. Before installing or booting a custom kernel, review:

- `docs/rollback.md`
- `docs/build-plan.md`
- `docs/test-checklist.md`

Do not boot a custom kernel unless the known-good Debian kernel is still
installed, visible in GRUB, and documented as the rollback target.

## Historical note

An earlier ASUS VivoBook experiment successfully built Linux
`7.1.1-kernel-lab` as Debian packages, but the kernel was rejected for daily use
because NVIDIA `nvidia-current/550.163.01` failed to build through DKMS for that
kernel. That failure is documented under `docs/nvidia-dkms-validation.md` and is
treated as host-specific historical context.
