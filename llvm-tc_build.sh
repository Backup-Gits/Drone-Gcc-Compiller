#!/usr/bin/env bash

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
