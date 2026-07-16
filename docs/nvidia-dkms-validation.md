# Historical NVIDIA DKMS Validation

This page records the previous NVIDIA DKMS failure. It is not a mandatory
gate for the current Intel-only host, where no NVIDIA GPU, `nvidia-smi`, or
`dkms` command is present.

On a host with NVIDIA hardware, a successful Linux package build does not prove
that the proprietary NVIDIA module compiles, loads, or works.

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
- `nvidia-smi` detects the NVIDIA GPU.
- Intel still renders the Wayland desktop.
- A small reproducible Ollama inference uses the NVIDIA GPU.

If any gate fails, preserve logs and boot the known-good Debian kernel. Do not
remove the fallback and do not blindly force a DKMS build.

## Linux 7.1.1 experiment failure

The `linux-image-7.1.1-kernel-lab` and
`linux-headers-7.1.1-kernel-lab` packages were installed for testing. During
the image package post-installation phase, DKMS attempted to build
`nvidia-current/550.163.01` for `7.1.1-kernel-lab` and failed. The detailed
build log was written to:

```text
/var/lib/dkms/nvidia-current/550.163.01/build/make.log
```

The errors fell into three kernel-API compatibility categories:

- Virtual memory API change:
  `struct vm_area_struct has no member named '__vm_flags'; did you mean 'vm_flags'?`
- Interrupt-context API change:
  `implicit declaration of function 'in_irq'`
- DMA mapping API change:
  `const struct dma_map_ops has no member named 'map_resource'`

The headers package configured successfully, but the image package remained
half-configured (`iF`) because its post-installation hook could not complete.
This result demonstrates that the Linux kernel and Debian packages were valid
enough to build, while NVIDIA 550.163.01 was incompatible with the target
kernel APIs.

The custom kernel was removed without forcing NVIDIA installation or ignoring
the DKMS failure. NVIDIA `550.163.01` remained usable with the known-good Debian
6.12 daily kernels on that host.
