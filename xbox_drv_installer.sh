#!/bin/bash
# Bootstrap
set -euo pipefail

BOOTSTRAP="https://raw.githubusercontent.com/forkymcforkface/replayos-drivers/dev/xbox_drv_installer.sh"
INSTALLER="https://github.com/forkymcforkface/replayos-drivers/releases/download/test/install.sh"

if [ -z "${DRV_LATEST:-}" ]; then
    export DRV_LATEST=1
    curl -fsSL --connect-timeout 10 --retry 3 "$BOOTSTRAP" | bash -s -- "$@" || { echo "Bootstrap fetch failed" >&2; exit 1; }
    exit $?
fi

curl -fsSL --connect-timeout 10 --retry 5 --retry-delay 1 --retry-all-errors "$INSTALLER" | bash -s -- "$@" || { echo "Installer fetch failed" >&2; exit 1; }
