#!/bin/bash

#====================================================
# System Request:Ubuntu 18.04lts/20.04lts/22.04lts
# Author:	281677160
# Dscription: Compile openwrt firmware
# github: https://github.com/281677160/build-actions
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
GITHUB_WORKSPACE="$PWD"

function print_ok() {
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
  echo
}
function ECHOGG() {
  echo -e "${Green} $1 ${Font}"
}
  function ECHORR() {
  echo -e "${Red} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成"
    echo
  else
    print_error "$1 失败"
    echo
    exit 1
  fi
}

source /etc/os-release
case "${UBUNTU_CODENAME}" in
"bionic"|"focal"|"jammy")
  echo "${PRETTY_NAME}"
;;
*)
  print_error "非Ubuntu系统"
  exit 1
;;
esac

if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` == '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

function ubuntu_bashrc() {
sudo service ssh start
if [ -z "$(sudo ps -e |grep ssh |grep sshd)" ]; then
  sudo apt-get -y update
  sudo apt-get -y remove openssh-server
  sudo apt-get -y remove openssh-server
  sudo apt-get -y install openssh-server
  sudo apt-get -y install openssh-server
  sudo apt-get -y install net-tools
  sudo service ssh start
fi

if [ -n "$(sudo ps -e |grep ssh |grep sshd)" ]; then
  sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
  sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
  sudo sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config
  sudo sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
  sudo sed -i '/Port 22/d' /etc/ssh/sshd_config

  sudo sh -c 'echo Port 22 >> /etc/ssh/sshd_config'
  sudo sh -c 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'
  sudo sh -c 'echo PasswordAuthentication yes >> /etc/ssh/sshd_config'
  sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
  sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
  
  sudo service ssh restart
  ECHOG "SSH安装完成"
else
  ECHOR "SSH安装失败"
fi

if [[ -n "$(sudo ps -e |grep ssh |grep sshd)" ]] && [[ -z "$(grep 'sudo service ssh start' ".bashrc")" ]]; then
  echo '[ -z "$(sudo ps -e |grep sshd)" ] && sudo service ssh start' >>  .bashrc
fi

if [[ -n "$(sudo ps -e |grep ssh |grep sshd)" ]] && [[ -z "$(grep 'ifconfig |grep inet' ".bashrc")" ]]; then
  echo "echo \"\$(ifconfig |grep inet |grep -v 'inet6\|127.0.0.1'|awk '{print \$(2)}')\"" >> .bashrc
fi
}

function ubuntu_WslPath() {
if [[ ! -f "/etc/wsl.conf" ]]; then
  sudo sh -c 'echo [interop] > /etc/wsl.conf'
  sudo sh -c 'echo appendWindowsPath = false >> /etc/wsl.conf'
elif [[ "$(du -s "/etc/wsl.conf" |awk '{print $1}')" == "0" ]] ; then
  sudo sh -c 'echo [interop] >> /etc/wsl.conf'
  sudo sh -c 'echo appendWindowsPath = false >> /etc/wsl.conf'
elif [[ -z "$(grep 'appendWindowsPath' "/etc/wsl.conf")" ]]; then
  sudo sh -c 'echo [interop] >> /etc/wsl.conf'
  sudo sh -c 'echo appendWindowsPath = false >> /etc/wsl.conf'
elif [[ -n "$(grep 'appendWindowsPath' "/etc/wsl.conf")" ]]; then
  if [[ -n "$(grep -B 1 'appendWindowsPath' '/etc/wsl.conf' |grep 'interop')" ]]; then
    sudo sed -i '$!N;/\n.*appendWindowsPath/!P;D' /etc/wsl.conf
    sudo sed -i '/appendWindowsPath/d' /etc/wsl.conf
  else
    sudo sed -i '/appendWindowsPath/d' bendienv
  fi
  sudo sh -c 'echo [interop] >> /etc/wsl.conf'
  sudo sh -c 'echo appendWindowsPath = false >> /etc/wsl.conf'
fi

if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` == '0' ]]; then
  ECHOR "解决WSL编译固件路径失败"
  exit 1
else
  ECHOG "解决WSL编译固件路径配置已更新"
  ECHOYY "请重启安装WSL的电脑，就完成了"
  exit 0
fi
}

function menu() {
  clear
  echo
  echo -e " 1${Red}.${Font}${Green}解决WSL编译固件路径、安装SSH功能和增加当前IP显示${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}退出${Font}"
  echo
  XUANZop="请输入数字"
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    ubuntu_bashrc
    ubuntu_WslPath
  break
  ;;
  2)
    echo
    exit 0
  ;;
  *)
    XUANZop="请输入正确的数字编号!"
  ;;
  esac
  done
}

menu "$@"
