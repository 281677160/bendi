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
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export LOCAL_Build="${GITHUB_WORKSPACE}/openwrt/build"
export BASE_PATH="${GITHUB_WORKSPACE}/openwrt/package/base-files/files"
export NETIP="${HOME_PATH}/package/base-files/files/etc/networkip"
export DELETE="${HOME_PATH}/package/base-files/files/etc/deletefile"
export date1="$(date +'%m-%d')"

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
  print_error "请注意命令的执行路径,并非在openwrt文件夹内执行,如果您ubuntu就叫openwrt的话,贡献您,就是不给您用,改名吧少年!"
  exit 0
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
  sudo apt-get install -y systemd build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl rename libpcap0.8-dev swig rsync
  judge "部署编译环境"
  sudo apt-get autoremove -y --purge
  sudo apt-get clean -y
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
    rm -rf bendi && git clone https://github.com/281677160/bendi ${GITHUB_WORKSPACE}/bendi
    judge "OP_DIY文件下载"
    cp -Rf ${GITHUB_WORKSPACE}/bendi/OP_DIY ${GITHUB_WORKSPACE}/OP_DIY
    rm -rf ${GITHUB_WORKSPACE}/bendi
  fi
}

function bianyi_xuanxiang() {
  cd ${GITHUB_WORKSPACE}
  [[ ! -d ${GITHUB_WORKSPACE}/OP_DIY ]] && op_diywenjian
  source $GITHUB_WORKSPACE/OP_DIY/${matrixtarget}/settings.ini
  if [[ "${EVERY_INQUIRY}" == "true" ]]; then
    ECHOY "请在 OP_DIY/${matrixtarget} 里面设置好自定义文件"
    ZDYSZ="设置完毕后，按[Y/y]回车继续编译"
    explorer.exe .
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
  source ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  tixing_op_config > /dev/null 2>&1
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
  sleep 2
}

function op_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  echo
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf openwrt && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" openwrt
  judge "${matrixtarget}源码下载"
}

function amlogic_s9xxx() {
  if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
    ECHOY "正在下载打包所需的内核,请耐心等候~~~"
    if [[ -d ${GITHUB_WORKSPACE}/amlogic/amlogic-s9xxx ]]; then
      ECHOGG "发现老旧晶晨内核文件存在，请输入ubuntu密码删除老旧内核"
      sudo rm -rf ${GITHUB_WORKSPACE}/amlogic
    fi
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
    judge "内核运行文件下载"
    rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,LICENSE,README.cn.md,README.md,.github,.git}
  fi
}

function op_jiaoben() {
  cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/* ${HOME_PATH}/build/
  rm -rf ${HOME_PATH}/build/common && git clone https://github.com/281677160/common ${HOME_PATH}/build/common
  judge "额外扩展脚本下载"
  mv -f ${LOCAL_Build}/common/*.sh ${BUILD_PATH}
  chmod -R +x ${BUILD_PATH}
}

function op_diy_zdy() {
  ECHOG "正在下载插件包,请耐心等候~~~"
  cd ${HOME_PATH}
  source "${BUILD_PATH}/settings.ini"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}
  
function op_diy_ip() {
  cd ${HOME_PATH}
  IP="$(grep 'network.lan.ipaddr=' ${BUILD_PATH}/$DIY_PART_SH |cut -f1 -d# |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  [[ -z "${IP}" ]] && IP="$(grep 'ipaddr:' ${HOME_PATH}/package/base-files/files/bin/config_generate |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")"
  echo "${Core}" > ${HOME_PATH}/${Core}
  echo
  ECHOYY "您的后台IP地址为：$IP"
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    export Github=${Github}
    ECHOY "您的Github地址为：$Github"
    export Apidz="${Github##*com/}"
    export Author="${Apidz%/*}"
    export CangKu="${Apidz##*/}"
  fi
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
  source "${BUILD_PATH}/common.sh" && Diy_menu2
  ./scripts/diffconfig.sh > ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/${CONFIG_FILE}
  if [[ -f ${HOME_PATH}/EXT4 ]] || [[ -f ${HOME_PATH}/Chajianlibiao ]]; then
    read -t 30 -p " [如需重新编译请按输入[ Y/y ]回车确认，直接回车则为否](不作处理,30秒自动跳过)： " MNUu
    case $MNUu in
    [Yy])
      sleep 1
      exit 1
    ;;
    *)
      ECHOG "继续编译中...！"
    ;;
    esac
  fi
  rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4} > /dev/null 2>&1
}

