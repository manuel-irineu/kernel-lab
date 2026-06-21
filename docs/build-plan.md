# Build Plan

Target: upstream Linux `7.1.1` as Debian `.deb` packages, installed alongside,
not instead of, the working Debian kernel.

## Stages

1. Run the read-only inventory and save its output.
2. Review the rollback procedure and identify the working GRUB entry.
3. Preview `scripts/01-install-build-deps.sh`; manually review its printed
   command. The script never runs it.
4. Preview `scripts/02-download-kernel.sh`. Source acquisition is for a later,
   explicitly authorized step; do not download it during initial setup.
5. Start from `/boot/config-$(uname -r)`, choose a unique local version, run
   `olddefconfig`, and review the resulting configuration.
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

Expected local paths:

```text
workspace/downloads/        tarball and signatures
workspace/src/linux-7.1.1/  extracted source
workspace/build/linux-7.1.1/ out-of-tree build data
artifacts/                   copied packages and checksums
logs/                        command and test output
```

