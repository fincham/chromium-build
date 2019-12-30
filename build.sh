#!/bin/bash

set -exv

# Based on https://github.com/ungoogled-software/ungoogled-chromium-debian/blob/debian_buster/README.md
# Assumes that the packages are already installed thanks to debootstrap etc

# Set up an unprivileged user to build with
useradd build
mkdir -p /working/build/src
chown -R build:build working
cd working
su - build -c 'git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git'
cd ungoogled-chromium-debian
su - build -c 'git checkout --recurse-submodules debian_buster'
cd ..

cp -pr ungoogled-chromium-debian/debian build/src/
cd build/src

su - build -c './debian/rules setup-debian'

# set up backports for newer llvm
echo "deb https://deb.debian.org/debian/ buster-backports main" > /etc/apt/sources/backports.list
apt-get update

# install remaining requirements to build Chromium
mk-build-deps -i debian/control
rm ungoogled-chromium-build-deps_*.deb

# download and unpack Chromium sources (this will take some time)
su - build -c './debian/rules setup-local-src'

# start building
su - build -c 'dpkg-buildpackage -b -uc'