function op_config() {
  cd ${HOME_PATH}
  source "${BUILD_PATH}/common.sh" && Make_upgrade
}

function tixing_op_config() {
  cd ${HOME_PATH}
  export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config")"
  export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config")"
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config"` -eq '1' ]]; then
    export TARGET_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config"` == '0' ]]; then
    export TARGET_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config"` -eq '1' ]]; then
    export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export TARGET_PROFILE="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/config)"
  fi
  export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
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
  rm -fr ${HOME_PATH}/build.log
  make -j4 download 2>&1 |tee ${HOME_PATH}/build.log
  find dl -size -1024c -exec ls -l {} \;
  find dl -size -1024c -exec rm -f {} \;
  if [[ `grep -c "make with -j1 V=s or V=sc" ${HOME_PATH}/build.log` == '0' ]] || [[ `grep -c "ERROR" ${HOME_PATH}/build.log` == '0' ]]; then
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
  if [[ "$(nproc)" -ge "16" ]];then
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j$(($(nproc) + 1)) V=s 2>&1 |tee ${HOME_PATH}/build.log
  else
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j16 V=s 2>&1 |tee ${HOME_PATH}/build.log
  fi
  if [[ `ls -a ${TARGET_BSGET} | grep -c "${TARGET_BOARD}"` == '0' ]]; then
    rm -rf ${LOCAL_Build}/chenggong > /dev/null 2>&1
    echo "shibai" >${LOCAL_Build}/shibai
    print_error "编译失败~~!"
    print_error "请用工具把openwrt文件夹里面的[build.log]日志文件拖至电脑，然后查找失败原因"
    sleep 1
    exit 1
  else
    rm -rf ${LOCAL_Build}/shibai > /dev/null 2>&1
    echo "chenggong" >${LOCAL_Build}/chenggong
    rm -rf ${HOME_PATH}/build.log
  fi
}

