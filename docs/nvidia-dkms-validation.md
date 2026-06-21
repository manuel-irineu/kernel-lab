# NVIDIA DKMS Validation

The NVIDIA MX230 serves Ollama workloads. A successful Linux package build does
not prove that the proprietary NVIDIA module compiles, loads, or works.

## Risks

- The installed driver may not support Linux 7.1.1 kernel APIs.
- DKMS may fail during a future package installation.
- Secure Boot may reject an unsigned module after a successful build.
- `nvidia-smi` may work while the intended Ollama workload still fails.
- Wayland and PRIME/offload behavior require separate validation.

Before building, run `./scripts/05-check-dkms.sh` and record the driver version,
DKMS state, Secure Boot state, PCI bindings, `nvidia-smi`, and a known Ollama
workload on the working kernel.

## Acceptance gate on the lab kernel

- `uname -r` identifies the intended lab kernel.
- DKMS reports NVIDIA built and installed for that exact release.
- `modinfo -k "$(uname -r)" nvidia` succeeds.
- Expected NVIDIA modules load without kernel errors.
- `nvidia-smi` detects the MX230.
- Intel still renders the Wayland desktop.
- A small reproducible Ollama inference uses the NVIDIA GPU.

If any gate fails, preserve logs and boot the known-good Debian kernel. Do not
remove the fallback and do not blindly force a DKMS build.

