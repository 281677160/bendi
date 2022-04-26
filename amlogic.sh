#!/bin/bash
git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
cd amlogic
mkdir -p openwrt-armvirt
wget -P openwrt-armvirt https://github.com/ophub/amlogic-s9xxx-openwrt/releases/download/openwrt_s9xxx_lede_2022.04.25.1109/openwrt-armvirt-64-default-rootfs.tar.gz -O openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
sudo chmod +x make
sudo ./make -d -b s905d -k 5.15.25_5.10.100