function op_upgrade3() {
  cd ${HOME_PATH}
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    rm -fr ${HOME_PATH}/bin/Firmware/* > /dev/null 2>&1
    rm -rf ${HOME_PATH}/upgrade && cp -Rf ${TARGET_BSGET} ${HOME_PATH}/upgrade
    source ${BUILD_PATH}/upgrade.sh && Diy_Part3
  fi
  if [[ `ls -a ${HOME_PATH}/bin/Firmware | grep -c "${Upgrade_Date}"` -ge '1' ]]; then
    print_ok "加入‘定时升级插件的固件’操作完成"
    export dsgx="加入‘定时升级插件的固件’已经放入[bin/Firmware]文件夹中"
    export upgra="1"
  else
    print_error "加入‘定时升级固件插件’的固件失败，您的机型或者不支持定时更新!"
    export upgra="0"
  fi
  cd ${TARGET_BSGET}
  rename -v "s/^immortalwrt/openwrt/" * > /dev/null 2>&1
  if [[ -f ${GITHUB_WORKSPACE}/Clear ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/Clear ${TARGET_BSGET}/Clear.sh
    chmod +x Clear.sh && source Clear.sh
    rm -rf Clear.sh
  fi
  rename -v "s/^openwrt/${SOURCE}/" * > /dev/null 2>&1
  cd ${HOME_PATH}
}

function op_amlogic() {
  cd ${GITHUB_WORKSPACE}
  if [[ `ls -a ${HOME_PATH}/bin/targets/armvirt/* | grep -c "tar.gz"` == '0' ]]; then
    mkdir -p ${HOME_PATH}/bin/targets/armvirt/64
    ECHOY "请先将openwrt-armvirt-64-default-rootfs.tar.gz固件存入"
    ECHOYY "openwrt/bin/targets/armvirt/64文件夹内，再进行打包"
    explorer.exe .
    echo
    exit 1
  fi
  if [[ ! -d ${GITHUB_WORKSPACE}/amlogic/amlogic-s9xxx ]]; then
    amlogic_s9xxx
  fi
  [ -d amlogic/openwrt-armvirt ] || mkdir -p amlogic/openwrt-armvirt
  ECHOY "全部可打包机型：s905x3_s905x2_s905x_s905w_s905d_s922x_s912"
  ECHOGG "设置要打包固件的机型[ 直接回车则默认 Phicomm-N1（s905d）]"
  read -p " 请输入您要设置的机型：" model
  export model=${model:-"s905d"}
  ECHOYY "您设置的机型为：${model}"
  echo
  ECHOGG "设置打包的内核版本[直接回车则默认自动检测最新内核]"
  read -p " 请输入您要设置的内核：" kernel
  export kernel=${kernel:-"5.10.100_5.4.180 -a true"}
  ECHOYY "您设置的内核版本为：自动检测最新版内核打包"
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认 960 ]"
  read -p " 请输入ROOTFS分区大小：" rootfs
  export rootfs=${rootfs:-"960"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs}"
  minsize="$(egrep -o "ROOT_MB=\"[0-9]+\"" ${GITHUB_WORKSPACE}/amlogic/make)"
  rootfssize="ROOT_MB=\"${rootfs}\""
  sed -i "s/${minsize}/${rootfssize}/g" ${GITHUB_WORKSPACE}/amlogic/make
  echo
  ECHOGG "请输入ubuntu密码进行固件打包程序"
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/out/*
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/*
  sudo rm -rf ${GITHUB_WORKSPACE}/amlogic/amlogic-s9xxx/amlogic-kernel/*
  cp -Rf ${HOME_PATH}/bin/targets/armvirt/*/*.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/ && sync
  if [[ `ls -a amlogic/openwrt-armvirt | grep -c "openwrt-armvirt-64-default-rootfs.tar.gz"` == '0' ]]; then
    print_error "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    print_error "请检查${HOME_PATH}/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd amlogic
  sudo chmod +x make
  sudo ./make -d -b ${model} -k ${kernel}
  if [[ `ls -a ${GITHUB_WORKSPACE}/amlogic/out | grep -c "openwrt"` -ge '1' ]]; then
    print_ok "打包完成，固件存放在[amlogic/out]文件夹"
    explorer.exe .
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
  ECHOY "固件已经存入${OPENGUJIAN}文件夹中"
  if [[ "${upgra}" == "1" ]]; then
    ECHOY "${dsgx}"
  fi
  if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
    ECHOR "提示：再次输入编译命令可选择二次编译或者打包N1和晶晨系列盒子专用固件"
  else
    ECHOR "提示：再次输入编译命令可进行二次编译"
  fi
  explorer.exe .
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
    export SOURCE="Lede"
    export Core=".Lede_core"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    export ZZZ_PATH="${HOME_PATH}/package/lean/default-settings/files/zzz-default-settings"
    export LUCI_EDITION="18.06"
    [[ -d "${HOME_PATH}" ]] && echo "Lede_source" > "${HOME_PATH}/.Lede_core"
  fi
  if [[ "${matrixtarget}" == "Lienol_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lienol_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lienol_source"
    export SOURCE="Lienol"
    export Core=".Lienol_core"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    export ZZZ_PATH="${HOME_PATH}/package/default-settings/files/zzz-default-settings"
    export LUCI_EDITION="20.06"
    [[ -d "${HOME_PATH}" ]] && echo "Lienol_source" > "${HOME_PATH}/.Lienol_core"
  fi
  if [[ "${matrixtarget}" == "Tianling_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Tianling_core" 2>/dev/null)" ]]; then
    export matrixtarget="Tianling_source"
    export SOURCE="Tianling"
    export Core=".Tianling_core"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    export ZZZ_PATH="${HOME_PATH}/package/emortal/default-settings/files/99-default-settings"
    export LUCI_EDITION="18.06"
    [[ -d "${HOME_PATH}" ]] && echo "Tianling_source" > "${HOME_PATH}/.Tianling_core"
  fi
  if [[ "${matrixtarget}" == "Mortal_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Mortal_core" 2>/dev/null)" ]]; then
    export matrixtarget="Mortal_source"
    export SOURCE="Mortal"
    export Core=".Mortal_core"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    export ZZZ_PATH="${HOME_PATH}/package/emortal/default-settings/files/99-default-settings"
    export LUCI_EDITION="21.02"
    [[ -d "${HOME_PATH}" ]] && echo "Mortal_source" > "${HOME_PATH}/.Mortal_core"
  fi
  if [[ "${matrixtarget}" == "openwrt_amlogic" ]] || [[ -n "$(ls -A "${HOME_PATH}/.amlogic_core" 2>/dev/null)" ]]; then
    export matrixtarget="openwrt_amlogic"
    export SOURCE="Lede"
    export Core=".amlogic_core"
    export BUILD_PATH="${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}"
    export ZZZ_PATH="${HOME_PATH}/package/lean/default-settings/files/zzz-default-settings"
    export LUCI_EDITION="18.06"
    [[ -d "${HOME_PATH}" ]] && echo "openwrt_amlogic" > "${HOME_PATH}/.amlogic_core"
  fi
}

function openwrt_qx() {
      cd ${GITHUB_WORKSPACE}
      if [[ -d amlogic/amlogic-s9xxx ]]; then
        ECHOGG "发现老旧晶晨内核文件存在，请输入ubuntu密码删除老旧内核"
        sudo rm -rf ${GITHUB_WORKSPACE}/amlogic
      fi
      if [[ -d ${GITHUB_WORKSPACE}/openwrt ]]; then
        ECHOGG "发现老源码存在，正在删除老源码"
        rm -rf ${HOME_PATH}
      fi
}

function openwrt_gitpull() {
  cd ${HOME_PATH}
  git pull
  ./scripts/feeds update -a && ./scripts/feeds install -a
}

function op_continue() {
  cd ${HOME_PATH}
  op_firmware
  op_diywenjian
  op_jiaoben
  op_kongjian
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source $BUILD_PATH/upgrade.sh && Diy_Part1
  fi
  bianyi_xuanxiang
  op_diy_ip
  op_menuconfig
  if [[ "${Menuconfig}" == "true" ]]; then
    source "${BUILD_PATH}/common.sh" && Diy_prevent
  fi
  source "${BUILD_PATH}/common.sh" && Diy_files
  op_config
  op_upgrade2
  op_download
  op_make
  op_upgrade3
  op_end
}

function op_again() {
  cd ${HOME_PATH}
  op_firmware
  op_diywenjian
  op_jiaoben
  openwrt_gitpull
  op_kongjian
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source $BUILD_PATH/upgrade.sh && Diy_Part1
  fi
  bianyi_xuanxiang
  op_diy_ip
  op_menuconfig
  if [[ "${Menuconfig}" == "true" ]]; then
    source "${BUILD_PATH}/common.sh" && Diy_prevent
  fi
  source "${BUILD_PATH}/common.sh" && Diy_files
  op_config
  op_upgrade2
  op_download
  op_make
  op_upgrade3
  op_end
}

function openwrt_new() {
  op_busuhuanjing
  op_firmware
  op_kongjian
  op_diywenjian
  bianyi_xuanxiang
  op_repo_branch
  amlogic_s9xxx
  op_jiaoben
  op_diy_zdy
  op_diy_ip
  op_menuconfig
  make_defconfig
  op_config
  op_upgrade2
  op_download
  op_cpuxinghao
  op_make
  op_upgrade3
  op_end
}

function menu() {
  ECHOB "正在加载信息中，请稍后..."
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
  cd ${GITHUB_WORKSPACE}
  ECHOB "  请选择编译源码"
  ECHOY " 1. Lede_${ledenh}内核,LUCI 18.06版本(Lede_source)"
  ECHOYY " 2. Lienol_${lienolnh}内核,LUCI Master版本(Lienol_source)"
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
      openwrt_qx
      openwrt_new
    break
    ;;
    2)
      export matrixtarget="Lienol_source"
      ECHOG "您选择了：Lienol_${lienolnh}内核,LUCI Master版本"
      openwrt_qx
      openwrt_new
    break
    ;;
    3)
      export matrixtarget="Tianling_source"
      ECHOG "您选择了：Immortalwrt_${tianlingnh}内核,LUCI 18.06版本"
      openwrt_qx
      openwrt_new
    break
    ;;
    4)
      export matrixtarget="Mortal_source"
      ECHOG "您选择了：Immortalwrt_${mortalnh}内核,LUCI 21.02版本"
      openwrt_qx
      openwrt_new
    break
    ;;
    5)
      export matrixtarget="openwrt_amlogic"
      ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
      openwrt_qx
      openwrt_new
    break
    ;;
    6)
      ECHOG "您选择了单独打包晶晨系列固件"
      export firmware="openwrt_amlogic"
      op_busuhuanjing
      op_amlogic
    break
    ;;
    7)
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

