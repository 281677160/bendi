#!/usr/bin/env bash

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
export GITHUB_WORKSPACE="$PWD"
export OP_DIY="${GITHUB_WORKSPACE}/OP_DIY"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export LOCAL_Build="${HOME_PATH}/build"
export COMMON_SH="${HOME_PATH}/build/common/common.sh"
export BASE_PATH="${HOME_PATH}/package/base-files/files"
export NETIP="${HOME_PATH}/package/base-files/files/etc/networkip"
export DELETE="${HOME_PATH}/package/base-files/files/etc/deletefile"
export FIN_PATH="${HOME_PATH}/package/base-files/files/etc/FinishIng.sh"
export KEEPD="${HOME_PATH}/package/base-files/files/lib/upgrade/keep.d/base-files-essential"
export Author="$(grep "syslog" "/etc/group"|awk 'NR==1' |cut -d "," -f2)"
export REPO_TOKEN="REPO_TOKEN"
export date1="$(date +'%m-%d')"
export bendi_script="1"

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
  export PATH=$PATH:'/mnt/c/windows'
else
  export WSL_ubuntu="NO"
fi


function op_common_sh() {
  cd ${GITHUB_WORKSPACE}
  clear
  echo
  ECHORR "|*******************************************|"
  ECHOGG "|                                           |"
  ECHOYY "|  首次编译,可能要输入Ubuntu密码继续下一步  |"
  ECHOGG "|                                           |"
  ECHOYY "|              部署编译环境                 |"
  ECHORR "|                                           |"
  ECHOGG "|*******************************************|"
  echo
  if [[ `sudo grep -c "NOPASSWD:ALL" /etc/sudoers` == '0' ]]; then
    sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
  fi
  clear
  if [[ -f /etc/ssh/sshd_config ]] && [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` == '0' ]]; then
    sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
    sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
    sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
    sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
    sudo service ssh restart
  fi
  curl -L https://raw.githubusercontent.com/281677160/common/main/common.sh > common.sh
  if [[ $? -ne 0 ]];then
    wget -O common.sh https://raw.githubusercontent.com/281677160/common/main/common.sh
  fi
  if [[ $? -eq 0 ]];then
    source common.sh && Diy_update
    rm -fr common.sh
  else
    ECHOR "common文件下载失败，请检测网络后再用一键命令试试!"
    exit 1
  fi
}

function op_kongjian() {
  cd ${GITHUB_WORKSPACE}
  export Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
  export FINAL=`echo ${Ubunkj: -1}`
  if [[ "${FINAL}" =~ (M|K) ]]; then
    print_error "敬告：可用空间小于[ 1G ]退出编译,建议可用空间大于20G"
    sleep 1
    exit 1
  fi
  export Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
  if [[ "${Ubuntu_kj}" -lt "20" ]];then
    ECHOY "您当前系统可用空间为${Ubuntu_kj}G"
    print_error "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
    read -p " 直接回车退出编译，按[Y/y]回车则继续编译： " YN
    case ${YN} in
    [Yy]) 
      ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
    ;;
    *)
      ECHOY  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
      sleep 1
      exit 0
    ;;
    esac
  fi
}

function op_diywenjian() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -d ${GITHUB_WORKSPACE}/OP_DIY ]]; then
    rm -rf bendi
    git clone https://github.com/281677160/build-actions bendi
    judge "OP_DIY文件下载"
    rm -rf ${GITHUB_WORKSPACE}/bendi/build/*/start-up
    for X in $(find ./bendi -name ".config" |sed 's/.config//g'); do mv "${X}".config "${X}"config; done
    for X in $(find ./bendi -name "settings.ini"); do
      sed -i 's/.config/config/g' "${X}"
      sed -i '/SSH_ACTIONS/d' "${X}"
      sed -i '/UPLOAD_CONFIG/d' "${X}"
      sed -i '/UPLOAD_FIRMWARE/d' "${X}"
      sed -i '/UPLOAD_WETRANSFER/d' "${X}"
      sed -i '/UPLOAD_RELEASE/d' "${X}"
      sed -i '/SERVERCHAN_SCKEY/d' "${X}"
      sed -i '/USE_CACHEWRTBUILD/d' "${X}"
      sed -i '/REGULAR_UPDATE/d' "${X}"
      sed -i '/BY_INFORMATION/d' "${X}"
      echo '
        EVERY_INQUIRY="true"            # 是否每次都询问您要不要去设置自定义文件（true=开启）（false=关闭）
        REGULAR_UPDATE="false"            # 把自动在线更新的插件编译进固件（在本地就是玩票性质）（true=开启）（false=关闭）
        Github="https://github.com/281677160/build-actions"     # 如果开启了‘把自动在线更新的插件编译进固件’，请设置好您的github地址
      ' >> "${X}"
      sed -i 's/^[ ]*//g' "${X}"
      sed -i '/^$/d' "${X}"
      sed -i '/REGULAR_UPDATE/d' "${GITHUB_WORKSPACE}/bendi/build/openwrt_amlogic/settings.ini"
      sed -i '/Github/d' "${GITHUB_WORKSPACE}/bendi/build/openwrt_amlogic/settings.ini"
    done
    mv -f ${GITHUB_WORKSPACE}/bendi/build ${GITHUB_WORKSPACE}/OP_DIY
  fi
}

function gengxin_opdiy() {
  cd ${GITHUB_WORKSPACE}
  rm -rf ${GITHUB_WORKSPACE}/bendi
  git clone https://github.com/281677160/build-actions bendi
  judge "OP_DIY文件下载"
  rm -rf ${GITHUB_WORKSPACE}/bendi/build/*/start-up
  rm -rf ${GITHUB_WORKSPACE}/bendi/build/*/.config
  for X in $(find ./bendi -name "settings.ini"); do
    sed -i 's/.config/config/g' "${X}"
    sed -i '/SSH_ACTIONS/d' "${X}"
    sed -i '/UPLOAD_CONFIG/d' "${X}"
    sed -i '/UPLOAD_FIRMWARE/d' "${X}"
    sed -i '/UPLOAD_WETRANSFER/d' "${X}"
    sed -i '/UPLOAD_RELEASE/d' "${X}"
    sed -i '/SERVERCHAN_SCKEY/d' "${X}"
    sed -i '/USE_CACHEWRTBUILD/d' "${X}"
    sed -i '/REGULAR_UPDATE/d' "${X}"
    sed -i '/BY_INFORMATION/d' "${X}"
    echo '
      EVERY_INQUIRY="true"            # 是否每次都询问您要不要去设置自定义文件（true=开启）（false=关闭）
      REGULAR_UPDATE="false"            # 把自动在线更新的插件编译进固件（在本地就是玩票性质）（true=开启）（false=关闭）
      Github="https://github.com/281677160/build-actions"     # 如果开启了‘把自动在线更新的插件编译进固件’，请设置好您的github地址
    ' >> "${X}"
    sed -i 's/^[ ]*//g' "${X}"
    sed -i '/^$/d' "${X}"
    sed -i '/REGULAR_UPDATE/d' "${GITHUB_WORKSPACE}/bendi/build/openwrt_amlogic/settings.ini"
    sed -i '/Github/d' "${GITHUB_WORKSPACE}/bendi/build/openwrt_amlogic/settings.ini"
  done
  if [[ -d ${GITHUB_WORKSPACE}/bendi/build ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/bendi/build/* ${GITHUB_WORKSPACE}/OP_DIY/
    rm -rf ${GITHUB_WORKSPACE}/bendi
    print_ok "同步OP_DIY完成!"
  else
    rm -rf ${GITHUB_WORKSPACE}/bendi
    print_error "同步OP_DIY失败!"
    exit 1
  fi
}

function bianyi_xuanxiang() {
  cd ${GITHUB_WORKSPACE}
  if [ -z "$(ls -A "$GITHUB_WORKSPACE/OP_DIY/${matrixtarget}/settings.ini" 2>/dev/null)" ]; then
    ECHOR "错误提示：编译脚本缺少[settings.ini]名称的配置文件,请在[OP_DIY/${matrixtarget}]文件夹内补齐"
    exit 1
  else
    source "$GITHUB_WORKSPACE/OP_DIY/${matrixtarget}/settings.ini"
  fi
  if [[ "${EVERY_INQUIRY}" == "true" ]]; then
    clear
    echo
    echo
    ECHOYY "请在 OP_DIY/${matrixtarget} 里面设置好自定义文件"
    ECHOY "设置完毕后，按[W/w]回车继续编译"
    ZDYSZ="请输入您的选择"
    if [[ "${WSL_ubuntu}" == "YES" ]]; then
      cd ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}
      explorer.exe .
      cd ${GITHUB_WORKSPACE}
    fi
    while :; do
      read -p " ${ZDYSZ}： " ZDYSZU
      case $ZDYSZU in
      [Ww])
        echo
      break
      ;;
      *)
        ZDYSZ="提醒：确认设置完毕后，请按[W/w]回车继续编译"
      ;;
      esac
    done
  fi
  echo
  echo
  tixing_op_config > /dev/null 2>&1
  clear
  echo
  echo
  echo -e "${Red} 提示${Font}：${Blue}您当前OP_DIY自定义文件夹的配置机型为[${TARGET_PROFILE}]${Font}"
  echo
  ECHOGG "是否需要选择机型和增删插件?"
  read -t 20 -p " [输入[ Y/y ]回车确认，直接回车则为否](不作处理,20秒自动跳过)： " MENUu
  case $MENUu in
  [Yy])
    export Menuconfig="true"
    ECHOYY "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
  ;;
  *)
    export Menuconfig="false"
    ECHORR "您已关闭选择机型和增删插件设置！"
  ;;
  esac
  echo
  echo
  ECHOG "3秒后为您执行编译程序,请稍后..."
  sleep 2
  source ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/common.sh > common.sh
  if [[ $? -ne 0 ]];then
    wget -q -O common.sh https://raw.githubusercontent.com/281677160/common/main/common.sh
  fi
  if [[ $? -eq 0 ]];then
    source common.sh && Diy_repo_url
    rm -fr common.sh
  else
    ECHOR "common文件下载失败，请检测网络后再用一键命令试试!"
    exit 1
  fi
}

function op_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  echo
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf openwrt && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" openwrt
  judge "${matrixtarget}源码下载"
}

function op_jiaoben() {
  if [[ ! -d "${HOME_PATH}/build" ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/OP_DIY ${HOME_PATH}/build
  else
    cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/* ${HOME_PATH}/build/
  fi
  [[ "${Tishi}" == "1" ]] && sed -i '/-rl/d' "${BUILD_PATH}/${DIY_PART_SH}"
  rm -rf ${HOME_PATH}/build/common && git clone https://github.com/281677160/common ${HOME_PATH}/build/common
  judge "额外扩展文件下载"
  cp -Rf ${LOCAL_Build}/common/*.sh ${BUILD_PATH}/
  chmod -R +x ${BUILD_PATH}
  source "${BUILD_PATH}/common.sh" && Diy_settings
  source "${BUILD_PATH}/common.sh" && Bendi_variable
  rm -rf ${LOCAL_Build}/chenggong > /dev/null 2>&1
  rm -rf ${LOCAL_Build}/shibai > /dev/null 2>&1
  echo "weiwan" > "${LOCAL_Build}/weiwan"
}

function op_diy_zdy() {
  ECHOG "正在下载插件包和更新feeds,请耐心等候~~~"
  cd ${HOME_PATH}
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_diy_ip() {
  cd ${HOME_PATH}
  IP="$(grep 'network.lan.ipaddr=' ${BUILD_PATH}/$DIY_PART_SH |cut -f1 -d# |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  [[ -z "${IP}" ]] && IP="$(grep 'ipaddr:' ${HOME_PATH}/package/base-files/files/bin/config_generate |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  echo "${Mark_Core}" > ${HOME_PATH}/${Mark_Core}
  ECHOY "您的后台IP地址为：$IP"
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    export Author=""
    export Github=${Github}
    export Warehouse="${Github##*com/}"
    export Author="$(echo "${Github}" |cut -d "/" -f4)"
    export Library="$(echo "${Github}" |cut -d "/" -f5)"
    ECHOYY "您的Github地址为：$Github"
    echo
  fi
  sleep 2
}

function op_menuconfig() {
  cd ${HOME_PATH}
  if [[ "${Menuconfig}" == "true" ]]; then
    make menuconfig
    if [[ $? -ne 0 ]]; then
      ECHOY "窗口分辨率太小，无法弹出设置更机型或插件的窗口"
      ECHOG "请调整窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
      XUANMA="请输入您的选择"
      while :; do
      read -p " ${XUANMA}：" Make
      case $Make in
      [Yy])
	op_menuconfig
	break
      ;;
      [Nn])
	exit 1
	break
      ;;
      *)
        XUANMA="输入错误,请输入[Y/n]"
      ;;
      esac
      done
    fi
  fi
}

function make_defconfig() {
  ECHOG "正在生成配置文件，请稍后..."
  cd ${HOME_PATH}
  source "${BUILD_PATH}/common.sh" && Diy_prevent
  if [[ -f ${HOME_PATH}/EXT4 ]] || [[ -f ${HOME_PATH}/Chajianlibiao ]]; then
    read -t 30 -p " [如需重新编译请按输入[ Y/y ]回车确认，直接回车则为否](不作处理,30秒自动跳过)： " MNUu
    case $MNUu in
    [Yy])
      rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
      sleep 1
      exit 1
    ;;
    *)
      rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
      ECHOG "继续编译中...！"
    ;;
    esac
  fi
  source "${BUILD_PATH}/common.sh" && Diy_menu2
}

function tixing_op_config() {
  export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}")"
  export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}")"
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}"` == '0' ]]; then
    export TARGET_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export TARGET_PROFILE="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE})"
  fi
  export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
  if [[ -z "${TARGET_PROFILE}" ]]; then
    if [[ -f ${BUILD_PATH}/.config ]]; then
      cp -Rf ${BUILD_PATH}/.config ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}
      tixing_op_config
    else
      TARGET_PROFILE="OP_DIY/${matrixtarget}没有${CONFIG_FILE}文件,或者${CONFIG_FILE}文件内容为空"
    fi
  fi
}

