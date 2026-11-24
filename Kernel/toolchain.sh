#!/bin/bash

echo "Started" 

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    build-essential \
    libssl-dev \
    libelf-dev \
    bc \
    cpio \
    bison \
    flex \
    device-tree-compiler \
    wget \
    gnupg \
    lsb-release \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-dev-armel-cross \
    patch \
    git \
    gh \
    rsync \
    make \
    libncurses-dev \
    dwarves \
    zstd \
    python3 python3-pip

sudo apt install -y \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-dev-arm64-cross

sudo apt install -y \
    gcc-arm-linux-gnueabi \
    binutils-arm-linux-gnueabi

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 20
rm ./llvm.sh

sudo apt install -y clang-20 lld-20 ccache

sudo ln -sf /usr/bin/clang-20 /usr/bin/clang
sudo ln -sf /usr/bin/ld.lld-20 /usr/bin/ld.lld

echo "Done!"
