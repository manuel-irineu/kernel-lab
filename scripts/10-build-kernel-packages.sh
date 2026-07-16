#!/usr/bin/env bash
# Orchestrate the unprivileged package build path. This never installs packages
# and never runs sudo. Preview is the default; --execute delegates to the staged
# helpers that perform download, config preparation, and bindeb-pkg.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/kernel-lab-env.sh"

if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no download, extraction, or build was started.

Kernel version: ${KERNEL_VERSION}
Local suffix: ${LOCAL_VERSION}
Download dir: ${DOWNLOAD_DIR}
Source dir: ${SOURCE_DIR}
Build dir: ${BUILD_DIR}
Log dir: ${LOG_DIR}

Execution will run:
1. scripts/02-download-kernel.sh --execute
2. scripts/02-verify-kernel-signature.sh --execute
3. scripts/03-prepare-config.sh --execute
4. scripts/04-build-deb.sh --execute

It will not run sudo, apt, dpkg, initramfs, GRUB, DKMS, or reboot commands.
Install generated packages manually only after reviewing them and the rollback
plan.
EOF
    exit 0
fi

"${SCRIPT_DIR}/02-download-kernel.sh" --execute
"${SCRIPT_DIR}/02-verify-kernel-signature.sh" --execute
"${SCRIPT_DIR}/03-prepare-config.sh" --execute
"${SCRIPT_DIR}/04-build-deb.sh" --execute

printf 'Kernel package build workflow completed. No packages were installed.\n'
