#!/usr/bin/env bash
# Build Debian packages without root. This never installs packages and defaults
# to a preview because a kernel build is expensive and writes substantial data.

set -euo pipefail

readonly VERSION='7.1.1'
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SOURCE_DIR="${REPO_ROOT}/workspace/src/linux-${VERSION}"
readonly BUILD_DIR="${REPO_ROOT}/workspace/build/linux-${VERSION}"
readonly LOG_DIR="${REPO_ROOT}/logs"
readonly JOBS="${JOBS:-$(nproc)}"

# Require explicit opt-in before starting the resource-intensive build.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no build was started.
Source: ${SOURCE_DIR}
Build: ${BUILD_DIR}
Parallel jobs: ${JOBS}

Execution runs make bindeb-pkg as an unprivileged user and captures its log. It
does not run dpkg, DKMS, initramfs, GRUB, sudo, or reboot commands.
EOF
    exit 0
fi

# Root is unnecessary for package creation and would leave unsafe ownership.
[[ $EUID -ne 0 ]] || { printf 'Refusing to build as root.\n' >&2; exit 1; }
[[ -f $BUILD_DIR/.config ]] || { printf 'Missing %s/.config\n' "$BUILD_DIR" >&2; exit 1; }
mkdir -p "$LOG_DIR"

# PIPESTATUS preserves make's result rather than hiding it behind tee.
set +e
make -C "$SOURCE_DIR" O="$BUILD_DIR" -j"$JOBS" bindeb-pkg 2>&1 \
    | tee "$LOG_DIR/build-linux-${VERSION}.log"
status=${PIPESTATUS[0]}
set -e
(( status == 0 )) || { printf 'Build failed with status %d.\n' "$status" >&2; exit "$status"; }
printf 'Build completed; inspect generated .deb files. None were installed.\n'
