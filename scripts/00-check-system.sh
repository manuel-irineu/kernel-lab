#!/usr/bin/env bash
# Collect a read-only host snapshot. Missing optional tools do not abort the
# inventory, which makes this useful before build dependencies are present.

set -euo pipefail

# Print a heading, check availability, and keep collecting if an optional probe
# is missing or returns a non-zero status. Every probe below is read-only.
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

# Avoid writing a log here: the caller chooses whether and where to save output.
printf '# Kernel lab system snapshot\n'
printf 'Captured: '
date --iso-8601=seconds
run_optional 'Kernel release' uname -a
run_optional 'Debian release' cat /etc/os-release
run_optional 'Boot command line' cat /proc/cmdline
run_optional 'PCI devices and drivers' lspci -nnk
run_optional 'Session type' printenv XDG_SESSION_TYPE
run_optional 'Loaded modules' lsmod
printf '\n## Graphics policy check\n'
if command -v lsmod >/dev/null 2>&1 && lsmod | grep -Eq '^i915[[:space:]]'; then
    printf 'OK: i915 is loaded for Intel graphics.\n'
else
    printf 'WARN: i915 is not loaded; verify Intel graphics before kernel testing.\n'
fi
if command -v lsmod >/dev/null 2>&1 && lsmod | grep -Eq '^nvidia(_|[[:space:]])'; then
    printf 'WARN: proprietary NVIDIA module is loaded; this host baseline expects none.\n'
else
    printf 'OK: no proprietary NVIDIA kernel module is loaded.\n'
fi
run_optional 'Disk usage' df -h
run_optional 'Memory' free -h
printf '\nNo settings were changed. Save output under logs/ if needed.\n'