function chenggong_op_config() {
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${BUILD_PATH}/.config"` -eq '1' ]]; then
    export CG_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" ${BUILD_PATH}/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" "${BUILD_PATH}/.config"` == '0' ]]; then
    export CG_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" "${BUILD_PATH}/.config"` -eq '1' ]]; then
    export CG_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" "${BUILD_PATH}/.config" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export CG_PROFILE="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${BUILD_PATH}/.config)"
  fi
  [[ -z "${CG_PROFILE}" ]] && CG_PROFILE="未知"
}

function op_upgrade2() {
  cd ${HOME_PATH}
  export Upgrade_Date="$(date +%Y%m%d%H%M)"
  if [ "${REGULAR_UPDATE}" == "true" ]; then
    source ${BUILD_PATH}/upgrade.sh && Diy_Part2
  fi
}

function op_download() {
  cd ${HOME_PATH}
  ECHOG "下载DL文件，请耐心等候..."
  rm -rf ${HOME_PATH}/build.log
  make -j8 download |tee ${HOME_PATH}/build.log
  find dl -size -1024c -exec ls -l {} \;
  find dl -size -1024c -exec rm -f {} \;
  if [[ `grep -c "make with -j1 V=s or V=sc" ${HOME_PATH}/build.log` == '0' ]] || [[ `grep -c "ERROR" ${HOME_PATH}/build.log` == '0' ]] || [[ `grep -c "error" ${HOME_PATH}/build.log` == '0' ]]; then
    print_ok "DL文件下载成功"
  else
    clear
    echo
    print_error "下载DL失败，更换节点后再尝试下载？"
    QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出编译"
    while :; do
      read -p " [${QLMEUN}]： " XZDLE
      case $XZDLE in
      [Yy])
        op_download
      break
      ;;
      [Nn])
        ECHOR "退出编译程序!"
        sleep 2
        exit 1
       break
       ;;
       *)
         QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或现在输入[N/n]回车,退出编译"
       ;;
       esac
    done
  fi
}

