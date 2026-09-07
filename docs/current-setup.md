# Current Setup

## Current host baseline

| Component | Value |
| --- | --- |
| Hostname | intentionally omitted |
| Machine | local Intel laptop/workstation with hybrid graphics |
| Operating system | Debian GNU/Linux forky/sid |
| `DEBIAN_VERSION_FULL` | rolling/unstable-style Debian baseline |
| Current kernel | Debian-packaged `7.1.12+deb14-amd64` |
| Boot parameter | no vendor-specific graphics kernel parameter |
| Desktop session | Wayland |
| Integrated GPU | Intel UHD Graphics 620 using the `i915` driver |
| Dedicated GPU | NVIDIA GeForce MX230 present; proprietary `nvidia` driver not installed |
| Current NVIDIA handling | `nouveau` may bind the dGPU; lab kernels intentionally omit NVIDIA/Nouveau modules |
| External modules | none required |
| Root filesystem available space | sufficient for kernel builds |
| `/boot/efi` available space | sufficient for the existing boot setup |
| System memory | sufficient RAM for local kernel builds |

Captured by `scripts/00-check-system.sh`. Exact hostnames, usernames, device
serials, UUIDs, and absolute home-directory paths are intentionally omitted from
public documentation.

## Graphics and module baseline

The current host has Intel integrated graphics plus an NVIDIA dGPU in the
collected PCI inventory:

- Intel UHD Graphics 620 using kernel driver `i915`.
- NVIDIA GeForce MX230 is present. The proprietary `nvidia` module is not part
  of this baseline and must not become a kernel-lab requirement.
- Intel wireless networking using `iwlwifi`.

No external module is required for the current host baseline. If one is added
later, it becomes a new host-specific acceptance gate. Intel `i915` is the
required graphics path for this machine.

These are stated baseline values, not settings that scripts may change. Run
`scripts/00-check-system.sh` before each major stage to collect current,
read-only facts.

## Facts to preserve

- The current Debian kernel and its matching headers remain installed.
- Its boot entry remains available in GRUB's advanced options.
- Intel integrated graphics remains capable of rendering the desktop with
  `i915`.
- Proprietary NVIDIA kernel modules remain absent unless the project baseline is
  deliberately changed later.
- Any future out-of-tree module requirement is recorded before experimentation.

Save local evidence under the ignored `logs/` directory:

```bash
./scripts/00-check-system.sh | tee logs/baseline.txt
uname -a
lspci -nnk
```

Optional commands may be unavailable. That is not permission to install or
change anything automatically.
