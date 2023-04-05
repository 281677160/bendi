#!/bin/bash

#====================================================
#	System Request:Ubuntu 18.04lts/20.04lts/22.04lts
#	Author:	281677160
#	Dscription: Compile openwrt firmware
#	github: https://github.com/281677160/build-actions
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
function ECHOBB() {
  echo -e "${Blue} $1 ${Font}"
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

# 变量
export BENDI_VERSION="2.2"
export GITHUB_WORKSPACE="$PWD"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export OPERATES_PATH="${GITHUB_WORKSPACE}/operates"
export GITHUB_ENV="${GITHUB_WORKSPACE}/GITHUB_ENV"
CURRENT_PATH="${GITHUB_WORKSPACE##*/}"
echo '#!/bin/bash' >${GITHUB_ENV}
sudo chmod +x ${GITHUB_ENV}
if [[ ! "$USER" == "openwrt" ]] && [[ "${CURRENT_PATH}" == "openwrt" ]]; then
  print_error "已在openwrt文件夹内,请在勿在此路径使用一键命令"
  exit 1
fi
source /etc/os-release
if [[ "${UBUNTU_CODENAME}" =~ (bionic|focal|jammy) ]]; then
  # Nothing to do
else
  print_error "请使用Ubuntu 64位系统，推荐 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS"
  exit 1
fi
if [[ "$USER" == "root" ]]; then
 print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
 exit 1
fi
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  print_error "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi


function Bendi_WslPath() {
if [[ `echo "${PATH}" |grep -ic "windows"` -ge '1' ]] && [[ ! "${WSL_ROUTEPATH}" == 'true' ]]; then
  clear
  echo
  echo
  ECHOR "您的ubuntu为Windows子系统,是否一次性解决路径问题,还是使用临时路径编译?"
  read -t 30 -p " [输入[Y/y]回车一次性解决路径问题，任意键回车则用临时路径编译继续编译](不作处理,30秒后使用临时路径编译继续编译)： " Bendi_Wsl
  case ${Bendi_Wsl} in
  [Yy])
    bash -c  "$(curl -fsSL https://raw.githubusercontent.com/281677160/bendi/main/wsl.sh)"
    if [[ `grep -c "appendWindowsPath = false" /etc/wsl.conf` == '1' ]]; then
      ECHOG "配置已更新，请重启您的电脑"
      exit 0
    else
      ECHOR "无法完成操作，请再次尝试"
      exit 1
    fi
  ;;
  *)
    ECHOYY "正在使用临时路径解决编译问题！"
  ;;
  esac
fi
}

function BENDI_Diskcapacity() {
if [[ -d "${GITHUB_WORKSPACE}/operates" ]]; then
  source "operates/${FOLDER_NAME}/settings.ini"
fi

Cipan_Size="$(df -hT $PWD|awk 'NR==2'|awk '{print $(3)}')"
Cipan_Used="$(df -hT $PWD|awk 'NR==2'|awk '{print $(4)}')"
Cipan_Avail="$(df -hT $PWD|awk 'NR==2'|awk '{print $(5)}' |cut -d 'G' -f1)"
ECHOY "磁盘总量为[${Cipan_Size}]，已用[${Cipan_Used}]，可用[${Cipan_Avail}G]"
if [[ "${Cipan_Avail}" -lt "20" ]];then
  print_error "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
  read -p " 直接回车退出编译，按[Y/y]回车则继续编译： " KJYN
  case ${KJYN} in
  [Yy]) 
    ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
  ;;
  *)
    ECHOY  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
    exit 0
  ;;
  esac
fi
}