function op_cpuxinghao() {
  cd ${HOME_PATH}
  rm -rf build.log
  Model_Name="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
  Cpu_Cores="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"
  clear
  ECHOG "您的CPU型号为[ ${Model_Name} ]"
  ECHOG "在Ubuntu使用核心数为[ ${Cpu_Cores} ],线程数为[ $(nproc) ]"
  if [[ ${matrixtarget} == "openwrt_amlogic" ]]; then
    ECHOG "使用[ ${matrixtarget} ]文件夹，编译[ N1和晶晨系列盒子专用固件 ]"
  else
    ECHOG "使用[ ${matrixtarget} ]文件夹，编译[ ${TARGET_PROFILE} ]"
  fi
  if [[ "$(nproc)" == "1" ]]; then
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[3.5]小时左右,请耐心等待..."
  elif [[ "$(nproc)" =~ (2|3) ]]; then
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[3]小时左右,请耐心等待..."
  elif [[ "$(nproc)" =~ (4|5) ]]; then
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[2.5]小时左右,请耐心等待..."
  elif [[ "$(nproc)" =~ (6|7) ]]; then
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[2]小时左右,请耐心等待..."
  elif [[ "$(nproc)" =~ (8|9) ]]; then
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[1.5]小时左右,请耐心等待..."
  else
    ECHOY "正在使用[$(nproc)线程]编译固件,预计要[1]小时左右,请耐心等待..."
    ECHOG "若您的CPU线程数超过16线程的话，强制使用16线程编译"
  fi
  sleep 3
}

