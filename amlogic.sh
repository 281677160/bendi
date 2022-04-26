#!/bin/bash

  cd ${GITHUB_WORKSPACE}
  if [[ `ls -1 "openwrt/bin/targets/armvirt/64" | grep -c "tar.gz"` == '0' ]]; then
    mkdir -p "openwrt/bin/targets/armvirt/64"
    clear
    echo
    echo
    echo
    echo "没发现您的 openwrt/bin/targets/armvirt/64 文件夹里存在.tar.gz固件，已为你创建了文件夹"
    echo "请先将\"openwrt-armvirt-64-default-rootfs.tar.gz\"固件"
    echo "存入 openwrt/bin/targets/armvirt/64 文件夹里面，再使用命令进行打包"
    echo
    [[ "${WSL_ubuntu}" == "YES" ]] && explorer.exe .
    exit 1
  fi
  if [[ ! -d amlogic ]]; then
    echo "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d amlogic ]] && [[  ! -f amlogic/make ]]; then
    echo "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf amlogic
    echo "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d amlogic ]] && [[  ! -d amlogic/amlogic-s9xxx ]]; then
    echo "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf amlogic
    echo "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  fi
  [ ! -d amlogic/openwrt-armvirt ] && mkdir -p amlogic/openwrt-armvirt || sudo rm -rf amlogic/openwrt-armvirt/*
  [[ -d "amlogic/out" ]] && sudo rm -rf amlogic/out/*
  [[ -d "amlogic/amlogic-s9xxx/amlogic-kernel" ]] && sudo rm -rf amlogic/amlogic-s9xxx/amlogic-kernel/*
  if [[ `ls -1 "openwrt/bin/targets/armvirt/64" | grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
    cp -Rf openwrt/bin/targets/armvirt/64/.*default-rootfs.tar.gz amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  else
    armvirtargz="$(ls -1 "${HOME_PATH}/bin/targets/armvirt/64" |grep ".*tar.gz" |awk 'END {print}')"
    cp -Rf openwrt/bin/targets/armvirt/64/${armvirtargz} amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  fi
  if [[ `ls -a amlogic/openwrt-armvirt | grep -c "openwrt-armvirt-64-default-rootfs.tar.gz"` == '0' ]]; then
    echo "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    echo "请检查openwrt/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd amlogic
  sudo chmod +x make
  sudo ./make -d -b s905d -k 5.15.25_5.10.100
  if [[ `ls -1 amlogic/out | grep -c "openwrt"` -ge '1' ]]; then
    echo "打包完成，固件存放在[amlogic/out]文件夹"
    if [[ "${WSL_ubuntu}" == "YES" ]]; then
      cd amlogic/out
      explorer.exe .
      cd amlogic
    fi
  else
    echo "打包失败，请再次尝试!"
  fi
