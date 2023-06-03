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
fi

if [[ -n "$(sudo ps -e |grep ssh |grep sshd)" ]] && [[ -z "$(grep 'sudo service ssh start' ".bashrc")" ]]; then
echo '
if [ `sudo ps -e |grep ssh |grep -Eoc sshd` -eq "0" ]; then
  sudo service ssh start
fi
' >> ".bashrc"
fi

if [[ -n "$(sudo ps -e |grep ssh |grep sshd)" ]] && [[ -z "$(grep 'ifconfig |grep inet' ".bashrc")" ]]; then
echo '
echo "当前IP：\$(ifconfig |grep inet |grep -v inet6 |grep -v 127.0.0.1|awk '{print \$(2)}')"
' >> ".bashrc"
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
  sudo sed -i '/appendWindowsPath/d' /etc/wsl.conf
  sudo sh -c 'echo [interop] >> /etc/wsl.conf'
  sudo sh -c 'echo appendWindowsPath = false >> /etc/wsl.conf'
fi

if [[ `sudo grep -c "appendWindowsPath = false" /etc/wsl.conf` == '0' ]]; then
  ECHOR "写入文件发生错误，无法完成"
  exit 1
else
  ubuntu_bashrc
  ECHOG "配置已更新，请按以下说明完成步骤"
  echo
  ECHOYY "按电脑键盘的 win键+x，点击终端(管理员)(A)"
  ECHOYY "或者鼠标右击开始菜单图标，点击终端(管理员)"
  ECHOYY "然后会弹出 windows PowerShell 的命令输入窗"
  echo
  ECHOYY "然后出入命令：wsl --shutdown"
  echo
  ECHOYY "看清楚命令格式是 wsl然后空格，然后两个横杠shutdown"
  ECHOYY "输入命令后，重启您的电脑就完成了"
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
  echo -e " 1${Red}.${Font}${Green}解决WSL编译固件路径、安装SSH功能和增加当前IP显示${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}还原回WSL路径${Font}"
  echo
  echo -e " 3${Red}.${Font}${Green}进入Ubuntu不需要显示当前IP${Font}"
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
