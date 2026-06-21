#!/usr/bin/env bash
# Read-only NVIDIA and DKMS inventory. It does not build DKMS modules or change
# the loaded module set.

set -euo pipefail

# NVIDIA utilities may not all be installed. Missing probes are reported without
# turning this inventory helper into an installer or repair tool.
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
printf '# NVIDIA/DKMS snapshot for %s\n' "$(uname -r)"
run_optional 'DKMS registrations' dkms status
run_optional 'NVIDIA report' nvidia-smi
run_optional 'NVIDIA module metadata' modinfo -k "$(uname -r)" nvidia
run_optional 'Loaded modules' lsmod
run_optional 'PCI graphics bindings' lspci -nnk
run_optional 'Secure Boot state' mokutil --sb-state
printf '\nRead-only check complete; no DKMS or module action was performed.\n'
