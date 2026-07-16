#!/usr/bin/env bash
# Verify the detached kernel.org signature against the uncompressed tar stream.
# This is read-only. It requires the signer key to already exist in the user's
# GPG keyring; the script does not import or trust keys automatically.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kernel-lab-env.sh"

if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no signature verification was run.

Tarball: ${TARBALL}
Signature: ${SIGNATURE}

Execution will run:
xz -cd <tarball> | gpg --verify <signature> -

The signer key must already be present in the local GPG keyring. This script
does not import keys, change trust settings, extract source, or build anything.
EOF
    exit 0
fi

command -v xz >/dev/null 2>&1 || {
    printf 'Error: xz is required; this script will not install it.\n' >&2
    exit 1
}

command -v gpg >/dev/null 2>&1 || {
    printf 'Error: gpg is required; this script will not install it.\n' >&2
    exit 1
}

[[ -r $TARBALL ]] || {
    printf 'Missing tarball: %s\n' "$TARBALL" >&2
    exit 1
}

[[ -r $SIGNATURE ]] || {
    printf 'Missing signature: %s\n' "$SIGNATURE" >&2
    exit 1
}

xz -cd "$TARBALL" | gpg --verify "$SIGNATURE" -
printf 'Signature verification completed successfully.\n'
