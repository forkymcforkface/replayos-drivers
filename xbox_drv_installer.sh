#!/bin/bash
# Bootstrap script

URL="https://github.com/forkymcforkface/replayos-drivers/releases/latest/download/install.sh"
chmod -R 755 /opt/xbox-drv
curl -fsSL --retry 5 --retry-delay 1 --retry-all-errors "$URL" | bash -s -- "$@"
