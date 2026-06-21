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