function op_make() {
  cd ${HOME_PATH}
  rm -rf build.log
  export START_TIME=`date +'%Y-%m-%d %H:%M:%S'`
  ECHOG "正在编译固件，请耐心等待..."
  [[ -d "${TARGET_BSGET}" ]] && rm -fr ${TARGET_BSGET}/*
  rm -rf ${HOME_PATH}/{README,README.md,README_EN.md} > /dev/null 2>&1
  ./scripts/diffconfig.sh > ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}
  if [[ "${WSL_ubuntu}" == "YES" ]]; then
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  fi
  if [[ "$(nproc)" -ge "16" ]];then
    make -j$(nproc)
  else
    make -j16
  fi
  if [[ "${WSL_ubuntu}" == "YES" ]]; then
    export PATH=$PATH:'/mnt/c/windows'
  fi
  if [[ `ls -a ${TARGET_BSGET} | grep -c "${TARGET_BOARD}"` == '0' ]]; then
    rm -rf ${LOCAL_Build}/chenggong > /dev/null 2>&1
    rm -rf ${LOCAL_Build}/weiwan > /dev/null 2>&1
    echo "shibai" >${LOCAL_Build}/shibai
    rm -rf ${HOME_PATH}/dl
    print_error "编译失败，请再次尝试编译试试~~!"
    sleep 1
    exit 1
  else
    rm -rf ${LOCAL_Build}/shibai > /dev/null 2>&1
    rm -rf ${LOCAL_Build}/weiwan > /dev/null 2>&1
    echo "chenggong" >${LOCAL_Build}/chenggong
    ./scripts/diffconfig.sh > ${BUILD_PATH}/.config
    export GUJIAN_TIME=`date +'%Y%m%d%H%M'`
  fi
}

function op_upgrade3() {
  cd ${HOME_PATH}
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    [[ -d "${HOME_PATH}/bin/Firmware" ]] && rm -fr ${HOME_PATH}/bin/Firmware/*
    [[ -d "${HOME_PATH}/upgrade" ]] && rm -rf ${HOME_PATH}/upgrade
    cp -Rf ${TARGET_BSGET} ${HOME_PATH}/upgrade
    source ${BUILD_PATH}/upgrade.sh && Diy_Part3
  fi
  if [[ `ls -a ${HOME_PATH}/bin/Firmware | grep -c "${Upgrade_Date}"` -ge '1' ]]; then
    print_ok "加入‘定时升级插件的固件’操作完成"
    export dsgx="加入‘定时升级插件的固件’已经放入[bin/Firmware]文件夹中"
  else
    export dsgx="加入‘定时升级固件插件’的固件失败，您的机型或者不支持定时更新!"
  fi
  cd ${TARGET_BSGET}
  rename -v "s/^immortalwrt/openwrt/" * > /dev/null 2>&1
  if [[ -f ${GITHUB_WORKSPACE}/Clear ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/Clear ${TARGET_BSGET}/Clear.sh
    chmod +x Clear.sh && source Clear.sh
    rm -rf Clear.sh
  fi
  rename -v "s/^openwrt/${SOURCE}-${GUJIAN_TIME}/" * > /dev/null 2>&1
  rename -v "s/sha256sums/${SOURCE}-${GUJIAN_TIME}-sha256sums/" * > /dev/null 2>&1
  cd ${HOME_PATH}
}

function op_amlogic() {
  cd ${GITHUB_WORKSPACE}
  if [[ `ls -1 "${HOME_PATH}/bin/targets/armvirt/64" | grep -c "tar.gz"` == '0' ]]; then
    mkdir -p "${HOME_PATH}/bin/targets/armvirt/64"
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
  if [[ ! -d "/home/dan/amlogic" ]]; then
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
    judge "内核运行文件下载"
    rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d "${GITHUB_WORKSPACE}/amlogic" ]] && [[  ! -f "${GITHUB_WORKSPACE}/amlogic/make" ]]; then
    ECHOGG "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf "${GITHUB_WORKSPACE}/amlogic"
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
    judge "内核运行文件下载"
    rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  elif [[ -d "${GITHUB_WORKSPACE}/amlogic" ]] && [[  ! -d "${GITHUB_WORKSPACE}/amlogic/amlogic-s9xxx" ]]; then
    ECHOGG "发现已存在的打包程序缺少文件，请输入ubuntu密码删除打包程序重新下载"
    sudo rm -rf "${GITHUB_WORKSPACE}/amlogic"
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
    judge "内核运行文件下载"
    rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  fi
  [ -d amlogic/openwrt-armvirt ] || mkdir -p amlogic/openwrt-armvirt
  ECHOY "全部可打包机型：s905x3_s905x2_s905x_s905w_s905d_s922x_s912"
  ECHOGG "设置要打包固件的机型[ 直接回车则默认全部机型 ]"
  export root_size="$(egrep -o ROOT_MB=\"[0-9]+\" "$GITHUB_WORKSPACE/amlogic/make" |cut -d "=" -f2 |sed 's/\"//g' )"
  read -p " 请输入您要设置的机型：" amlogic_model
  export amlogic_model=${amlogic_model:-"s905x3_s905x2_s905x_s905w_s905d_s922x_s912"}
  ECHOYY "您设置的机型为：${amlogic_model}"
  echo
  ECHOGG "设置打包的内核版本[直接回车则默认自动检测最新内核]"
  read -p " 请输入您要设置的内核：" amlogic_kernel
  export amlogic_kernel=${amlogic_kernel:-"5.10.100_5.4.180 -a true"}
  if [[ "${amlogic_kernel}" == "5.10.100_5.4.180 -a true" ]]; then
    ECHOYY "您设置的内核版本为：自动检测最新版内核打包"
  else
    ECHOYY "您设置的内核版本为：${amlogic_kernel}"
  fi
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认：${root_size} ]"
  read -p " 请输入ROOTFS分区大小：" rootfs_size
  export rootfs_size=${rootfs_size:-"${root_size}"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs_size}"
  export make_size="$(egrep -o ROOT_MB=\"[0-9]+\" "$GITHUB_WORKSPACE/amlogic/make")"
  export zhiding_size="ROOT_MB=\"${rootfs_size}\""
  sed -i "s?${make_size}?${zhiding_size}?g" "$GITHUB_WORKSPACE/amlogic/make"
  echo
  ECHOGG "请输入ubuntu密码进行固件打包程序"
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/out/*
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/*
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/amlogic-s9xxx/amlogic-kernel/*
  cp -Rf ${HOME_PATH}/bin/targets/armvirt/64/*.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
  if [[ `ls -a amlogic/openwrt-armvirt | grep -c "openwrt-armvirt-64-default-rootfs.tar.gz"` == '0' ]]; then
    print_error "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    print_error "请检查${HOME_PATH}/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd amlogic
  sudo chmod +x make
  sudo ./make -d -b ${amlogic_model} -k ${amlogic_kernel}
  if [[ `ls -a ${GITHUB_WORKSPACE}/amlogic/out | grep -c "openwrt"` -ge '1' ]]; then
    print_ok "打包完成，固件存放在[amlogic/out]文件夹"
    if [[ "${WSL_ubuntu}" == "YES" ]]; then
      cd ${GITHUB_WORKSPACE}/amlogic/out
      explorer.exe .
      cd amlogic
    fi
  else
    print_error "打包失败，请再次尝试!"
  fi
  [[ -d ${HOME_PATH} ]] && cd ${HOME_PATH}
}

function op_end() {
  clear
  echo
  echo
  cd ${HOME_PATH}
  if [[ ${matrixtarget} == "openwrt_amlogic" ]]; then
    print_ok "使用[ ${matrixtarget} ]文件夹，编译[ N1和晶晨系列盒子专用固件 ]顺利编译完成~~~"
  else
    print_ok "使用[ ${matrixtarget} ]文件夹，编译[ ${TARGET_PROFILE} ]顺利编译完成~~~"
  fi
  ECHOY "后台地址: ${IP}"
  ECHOY "用户名: root"
  ECHOY "固件已经存入${TARGET_OPENWRT}文件夹中"
  [[ "${REGULAR_UPDATE}" == "true" ]] && ECHOY "${dsgx}"
  if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
    ECHOR "提示：再次输入编译命令可选择二次编译或者打包N1和晶晨系列盒子专用固件"
  else
    ECHOR "提示：再次输入编译命令可进行二次编译"
  fi
  if [[ "${WSL_ubuntu}" == "YES" ]]; then
    if [[ "${REGULAR_UPDATE}" == "true" ]]; then
      cd bin/Firmware
      explorer.exe .
      cd ${HOME_PATH}
    else
      cd ${TARGET_BSGET}
      explorer.exe .
      cd ${HOME_PATH}
    fi
  fi
  ECHOY "编译日期：$(date +'%Y年%m月%d号')"
  export END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
  START_SECONDS=$(date --date="$START_TIME" +%s)
  END_SECONDS=$(date --date="$END_TIME" +%s)
  SECONDS=$((END_SECONDS-START_SECONDS))
  HOUR=$(( $SECONDS/3600 ))
  MIN=$(( ($SECONDS-${HOUR}*3600)/60 ))
  SEC=$(( $SECONDS-${HOUR}*3600-${MIN}*60 ))
  if [[ "${HOUR}" == "0" ]]; then
    ECHOG "编译总计用时 ${MIN}分${SEC}秒"
  else
    ECHOG "编译总计用时 ${HOUR}时${MIN}分${SEC}秒"
  fi
}

function op_firmware() {
  if [[ "${matrixtarget}" == "Lede_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lede_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lede_source"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lede_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Lienol_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lienol_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lienol_source"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lienol_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Tianling_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Tianling_core" 2>/dev/null)" ]]; then
    export matrixtarget="Tianling_source"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Tianling_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Mortal_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Mortal_core" 2>/dev/null)" ]]; then
    export matrixtarget="Mortal_source"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Mortal_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "openwrt_amlogic" ]] || [[ -n "$(ls -A "${HOME_PATH}/.amlogic_core" 2>/dev/null)" ]]; then
    export matrixtarget="openwrt_amlogic"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".amlogic_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  fi
}

function openwrt_qx() {
    cd ${GITHUB_WORKSPACE}
    if [[ -d ${HOME_PATH} ]]; then
      ECHOG "正在删除已存在的openwrt文件夹,请稍后..."
      rm -rf ${HOME_PATH}
    fi
}

function openwrt_gitpull() {
  cd ${HOME_PATH}
  ECHOG "git pull上游源码"
  if [[ ! -d ${HOME_PATH}/feeds ]]; then
    ./scripts/feeds update -a
  fi
  
  git reset --hard
  if [[ `grep -c "webweb.sh" ${ZZZ_PATH}` -ge '1' ]]; then
    git reset --hard
  fi
  git pull
  ECHOG "同步上游源码完毕,开始编译固件"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_upgrade1() {
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source $BUILD_PATH/upgrade.sh && Diy_Part1
  fi
}

function op_again() {
  export Tishi="1"
  cd ${HOME_PATH}
  op_firmware
  bianyi_xuanxiang
  op_common_sh
  op_diy_ip
  op_diywenjian
  op_jiaoben
  openwrt_gitpull
  op_kongjian
  op_menuconfig
  make_defconfig
  op_upgrade2
  op_download
  op_make
  op_upgrade3
  op_end
}

function openwrt_tow() {
  bianyi_xuanxiang
  op_common_sh
  openwrt_qx
  op_firmware
  op_kongjian
  op_diywenjian
  op_repo_branch
  op_jiaoben
  op_diy_zdy
  op_diy_ip
  op_menuconfig
  make_defconfig
  op_upgrade2
  op_download
  op_cpuxinghao
  op_make
  op_upgrade3
  op_end
}

function openwrt_new() {
  op_common_sh
  openwrt_qx
  op_firmware
  op_kongjian
  op_diywenjian
  bianyi_xuanxiang
  op_repo_branch
  op_jiaoben
  op_diy_zdy
  op_diy_ip
  op_menuconfig
  make_defconfig
  op_upgrade2
  op_download
  op_cpuxinghao
  op_make
  op_upgrade3
  op_end
}

function menu() {
  ECHOG "正在加载数据中，请稍后..."
  cd ${GITHUB_WORKSPACE}
  curl -fsSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/x86/Makefile > Makefile
  export ledenh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/22.03/target/linux/x86/Makefile > Makefile
  export lienolnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-21.02/target/linux/x86/Makefile > Makefile
  export mortalnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-18.06/target/linux/x86/Makefile > Makefile
  export tianlingnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  rm -rf Makefile
  clear
  clear
  echo
  ECHOB "  请选择编译源码"
  ECHOY " 1. Lede_${ledenh}内核,LUCI 18.06版本(Lede_source)"
  ECHOYY " 2. Lienol_${lienolnh}内核,LUCI 22.03版本(Lienol_source)"
  echo
  ECHOYY " 3. Immortalwrt_${tianlingnh}内核,LUCI 18.06版本(Tianling_source)"
  ECHOY " 4. Immortalwrt_${mortalnh}内核,LUCI 21.02版本(Mortal_source)"
  ECHOYY " 5. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
  ECHOY " 6. 单独打包晶晨系列固件(前提是您要有armvirt的.tar.gz固件)"
  ECHOYY " 7. 退出编译程序"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      export matrixtarget="Lede_source"
      ECHOG "您选择了：Lede_${ledenh}内核,LUCI 18.06版本"
      openwrt_new
    break
    ;;
    2)
      export matrixtarget="Lienol_source"
      ECHOG "您选择了：Lienol_${lienolnh}内核,LUCI 22.03版本"
      openwrt_new
    break
    ;;
    3)
      export matrixtarget="Tianling_source"
      ECHOG "您选择了：Immortalwrt_${tianlingnh}内核,LUCI 18.06版本"
      openwrt_new
    break
    ;;
    4)
      export matrixtarget="Mortal_source"
      ECHOG "您选择了：Immortalwrt_${mortalnh}内核,LUCI 21.02版本"
      openwrt_new
    break
    ;;
    5)
      export matrixtarget="openwrt_amlogic"
      ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
      openwrt_new
    break
    ;;
    6)
      ECHOG "您选择了单独打包晶晨系列固件"
      export matrixtarget="openwrt_amlogic"
      op_common_sh
      op_amlogic
    break
    ;;
    7)
      ECHOR "您选择了退出编译程序"
      echo
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号!"
    ;;
    esac
    done
}

function Menu_requirements() {
  op_firmware > /dev/null 2>&1
  source ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  tixing_op_config > /dev/null 2>&1
  chenggong_op_config > /dev/null 2>&1
  if [[ -f ${LOCAL_Build}/shibai ]] ; then
    SHANGCIZHUANGTAI="失败"
  elif [[ -f ${LOCAL_Build}/weiwan ]] ; then
    SHANGCIZHUANGTAI="未完成"
  elif [[ -f ${LOCAL_Build}/chenggong ]] ; then
    SHANGCIZHUANGTAI="成功"
  else
    SHANGCIZHUANGTAI="未知"
  fi
  cd ${GITHUB_WORKSPACE}
}

function menuop() {
  Menu_requirements
  clear
  echo
  echo
  echo -e " ${Blue}当前使用源码${Font}：${Yellow}${matrixtarget}${Font}"
  echo -e " ${Blue}成功编译过的机型${Font}：${Yellow}${CG_PROFILE}${Font}"
  echo -e " ${Blue}OP_DIY配置文件机型${Font}：${Yellow}${TARGET_PROFILE}${Font}"
  echo -e " ${Blue}上回编译操作${Font}：${Yellow}${SHANGCIZHUANGTAI}${Font}"
  echo
  echo
  echo -e " 1${Red}.${Font}${Green}保留缓存同步上游仓库源码,再次编译${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}删除现有源码,重新下载[${matrixtarget}]源码再编译${Font}"
  echo
  echo -e " 3${Red}.${Font}${Green}同步上游OP_DIY文件(不覆盖config配置文件)${Font}"
  echo
  echo -e " 4${Red}.${Font}${Green}打包N1和晶晨系列CPU固件${Font}"
  echo
  echo -e " 5${Red}.${Font}${Green}更换其他作者源码编译${Font}"
  echo
  echo -e " 6${Red}.${Font}${Green}退出${Font}"
  echo
  echo
  XUANZop="请输入数字"
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    op_again
  break
  ;;
  2)
    openwrt_tow
  break
  ;;
  3)
    gengxin_opdiy
  break
  ;;
  4)
    op_amlogic
  break
  ;;
  5)
    menu
  break
  ;;
  6)
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

if [[ -d "${HOME_PATH}/package" && -d "${HOME_PATH}/target" && -d "${HOME_PATH}/toolchain" && -d "${HOME_PATH}/build" && -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
	menuop "$@"
else
	menu "$@"
fi
