#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/kernel-lab-env.sh
source "$SCRIPT_DIR/kernel-lab-env.sh"

OUT_DIR="$BUILD_PARENT"

failures=0

latest_file() {
  local files=("$@")

  if [[ "${#files[@]}" -eq 0 ]]; then
    return 1
  fi

  printf '%s\n' "${files[@]}" | sort -V | tail -n 1
}

require_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "Missing expected artifact: $file" >&2
    failures=$((failures + 1))
    return 1
  fi

  return 0
}

shopt -s nullglob
IMAGE_CANDIDATES=("$OUT_DIR"/linux-image-"${KERNEL_VERSION}${LOCAL_VERSION}"_"${KERNEL_VERSION}"-*_amd64.deb)
if ! IMAGE_PACKAGE="$(latest_file "${IMAGE_CANDIDATES[@]}")"; then
  echo "Missing expected artifact: linux-image package for $KERNEL_VERSION$LOCAL_VERSION" >&2
  exit 1
fi
IMAGE_BASENAME="$(basename "$IMAGE_PACKAGE")"
PACKAGE_REVISION="${IMAGE_BASENAME#linux-image-${KERNEL_VERSION}${LOCAL_VERSION}_}"
PACKAGE_REVISION="${PACKAGE_REVISION%_amd64.deb}"

HEADERS_PACKAGE="$OUT_DIR/linux-headers-${KERNEL_VERSION}${LOCAL_VERSION}_${PACKAGE_REVISION}_amd64.deb"
CHANGES_FILE="$OUT_DIR/linux-upstream_${PACKAGE_REVISION}_amd64.changes"
BUILDINFO_FILE="$OUT_DIR/linux-upstream_${PACKAGE_REVISION}_amd64.buildinfo"
shopt -u nullglob

print_package_summary() {
  local package="$1"

  require_file "$package" || return 0

  echo
  echo "Package: $(basename "$package")"
  dpkg-deb --field "$package" Package Version Architecture Maintainer
}

check_private_metadata() {
  local file="$1"

  require_file "$file" || return 0

  echo
  echo "Metadata scan: $(basename "$file")"

  if grep -Eiq 'manuel|pchome|/home/manuel' "$file"; then
    echo "FAIL: possible personal metadata found in $(basename "$file")" >&2
    grep -Ein 'manuel|pchome|/home/manuel' "$file" >&2 || true
    failures=$((failures + 1))
  else
    echo "OK: no known personal metadata markers found"
  fi
}

check_nvidia_modules() {
  require_file "$IMAGE_PACKAGE" || return 0

  echo
  echo "NVIDIA/Nouveau module scan: $(basename "$IMAGE_PACKAGE")"

  local matches
  matches="$(dpkg-deb --contents "$IMAGE_PACKAGE" | grep -Ei '/(nvidia|nouveau|forcedeth|typec_nvidia)[^/]*\.ko(\.xz)?$' || true)"

  if [[ -n "$matches" ]]; then
    echo "FAIL: NVIDIA/Nouveau-related modules found" >&2
    echo "$matches" >&2
    failures=$((failures + 1))
  else
    echo "OK: no NVIDIA/Nouveau-related modules found"
  fi
}

echo "Inspecting generated kernel packages"
echo "Kernel version: $KERNEL_VERSION"
echo "Local version: $LOCAL_VERSION"
echo "Package revision: $PACKAGE_REVISION"
echo "Output directory: $OUT_DIR"

print_package_summary "$IMAGE_PACKAGE"
print_package_summary "$HEADERS_PACKAGE"

check_private_metadata "$CHANGES_FILE"
check_private_metadata "$BUILDINFO_FILE"
check_nvidia_modules

echo
if [[ "$failures" -gt 0 ]]; then
  echo "Inspection failed with $failures issue(s)." >&2
  exit 1
fi

echo "Inspection completed successfully."
