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
  echo "全部可打包机型：s905x3_s905x2_s905x_s905w_s905d_s922x_s912"
  echo "设置要打包固件的机型[ 直接回车则默认全部机型 ]"
  export root_size="$(egrep -o ROOT_MB=\"[0-9]+\" "amlogic/make" |cut -d "=" -f2 |sed 's/\"//g' )"
  read -p " 请输入您要设置的机型：" amlogic_model
  export amlogic_model=${amlogic_model:-"s905x3_s905x2_s905x_s905w_s905d_s922x_s912"}
  echo "您设置的机型为：${amlogic_model}"
  echo
  echo "设置打包的内核版本[直接回车则默认自动检测最新内核]"
  read -p " 请输入您要设置的内核：" amlogic_kernel
  export amlogic_kernel=${amlogic_kernel:-"5.10.100_5.4.180"}
  if [[ "${amlogic_kernel}" == "5.10.100_5.4.180" ]]; then
    echo "您设置的内核版本为：自动检测最新版内核打包"
  else
    echo "您设置的内核版本为：${amlogic_kernel}"
  fi
  echo
  echo "设置ROOTFS分区大小[ 直接回车则默认：${root_size} ]"
  read -p " 请输入ROOTFS分区大小：" rootfs_size
  export rootfs_size=${rootfs_size:-"${root_size}"}
  echo "您设置的ROOTFS分区大小为：${rootfs_size}"
  export make_size="$(egrep -o ROOT_MB=\"[0-9]+\" "amlogic/make")"
  export zhiding_size="ROOT_MB=\"${rootfs_size}\""
  echo
  echo "请输入ubuntu密码进行固件打包程序"
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
  sed -i "s?${make_size}?${zhiding_size}?g" make
  sudo chmod +x make
  sudo ./make -d -b ${amlogic_model} -k ${amlogic_kernel}
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
