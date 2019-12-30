#!/bin/bash -x -e

# Based on https://github.com/ungoogled-software/ungoogled-chromium-debian/blob/debian_buster/README.md
# Assumes that the packages are already installed thanks to debootstrap etc

# Set up an unprivileged user to build with
useradd build
groupadd build
mkdir -p /working/build/src
chown -R build:build working
cd working
git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git
git checkout --recurse-submodules debian_buster

cp -r ungoogled-chromium-debian/debian build/src/
cd build/src

./debian/rules setup-debian

# set up backports for newer llvm
echo "deb https://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources/backports.list
apt-get update

# install remaining requirements to build Chromium
sudo mk-build-deps -i debian/control
rm ungoogled-chromium-build-deps_*.deb

# download and unpack Chromium sources (this will take some time)
./debian/rules setup-local-src

# start building
dpkg-buildpackage -b -uc
