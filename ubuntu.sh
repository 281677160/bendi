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

if [[ `echo "${PATH}" |grep -c "Windows"` -eq '0' ]]; then
  ECHOR "没有需要解决路径的问题"
  exit 1
fi

if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` == '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

function ubuntu_WslPath() {
if [[ -f "/etc/wsl.conf" ]]; then
  sudo sed -i '/[interop]/d' /etc/wsl.conf
  sudo sed -i '/appendWindowsPath/d' /etc/wsl.conf
fi

sudo tee -a /etc/wsl.conf << EOF > /dev/null
[interop]
appendWindowsPath = false
EOF

if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` == '0' ]]; then
sudo tee -a /etc/wsl.conf << EOF > /dev/null
[interop]
appendWindowsPath = false
EOF
fi

if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` == '0' ]]; then
  ECHOR "写入文件发生错误，无法完成"
  exit 1
else
  sudo apt-get -y update
  sudo apt-get remove openssh-server
  sudo apt-get install openssh-server
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
  
  ECHOG "配置已更新，请重启电脑"
  exit 0
fi
}

ubuntu_WslPath "$@"
