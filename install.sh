#!/bin/bash
set -e
exec > >(tee "/opt/xbox-drv/install.log") 2>&1

export DEBIAN_FRONTEND=noninteractive

ensure_install() {
    local MAX_RETRIES=60
    local COUNT=0

    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        
        if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
            LOCK_PID=$(fuser /var/lib/dpkg/lock 2>/dev/null)
            if [ -n "$LOCK_PID" ]; then
                kill -15 "$LOCK_PID" 2>/dev/null
                sleep 5
                if kill -0 "$LOCK_PID" 2>/dev/null; then
                     kill -9 "$LOCK_PID" 2>/dev/null
                     rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
                fi
            fi
            break
        fi
        
        sleep 2
        COUNT=$((COUNT+1))
    done

    rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*
    dpkg --configure -a --force-confdef --force-confold
}

ensure_install

apt-get update
apt-get install -y git dkms build-essential patch libasound2-dev usbutils libarchive-tools curl "linux-headers-$(uname -r)"

cd /opt/xbox-drv

# install/update xone
rm -rf xone
git clone --depth 1 "https://github.com/dlundqvist/xone.git" "xone"
make -j$(nproc) -C xone install

# install/update xpad-noone
rm -rf xpad-noone-1.0
git clone --depth 1 "https://github.com/forkymcforkface/xpad-noone.git" "xpad-noone-1.0"

# DKMS handling
dkms remove -m xpad-noone -v 1.0 --all || true
mkdir -p /usr/src/xpad-noone-1.0/
rsync -a --delete xpad-noone-1.0/ /usr/src/xpad-noone-1.0/
dkms install -m xpad-noone -v 1.0 --force

# Load module
echo 'xpad-noone' > /etc/modules-load.d/xpad-noone.conf
