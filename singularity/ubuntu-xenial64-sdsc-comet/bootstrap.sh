#!/usr/bin/env bash

echo "Installing base packages"
apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential python debootstrap

wget https://github.com/singularityware/singularity/releases/download/2.3.2/singularity-2.3.2.tar.gz
tar xvf singularity-2.3.2.tar.gz
cd singularity-2.3.2
./configure --prefix=/usr/local
make
make install
/bin/rm -rf singularity*
/bin/rm -f /tmp/*.deb
