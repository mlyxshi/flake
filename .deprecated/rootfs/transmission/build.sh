#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

apt update
apt install -y git build-essential cmake libcurl4-openssl-dev libssl-dev python3 rclone curl

git clone --recurse-submodules https://github.com/transmission/transmission
cd transmission

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
make install