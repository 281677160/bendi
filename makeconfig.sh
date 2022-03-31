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
export OP_DIY="${GITHUB_WORKSPACE}/CONFIG_DIY"
export HOME_PATH="${GITHUB_WORKSPACE}/op_config"
export LOCAL_Build="${HOME_PATH}/build"
export BASE_PATH="${HOME_PATH}/package/base-files/files"
export NETIP="${HOME_PATH}/package/base-files/files/etc/networkip"
export DELETE="${HOME_PATH}/package/base-files/files/etc/deletefile"
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
if [[ "$(echo ${GITHUB_WORKSPACE} |grep -c 'op_config')" -ge '1' ]]; then
  print_error "请注意命令的执行路径,并非在op_config文件夹内执行,如果您ubuntu或机器就叫op_config的话,恭喜您,就是不给您用,改名吧少年!"
  exit 0
fi
if [[ `ls -1 /mnt/* | grep -c "Windows"` -ge '1' ]] || [[ `ls -1 /mnt | grep -c "wsl"` -ge '1' ]]; then
  export WSL_ubuntu="YES"
else
  export WSL_ubuntu="NO"
fi

function op_busuhuanjing() {
cd ${GITHUB_WORKSPACE}
  clear
  echo
  ECHORR "|*******************************************|"
  ECHOGG "|                                           |"
  ECHOYY "|    首次编译,请输入Ubuntu密码继续下一步    |"
  ECHOGG "|                                           |"
  ECHOYY "|              编译环境部署                 |"
  ECHORR "|                                           |"
  ECHOGG "|*******************************************|"
  echo
  sudo apt-get update -y
  sudo apt-get full-upgrade -y
  sudo -E apt-get -qq install -y git subversion git-core wget curl grep
  judge "部署Ubuntu环境"
  sudo apt-get autoremove -y --purge > /dev/null 2>&1
  sudo apt-get clean -y > /dev/null 2>&1
}

