#!/usr/bin/env bash
# Shared defaults for kernel-lab helpers. Callers may override these variables
# in the environment before invoking a script.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly KERNEL_VERSION="${KERNEL_VERSION:-7.1.1}"
readonly LOCAL_VERSION="${LOCAL_VERSION:--kernel-lab}"
readonly KERNEL_MAJOR="${KERNEL_VERSION%%.*}"
readonly KERNEL_SERIES="${KERNEL_SERIES:-v${KERNEL_MAJOR}.x}"
readonly BASE_URL="${BASE_URL:-https://cdn.kernel.org/pub/linux/kernel/${KERNEL_SERIES}}"
readonly WORKSPACE_DIR="${WORKSPACE_DIR:-${REPO_ROOT}/workspace}"
readonly DOWNLOAD_DIR="${DOWNLOAD_DIR:-${WORKSPACE_DIR}/downloads}"
readonly BUILD_ROOT="${BUILD_ROOT:-${WORKSPACE_DIR}/build}"
readonly SOURCE_PARENT="${SOURCE_PARENT:-${BUILD_ROOT}/src}"
readonly SOURCE_DIR="${SOURCE_DIR:-${SOURCE_PARENT}/linux-${KERNEL_VERSION}}"
readonly BUILD_PARENT="${BUILD_PARENT:-${BUILD_ROOT}/out}"
readonly BUILD_DIR="${BUILD_DIR:-${BUILD_PARENT}/linux-${KERNEL_VERSION}}"
readonly LOG_DIR="${LOG_DIR:-${REPO_ROOT}/logs}"
readonly TARBALL="${TARBALL:-${DOWNLOAD_DIR}/linux-${KERNEL_VERSION}.tar.xz}"
readonly SIGNATURE="${SIGNATURE:-${DOWNLOAD_DIR}/linux-${KERNEL_VERSION}.tar.sign}"
readonly RUNNING_CONFIG="${RUNNING_CONFIG:-/boot/config-$(uname -r)}"
