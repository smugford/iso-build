#!/bin/bash

apt-get -qq update
apt-get -qq install -y --no-install-recommends \
build-essential \
curl \
e2fsprogs \
parted \
qemu-utils \
bzip2 \
git \
pigz \
ansible \
vim \
cloud-guest-utils \
gdisk
