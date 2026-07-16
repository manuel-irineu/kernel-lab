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
- disables known NVIDIA/Nouveau options for the current Intel-only host;
- builds Debian `.deb` packages as an unprivileged user;
- leaves package installation and boot testing as explicit manual steps.

No kernel source, generated package, or build artifact is committed to this
repository.

## Current target

Default build target:

```text
Linux 7.1.3 with local version suffix -kernel-lab
```

The target can be overridden without editing scripts:

```bash
KERNEL_VERSION=7.1.3 LOCAL_VERSION=-kernel-lab ./scripts/10-build-kernel-packages.sh --execute
```

## Current host baseline

Captured using read-only inventory commands. Exact hostnames, usernames, device
serials, and absolute home-directory paths are intentionally omitted from the
public documentation.

| Component | Current value |
| --- | --- |
| Host | Local Debian 13 workstation |
| Operating system | Debian GNU/Linux 13 (`trixie`) |
| Current Debian kernel | Debian-packaged 6.12 series kernel |
| CPU | Intel x86_64 CPU, 4 cores / 4 threads |
| Architecture | `x86_64` |
| Integrated GPU | Intel integrated graphics, driver `i915` |
| Dedicated GPU | none detected |
| Memory | sufficient RAM for local kernel builds |
| Root storage | SATA SSD with sufficient free space for kernel builds |
| Root filesystem | Btrfs root filesystem |
| EFI system partition | vfat ESP mounted at `/boot/efi` |
| Ethernet | Intel Ethernet, driver `e1000e` |
| Wi-Fi | Intel wireless, driver `iwlwifi` |
| Audio | Intel HD Audio, driver `snd_hda_intel` |
| Desktop session | Wayland |
| External modules | none required |

The current machine uses Intel integrated graphics only. The project does not
require external graphics modules for this host.

## Safety guarantees

Repository scripts follow these rules:

- no `sudo`;
- no `apt install`;
- no `dpkg` package installation or removal;
- no GRUB updates;
- no initramfs updates;
- no external module build or installation;
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

Import the kernel.org stable release signing key if it is not already present
in the local GPG keyring:

```bash
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 647F28654894E3BD457199BE38DBBDC86092693E
gpg --fingerprint 647F28654894E3BD457199BE38DBBDC86092693E
```

The expected fingerprint is:

```text
647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E
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

Package builds use generic local metadata by default:

```text
KBUILD_BUILD_USER=kernel-lab
KBUILD_BUILD_HOST=local-builder
DEBFULLNAME=Kernel Lab
DEBEMAIL=kernel-lab@example.invalid
```

These defaults avoid embedding the local username, hostname, or personal email
in generated Debian package metadata. Override them explicitly only for private
local builds where personal metadata is acceptable.

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
| 6 | `scripts/06-post-boot-tests.sh` | collect post-boot evidence after manual testing |

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

An earlier experiment showed that a successful kernel package build does not
automatically make a custom kernel suitable for daily use. Required external
modules, boot behavior, graphics, storage, network, and rollback paths must be
validated for the exact target kernel before adoption.
