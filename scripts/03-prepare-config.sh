#!/usr/bin/env bash
# Prepare an out-of-tree config based on the running Debian kernel. Preview is
# the default; --execute performs only unprivileged repository workspace writes.

set -euo pipefail

readonly VERSION='7.1.1'
readonly LOCAL_VERSION='-kernel-lab'
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SOURCE_DIR="${REPO_ROOT}/workspace/src/linux-${VERSION}"
readonly BUILD_DIR="${REPO_ROOT}/workspace/build/linux-${VERSION}"
readonly RUNNING_CONFIG="/boot/config-$(uname -r)"

# Configuration writes require an explicit opt-in, even though they stay local.
if [[ ${1:-} != '--execute' ]]; then
    cat <<EOF
Preview only; no configuration was created.
Source: ${SOURCE_DIR}
Build: ${BUILD_DIR}
Baseline: ${RUNNING_CONFIG}
Local suffix: ${LOCAL_VERSION}

Execution copies the baseline config, assigns a unique suffix, and runs
olddefconfig. The resulting .config still requires manual review.
EOF
    exit 0
fi

# Validate every input before creating the output directory.
[[ -d $SOURCE_DIR ]] || { printf 'Missing source: %s\n' "$SOURCE_DIR" >&2; exit 1; }
[[ -r $RUNNING_CONFIG ]] || { printf 'Unreadable config: %s\n' "$RUNNING_CONFIG" >&2; exit 1; }
[[ -x $SOURCE_DIR/scripts/config ]] || { printf 'Missing scripts/config.\n' >&2; exit 1; }
mkdir -p "$BUILD_DIR"
# Refuse to overwrite an existing configuration so manual tuning is preserved.
cp --no-clobber "$RUNNING_CONFIG" "$BUILD_DIR/.config"
"$SOURCE_DIR/scripts/config" --file "$BUILD_DIR/.config" \
    --set-str LOCALVERSION "$LOCAL_VERSION" --disable LOCALVERSION_AUTO
make -C "$SOURCE_DIR" O="$BUILD_DIR" olddefconfig
printf 'Prepared %s/.config; review it before building.\n' "$BUILD_DIR"
