# Build Plan

Target: upstream Linux `7.1.1` as Debian `.deb` packages, installed alongside,
not instead of, the working Debian kernel.

## Current progress

- The Linux 7.1.1 tarball was downloaded to
  `/home/manuel/Downloads/kernel`.
- The detached signature was verified successfully with Greg Kroah-Hartman's
  signing key. The verified fingerprint is
  `647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E`.
- The source was extracted to
  `/home/manuel/build/kernel/src/linux-7.1.1`.
- The out-of-tree build directory is
  `/home/manuel/build/kernel/build/linux-7.1.1`.
- The running Debian kernel configuration was copied from
  `/boot/config-$(uname -r)`.
- `olddefconfig` completed successfully. It emitted non-fatal warnings that
  should remain available in the build log for review.
- The configured final kernel release string is `7.1.1-kernel-lab`.
- `make bindeb-pkg` completed successfully and generated:

  ```text
  /home/manuel/build/kernel/build/linux-image-7.1.1-kernel-lab_7.1.1-2_amd64.deb
  /home/manuel/build/kernel/build/linux-headers-7.1.1-kernel-lab_7.1.1-2_amd64.deb
  /home/manuel/build/kernel/build/linux-libc-dev_7.1.1-2_amd64.deb
  /home/manuel/build/kernel/build/linux-image-7.1.1-kernel-lab-dbg_7.1.1-2_amd64.deb
  ```

- The image and headers packages were installed for testing. Installation
  created `/boot/vmlinuz-7.1.1-kernel-lab`, generated
  `/boot/initrd.img-7.1.1-kernel-lab`, and added a GRUB entry.
- The image post-installation phase failed because
  `nvidia-current/550.163.01` could not build for `7.1.1-kernel-lab`. The
  headers were configured, but the image package was left half-configured
  (`iF`).
- The custom kernel was removed. GRUB no longer lists it, and the notebook is
  back on the Debian `6.12.94+deb13-amd64` daily kernel.

## Stages

1. Run the read-only inventory and save its output.
2. Review the rollback procedure and identify the working GRUB entry.
3. Preview `scripts/01-install-build-deps.sh`; manually review its printed
   command. The script never runs it.
4. Source acquisition and detached-signature verification are complete.
5. The out-of-tree configuration was prepared from
   `/boot/config-$(uname -r)`, and `olddefconfig` completed with non-fatal
   warnings. Review the resulting configuration before building.
6. Build packages as an unprivileged user and save the complete log.
7. Verify driver compatibility and NVIDIA DKMS results for the exact kernel.
8. In a separate manual step, inspect and install only the new image and needed
   headers. This repository intentionally does not automate installation.
9. Boot deliberately, run the checklist, and roll back on any material failure.

For this experiment, stage 6 succeeded. Stage 7 failed before the custom kernel
was booted, so stages 8 and 9 ended in package cleanup and rollback rather than
daily-kernel acceptance.

## Result and lesson learned

The kernel compilation and Debian package generation were successful. The
blocker was the out-of-tree NVIDIA DKMS module, not the kernel build process.
Linux `7.1.1-kernel-lab` is unsuitable as the daily kernel on this notebook
while Debian NVIDIA `550.163.01` is required.

A newer upstream kernel can compile and package successfully while remaining
unusable on a daily system because required out-of-tree DKMS modules—especially
NVIDIA—may not support its APIs. DKMS compatibility must be proven for the exact
kernel release before rebooting into it.

## Principles

- Never use `make install` or `make modules_install` on the host.
- Use unique version strings so packages do not collide with Debian packages.
- Keep source and output under ignored repository paths.
- Inspect generated packages before any future installation.
- Never remove the known-good Debian kernel.

Current local paths:

```text
/home/manuel/Downloads/kernel/                    tarball and signature
/home/manuel/build/kernel/src/linux-7.1.1/        extracted source
/home/manuel/build/kernel/build/linux-7.1.1/      out-of-tree build data
```