function menuop() {
  op_firmware
  tixing_op_config > /dev/null 2>&1
  cd ${GITHUB_WORKSPACE}
  clear
  echo
  echo
  echo -e " ${Blue}当前源码${Font}：${Green}${matrixtarget}${Font}"
  echo -e " ${Blue}编译机型${Font}：${Green}${TARGET_PROFILE}${Font}"
  echo
  echo
  echo -e " 1${Green}.${Font}${Yellow}删除旧源码,使用[${matrixtarget}]源码全新编译${Font}(推荐)"
  echo
  echo -e " 2${Green}.${Font}${Yellow}同步上游固件源码,再次编译${Font}"
  echo
  echo -e " 3${Green}.${Font}${Yellow}不需同步上游固件源码,再次编译${Font}"
  echo
  echo -e " 4${Green}.${Font}${Yellow}更换其他作者源码编译${Font}"
  echo
  echo -e " 5${Green}.${Font}${Yellow}打包N1和晶晨系列CPU固件${Font}"
  echo
  echo -e " 6${Green}.${Font}${Yellow}退出${Font}"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    openwrt_qx
    openwrt_new
  break
  ;;
  2)
    op_again
  break
  ;;
  3)
    op_continue
  break
  ;;
  4)
    menu
  break
  ;;
  5)
    op_amlogic
  break
  ;;   
  6)
    exit 0
    break
  ;;
  *)
    XUANZHE="请输入正确的数字编号!"
  ;;
  esac
  done
}

