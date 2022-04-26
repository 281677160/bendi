#!/bin/bash

#====================================================
#	System Request:Ubuntu 18.04+/20.04+
#	Author:	281677160
#	Dscription: openwrt onekey Management
#	github: https://github.com/281677160
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

# 变量

function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOG() {
  echo
  echo -e "${Green} $1 ${Font}"
  echo
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
  function ECHOR() {
  echo
  echo -e "${Red} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOGG() {
  echo -e "${Green} $1 ${Font}"
}
  function ECHORR() {
  echo -e "${Red} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    echo
    print_ok "$1 完成"
    echo
    sleep 1
  else
    echo
    print_error "$1 失败"
    echo
    exit 1
  fi
}

export Ubname=`cat /etc/issue`
export xtname="Ubuntu"
export xtbit=`getconf LONG_BIT`
if [[ ( $Ubname != *$xtname* ) || ( $xtbit != 64 ) ]]; then
  print_error "请使用Ubuntu 64位系统，推荐 Ubuntu 18 LTS 或 Ubuntu 20 LTS"
  exit 1
fi
if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "$Google_Check" == 301 ];then
  print_error "提醒：编译之前请自备梯子，编译全程都需要稳定梯子~~"
  exit 0
fi
if [[ "$(echo ${GITHUB_WORKSPACE} |grep -c 'openwrt')" -ge '1' ]]; then
  print_error "请注意命令的执行路径,并非在openwrt文件夹内执行,如果您ubuntu或机器就叫openwrt的话,恭喜您,就是不给您用,改名吧少年!"
  exit 0
fi
if [[ `ls -1 /mnt/* | grep -c "Windows"` -ge '1' ]] || [[ `ls -1 /mnt | grep -c "wsl"` -ge '1' ]]; then
  export WSL_ubuntu="YES"
else
  export WSL_ubuntu="NO"
fi


  cd ${GITHUB_WORKSPACE}
  if [[ `ls -1 "openwrt/bin/targets/armvirt/64" | grep -c "tar.gz"` == '0' ]]; then
    mkdir -p "openwrt/bin/targets/armvirt/64"
    clear
    echo
    echo
    echo
    ECHOR "没发现您的 openwrt/bin/targets/armvirt/64 文件夹里存在.tar.gz固件，已为你创建了文件夹"
    ECHORR "请先将\"openwrt-armvirt-64-default-rootfs.tar.gz\"固件"
    ECHOR "存入 openwrt/bin/targets/armvirt/64 文件夹里面，再使用命令进行打包"
    echo
    [[ "${WSL_ubuntu}" == "YES" ]] && explorer.exe .
    exit 1
  fi
  if [[ ! -d amlogic ]]; then
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    judge "内核运行文件下载"
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d amlogic ]] && [[  ! -f amlogic/make ]]; then
    ECHOGG "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf amlogic
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    judge "内核运行文件下载"
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d amlogic ]] && [[  ! -d amlogic/amlogic-s9xxx ]]; then
    ECHOGG "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf amlogic
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git amlogic
    judge "内核运行文件下载"
    rm -rf amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  fi
  [ ! -d amlogic/openwrt-armvirt ] && mkdir -p amlogic/openwrt-armvirt || sudo rm -rf amlogic/openwrt-armvirt/*
  ECHOY "全部可打包机型：s905x3_s905x2_s905x_s905w_s905d_s922x_s912"
  ECHOGG "设置要打包固件的机型[ 直接回车则默认全部机型 ]"
  export root_size="$(egrep -o ROOT_MB=\"[0-9]+\" "amlogic/make" |cut -d "=" -f2 |sed 's/\"//g' )"
  read -p " 请输入您要设置的机型：" amlogic_model
  export amlogic_model=${amlogic_model:-"s905x3_s905x2_s905x_s905w_s905d_s922x_s912"}
  ECHOYY "您设置的机型为：${amlogic_model}"
  echo
  ECHOGG "设置打包的内核版本[直接回车则默认自动检测最新内核]"
  read -p " 请输入您要设置的内核：" amlogic_kernel
  export amlogic_kernel=${amlogic_kernel:-"5.10.100_5.4.180"}
  if [[ "${amlogic_kernel}" == "5.10.100_5.4.180" ]]; then
    ECHOYY "您设置的内核版本为：自动检测最新版内核打包"
  else
    ECHOYY "您设置的内核版本为：${amlogic_kernel}"
  fi
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认：${root_size} ]"
  read -p " 请输入ROOTFS分区大小：" rootfs_size
  export rootfs_size=${rootfs_size:-"${root_size}"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs_size}"
  export make_size="$(egrep -o ROOT_MB=\"[0-9]+\" "amlogic/make")"
  export zhiding_size="ROOT_MB=\"${rootfs_size}\""
  echo
  ECHOGG "请输入ubuntu密码进行固件打包程序"
  [[ -d "amlogic/out" ]] && sudo rm -rf amlogic/out/*
  [[ -d "amlogic/amlogic-s9xxx/amlogic-kernel" ]] && sudo rm -rf amlogic/amlogic-s9xxx/amlogic-kernel/*
  if [[ `ls -1 "openwrt/bin/targets/armvirt/64" | grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
    cp -Rf openwrt/bin/targets/armvirt/64/.*default-rootfs.tar.gz amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  else
    armvirtargz="$(ls -1 "${HOME_PATH}/bin/targets/armvirt/64" |grep ".*tar.gz" |awk 'END {print}')"
    cp -Rf openwrt/bin/targets/armvirt/64/${armvirtargz} amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  fi
  if [[ `ls -a amlogic/openwrt-armvirt | grep -c "openwrt-armvirt-64-default-rootfs.tar.gz"` == '0' ]]; then
    print_error "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    print_error "请检查openwrt/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd amlogic
  sed -i "s?${make_size}?${zhiding_size}?g" make
  sudo chmod +x make
  sudo ./make -d -b ${amlogic_model} -k ${amlogic_kernel}
  if [[ `ls -1 amlogic/out | grep -c "openwrt"` -ge '1' ]]; then
    print_ok "打包完成，固件存放在[amlogic/out]文件夹"
    if [[ "${WSL_ubuntu}" == "YES" ]]; then
      cd amlogic/out
      explorer.exe .
      cd amlogic
    fi
  else
    print_error "打包失败，请再次尝试!"
  fi
