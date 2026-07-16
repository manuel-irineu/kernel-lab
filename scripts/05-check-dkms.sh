#!/usr/bin/env bash
# Read-only external module inventory. It does not build DKMS modules or change
# the loaded module set. On hosts without external modules, missing DKMS tools
# are expected and reported without failing the script.

set -euo pipefail

# Optional utilities may not all be installed. Missing probes are reported
# without turning this inventory helper into an installer or repair tool.
run_optional() {
    local description=$1
    shift
    printf '\n## %s\n' "$description"
    if command -v "$1" >/dev/null 2>&1; then
        "$@" || printf 'Command failed (status %s): %s\n' "$?" "$*"
    else
        printf 'Not available: %s\n' "$1"
    fi
}

# These commands query current state only; none load, unload, build, or sign.
printf '# External module snapshot for %s\n' "$(uname -r)"
run_optional 'DKMS registrations' dkms status
run_optional 'Loaded modules' lsmod
run_optional 'PCI device bindings' lspci -nnk
run_optional 'Secure Boot state' mokutil --sb-state
printf '\nRead-only check complete; no DKMS or module action was performed.\n'
