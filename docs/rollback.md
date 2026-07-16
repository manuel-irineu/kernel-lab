# Rollback Plan

Rollback is a prerequisite, not a cleanup task.

## Before any future installation

- Confirm the Debian kernel image and matching initramfs exist in `/boot`.
- Confirm its package is installed and is not marked for removal.
- Know how to open GRUB and select **Advanced options for Debian GNU/Linux**, then
  choose the daily Debian kernel or another known-good Debian kernel.
- Keep important data backed up outside this experiment.
- Stop if the known-good entry cannot be identified.

## If the lab kernel fails

1. Reboot using the machine's normal controls.
2. Select the known-good Debian kernel explicitly in GRUB.
3. Verify the rollback with `uname -r`.
4. Preserve evidence before changing packages:

   ```bash
   journalctl -b -1 -k
   journalctl -b -1 -p warning
   ```

5. Diagnose from the working kernel. Never remove that kernel.

Intel `i915` is the current recovery graphics path; verify this rather than
assuming it. After rollback, retest `uname -r`, display output, network, and any
host-specific workloads. This repository contains no uninstall or
kernel-removal script.

## Cleaning up failed custom packages

Perform package cleanup only after booting a known-good Debian kernel. Review
package names carefully; never remove the running Debian kernel. A maintainer
script can leave a custom image half-configured (`iF`) even when its headers are
fully configured.

The commands used for the `7.1.1-kernel-lab` experiment were:

```bash
sudo dpkg --remove linux-image-7.1.1-kernel-lab linux-headers-7.1.1-kernel-lab
sudo dpkg --purge linux-image-7.1.1-kernel-lab linux-headers-7.1.1-kernel-lab
sudo update-grub
sudo dpkg --audit
dpkg -l | grep -E 'linux-image-7.1.1|linux-headers-7.1.1'
```

These are manual recovery commands, not commands executed by repository
scripts. Inspect the output after each step. Do not force module installation,
bypass external module errors, or delete generated build artifacts as part of
rollback.

After cleanup, GRUB no longer listed `7.1.1-kernel-lab`, and known-good Debian
kernels remained available.
