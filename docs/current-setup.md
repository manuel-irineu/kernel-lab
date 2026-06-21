# Current Setup

## Known baseline

| Component | Value |
| --- | --- |
| Hostname | `irishell` |
| Machine | ASUS VivoBook X512FJ notebook |
| Operating system | Debian GNU/Linux 13 (trixie) |
| `DEBIAN_VERSION_FULL` | `13.5` |
| Current kernel | `6.12.94+deb13-amd64` |
| Boot parameter | `nvidia-drm.modeset=1` |
| Desktop session | Wayland |
| Integrated GPU | Intel UHD Graphics 620 using the `i915` driver |
| Dedicated GPU | NVIDIA GeForce MX230 using the `nvidia` driver |
| NVIDIA driver | `550.163.01` |
| CUDA reported by `nvidia-smi` | `12.4` |
| Root filesystem available space | Approximately 424G |
| `/boot` available space | Approximately 3.8G |
| System memory | 31 GiB RAM and 4 GiB swap |

## NVIDIA DKMS baseline

DKMS reports `nvidia-current/550.163.01` installed for both Debian kernels:

- `6.12.90+deb13.1-amd64`
- `6.12.94+deb13-amd64`

The current boot uses `6.12.94+deb13-amd64`. Its command line includes
`nvidia-drm.modeset=1`, and the desktop session uses Wayland. Intel UHD Graphics
620 remains the desktop GPU through `i915`, while the NVIDIA GeForce MX230 uses
the proprietary `nvidia` driver for local Ollama workloads.

NVIDIA `550.163.01` is compatible with the tested Debian 6.12 kernels above,
but its DKMS module did not compile for the tested custom
`7.1.1-kernel-lab`. The daily kernel therefore remains
`6.12.94+deb13-amd64`; the custom kernel was removed after the failed DKMS
validation.

These are stated baseline values, not settings that scripts may change. Run
`scripts/00-check-system.sh` before each major stage to collect current,
read-only facts.

## Facts to preserve

- The current Debian kernel and its matching headers remain installed.
- Its boot entry remains available in GRUB's advanced options.
- Intel UHD Graphics 620 remains capable of rendering the desktop with `i915`.
- NVIDIA driver, DKMS, and Ollama behavior are recorded before experimentation.

Save local evidence under the ignored `logs/` directory:

```bash
./scripts/00-check-system.sh | tee logs/baseline.txt
uname -a
lspci -nnk
dkms status
nvidia-smi
```

Optional commands may be unavailable. That is not permission to install or
change anything automatically.
