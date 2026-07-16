#!/usr/bin/env bash
# Verify the detached kernel.org signature against the uncompressed tar stream.
# This is read-only. It requires the signer key to already exist in the user's
# GPG keyring; the script does not import or trust keys automatically.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kernel-lab-env.sh"

readonly SIGNER_FINGERPRINT='647F28654894E3BD457199BE38DBBDC86092693E'
readonly SIGNER_FINGERPRINT_DISPLAY='647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E'

if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no signature verification was run.

Tarball: ${TARBALL}
Signature: ${SIGNATURE}
Expected signer fingerprint:
${SIGNER_FINGERPRINT_DISPLAY}

Execution will run:
xz -cd <tarball> | gpg --verify <signature> -

The signer key must already be present in the local GPG keyring. This script
does not import keys, change trust settings, extract source, or build anything.

If the key is missing, import it manually and verify the fingerprint:
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${SIGNER_FINGERPRINT}
gpg --fingerprint ${SIGNER_FINGERPRINT}
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
printf 'Expected signer fingerprint: %s\n' "$SIGNER_FINGERPRINT_DISPLAY"
