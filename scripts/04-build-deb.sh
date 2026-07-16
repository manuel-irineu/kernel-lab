#!/usr/bin/env bash
# Build Debian packages without root. This never installs packages and defaults
# to a preview because a kernel build is expensive and writes substantial data.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kernel-lab-env.sh"
readonly JOBS="${JOBS:-$(nproc)}"
export KBUILD_BUILD_USER="${KBUILD_BUILD_USER:-kernel-lab}"
export KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST:-local-builder}"
export DEBFULLNAME="${DEBFULLNAME:-Kernel Lab}"
export DEBEMAIL="${DEBEMAIL:-kernel-lab@example.invalid}"

# Require explicit opt-in before starting the resource-intensive build.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no build was started.
Source: ${SOURCE_DIR}
Build: ${BUILD_DIR}
Log directory: ${LOG_DIR}
Parallel jobs: ${JOBS}
Build user: ${KBUILD_BUILD_USER}
Build host: ${KBUILD_BUILD_HOST}
Debian maintainer: ${DEBFULLNAME} <${DEBEMAIL}>

Execution runs make bindeb-pkg as an unprivileged user and captures its log.
It does not run dpkg, initramfs, GRUB, sudo, or reboot commands.

Generated .deb files are expected near:
${BUILD_PARENT}
or the parent directory used by the kernel build system.
EOF
    exit 0
fi

# Root is unnecessary for package creation and would leave unsafe ownership.
[[ $EUID -ne 0 ]] || {
    printf 'Refusing to build as root.\n' >&2
    exit 1
}

[[ -d $SOURCE_DIR ]] || {
    printf 'Missing source directory: %s\n' "$SOURCE_DIR" >&2
    exit 1
}

[[ -f $BUILD_DIR/.config ]] || {
    printf 'Missing %s/.config\n' "$BUILD_DIR" >&2
    exit 1
}

mkdir -p "$LOG_DIR"

readonly REL_SOURCE_DIR="$(realpath --relative-to="$REPO_ROOT" "$SOURCE_DIR")"
readonly REL_BUILD_DIR_FROM_SOURCE="$(realpath --relative-to="$SOURCE_DIR" "$BUILD_DIR")"
readonly BUILD_LOG="$LOG_DIR/build-linux-${KERNEL_VERSION}.log"

printf 'Build started; detailed output is being written to %s\n' "$BUILD_LOG"
printf 'This can take a long time for Debian-derived configurations.\n'

set +e
(
    cd "$REPO_ROOT"
    make -C "$REL_SOURCE_DIR" O="$REL_BUILD_DIR_FROM_SOURCE" -j"$JOBS" bindeb-pkg
) >"$BUILD_LOG" 2>&1
status=$?
set -e

(( status == 0 )) || {
    printf 'Build failed with status %d.\n' "$status" >&2
    printf 'Last log lines:\n' >&2
    tail -n 40 "$BUILD_LOG" >&2 || true
    printf 'Review log: %s\n' "$BUILD_LOG" >&2
    exit "$status"
}

printf 'Build completed; inspect generated .deb files. None were installed.\n'
printf 'Build log: %s\n' "$BUILD_LOG"
