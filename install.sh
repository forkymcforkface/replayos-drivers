#!/bin/bash
set -e
exec > >(tee "/opt/xbox-drv/install.log") 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y git dkms build-essential patch libasound2-dev usbutils libarchive-tools curl "linux-headers-$(uname -r)"

cd /opt/xbox-drv

# install/update xone
rm -rf xone
git clone --depth 1 "https://github.com/dlundqvist/xone.git" "xone"
make -C xone install

# install/update xpad-noone
rm -rf xpad-noone-1.0
git clone --depth 1 "https://github.com/forkymcforkface/xpad-noone.git" "xpad-noone-1.0"
dkms remove -m xpad-noone -v 1.0 --all || true
mkdir -p /usr/src/xpad-noone-1.0/
rsync -a --delete xpad-noone-1.0/ /usr/src/xpad-noone-1.0/
dkms install -m xpad-noone -v 1.0 --force
echo 'xpad-noone' > /etc/modules-load.d/xpad-noone.conf
