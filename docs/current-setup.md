# Current Setup

## Current host baseline

| Component | Value |
| --- | --- |
| Hostname | `pchome` |
| Machine | Lenovo desktop-class Intel system |
| Operating system | Debian GNU/Linux 13 (trixie) |
| `DEBIAN_VERSION_FULL` | `13.6` |
| Current kernel | `6.12.95+deb13-amd64` |
| Boot parameter | no NVIDIA-specific kernel parameter |
| Desktop session | Wayland |
| Integrated GPU | Intel HD Graphics 530 using the `i915` driver |
| Dedicated GPU | none detected |
| NVIDIA driver | not installed/detected |
| DKMS | `dkms` command not installed/detected |
| Root filesystem available space | Approximately 877G |
| `/boot/efi` available space | Approximately 3.8G |
| System memory | 30 GiB RAM and no swap |

Captured by `scripts/00-check-system.sh` on `2026-07-15T23:29:01-03:00`.

## Graphics and module baseline

The current host has only Intel integrated graphics in the collected PCI
inventory:

- Intel HD Graphics 530 using kernel driver `i915`.
- Intel Wireless 8260 using `iwlwifi`.
- Intel I219-LM Ethernet using `e1000e`.

`dkms` and `nvidia-smi` are not available. That means the previous NVIDIA DKMS
failure is not a required gate for this host. If an out-of-tree module is added
later, it becomes a new host-specific acceptance gate.

These are stated baseline values, not settings that scripts may change. Run
`scripts/00-check-system.sh` before each major stage to collect current,
read-only facts.

## Facts to preserve

- The current Debian kernel and its matching headers remain installed.
- Its boot entry remains available in GRUB's advanced options.
- Intel HD Graphics 530 remains capable of rendering the desktop with `i915`.
- Any future out-of-tree module requirement is recorded before experimentation.

Save local evidence under the ignored `logs/` directory:

```bash
./scripts/00-check-system.sh | tee logs/baseline.txt
uname -a
lspci -nnk
```

Optional commands may be unavailable. That is not permission to install or
change anything automatically.
