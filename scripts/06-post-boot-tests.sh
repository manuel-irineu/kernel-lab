#!/usr/bin/env bash
# Capture read-only evidence after boot. Suspend/resume and Ollama inference stay
# as deliberate manual tests in the checklist.

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kernel-lab-env.sh"
readonly EXPECTED_PREFIX="${EXPECTED_PREFIX:-${KERNEL_VERSION}}"

# Warn instead of aborting because collecting evidence on the rollback kernel is
# also useful when diagnosing a failed lab-kernel boot.
if [[ $(uname -r) != "${EXPECTED_PREFIX}"* ]]; then
    printf 'Warning: %s is not the expected lab kernel prefix %s.\n' \
        "$(uname -r)" "$EXPECTED_PREFIX" >&2
fi

mkdir -p "$LOG_DIR"
timestamp=$(date +%Y%m%d-%H%M%S)
output="${LOG_DIR}/post-boot-${timestamp}.txt"

# Combine existing read-only inventories with warnings from the current boot.
# journalctl failures are captured in the report but do not discard other data.
{
    printf '# Post-boot evidence\n'
    "$REPO_ROOT/scripts/00-check-system.sh"
    printf '\n## Graphics driver gate\n'
    if lsmod | grep -Eq '^i915[[:space:]]'; then
        printf 'OK: i915 is loaded for Intel graphics.\n'
    else
        printf 'WARN: i915 is not loaded; verify Intel graphics before daily use.\n'
    fi
    if lsmod | grep -Eq '^nvidia(_|[[:space:]])'; then
        printf 'WARN: proprietary NVIDIA module is loaded; this host baseline expects none.\n'
    else
        printf 'OK: no proprietary NVIDIA kernel module is loaded.\n'
    fi
    printf '\n## Kernel warnings for this boot\n'
    journalctl --no-pager -b -k -p warning 2>&1 || true
} | tee "$output"

printf '\nSaved evidence to %s\n' "$output"
printf 'Complete docs/test-checklist.md manually; nothing was changed.\n'
