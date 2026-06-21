# Current Setup

## Known baseline

| Component | Value |
| --- | --- |
| Machine | ASUS VivoBook X512FJ notebook |
| Operating system | Debian 13 |
| Current kernel | `6.12.90+deb13.1-amd64` |
| Desktop session | Wayland |
| Integrated GPU | Intel, desktop renderer |
| Dedicated GPU | NVIDIA MX230, local Ollama workloads |

These are stated baseline values, not settings that scripts may change. Run
`scripts/00-check-system.sh` before each major stage to collect current,
read-only facts.

## Facts to preserve

- The Debian kernel and its matching headers remain installed.
- Its boot entry remains available in GRUB's advanced options.
- Intel remains capable of rendering the desktop.
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

