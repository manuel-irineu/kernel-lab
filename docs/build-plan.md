# Build Plan

Target: upstream Linux as Debian `.deb` packages, installed alongside, not
instead of, the working Debian kernel.

Default script target: `7.1.3-kernel-lab`.

## Current progress on the current host

- The current host runs Debian 13 with a Debian-packaged 6.12 series kernel.
- Graphics are Intel-only and use the `i915` driver.
- `dkms` and `nvidia-smi` are not installed/detected.
- The previous NVIDIA DKMS blocker from an earlier laptop experiment is not a
  required gate on this host.
- Scripts now use repository-local ignored paths by default:

  ```text
  workspace/downloads/                 tarball and signature
  workspace/build/src/linux-<version>/ extracted source
  workspace/build/out/linux-<version>/ out-of-tree build data
  logs/                                build and boot evidence
  ```

## Previous NVIDIA DKMS result

- The Linux 7.1.1 tarball was downloaded to
  an external download directory.
- The detached signature was verified successfully with Greg Kroah-Hartman's
  signing key. The verified fingerprint is
  `647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E`.
- The source was extracted to
  a local build source directory.
- The out-of-tree build directory is
  a local out-of-tree build directory.
- The running Debian kernel configuration was copied from
  `/boot/config-$(uname -r)`.
- `olddefconfig` completed successfully. It emitted non-fatal warnings that
  should remain available in the build log for review.
- The configured final kernel release string is `7.1.1-kernel-lab`.
- `make bindeb-pkg` completed successfully and generated:

  ```text
  linux-image-7.1.1-kernel-lab_7.1.1-2_amd64.deb
  linux-headers-7.1.1-kernel-lab_7.1.1-2_amd64.deb
  linux-libc-dev_7.1.1-2_amd64.deb
  linux-image-7.1.1-kernel-lab-dbg_7.1.1-2_amd64.deb
  ```

- The image and headers packages were installed for testing. Installation
  created `/boot/vmlinuz-7.1.1-kernel-lab`, generated
  `/boot/initrd.img-7.1.1-kernel-lab`, and added a GRUB entry.
- The image post-installation phase failed because
  `nvidia-current/550.163.01` could not build for `7.1.1-kernel-lab`. The
  headers were configured, but the image package was left half-configured
  (`iF`).
- The custom kernel was removed. GRUB no longer lists it, and the machine was
  returned to a known-good Debian daily kernel.

## Stages

1. Run the read-only inventory and save its output.
2. Review the rollback procedure and identify the working GRUB entry.
3. Preview `scripts/01-install-build-deps.sh`; manually review its printed
   command. The script never runs it.
4. Preview or run `scripts/10-build-kernel-packages.sh`. Preview is the
   default; `--execute` downloads, verifies the detached GPG signature, prepares
   config, and builds packages without root.
5. Signature verification requires Greg Kroah-Hartman's kernel.org signer key
   to already exist in the user's GPG keyring. The scripts do not import or
   trust keys automatically. The expected fingerprint is:

   ```text
   647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E
   ```
6. The out-of-tree configuration is prepared from
   `/boot/config-$(uname -r)`, and `olddefconfig` completed with non-fatal
   warnings. Review the resulting configuration before building.
7. Build packages as an unprivileged user and save the complete log.
8. Verify host-specific driver compatibility for the exact kernel. On the
   current Intel-only host, this means at minimum `i915`, storage, network, and
   boot logs; there is no NVIDIA DKMS gate.
9. In a separate manual step, inspect and install only the new image and needed
   headers. This repository intentionally does not automate installation.
10. Boot deliberately, run the checklist, and roll back on any material failure.

For this experiment, stage 6 succeeded. Stage 7 failed before the custom kernel
was booted, so stages 8 and 9 ended in package cleanup and rollback rather than
daily-kernel acceptance.

## Result and lesson learned

The kernel compilation and Debian package generation were successful. The
blocker was the out-of-tree NVIDIA DKMS module, not the kernel build process.
Linux `7.1.1-kernel-lab` is unsuitable as the daily kernel on that host
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

Current local paths use repository-local ignored directories:

```text
workspace/downloads/                 tarball and signature
workspace/build/src/linux-<version>/ extracted source
workspace/build/out/linux-<version>/ out-of-tree build data
logs/                                build and boot evidence
```
