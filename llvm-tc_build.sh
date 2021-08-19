#!/usr/bin/env bash

add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update
apt-get install -y axel flex bison ncurses-dev texinfo gcc gperf patch libtool automake g++ libncurses5-dev gawk subversion expat libexpat1-dev python-all-dev binutils-dev bc libcap-dev autoconf libgmp-dev build-essential pkg-config libmpc-dev libmpfr-dev autopoint gettext txt2man liblzma-dev libssl-dev libz-dev mercurial wget tar gcc-10 g++-10 cmake ninja-build zstd lz4 liblz4-tool liblz4-dev lzma --fix-broken --fix-missing
timedatectl set-timezone Asia/Jakarta
echo ::set-output name=date::$(/bin/date -u "+%Y%m%d")
alias gcc=gcc-10
alias g++=g++-10
git config --global user.name "${GITHUB_USER}"
git config --global user.email "${GITHUB_EMAIL}"
git clone https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/AnGgIt88/gcc-arm64 ../gcc-arm64 -b gcc-master
rm -rf ../gcc-arm64/*
chmod a+x build-*.sh
./build-gcc.sh -a arm64
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
./build-lld.sh -a arm64
cript_dir=$(pwd)
cd ../gcc-arm64
./bin/aarch64-elf-gcc -v 2>&1 | tee /tmp/gcc-version
./bin/aarch64-elf-ld.lld -v 2>&1 | tee /tmp/lld-arm64-version
bash "$script_dir/strip-binaries.sh"
git add . -f
git commit -as -m "NeedForSpeed:GCC ARM64 bump to ${{ steps.get-date.outputs.date }}" -m "Build completed on: $(/bin/date)" -m "Configuration: $(/bin/cat /tmp/gcc-version)" -m "LLD: $(/bin/cat /tmp/lld-arm64-version)"
git gc
git push origin gcc-master -f
