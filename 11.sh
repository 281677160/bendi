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
sudo apt-get -y update
sudo apt-get -y remove openssh-server
sudo apt-get -y remove openssh-server
sudo apt-get -y install openssh-server
sudo apt-get -y install openssh-server
sudo apt-get -y install net-tools
sudo service ssh start

if [[ -f "/etc/ssh/sshd_config" ]]; then
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
else
  echo "SSH安装失败"
fi

sudo sed -i '/grep -v inet6/d' ".bashrc"
sudo tee -a ".bashrc" << EOF > /dev/null
echo "\$(ifconfig |grep inet |grep -v inet6 |grep -v 127.0.0.1|awk '{print \$(2)}')"
EOF

if [[ `sudo grep -c "grep -Eoc sshd" ".bashrc"` -eq '0' ]]; then
sudo echo '
if [ `sudo ps -e |grep ssh |grep -Eoc sshd` -eq "0" ]; then
  sudo service ssh start
fi
' >> ".bashrc"
fi
}

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
  ubuntu_bashrc
  ECHOG "配置已更新，请按说明完成以下步骤，然后重启电脑"
  exit 0
fi
}

function wsl_huanyuan() {
sudo sed -i '/[interop]/d' /etc/wsl.conf
sudo sed -i '/appendWindowsPath/d' /etc/wsl.conf
if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` -ge '1' ]]; then
  sudo sed -i '/[interop]/d' /etc/wsl.conf
  sudo sed -i '/appendWindowsPath/d' /etc/wsl.conf
fi

if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` == '0' ]]; then
  ECHOG "配置已更新，重启电脑即可"
  exit 0
else
  ECHOG "无法完成操作请查看/etc/wsl.conf自行删除试试，删除以下2行代码"
  ECHOG "删除：[interop]"
  ECHOG "删除：appendWindowsPath = false"
  exit 1
fi
}


function menu() {
  clear
  echo
  echo
  echo -e " 1${Red}.${Font}${Green}更改WSL路径和安装SSH${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}还原回WSL路径${Font}"
  echo
  echo -e " 3${Red}.${Font}${Green}进入SSH不需要显示IP${Font}"
  echo
  echo -e " 4${Red}.${Font}${Green}退出${Font}"
  echo
  echo
  XUANZop="请输入数字"
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    ubuntu_WslPath
  break
  ;;
  2)
    wsl_huanyuan
  break
  ;;
  3)
    sudo sed -i '/grep -v inet6/d' ${GITHUB_WORKSPACE}/.bashrc
    ECHOG "操作完成"
  break
  ;;
  4)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop="请输入正确的数字编号!"
  ;;
  esac
  done
}

menu "$@"
