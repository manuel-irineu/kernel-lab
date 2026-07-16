#!/usr/bin/env bash
# Preview or explicitly download Linux from kernel.org. --no-clobber preserves
# an existing copy for explicit inspection instead of silently replacing it.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kernel-lab-env.sh"

# Safe default: an absent or unknown argument only describes the future action.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; nothing was downloaded.
Destination: ${DOWNLOAD_DIR}
Files: linux-${KERNEL_VERSION}.tar.xz and linux-${KERNEL_VERSION}.tar.sign
Base URL: ${BASE_URL}

After reviewing the script, use --execute in a later authorized step. Verify
the detached kernel.org signature before extracting the source.
EOF
    exit 0
fi

# Do not attempt package installation when the downloader is unavailable.
command -v wget >/dev/null 2>&1 || {
    printf 'Error: wget is required; this script will not install it.\n' >&2
    exit 1
}
# Both downloaded files live in the ignored workspace; --no-clobber preserves
# an existing copy for explicit inspection instead of silently replacing it.
mkdir -p "$DOWNLOAD_DIR"
wget --https-only --no-clobber --directory-prefix="$DOWNLOAD_DIR" \
    "${BASE_URL}/linux-${KERNEL_VERSION}.tar.xz" \
    "${BASE_URL}/linux-${KERNEL_VERSION}.tar.sign"
printf 'Downloaded only; no source was extracted. Verify the signature next.\n'
