#!/usr/bin/env bash
# Capture read-only evidence after boot. Suspend/resume and Ollama inference stay
# as deliberate manual tests in the checklist.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LOG_DIR="${REPO_ROOT}/logs"
readonly EXPECTED_PREFIX='7.1.1'

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
    "$REPO_ROOT/scripts/05-check-dkms.sh"
    printf '\n## Kernel warnings for this boot\n'
    journalctl --no-pager -b -k -p warning 2>&1 || true
} | tee "$output"

printf '\nSaved evidence to %s\n' "$output"
printf 'Complete docs/test-checklist.md manually; nothing was changed.\n'
