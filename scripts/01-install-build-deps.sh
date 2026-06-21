#!/usr/bin/env bash
# Print, but never execute, a suggested Debian build dependency command. The
# package list must be reviewed by the user against current Debian 13 metadata.

set -euo pipefail

# A quoted heredoc prevents expansion and ensures the command remains plain
# output. There is intentionally no execution mode in this helper.
cat <<'EOF'
This script does not install anything.

Review this command and run it manually only if appropriate for this host:

sudo apt install build-essential bc bison flex libssl-dev libelf-dev \
  libncurses-dev dwarves fakeroot rsync debhelper cpio kmod xz-utils \
  zstd dkms wget gnupg

No sudo command was executed.
EOF
