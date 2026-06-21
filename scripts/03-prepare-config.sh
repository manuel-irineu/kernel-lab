#!/usr/bin/env bash
# Prepare an out-of-tree config based on the running Debian kernel.
# Preview is the default; --execute performs only unprivileged writes under
# /home/manuel/build/kernel.

set -euo pipefail

readonly VERSION='7.1.1'
readonly LOCAL_VERSION='-kernel-lab'
readonly DOWNLOAD_DIR='/home/manuel/Downloads/kernel'
readonly BUILD_ROOT='/home/manuel/build/kernel'
readonly SOURCE_PARENT="${BUILD_ROOT}/src"
readonly SOURCE_DIR="${SOURCE_PARENT}/linux-${VERSION}"
readonly BUILD_DIR="${BUILD_ROOT}/build/linux-${VERSION}"
readonly TARBALL="${DOWNLOAD_DIR}/linux-${VERSION}.tar.xz"
readonly RUNNING_CONFIG="/boot/config-$(uname -r)"

# Configuration writes require an explicit opt-in, even though they stay local.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no configuration was created.

Tarball: ${TARBALL}
Source: ${SOURCE_DIR}
Build: ${BUILD_DIR}
Baseline: ${RUNNING_CONFIG}
Local suffix: ${LOCAL_VERSION}

Execution will:
- create ${SOURCE_PARENT} if needed;
- extract linux-${VERSION}.tar.xz if ${SOURCE_DIR} does not exist;
- create ${BUILD_DIR};
- copy the running Debian kernel config to ${BUILD_DIR}/.config;
- set CONFIG_LOCALVERSION=${LOCAL_VERSION};
- disable CONFIG_LOCALVERSION_AUTO;
- clear Debian-specific trusted/revocation key paths;
- run olddefconfig.

No sudo command will be executed.
No GRUB, initramfs, DKMS, or installed kernel will be modified.
The resulting .config still requires manual review.
EOF
    exit 0
fi

# Validate every input before creating or modifying build output.
[[ -r $TARBALL ]] || {
    printf 'Missing tarball: %s\n' "$TARBALL" >&2
    exit 1
}

[[ -r $RUNNING_CONFIG ]] || {
    printf 'Unreadable config: %s\n' "$RUNNING_CONFIG" >&2
    exit 1
}

mkdir -p "$SOURCE_PARENT"

if [[ ! -d $SOURCE_DIR ]]; then
    printf 'Extracting %s into %s\n' "$TARBALL" "$SOURCE_PARENT"
    tar -xf "$TARBALL" -C "$SOURCE_PARENT"
else
    printf 'Source already exists: %s\n' "$SOURCE_DIR"
fi

[[ -d $SOURCE_DIR ]] || {
    printf 'Missing source after extraction: %s\n' "$SOURCE_DIR" >&2
    exit 1
}

[[ -x $SOURCE_DIR/scripts/config ]] || {
    printf 'Missing executable scripts/config in source tree.\n' >&2
    exit 1
}

mkdir -p "$BUILD_DIR"

# Refuse to overwrite an existing configuration so manual tuning is preserved.
cp --no-clobber "$RUNNING_CONFIG" "$BUILD_DIR/.config"

"$SOURCE_DIR/scripts/config" --file "$BUILD_DIR/.config" \
    --set-str LOCALVERSION "$LOCAL_VERSION" \
    --disable LOCALVERSION_AUTO \
    --set-str SYSTEM_TRUSTED_KEYS "" \
    --set-str SYSTEM_REVOCATION_KEYS ""

make -C "$SOURCE_DIR" O="$BUILD_DIR" olddefconfig

printf 'Prepared %s/.config; review it before building.\n' "$BUILD_DIR"
