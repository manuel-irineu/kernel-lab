# Current Setup

## Current host baseline

| Component | Value |
| --- | --- |
| Hostname | intentionally omitted |
| Machine | local Intel desktop-class system |
| Operating system | Debian GNU/Linux 13 (trixie) |
| `DEBIAN_VERSION_FULL` | Debian 13 point release |
| Current kernel | Debian-packaged 6.12 series kernel |
| Boot parameter | no vendor-specific graphics kernel parameter |
| Desktop session | Wayland |
| Integrated GPU | Intel integrated graphics using the `i915` driver |
| Dedicated GPU | none detected |
| DKMS | `dkms` command not installed/detected |
| Root filesystem available space | sufficient for kernel builds |
| `/boot/efi` available space | sufficient for the existing boot setup |
| System memory | sufficient RAM for local kernel builds |

Captured by `scripts/00-check-system.sh`. Exact hostnames, usernames, device
serials, UUIDs, and absolute home-directory paths are intentionally omitted from
public documentation.

## Graphics and module baseline

The current host has only Intel integrated graphics in the collected PCI
inventory:

- Intel integrated graphics using kernel driver `i915`.
- Intel wireless networking using `iwlwifi`.
- Intel Ethernet using `e1000e`.

`dkms` is not available. If an out-of-tree module is added later, it becomes a
new host-specific acceptance gate.

These are stated baseline values, not settings that scripts may change. Run
`scripts/00-check-system.sh` before each major stage to collect current,
read-only facts.

## Facts to preserve

- The current Debian kernel and its matching headers remain installed.
- Its boot entry remains available in GRUB's advanced options.
- Intel integrated graphics remains capable of rendering the desktop with
  `i915`.
- Any future out-of-tree module requirement is recorded before experimentation.

Save local evidence under the ignored `logs/` directory:

```bash
./scripts/00-check-system.sh | tee logs/baseline.txt
uname -a
lspci -nnk
```

Optional commands may be unavailable. That is not permission to install or
change anything automatically.
