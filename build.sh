#!/bin/bash

set -exv

# Based on https://github.com/ungoogled-software/ungoogled-chromium-debian/blob/debian_buster/README.md
# Assumes that the packages are already installed thanks to debootstrap etc

cd /
mkdir -p proc
mkdir -p /home/build
mkdir -p /dev/pts || true
mount -t proc proc proc
mount -t devpts none /dev/pts

# Set up an unprivileged user to build with
useradd build
mkdir -p /home/build/src
chown -R build:build /home/build/build

cd /home/build
su build -c 'cd /home/build; git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git'
su build -c 'cd /home/build/ungoogled-chromium-debian; git checkout --recurse-submodules debian_buster'

cp -pr ungoogled-chromium-debian/debian build/src/
cd build/src

# set up backports for newer llvm
echo "deb https://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -t buster-backports -y llvm-8 clang-8 equivs

su build -c './debian/rules setup-debian'

# install remaining requirements to build Chromium
mk-build-deps -i debian/control
rm ungoogled-chromium-build-deps_*.deb

# download and unpack Chromium sources (this will take some time)
su build -c './debian/rules setup-local-src'

# start building
su build -c 'dpkg-buildpackage -b -uc'
