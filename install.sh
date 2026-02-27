#!/bin/bash
set -euo pipefail

DIR="/dev/shm/xbox-drv-build"
trap 'cd / && rm -rf "$DIR"' EXIT
mkdir -p "$DIR" && cd "$DIR"

exec > >(tee /root/xbox-drv-install.log) 2>&1
export DEBIAN_FRONTEND=noninteractive

LOCKS="/var/lib/dpkg/lock /var/lib/apt/lists/lock /var/lib/dpkg/lock-frontend"

wait_for_dpkg_lock() {
    local i=0
    while fuser $LOCKS >/dev/null 2>&1; do
        if [ "$i" -ge 60 ]; then
            fuser -k -15 $LOCKS >/dev/null 2>&1 || true
            sleep 5
            fuser -k -9 $LOCKS >/dev/null 2>&1 || true
            break
        fi
        sleep 2
        i=$((i+1))
    done
    rm -f $LOCKS /var/cache/apt/archives/lock
    dpkg --configure -a --force-confdef --force-confold
}

wait_for_dpkg_lock

apt-get update -qq
apt-get install -y -qq git dkms build-essential patch libasound2-dev usbutils libarchive-tools curl "linux-headers-$(uname -r)"

# xone
rm -rf xone
git clone --depth 1 "https://github.com/dlundqvist/xone.git" xone
sed -i 's/modprobe -r xpad/true/' xone/install.sh || true
make -j"$(nproc)" -C xone install
echo 'xone_dongle' > /etc/modules-load.d/xone.conf

# xpad-noone
rm -rf xpad-noone-1.0
git clone --depth 1 "https://github.com/forkymcforkface/xpad-noone.git" xpad-noone-1.0
dkms remove -m xpad-noone -v 1.0 --all >/dev/null 2>&1 || true
cp -a xpad-noone-1.0/. /usr/src/xpad-noone-1.0/
dkms install -m xpad-noone -v 1.0 -j "$(nproc)" --force
echo 'xpad-noone' > /etc/modules-load.d/xpad-noone.conf
echo "completed"