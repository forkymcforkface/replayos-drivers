#!/bin/bash
# Bootstrap
set -euo pipefail

BOOTSTRAP="https://raw.githubusercontent.com/forkymcforkface/replayos-drivers/main/xbox_drv_installer.sh"
INSTALLER="https://github.com/forkymcforkface/replayos-drivers/releases/latest/download/install.sh"

if [ -z "${DRV_LATEST:-}" ]; then
    export DRV_LATEST=1
    curl -fsL --connect-timeout 10 --retry 3 -o /dev/shm/xbox_drv_installer.sh "$BOOTSTRAP" || { echo "Internet Required" >&2; exit 1; }
    exec bash /dev/shm/xbox_drv_installer.sh "$@"
fi

curl -fsL --connect-timeout 10 --retry 5 --retry-delay 1 --retry-all-errors -o /dev/shm/install.sh "$INSTALLER" || { echo "Internet Required" >&2; exit 1; }
exec bash /dev/shm/install.sh "$@"