function Bendi_Dependent() {
ECHOG "下载common.sh运行文件"
cd ${GITHUB_WORKSPACE}
sudo rm -rf common.sh
wget -O common.sh https://raw.githubusercontent.com/281677160/common/main/common.sh
if [[ $? -ne 0 ]]; then
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/common.sh > common.sh
fi
if [[ `grep -c "TIME" common.sh` -ge '1' ]]; then
  sudo chmod +x common.sh
  if [[ ! -f "/etc/oprelyon" ]]; then
   clear
   echo
   ECHOY "首次使用本脚本，需要先安装依赖，10秒后开始安装依赖"
   ECHOYY "升级ubuntu插件和安装依赖，时间或者会比较长(取决于您的网络质量)，请耐心等待"
   ECHOY "如果出现 YES OR NO 选择界面，直接按回车即可"
   sleep 10
   echo
   source common.sh && Diy_update
   if [[ -f /etc/ssh/sshd_config ]] && [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` -eq '0' ]]; then
      sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
      sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
      sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
      sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
      sudo service ssh restart
    fi
  fi
else
  print_error "common.sh下载失败，请检测网络后再用一键命令试试!"
  exit 1
fi
}

function Bendi_DiySetup() {
cd ${GITHUB_WORKSPACE}
if [[ ! -f "operates/${FOLDER_NAME}/settings.ini" ]]; then
  ECHOG "下载operates自定义配置文件"
  curl -fsSL https://raw.githubusercontent.com/281677160/common/main/bendi/tongbu.sh -o tongbu.sh
  source tongbu.sh && menu3
  judge "operates自定义配置文件下载"
  rm -rf tongbu.sh
  if [[ -n "${FOLDER_NAME}" ]]; then
    source "operates/${FOLDER_NAME}/settings.ini"
  fi
else
  source "operates/${FOLDER_NAME}/settings.ini"
fi
}

function Bendi_Tongbu() {
cd ${GITHUB_WORKSPACE}
echo
echo "开始同步上游operates文件"
curl -fsSL https://raw.githubusercontent.com/281677160/common/main/bendi/tongbu.sh -o tongbu.sh
source tongbu.sh && ${tongbumemu}
if [[ $? -ne 0 ]]; then
  rm -rf tongbu.sh
  ECHOB "同步上游仓库失败，请检查网络"
else
  rm -rf tongbu.sh
  ECHOB "同步上游仓库完成，请至operates检查设置，设置好最新配置再进行编译"
fi
}

function Bendi_Version() {
  cd ${GITHUB_WORKSPACE}
  if [[ -d "operates" ]]; then
    A="$(grep "BENDI_VERSION=" "operates/${FOLDER_NAME}/relevance/bendi_version" |grep -Eo "[0-9]+\.[0-9]+")"
    [[ -z ${A} ]] && A="0.9"
    B="${BENDI_VERSION}"
    if [[ `awk -v num1=${A} -v num2=${B} 'BEGIN{print(num1<num2)?"0":"1"}'` -eq '0' ]]; then
      clear
      echo
      echo
      ECHOY "上游operates文件有更新，是否同步更新operates文件?"
      read -p " 按[Y/y]回车同步文件，任意键回车则跳过更新： " TB
      case ${TB} in
      [Yy]) 
        ECHOG "正在同步operates文件，请稍后..."
        export tongbumemu="menu2"
        Bendi_Tongbu
      ;;
      *)
        ECHOR "您已跳过更新operates文件"
    ;;
    esac
    fi
  fi
}

function github_deletefile() {
ECHOY "删除operates文件夹里面的机型文件夹"
ls -1 operates |awk '{print "  " $0}'
echo
ECHOGG "请输入您要删除的文件夹名称,多个文件名的话请用英文的逗号分隔"
while :; do
read -p " 请输入：" aa
if [[ -z "${aa}" ]]; then
  ECHOR "文件名不能为空"
else
  echo
  echo " 删除${aa}"
  github_deletefile2
  exit 0
fi
done
}
function github_deletefile2() {
bb=(${aa//,/ })
for cc in ${bb[@]}; do
  if [[ -d "operates/${cc}" ]]; then
    rm -rf operates/${cc}
    ECHOY "已删除[${cc}]文件夹"
  else
    ECHOR "[${cc}]文件夹不存在"
  fi
done
ECHOBB "10秒后返回主菜单"
sleep 1
seconds=9
while [ $seconds -gt 0 ];do
  echo -n " ${seconds}"
  sleep 1
  seconds=$((${seconds} - 1))
  echo -ne "\r   \r"
done
BENDI_WENJIAN
}

function github_establish() {
ECHOY "在operates文件夹里面创建机型文件夹,正在下载上游源码,请稍后..."
rm -rf chuang && git clone https://github.com/281677160/build-actions chuang > /dev/null 2>&1
if [[ ! -d "chuang/build" ]]; then
  rm -rf chuang && svn co https://github.com/281677160/build-actions/trunk/build chuang/build > /dev/null 2>&1
  rm -rf chuang/build/.svn
fi
if [[ ! -d "chuang/build" ]]; then
  ECHOR "上游源码下载失败,请检测网络"
  exit 1
else
  ls -1 chuang/build |awk '{print "  " $0}'
fi
echo
ECHOGG "请输入上面某一文件夹名称,为您要创建的机型文件夹当蓝本"
while :; do
read -p " 请输入源码文件夹名称：" aa
if [[ -z "${aa}" ]]; then
  ECHOR "文件名不能为空"
elif [[ ! -d "chuang/build/${aa}" ]]; then
  ECHOR "${aa}源码不存在"
else
  echo
  echo " 以${aa}为蓝本创建文件夹"
  github_establish2
  exit 0
fi
done
}
function github_establish2() {
echo
ECHOGG "请输入您要创建的机型文件夹名称"
while :; do
read -p " 请输入创建文件名称：" bb
if [[ -z "${bb}" ]]; then
  ECHOR "文件名不能为空"
elif [[ -d "operates/${bb}" ]]; then
  ECHOR "operates文件夹里面,已存在${bb}"
else
  echo
  echo " 创建${bb}文件夹"
  github_establish3
  exit 0
fi
done
}
function github_establish3() {
cp -Rf chuang/build/"${aa}" operates/"${bb}"
rm -rf chuang
ECHOY "[${bb}]文件夹创建完成"
ECHOBB "10秒后返回主菜单"
sleep 1
seconds=9
while [ $seconds -gt 0 ];do
  echo -n " ${seconds}"
  sleep 1
  seconds=$((${seconds} - 1))
  echo -ne "\r   \r"
done
BENDI_WENJIAN
}

function Bendi_EveryInquiry() {
if [[ "${MODIFY_CONFIGURATION}" == "true" ]]; then
  clear
  echo
  echo
  if [[ "${zhizuoconfig}" = "1" ]]; then
    ECHOY "提示：请在 operates/${FOLDER_NAME}/settings.ini 里面设置好应用什么分支"
  else
    ECHOY "提示：编译前，请在 operates/${FOLDER_NAME} 里面设置好各项自定义文件和源码分支"
  fi
  ECHOY "设置完毕后，按[W/w]回车继续编译"
  ZDYSZ="请输入您的选择"
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

clear
echo
echo
echo
if [[ "${zhizuoconfig}" = "1" ]]; then
  Menuconfig_Config="true"
  ECHOG "请耐心等待程序运行至窗口弹出进行机型和插件配置!"
else
  ECHOGG "是否需要选择机型和增删插件?"
  read -t 30 -p " [输入[ Y/y ]回车确认，任意键则为否](不作处理,30秒自动跳过)： " Bendi_Diy
  case ${Bendi_Diy} in
  [Yy])
    Menuconfig_Config="true"
    ECHOY "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
  ;;
  *)
    Menuconfig_Config="false"
    ECHOR "您已关闭选择机型和增删插件设置！"
  ;;
  esac
fi
}

function Bendi_Variable() {
cd ${GITHUB_WORKSPACE}
source common.sh && Diy_variable
judge "变量读取"
source ${GITHUB_ENV}
}

function Bendi_MainProgram() {
ECHOGG "下载扩展文件"
cd ${GITHUB_WORKSPACE}
source "operates/${FOLDER_NAME}/settings.ini"
echo "WSL_ROUTEPATH=${WSL_ROUTEPATH}" >> ${GITHUB_ENV}
source ${GITHUB_ENV}
sudo rm -rf build && cp -Rf operates build
git clone -b main --depth 1 https://github.com/281677160/common build/common
judge "扩展文件下载"
cp -Rf build/common/common.sh build/${FOLDER_NAME}/common.sh
cp -Rf build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
cp -Rf ${GITHUB_WORKSPACE}/build/common/*.sh build/${FOLDER_NAME}/
sudo chmod -R +x build

ECHOGG "检测是否缺少文件"
source ${GITHUB_WORKSPACE}/common.sh && Diy_settings
if [[ "${ERCI}" == "1" ]]; then
  cd ${HOME_PATH}
  source ${GITHUB_WORKSPACE}/common.sh && Diy_wenjian2
fi
echo
}

function Bendi_Download() {
ECHOGG "下载${SOURCE_CODE}-${LUCI_EDITION}源码中，请耐心等候..."
cd ${GITHUB_WORKSPACE}
sudo rm -rf ${HOME_PATH}
git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" ${HOME_PATH}
judge "${SOURCE_CODE}-${LUCI_EDITION}源码下载"
cd ${HOME_PATH}
mkdir -p LICENSES/doc
ECHOGG "整理源码，请耐心等候..."
source ${GITHUB_WORKSPACE}/build/${FOLDER_NAME}/common.sh && Diy_checkout
judge "整理源码"
mv -f ${GITHUB_WORKSPACE}/build ${HOME_PATH}/build
}

function Bendi_Restore() {
rm -rf ${HOME_PATH}/build
mv -f ${GITHUB_WORKSPACE}/build ${HOME_PATH}/build
if [[ ! -f "${BUILD_PATH}/common.sh" ]]; then
  cp -Rf ${HOME_PATH}/build/common/common.sh ${BUILD_PATH}/common.sh
  cp -Rf ${HOME_PATH}/build/commonupgrade.sh ${BUILD_PATH}/upgrade.sh
  cp -rf ${HOME_PATH}/build/common/*.sh ${BUILD_PATH}/
else
  source ${BUILD_PATH}/common.sh && Diy_distrib
fi
}

function Bendi_SourceClean() {
ECHOGG "源码微调和增加插件源"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_menu3
judge "源码微调和增加插件源"
echo
}

function Bendi_UpdateSource() {
ECHOGG "读取自定义文件"
cd ${HOME_PATH}
source ${BUILD_PATH}/common.sh && Diy_zdypartsh
source ${BUILD_PATH}/common.sh && Diy_Publicarea
judge "读取自定义文件"
ECHOGG "加载files,语言,更新源"
source ${BUILD_PATH}/common.sh && Diy_menu4
judge "加载files,语言,更新源"
}

function Bendi_Menuconfig() {
if [[ "${zhizuoconfig}" = "1" ]]; then
  Menuconfig_Config="true"
fi
cd ${HOME_PATH}
if [[ "${Menuconfig_Config}" == "true" ]]; then
  ECHOGG "配置机型，插件等..."
  make menuconfig
  if [[ $? -ne 0 ]]; then
    ECHOY "SSH工具窗口分辨率太小，无法弹出设置机型或插件的窗口"
    ECHOG "请调整SSH工具窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
    XUANMA="请输入您的选择"
    while :; do
    read -p " ${XUANMA}：" Bendi_Menu
    case ${Bendi_Menu} in
    [Yy])
      Bendi_Menuconfig
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

function Make_Menuconfig() {
if [[ "${zhizuoconfig}" = "1" ]]; then
  make defconfig
  source ${BUILD_PATH}/common.sh && Make_defconfig
  source ${GITHUB_ENV}
  ./scripts/diffconfig.sh > ${GITHUB_WORKSPACE}/operates/${FOLDER_NAME}/${CONFIG_FILE}
  echo "
  SUCCESS_FAILED="makeconfig"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  SOURCE2="${SOURCE}"
  " > ${HOME_PATH}/LICENSES/doc/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/LICENSES/doc/key-buildzu
  sudo chmod +x ${HOME_PATH}/LICENSES/doc/key-buildzu
  ECHOG "配置已经存入operates/${FOLDER_NAME}/${CONFIG_FILE}中"
  exit 0
fi
}

function Bendi_Configuration() {
ECHOGG "检查配置,生成配置"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_menu5
judge "检测配置,生成配置"
rm -rf ${GITHUB_WORKSPACE}/config
}

function Bendi_ErrorMessage() {
cd ${HOME_PATH}
source ${GITHUB_ENV}
if [[ -s "${HOME_PATH}/CHONGTU" ]]; then
  echo
  TIME b "		错误提示"
  echo
  sudo chmod +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  echo
  read -t 30 -p " [如需重新编译请输入[ Y/y ]按回车，任意键则为继续编译](不作处理话,30后秒继续编译)： " Bendi_Error
  case ${Bendi_Error} in
  [Yy])
     exit 1
  ;;
  *)
    ECHOG "继续编译中..."
  ;;
  esac
fi
rm -rf ${HOME_PATH}/CHONGTU
}

function Bendi_DownloadDLFile() {
ECHOGG "下载DL文件，请耐心等候..."
echo "
SUCCESS_FAILED="xzdl"
FOLDER_NAME2="${FOLDER_NAME}"
REPO_BRANCH2="${REPO_BRANCH}"
LUCI_EDITION2="${LUCI_EDITION}"
TARGET_PROFILE2="${TARGET_PROFILE}"
SOURCE2="${SOURCE}"
" > ${HOME_PATH}/LICENSES/doc/key-buildzu
sed -i 's/^[ ]*//g' ${HOME_PATH}/LICENSES/doc/key-buildzu
sudo chmod +x ${HOME_PATH}/LICENSES/doc/key-buildzu
cd ${HOME_PATH}
make defconfig
[[ ! -d "${HOME_PATH}/build_logo" ]] && mkdir -p ${HOME_PATH}/build_logo
rm -rf ${HOME_PATH}/build_logo/build.log

make -j8 download | tee ${HOME_PATH}/build_logo/build.log

if [[ `grep -ic "ERROR" ${HOME_PATH}/build_logo/build.log` -eq '0' ]]; then
  print_ok "DL文件下载成功"
else
  clear
  echo
  print_error "下载DL失败，更换节点后再尝试下载？"
  QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出编译"
  while :; do
    read -p " [${QLMEUN}]： " Bendi_DownloadDL
    case ${Bendi_DownloadDL} in
  [Yy])
    Bendi_DownloadDLFile
  break
  ;;
  [Nn])
    ECHOR "退出编译程序!"
    sleep 1
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

function Bendi_Compile() {
cd ${HOME_PATH}
source ${GITHUB_ENV}
START_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
Model_Name="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
Cpu_Cores="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"
RAM_total="$(free -h |awk 'NR==2' |awk '{print $(2)}' |sed 's/.$//')"
RAM_available="$(free -h |awk 'NR==2' |awk '{print $(7)}' |sed 's/.$//')"

echo
ECHOG "您的机器CPU型号为[ ${Model_Name} ]"
ECHOGG "在此ubuntu分配核心数为[ ${Cpu_Cores} ],线程数为[ $(nproc) ]"
ECHOG "在此ubuntu分配内存为[ ${RAM_total} ],现剩余内存为[ ${RAM_available} ]"
echo

[[ -f "${GITHUB_WORKSPACE}/common.sh" ]] && rm -rf ${GITHUB_WORKSPACE}/common.sh
[[ -d "${FIRMWARE_PATH}" ]] && sudo rm -rf ${FIRMWARE_PATH}
[[ ! -d "${HOME_PATH}/build_logo" ]] && mkdir -p ${HOME_PATH}/build_logo
rm -rf ${HOME_PATH}/build_logo/build.log

if [[ "$(nproc)" -le "12" ]];then
  ECHOY "即将使用$(nproc)线程进行编译固件"
  sleep 8
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    ECHOG "WSL临时路径编译中"
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j$(nproc) | tee ${HOME_PATH}/build_logo/build.log
  else
     make -j$(nproc) | tee ${HOME_PATH}/build_logo/build.log
  fi
else
  ECHOGG "您的CPU线程超过或等于16线程，强制使用16线程进行编译固件"
  sleep 8
  if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
    ECHO "WSL临时路径编译中"
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j16 | tee ${HOME_PATH}/build_logo/build.log | tee ${HOME_PATH}/build_logo/build.log
  else
     make -j16 | tee ${HOME_PATH}/build_logo/build.log | tee ${HOME_PATH}/build_logo/build.log
  fi
fi

if [[ `grep -ic "Error 2" ${HOME_PATH}/build_logo/build.log` -eq '0' ]]; then
  compile_error="0"
else
  compile_error="1"
fi

sleep 3
if [[ "${compile_error}" == "1" ]] || [[ `ls -1 "${FIRMWARE_PATH}" |grep -c "${TARGET_BOARD}"` -eq '0' ]]; then
  print_error "编译失败~~!"
  ECHOY "在 openwrt/build_logo/build.log 可查看编译日志,日志文件比较大,拖动到电脑查看比较方便"
  echo "
  SUCCESS_FAILED="fail"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  SOURCE2="${SOURCE}"
  " > ${HOME_PATH}/LICENSES/doc/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/LICENSES/doc/key-buildzu
  sudo chmod +x ${HOME_PATH}/LICENSES/doc/key-buildzu
  exit 1
else
  cp -Rf ${FIRMWARE_PATH}/config.buildinfo ${GITHUB_WORKSPACE}/operates/${FOLDER_NAME}/${CONFIG_FILE}
  echo "
  SUCCESS_FAILED="success"
  FOLDER_NAME2="${FOLDER_NAME}"
  REPO_BRANCH2="${REPO_BRANCH}"
  LUCI_EDITION2="${LUCI_EDITION}"
  TARGET_PROFILE2="${TARGET_PROFILE}"
  SOURCE2="${SOURCE}"
  " > ${HOME_PATH}/LICENSES/doc/key-buildzu
  sed -i 's/^[ ]*//g' ${HOME_PATH}/LICENSES/doc/key-buildzu
  sudo chmod +x ${HOME_PATH}/LICENSES/doc/key-buildzu
  source ${GITHUB_ENV}
fi
}


function Bendi_PackageAmlogic() {
if [[ ${PACKAGING_FIRMWARE} == "true" ]] && [[ `grep -Eoc 'CONFIG_TARGET_armvirt_64_Default=y' ${HOME_PATH}/.config` -eq '1' ]]; then
  source ${BUILD_PATH}/common.sh && Package_amlogic
fi
}

function Bendi_Arrangement() {
echo
ECHOGG "整理固件"
cd ${HOME_PATH}
source ${GITHUB_ENV}
source ${BUILD_PATH}/common.sh && Diy_firmware
judge "整理固件"
}

function Bendi_shouweigongzhong() {
if [[ `grep -c 'CONFIG_TARGET_armvirt_64_Default=y' ${HOME_PATH}/.config` -eq '1' ]]; then
  print_ok "[ N1或晶晨系列盒子专用固件 ]顺利编译完成~~~"
else
  print_ok "[ ${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE} ]顺利编译完成~~~"
fi
ECHOGG "已为您把配置文件替换到operates/${FOLDER_NAME}/${CONFIG_FILE}里"
ECHOY "编译日期：$(date +'%Y年%m月%d号')"
END_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
SECONDS=$((END_TIME-START_TIME))
HOUR=$(( $SECONDS/3600 ))
MIN=$(( ($SECONDS-${HOUR}*3600)/60 ))
SEC=$(( $SECONDS-${HOUR}*3600-${MIN}*60 ))
if [[ "${HOUR}" == "0" ]]; then
  ECHOGG "编译总计用时 ${MIN}分${SEC}秒"
else
  ECHOGG "编译总计用时 ${HOUR}时${MIN}分${SEC}秒"
fi
ECHOR "提示：再次输入编译命令可进行二次编译"
echo
}

function Bendi_Packaging() {
  cd ${GITHUB_WORKSPACE}
  export FIRMWARE_PATH="${HOME_PATH}/bin/targets/armvirt/64"
  sudo rm -rf ${FIRMWARE_PATH}/*Identifier*
  if [[ -d "amlogic" ]]; then
    t1="$(cat amlogic/start_time)"
    END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
    t2=`date -d "$END_TIME" +%s`
    SECONDS=$((t2-t1))
    HOUR=$(( $SECONDS/3600 ))
    if [[ "${HOUR}" -lt "12" ]]; then
      sudo rm -rf amlogic/out/*
      echo "amlogic"
    else
      sudo rm -rf amlogic
      if [[ -d "amlogic" ]]; then
        ECHOR "已存在的amlogic文件夹无法删除，请重启系统再来尝试"
        exit 1
      else
        ECHOY "正在下载打包所需的程序,请耐心等候~~~"
        git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
        judge "打包程序下载1"
        curl -fsSL https://github.com/281677160/common/releases/download/API/stable.api -o amlogic/stable.api
        if [[ $? -ne 0 ]]; then
          curl -fsSL https://github.com/281677160/common/releases/download/API/stable.api -o amlogic/stable.api
        fi
        if [[ `grep -c "name" amlogic/stable.api` -eq '0' ]]; then
          print_error "上游仓库amlogic内核版本API下载失败!"
          exit 1
        fi
      fi
    fi
  else
    ECHOY "正在下载打包所需的程序,请耐心等候~~~"
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
    judge "打包程序下载1"
    curl -fsSL https://github.com/281677160/common/releases/download/API/stable.api -o amlogic/stable.api
    if [[ $? -ne 0 ]]; then
      curl -fsSL https://github.com/281677160/common/releases/download/API/stable.api -o amlogic/stable.api
    fi
    if [[ `grep -c "name" amlogic/stable.api` -eq '0' ]]; then
      print_error "上游仓库amlogic内核版本API下载失败!"
      exit 1
    fi
  fi
  if [[ ! -d "${FIRMWARE_PATH}" ]] || [[ `ls -1 "${FIRMWARE_PATH}" |grep -Eoc "*armvirt-64-default-rootfs.tar.gz"` -eq '0' ]]; then
    mkdir -p "${FIRMWARE_PATH}"
    clear
    ECHOR "没发现 openwrt/bin/targets/armvirt/64 文件夹里存在.tar.gz固件，已为你创建了文件夹"
    ECHORR "请用WinSCP工具将\"openwrt-armvirt-64-default-rootfs.tar.gz\"固件存入文件夹中"
    if [[ `echo "${PATH}" |grep -c "Windows"` -ge '1' ]]; then
      ECHOY "提醒：Windows的WSL系统的话，千万别直接打开文件夹来存放固件，很容易出错的，要用WinSCP工具或SSH工具自带的文件管理器"
    fi
    exit 1
  fi
  sudo chmod +x common.sh
  grep -Eo '"name": "[0-9]+\.[0-9]+\.[0-9]+\.tar.gz"' "amlogic/stable.api" |grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" >amlogic/kernelpub
  START_TIME=`date +'%Y-%m-%d %H:%M:%S'`
  t1=`date -d "$START_TIME" +%s`
  echo "${t1}" >amlogic/start_time
  export amkernel="$(cat amlogic/kernelpub |awk 'END {print}' |sed s/[[:space:]]//g)"
  export kernel_repo=https://github.com/ophub/kernel/tree/main/pub
  rm -rf ${GITHUB_WORKSPACE}/amlogic/{router-config,*README*,LICENSE}
  [ ! -d amlogic/openwrt-armvirt ] && mkdir -p amlogic/openwrt-armvirt
  
  ECHOY "可用芯片：a311d, s922x, s905x3, s905x2, s905l3a, s912, s905d, s905x, s905w, s905"
  ECHOYY "对应支持有什么机型请看说明"
  ECHOGG "设置要打包固件的机型[ 任意键回车则默认(N1) ]"
  read -p " 请输入您要设置的机型：" amlogic_model
  export amlogic_model=${amlogic_model:-"s905d"}
  ECHOYY "您设置的机型为：${amlogic_model}"
  echo
  ECHOGG "设置打包的内核版本[任意键回车则默认 ${amkernel}]"
  echo
  cat amlogic/kernelpub|awk '{print "  " $0}'
  echo
  read -p " 请输入您要设置打包的内核版本：" amlogic_kernel
  export amlogic_kernel=${amlogic_kernel:-"${amkernel}"}
  ECHOYY "您设置的内核版本为：${amlogic_kernel}"
  echo
  ECHOGG "请选择是否自动打包您输入的内核版本同类型的最新内核"
  export YUMINGIP=" 输入[N/n]则为否,任意键回车则为是"
  read -p "${YUMINGIP}：" auto_kernel
  case $auto_kernel in
  [Nn])
    export auto_kernel="false"
  ;;
  *)
    export auto_kernel="true"
  ;;
  esac
  export auto_kernel=${auto_kernel}
  if [[ "${auto_kernel}" == "false" ]]; then
    ECHORR "关闭自动打包最新内核"
  else
    ECHOYY "开启自动打包最新内核"
  fi
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认：960 ]"
  read -p " 请输入ROOTFS分区大小：" rootfs_size
  export rootfs_size=${rootfs_size:-"960"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs_size}"
  ECHOG "设置完毕，开始进行打包操作"
  if [[ `ls -1 "${FIRMWARE_PATH}" |grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
    cp -Rf ${FIRMWARE_PATH}/*armvirt-64-default-rootfs.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  else
    armvirtargz="$(ls -1 "${FIRMWARE_PATH}" |grep ".*tar.gz" |awk 'END {print}')"
    cp -Rf ${FIRMWARE_PATH}/${armvirtargz} ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  fi
  if [[ `ls -1 "${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt" | grep -c ".tar.gz"` -eq '0' ]]; then
    print_error "amlogic/openwrt-armvirt文件夹没发现openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    print_error "请检查openwrt/bin/targets/armvirt/64文件夹内有没有openwrt-armvirt-64-default-rootfs.tar.gz固件存在"
    exit 1
  fi
  cd ${GITHUB_WORKSPACE}/amlogic
  sudo chmod +x make
  sudo ./make -b ${amlogic_model} -v stable -k ${amlogic_kernel} -a ${auto_kernel} -s ${rootfs_size}
  if [[ $? -eq 0 ]];then
    echo
    print_ok "打包完成，固件存放在[amlogic/out]文件夹"
  else
    print_error "打包失败，请查看当前错误说明!"
  fi
}

function Bendi_Change() {
cd ${HOME_PATH}
sed -i '/^#/d' feeds.conf.default
if [[ ! "${REPO_BRANCH2}" == "${REPO_BRANCH}" ]]; then
  ECHOR "编译分支发生改变,需要重新下载源码,下载源码中..."
  sleep 3
  Bendi_Download
elif [[ ! "${COLLECTED_PACKAGES}" == "true" ]]; then
  if [[ `grep -c "danshui" feeds.conf.default` -ge '1' ]]; then
    ECHOR "您的自定义设置更改为不需要作者收集的插件包,正在清理插件中..."
    sleep 3
    find . -name 'luci-app-openclash' | xargs -i rm -rf {}
    sed -i '/danshui/d' feeds.conf.default
    sed -i '/helloworld/d' feeds.conf.default
    sed -i '/passwall/d' feeds.conf.default
    ./scripts/feeds clean
    ./scripts/feeds update -a
  fi
elif [[ "${COLLECTED_PACKAGES}" == "true" ]]; then
  if [[ `grep -c "danshui" feeds.conf.default` -eq '0' ]]; then
    ECHOG "您的自定义设置更改为需要作者收集的插件包,正在增加插件中..."
    sleep 3
    sed -i '/danshui/d' feeds.conf.default
    sed -i '/helloworld/d' feeds.conf.default
    sed -i '/fw876/d' feeds.conf.default
    sed -i '/passwall/d' feeds.conf.default
    sed -i '/xiaorouji/d' feeds.conf.default
    ./scripts/feeds clean
    ./scripts/feeds update -a
    source ${GITHUB_WORKSPACE}/common.sh && Diy_${SOURCE_CODE}
    source ${GITHUB_WORKSPACE}/common.sh && Diy_chajianyuan
  fi
fi
}

function Bendi_gitpull() {
if [[ "${SOURCE_CODE}" == "OFFICIAL" ]] && [[ "${REPO_BRANCH}" =~ (openwrt-19.07|openwrt-21.02|openwrt-22.03) ]]; then
  echo
else
  ECHOG "同步上游源码"
  git pull
  if [[ $? -ne 0 ]]; then
    ECHOR "同步上游源码失败"
  else
    ECHOB "同步上游源码完成"
  fi
fi
}

function Bendi_xuanzhe() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -f "/etc/oprelyon" ]]; then
    Bendi_Dependent
  fi
  if [[ ! -d "operates" ]]; then
    ECHOG "没有主要编译程序存在,正在下载中,请稍后..."
    sleep 2
    Bendi_DiySetup
  else
    YY="$(ls -1 "operates" |awk 'NR==1')"
    if [[ ! -f "operates/${YY}/settings.ini" ]]; then
      ECHOG "没有主要编译程序存在,正在下载中,请稍后..."
      sleep 2
      Bendi_DiySetup
    fi
  fi
  clear
  echo 
  echo
  ls -1 "operates" |awk '$0=NR" "$0' > GITHUB_ENN
  ls -1 "operates" > GITHUB_EVN
  XYZDSZ="$(cat GITHUB_ENN | awk 'END {print}' |awk '{print $(1)}')"
  rm -rf GITHUB_ENN
  ls -1 "operates" |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  echo
  echo
  if [[ "$zhizuoconfig" == "1" ]]; then
    echo -e "${Blue}  请输入您要制作.config配置文件的源码前面对应的数值(1~X),输入[N]则为退出程序${Font}"
  else
    echo -e "${Blue}  请输入您要编译源码前面对应的数值(1~X),输入[N]则为退出程序${Font}"
  fi
  echo
  echo -e "${Yellow}  输入[0]或[Y/y]回车,进行创建机型文件夹或删除机型文件夹${Font}"
  echo
  export YUMINGIP="  请输入您的选择"
  while :; do
  YMXZ=""
  read -p "${YUMINGIP}：" YMXZ
  if [[ "${YMXZ}" == "0" ]] || [[ "${YMXZ}" == "Y" ]] || [[ "${YMXZ}" == "y" ]]; then
    CUrrenty="Y"
  elif [[ "${YMXZ}" == "N" ]] || [[ "${YMXZ}" == "n" ]]; then
    CUrrenty="N"
  elif [[ -z "${YMXZ}" ]]; then
    CUrrenty="x"
  elif [[ "${YMXZ}" -le "${XYZDSZ}" ]]; then
    CUrrenty="B"
  else
    CUrrenty="x"
  fi
  case $CUrrenty in
  B)
    export FOLDER_NAME3=$(cat GITHUB_EVN |awk ''NR==${YMXZ}'')
    export FOLDER_NAME="${FOLDER_NAME3}"
    sed -i '/FOLDER_NAME=/d' "${GITHUB_ENV}"
    echo "FOLDER_NAME=${FOLDER_NAME}" >> ${GITHUB_ENV}
    source ${GITHUB_ENV}
    if [[ "$zhizuoconfig" == "1" ]]; then
      ECHOY " 您选择了使用 ${FOLDER_NAME} 制作.config配置文件,3秒后将进行启动编译"
    else
      ECHOY " 您选择了使用 ${FOLDER_NAME} 编译固件,3秒后将进行启动编译"
    fi
    rm -rf GITHUB_EVN
    sleep 2
    Bendi_menu
  break
  ;;
  N)
    rm -rf GITHUB_ENN
    echo
    exit 0
  break
  ;;
  Y)
    BENDI_WENJIAN
    echo
  break
  ;;
  *)
    export YUMINGIP="  敬告,请输入正确选项"
  ;;
  esac
  done
}

function Bendi_menu2() {
export ERCI="1"
BENDI_Diskcapacity
Bendi_Dependent
Bendi_Version
Bendi_WslPath
Bendi_DiySetup
Bendi_EveryInquiry
Bendi_Variable
Bendi_Version
Bendi_Change
Bendi_gitpull
Bendi_MainProgram
Bendi_Restore
Bendi_UpdateSource
Bendi_Menuconfig
Make_Menuconfig
Bendi_Configuration
Bendi_ErrorMessage
Bendi_DownloadDLFile
Bendi_Compile
Bendi_PackageAmlogic
Bendi_Arrangement
Bendi_shouweigongzhong
}

function Bendi_menu() {
export ERCI="0"
BENDI_Diskcapacity
Bendi_Dependent
Bendi_Version
Bendi_WslPath
Bendi_DiySetup
Bendi_EveryInquiry
Bendi_Variable
Bendi_MainProgram
Bendi_Download
Bendi_SourceClean
Bendi_UpdateSource
Bendi_Menuconfig
Make_Menuconfig
Bendi_Configuration
Bendi_ErrorMessage
Bendi_DownloadDLFile
Bendi_Compile
Bendi_PackageAmlogic
Bendi_Arrangement
Bendi_shouweigongzhong
}

function BENDI_WENJIAN() {
cd ${GITHUB_WORKSPACE}
clear
echo
echo
ECHOY " 1. 创建机型文件夹"
ECHOY " 2. 删除机型文件夹"
ECHOY " 3. 啥都不干,回到选择机型继续编译"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  github_establish
break
;;
2)
  github_deletefile
break
;;
3)
  Bendi_xuanzhe
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function Bendi_UPDIYSETUP() {
cd ${GITHUB_WORKSPACE}
clear
echo 
echo
echo -e "  ${Green}请选择更新方式${Font}"
echo
echo -e "  ${Blue}1${Font}、${Yellow}单文件更新,只更新您现有机型文件夹的diy-part.sh和settings.ini(带备份文件)${Font}"
echo
echo -e "  ${Blue}2${Font}、${Yellow}单文件更新,只更新您现有机型文件夹的diy-part.sh和settings.ini(不要备份文件)${Font}"
echo
echo -e "  ${Blue}3${Font}、${Yellow}删除您现有的operates文件夹,从上游重新拉取operates文件夹${Font}"
echo
echo -e "  ${Blue}4${Font}、${Yellow}返回上级菜单${Font}"
echo
echo -e "  ${Blue}5${Font}、${Yellow}退出程序${Font}"
echo
echo
IYSETUP="  请输入数字确定您的选择"
echo
while :; do
read -p "${IYSETUP}：" Bendi_upsetup
case ${Bendi_upsetup} in
1)
  [[ ! -f "/etc/oprelyon" ]] && Bendi_Dependent
  export tongbumemu="menu2"
  Bendi_Tongbu
break
;;
2)
  [[ ! -f "/etc/oprelyon" ]] && Bendi_Dependent
  export tongbumemu="menu3"
  Bendi_Tongbu
break
;;
3)
  [[ ! -f "/etc/oprelyon" ]] && Bendi_Dependent
  [[ -d "operates" ]] && rm -rf operates
  Bendi_DiySetup
break
;;
4)
  if [[ -n "${BENDI_MEMU}" ]]; then
    ${BENDI_MEMU}
  else
    menu
  fi
break
;;
5)
  exit 0
break
;;
*)
  IYSETUP="  输入错误,请输入数字"
;;
esac
done
}

function menu2() {
  clear
  echo
  echo
  if [[ "${SUCCESS_FAILED}" == "success" ]]; then
    echo -e " ${Blue}上回使用源码文件夹${Font}：${Yellow}${FOLDER_NAME2}${Font}"
    echo -e " ${Blue}上回编译使用分支${Font}：${Yellow}${LUCI_EDITION2}${Font}"
    echo -e " ${Blue}上回成功编译机型${Font}：${Yellow}${TARGET_PROFILE2}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}使用配置文件名称${Font}：${Yellow}${CONFIG_FILE1}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/seed文件夹是否存在${CONFIG_FILE1}名称文件${Font}：${Yellow}${JIXINGWENJIAN}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/${SEED_CONFIG1}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="保留缓存,再次编译?"
    bbbbb="编译"
    zhizuoconfig="0"
  elif [[ "${SUCCESS_FAILED}" == "makeconfig" ]]; then  
    echo -e " ${Blue}上回使用源码文件夹${Font}：${Yellow}${FOLDER_NAME2}${Font}"
    echo -e " ${Blue}上回编译使用分支${Font}：${Yellow}${LUCI_EDITION2}${Font}"
    echo -e " ${Blue}上回制作了${Font}${Yellow}${TARGET_PROFILE2}机型的.config${Font}${Blue}配置文件${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}使用配置文件名称${Font}：${Yellow}${CONFIG_FILE1}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/seed文件夹是否存在${CONFIG_FILE1}名称文件${Font}：${Yellow}${JIXINGWENJIAN}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/${SEED_CONFIG1}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="继续制作.config配置文件"
    bbbbb="制作.config配置文件?"
    zhizuoconfig="1"
  elif [[ "${SUCCESS_FAILED}" == "xzdl" ]]; then
    echo -e " ${Blue}上回使用源码文件夹${Font}：${Yellow}${FOLDER_NAME2}${Font}"
    echo -e " ${Blue}上回编译使用分支${Font}：${Yellow}${LUCI_EDITION2}${Font}"
    echo -e " ${Red}大兄弟啊,上回没搞成,继续[${FOLDER_NAME2}]搞下去?${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}使用配置文件名称${Font}：${Yellow}${CONFIG_FILE1}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/seed文件夹是否存在${CONFIG_FILE1}名称文件${Font}：${Yellow}${JIXINGWENJIAN}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/${SEED_CONFIG1}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="接着上次继续再搞下去?"
    bbbbb="编译"
    zhizuoconfig="0"
  else
    echo -e " ${Blue}上回使用源码文件夹${Font}：${Yellow}${FOLDER_NAME2}${Font}"
    echo -e " ${Blue}上回编译使用分支${Font}：${Yellow}${LUCI_EDITION2}${Font}"
    echo -e " ${Red}大兄弟啊,上回编译${Yellow}[${TARGET_PROFILE2}]${Font}${Red}于失败告终了${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}使用配置文件名称${Font}：${Yellow}${CONFIG_FILE1}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/seed文件夹是否存在${CONFIG_FILE1}名称文件${Font}：${Yellow}${JIXINGWENJIAN}${Font}"
    echo -e " ${Blue}当前operates/${FOLDER_NAME2}/${SEED_CONFIG1}配置文件机型${Font}：${Yellow}${TARGET_PROFILE3}${Font}"
    aaaa="保留缓存,再特么的搞一搞?"
    bbbbb="编译"
    zhizuoconfig="0"
  fi
  echo
  echo
  echo -e " 1${Red}.${Font}${Green}${aaaa}${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}重新选择源码${bbbbb}${Font}"
  echo
  echo -e " 3${Red}.${Font}${Green}同步上游operates文件${Font}"
  echo
  echo -e " 4${Red}.${Font}${Green}回到编译主菜单${Font}"
  echo
  echo -e " 5${Red}.${Font}${Green}打包N1或晶晨系列固件(您要有armvirt_64的.tar.gz固件)${Font}"
  echo
  echo -e " 6${Red}.${Font}${Green}退出${Font}"
  echo
  echo
  XUANZop="请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    Bendi_menu2
  break
  ;;
  2)
    Bendi_xuanzhe
  break
  ;;
  3)
    Bendi_UPDIYSETUP
  break
  ;;
  4)
    menu
  break
  ;;
  5)
    Bendi_Dependent
    Bendi_Packaging
  break
  ;;
  6)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop="请输入正确的数字编号"
  ;;
  esac
  done
}

function menu() {
cd ${GITHUB_WORKSPACE}
clear
echo
echo
ECHOY " 1. 进行编译固件"
ECHOY " 2. 进行制作.config配置文件"
ECHOY " 3. 同步上游operates文件"
ECHOY " 4. 打包N1或晶晨系列固件(您要有armvirt_64的.tar.gz固件)"
ECHOY " 5. 退出程序"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  zhizuoconfig="0"
  Bendi_xuanzhe
break
;;
2)
  zhizuoconfig="1"
  Bendi_xuanzhe
break
;;
3)
  Bendi_UPDIYSETUP
break
;;
4)
  Bendi_Dependent
  Bendi_Packaging
break
;;
5)
  echo
  exit 0
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function menuoo() {
cd ${GITHUB_WORKSPACE}
if [[ -d "${HOME_PATH}" ]]; then
cat > Update.txt <<EOF
config
include
package
scripts
target
toolchain
tools
EOF
ls -1 ${HOME_PATH} > UpdateList.txt
FOLDERS=`grep -Fxvf UpdateList.txt Update.txt`
FOLDERSX=`echo $FOLDERS | sed 's/ /、/g'`;echo $FOLDERSX
rm -rf {UpdateList.txt,Update.txt}
fi

if [[ -z "${FOLDERS}" ]]; then
  KAIDUAN_JIANCE="1"
else
  KAIDUAN_JIANCE="0"
fi
if [[ -f "${HOME_PATH}/LICENSES/doc/key-buildzu" ]]; then
  KAIDUAN_JIANCE="1"
  source ${HOME_PATH}/LICENSES/doc/key-buildzu
else
  KAIDUAN_JIANCE="0"
fi
if [[ -f "operates/${FOLDER_NAME2}/settings.ini" ]]; then
  KAIDUAN_JIANCE="1"
  CONFIG_FILE1="$(source ${OPERATES_PATH}/${FOLDER_NAME2}/settings.ini && echo "${CONFIG_FILE}")"
  SEED_CONFIG1="seed/${CONFIG_FILE1}"
else
  KAIDUAN_JIANCE="0"
fi

if [[ -f "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}" ]]; then
  JIXINGWENJIAN="存在"
else
  JIXINGWENJIAN="不存在"
fi

if [[ "${KAIDUAN_JIANCE}" == "1" ]] && [[ "${JIXINGWENJIAN}" == "存在" ]]; then
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}"` -eq '1' ]]; then
    TARGET_PROFILE3="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}"` == '1' ]]; then
    TARGET_PROFILE3="x86-32"
  elif [[ `grep -c "CONFIG_TARGET_armvirt_64_Default=y" "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}"` -eq '1' ]]; then
    TARGET_PROFILE3="Armvirt_64"
  elif [[ `grep -Eoc "CONFIG_TARGET.*DEVICE.*=y" "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}"` -eq '1' ]]; then
    TARGET_PROFILE3="$(grep -Eo "CONFIG_TARGET.*DEVICE.*=y" "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    TARGET_PROFILE3="$(cat "${OPERATES_PATH}/${FOLDER_NAME2}/${SEED_CONFIG1}" |grep "CONFIG_TARGET_.*=y" |awk 'END {print}'|sed "s/CONFIG_TARGET_//g"|sed "s/=y//g")"
  fi
  [[ -z "${TARGET_PROFILE3}" ]] && TARGET_PROFILE3="未知"
else
  TARGET_PROFILE3="未知"
fi
if [[ "${KAIDUAN_JIANCE}" == "1" ]]; then
  FOLDER_NAME="${FOLDER_NAME2}"
  echo "FOLDER_NAME=${FOLDER_NAME}" >> ${GITHUB_ENV}
  BENDI_MEMU="menu2"
  menu2
else
  FOLDER_NAME=""
  echo "FOLDER_NAME=${FOLDER_NAME}" >> ${GITHUB_ENV}
  BENDI_MEMU="menu"
  menu
fi
}

menuoo "$@"
