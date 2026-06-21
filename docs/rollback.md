# Rollback Plan

Rollback is a prerequisite, not a cleanup task.

## Before any future installation

- Confirm the Debian kernel image and matching initramfs exist in `/boot`.
- Confirm its package is installed and is not marked for removal.
- Know how to open GRUB and select **Advanced options for Debian GNU/Linux**, then
  choose `6.12.90+deb13.1-amd64`.
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

A missing NVIDIA module should leave Intel as the primary recovery graphics
path, but verify this rather than assuming it. After rollback, retest
`nvidia-smi`, `dkms status`, and Ollama. This repository contains no uninstall
or kernel-removal script.

