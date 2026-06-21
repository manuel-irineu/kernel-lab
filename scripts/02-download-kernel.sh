#!/usr/bin/env bash
# Preview or explicitly download Linux 7.1.1 from kernel.org. Do not use
# Both downloaded files live outside the Git repository. --no-clobber preserves
# an existing copy for explicit inspection instead of silently replacing it.
set -euo pipefail

readonly VERSION='7.1.1'
readonly BASE_URL='https://cdn.kernel.org/pub/linux/kernel/v7.x'
readonly DOWNLOAD_DIR="/home/manuel/Downloads/kernel"

# Safe default: an absent or unknown argument only describes the future action.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; nothing was downloaded.
Destination: ${DOWNLOAD_DIR}
Files: linux-${VERSION}.tar.xz and linux-${VERSION}.tar.sign

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
    "${BASE_URL}/linux-${VERSION}.tar.xz" \
    "${BASE_URL}/linux-${VERSION}.tar.sign"
printf 'Downloaded only; no source was extracted. Verify the signature next.\n'