function op_diywenjian() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]]; then
    rm -rf bendi && git clone https://github.com/281677160/build-actions bendi
    mv -f ${GITHUB_WORKSPACE}/bendi/build ${GITHUB_WORKSPACE}/CONFIG_DIY
    rm -rf ${GITHUB_WORKSPACE}/CONFIG_DIY/*/start-up
    rm -rf ${GITHUB_WORKSPACE}/CONFIG_DIY/*/.config
    if [[ -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]]; then
      rm -rf bendi && git clone https://github.com/281677160/common bendi
      judge  "CONFIG_DIY文件下载"
      cp -Rf ${GITHUB_WORKSPACE}/bendi/OP_DIY/* ${GITHUB_WORKSPACE}/CONFIG_DIY/
    else
      print_error "CONFIG_DIY文件下载失败"
      exit 1
    fi
    rm -rf ${GITHUB_WORKSPACE}/bendi
  fi
}

function bianyi_xuanxiang() {
  cd ${GITHUB_WORKSPACE}
  [[ ! -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]] && op_diywenjian
  source $GITHUB_WORKSPACE/CONFIG_DIY/${matrixtarget}/settings.ini
  if [[ "${EVERY_INQUIRY}" == "true" ]]; then
    ECHOY "请在 CONFIG_DIY/${matrixtarget} 里面设置好自定义文件，主要是您要增加的插件，需要跟您的云端同步增加"
    ZDYSZ="设置完毕后，按[Y/y]回车继续编译"
    [[ "${WSL_ubuntu}" == "YES" ]] && explorer.exe .
    while :; do
      read -p " ${ZDYSZ}： " ZDYSZU
      case $ZDYSZU in
      [Yy])
        echo
      break
      ;;
      *)
        ZDYSZ="确认设置完毕后，请按[Y/y]回车继续编译"
      ;;
      esac
    done
  fi
  echo
  echo
  source ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  tixing_op_config > /dev/null 2>&1
  echo
  echo -e "${Red} 提示${Font}：${Blue}您当前CONFIG_DIY自定义文件夹的配置机型为[${TARGET_PROFILE}]${Font}"
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
  sleep 2
}

function op_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  echo
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf op_config && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" op_config
  judge "${matrixtarget}源码下载"
}

function op_jiaoben() {
  if [[ ! -d ${HOME_PATH}/build ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/CONFIG_DIY ${HOME_PATH}/build
  else
    cp -Rf ${GITHUB_WORKSPACE}/CONFIG_DIY/* ${HOME_PATH}/build/
  fi
  [[ "${Tishi}" == "1" ]] && sed -i '/-rl/d' "${BUILD_PATH}/${DIY_PART_SH}"
  rm -rf ${HOME_PATH}/build/common && git clone https://github.com/281677160/common ${HOME_PATH}/build/common
  judge "额外扩展文件下载"
  rm -rf ${HOME_PATH}/build/common/OP_DIY
  mv -f ${LOCAL_Build}/common/*.sh ${BUILD_PATH}
  chmod -R +x ${BUILD_PATH}
  source "${BUILD_PATH}/common.sh" && Bendi_variable
}

function op_diy_zdy() {
  ECHOG "正在下载插件包和更新feeds,请耐心等候~~~"
  cd ${HOME_PATH}
  source "${BUILD_PATH}/settings.ini"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_diy_ip() {
  cd ${HOME_PATH}
  IP="$(grep 'network.lan.ipaddr=' ${BUILD_PATH}/$DIY_PART_SH |cut -f1 -d# |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  [[ -z "${IP}" ]] && IP="$(grep 'ipaddr:' ${HOME_PATH}/package/base-files/files/bin/config_generate |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  echo "${Mark_Core}" > ${HOME_PATH}/${Mark_Core}
  echo
  ECHOY "您的后台IP地址为：$IP"
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
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
      ECHOG "正在制作配置文件...！"
    ;;
    esac
  fi
  source "${BUILD_PATH}/common.sh" && Diy_menu2 > /dev/null 2>&1
  rm -rf "${OP_DIY}/${matrixtarget}/${CONFIG_FILE}"
  ./scripts/diffconfig.sh > "${OP_DIY}/${matrixtarget}/${CONFIG_FILE}"
}

function op_end() {
  cd ${HOME_PATH}
  print_ok "配置文件制作完成，已经覆盖进[CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}]文件中"
  [[ "${WSL_ubuntu}" == "YES" ]] && explorer.exe .
  echo
}

function tixing_op_config() {
  export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}")"
  export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}")"
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` == '0' ]]; then
    export TARGET_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export TARGET_PROFILE="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE})"
  fi
  export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
  [[ -z "${TARGET_PROFILE}" ]] && TARGET_PROFILE="CONFIG_DIY/${matrixtarget}没有${CONFIG_FILE}文件,或者${CONFIG_FILE}文件内容为空"
}

function op_firmware() {
  if [[ "${matrixtarget}" == "Lede_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lede_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lede_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lede_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Lienol_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lienol_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lienol_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lienol_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Tianling_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Tianling_core" 2>/dev/null)" ]]; then
    export matrixtarget="Tianling_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Tianling_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Mortal_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Mortal_core" 2>/dev/null)" ]]; then
    export matrixtarget="Mortal_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Mortal_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "openwrt_amlogic" ]] || [[ -n "$(ls -A "${HOME_PATH}/.amlogic_core" 2>/dev/null)" ]]; then
    export matrixtarget="openwrt_amlogic"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".amlogic_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  fi
}

function openwrt_qx() {
    cd ${GITHUB_WORKSPACE}
    if [[ -d ${GITHUB_WORKSPACE}/op_config ]]; then
      ECHOGG "正在删除已存在的op_config文件夹"
      rm -rf ${HOME_PATH}
    fi
}

function openwrt_gitpull() {
  cd ${HOME_PATH}
  ECHOG "git pull上游源码"
  git reset --hard
  if [[ `grep -c "webweb.sh" ${ZZZ_PATH}` -ge '1' ]]; then
    git reset --hard
  fi
  if [[ `grep -c "webweb.sh" ${ZZZ_PATH}` -ge '1' ]]; then
    print_error "同步上游源码失败,请检查网络"
    exit 1
  fi
  git pull
  ECHOG "同步上游源码完毕,开始制作配置文件"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_upgrade1() {
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source $BUILD_PATH/upgrade.sh && Diy_Part1
  fi
}

function op_again() {
  cd ${HOME_PATH}
  op_firmware
  bianyi_xuanxiang
  op_diy_ip
  op_diywenjian
  op_jiaoben
  openwrt_gitpull
  op_menuconfig
  make_defconfig
  op_end
}

function openwrt_new() {
  openwrt_qx
  op_busuhuanjing
  op_firmware
  op_diywenjian
  bianyi_xuanxiang
  op_repo_branch
  op_jiaoben
  op_diy_zdy
  op_diy_ip
  op_menuconfig
  make_defconfig
  op_end
}

function menu() {
  ECHOG "正在加载数据中，请稍后..."
  cd ${GITHUB_WORKSPACE}
  curl -fsSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/x86/Makefile > Makefile
  export ledenh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/main/target/linux/x86/Makefile > Makefile
  export lienolnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-21.02/target/linux/x86/Makefile > Makefile
  export mortalnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-18.06/target/linux/x86/Makefile > Makefile
  export tianlingnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  rm -rf Makefile
  clear
  clear
  echo
  ECHOB "  请选择制作配置文件的源码"
  ECHOY " 1. Lede_${ledenh}内核,LUCI 18.06版本(Lede_source)"
  ECHOYY " 2. Lienol_${lienolnh}内核,LUCI Master版本(Lienol_source)"
  echo
  ECHOYY " 3. Immortalwrt_${tianlingnh}内核,LUCI 18.06版本(Tianling_source)"
  ECHOY " 4. Immortalwrt_${mortalnh}内核,LUCI 21.02版本(Mortal_source)"
  ECHOYY " 5. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
  ECHOYY " 6. 退出编译程序"
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
      ECHOG "您选择了：Lienol_${lienolnh}内核,LUCI Master版本"
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
      ECHOR "您选择了退出编译程序"
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
  source ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  tixing_op_config > /dev/null 2>&1
  cd ${GITHUB_WORKSPACE}
}

function menuop() {
  Menu_requirements
  clear
  echo
  echo
  echo -e " ${Blue}当前使用源码${Font}：${Green}${matrixtarget}${Font}"
  echo -e " ${Blue}CONFIG_DIY配置文件机型${Font}：${Green}${TARGET_PROFILE}${Font}"
  echo
  echo
  echo -e " 1${Green}.${Font}${Yellow}使用[${matrixtarget}]源码,再次制作配置文件${Font}"
  echo
  echo -e " 2${Green}.${Font}${Yellow}更换其他作者源码制作配置文件${Font}"
  echo
  echo -e " 3${Green}.${Font}${Yellow}退出${Font}"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    Tishi="1"
    op_again
  break
  ;;
  2)
    menu
  break
  ;;   
  3)
    exit 0
    break
  ;;
  *)
    XUANZHE="请输入正确的数字编号!"
  ;;
  esac
  done
}

if [[ -d "${HOME_PATH}/package" && -d "${HOME_PATH}/target" && -d "${HOME_PATH}/toolchain" && -d "${GITHUB_WORKSPACE}/CONFIG_DIY" ]]; then
	menuop "$@"
else
	menu "$@"
fi
