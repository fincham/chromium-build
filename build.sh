#!/bin/bash

set -exv

# Based on https://github.com/ungoogled-software/ungoogled-chromium-debian/blob/debian_buster/README.md
# Assumes that the packages are already installed thanks to debootstrap etc

cd /
mkdir -p proc
mkdir -p /dev/pts || true
mount -t proc proc proc
mount -t devpts none /dev/pts


mkdir -p /working/build/src
cd /working
git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git
cd ungoogled*
git checkout --recurse-submodules debian_buster
cd ..

cp -pr ungoogled-chromium-debian/debian build/src/
cd build/src

# set up backports for newer llvm
echo "deb https://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -t buster-backports -y llvm-8 clang-8 equivs

./debian/rules setup-debian

# install remaining requirements to build Chromium
mk-build-deps -i debian/control
rm ungoogled-chromium-build-deps_*.deb

# download and unpack Chromium sources (this will take some time)
./debian/rules setup-local-src

# start building
dpkg-buildpackage -b -uc