function mecuowu() {
  op_firmware
  tixing_op_config > /dev/null 2>&1
  cd ${GITHUB_WORKSPACE}
  clear
  echo
  echo
  echo -e " ${Yellow}您上回使用[${matrixtarget}]源码编译出现错误，请作如下选择${Font}"
  echo
  echo
  echo -e " 1${Red}.${Font}${Blue}删除旧源码,继续使用[${matrixtarget}]源码全新编译${Font}"
  echo
  echo -e " 2${Red}.${Font}${Blue}保留缓存(菜单)${Font}"
  echo
  echo -e " 3${Red}.${Font}${Blue}更换其他作者源码(菜单)${Font}"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_cuowu
  case $menu_cuowu in
  1)
    ECHOG "开始以${matrixtarget}最新源码重新编译"
    export firmware="${matrixtarget}"
    openwrt_qx
  break
  ;;
  2)
    menuop
    rm -rf "${LOCAL_Build}/{shibai,chenggong}"
  break
  ;;
  3)
    menu
    break
  ;;
  *)
    XUANZHE="请输入正确的数字编号!"
  ;;
  esac
  done
}

if [[ -f ${LOCAL_Build}/shibai ]]; then
	mecuowu "$@"
elif [[ -d "${HOME_PATH}/package" && -d "${HOME_PATH}/target" && -d "${HOME_PATH}/toolchain" && -f "${LOCAL_Build}/chenggong" ]]; then
	menuop "$@"
else
	menu "$@"
fi
