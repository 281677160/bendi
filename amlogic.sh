#!/bin/bash
git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
mkdir -p amlogic/openwrt-armvirt
if [[ `ls -1 "openwrt/bin/targets/armvirt/64" | grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
  cp -Rf openwrt/bin/targets/armvirt/64/.*default-rootfs.tar.gz amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
else
  armvirtargz="$(ls -1 "${HOME_PATH}/bin/targets/armvirt/64" |grep ".*tar.gz" |awk 'END {print}')"
  cp -Rf openwrt/bin/targets/armvirt/64/${armvirtargz} amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
fi
if [[ `ls -1 "amlogic/openwrt-armvirt" | grep -c "openwrt-armvirt-64-default-rootfs.tar.gz"` == '0' ]]; then
  echo "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
  echo "请检查openwrt/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
  exit 1
fi
cd amlogic
sudo chmod +x make
sudo ./make -d -b s905d -k 5.15.25_5.10.100
