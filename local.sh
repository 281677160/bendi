#!/bin/bash

function TIME() {
  case "$1" in
    r) local Color="\033[0;31m";;
    g) local Color="\033[0;32m";;
    y) local Color="\033[0;33m";;
    b) local Color="\033[0;34m";;
    z) local Color="\033[0;35m";;
    l) local Color="\033[0;36m";;
    *) local Color="\033[0;0m";;
  esac
echo -e "\n${Color}${2}\033[0m"
}

source /etc/os-release
if [[ ! "${UBUNTU_CODENAME}" == "jammy" ]]; then
  TIME r "请使用Ubuntu 22.04 LTS位系统"
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  TIME r "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi

export GITHUB_WORKSPACE="/home/$USER"
export HOME_PATH="${GITHUB_WORKSPACE}/openwrt"
export OPERATES_PATH="${GITHUB_WORKSPACE}/operates"
export GITHUB_ENV="/tmp/compile"
export DIAN_GIT="${HOME_PATH}/.git/config"
export BENDI_VERSION="1"
export op_log="${OPERATES_PATH}/build.log"
export LICENSES_DOC="${HOME_PATH}/LICENSES/doc"
export NUM_BER=""
export SUCCESS_FAILED=""
export rootfs_targz=""
install -m 0755 /dev/null $GITHUB_ENV
cd $GITHUB_WORKSPACE

Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  TIME r "提醒：编译之前请自备梯子，编译全程都需要稳定翻墙的梯子~~"
  exit 1
fi
if [[ `sudo grep -c "sudo ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers` -eq '0' ]]; then
  sudo sed -i 's?%sudo.*?%sudo ALL=(ALL:ALL) NOPASSWD:ALL?g' /etc/sudoers
fi

function Ben_wslpath() {
if [[ -n "$(echo "${PATH}" |grep -i 'windows')" ]]; then
  clear
  echo
  TIME r "您的ubuntu为Windows子系统,需要解决路径问题"
  read -p "输入[Y/y]回车解决路径问题，输入[N/n]回车则退出编译： " Bendi_Wsl
  while :; do
    read -p "请选择：" YONU
    case ${YONU} in
    [Yy])
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/bendi/main/wsl.sh)"
        exit 0
        break
    ;;
    [Nn])
        TIME y "退出编译openwrt固件"
        exit 1
        break
    ;;
    *)
        TIME r "请输入正确选项"
    ;;
    esac
  done
fi
}

function Ben_diskcapacity() {
total_size=$(df -h / | awk 'NR==2 {gsub("G", "", $2); print $2}')
available_size=$(df -h / | awk 'NR==2 {gsub("G", "", $4); print $4}')
TIME y "磁盘总量为[${total_size}G]，可用[${available_size}G]"
if [[ "${available_size}" -lt "20" ]];then
  TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于[ 20G ],是否继续?"
  read -n 1 -s -r -p "按任意键退出编译，按[Y/y]则继续编译： " KJYN
  case ${KJYN} in
  [Yy])
      TIME y "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
      sleep 2
      ;;
  *)
      TIME y "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
      exit 0
      ;;
  esac
fi
}

function Ben_update() {
if [[ ! -f "/etc/oprelyonu" ]]; then
  clear
  echo
  TIME y "首次使用本脚本，或版本有更新的时候，需要先安装依赖"
  TIME y "升级ubuntu插件和安装依赖，时间或者会比较长(取决于您的网络质量)，请耐心等待"
  TIME y "如果出现 YES OR NO 选择界面，直接按回车即可"
  TIME g "输入[Y/y]回车则继续，输入[N/n]回车则退出"
  while :; do
    read -p "请选择：" YONU
    case ${YONU} in
    [Yy])
        sudo rm -rf /etc/oprelyo*
        TIME g "开始安装依赖..."
        break
    ;;
    [Nn])
        exit 1
        break
    ;;
    *)
        TIME r "请输入正确选项"
    ;;
    esac
  done
  if sudo bash -c 'bash <(curl -fsSL https://github.com/281677160/common/raw/main/custom/ubuntu.sh)'; then
    sudo sh -c 'echo openwrt > /etc/oprelyonu'
  else
    sudo rm -rf /etc/oprelyo*
    TIME r "依赖安装失败,请检查网络再来"
    exit 1
  fi
fi
if [[ -f "/etc/ssh/sshd_config" ]] && [[ -z "$(grep -E 'ClientAliveInterval 30' '/etc/ssh/sshd_config' 2>/dev/null)" ]]; then
  sudo sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
  sudo sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
  sudo sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
  sudo sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
  sudo service ssh restart
fi
clear
}

function Ben_variable() {
cd ${GITHUB_WORKSPACE}
export FOLDER_NAME="$FOLDER_NAME"
export SETT_TINGS="$OPERATES_PATH/$FOLDER_NAME/settings.ini"
if [[ -f "${SETT_TINGS}" ]] && [[ "${NUM_BER}" == "1" ]]; then
  source ${SETT_TINGS}
else
  [[ -d "${OPERATES_PATH}" ]] && PACKAGING_FIRMWARE="$(grep '^PACKAGING_FIRMWARE=' "${SETT_TINGS}" | awk -F'"' '{print $2}')"
  [[ -d "${OPERATES_PATH}" ]] && MODIFY_CONFIGURATION="$(grep '^MODIFY_CONFIGURATION=' "${SETT_TINGS}" | awk -F'"' '{print $2}')"
fi
export COMPILE_PATH="$OPERATES_PATH/$FOLDER_NAME"
export SOURCE_CODE="${SOURCE_CODE}"
export REPO_BRANCH="${REPO_BRANCH}"
export BUILD_DIY="${COMPILE_PATH}/diy"
export BUILD_FILES="${COMPILE_PATH}/files"
export BUILD_PATCHES="${COMPILE_PATH}/patches"
export BUILD_PARTSH="${COMPILE_PATH}/diy-part.sh"
export BUILD_SETTINGS="${COMPILE_PATH}/settings.ini"
export CONFIG_FILE="${CONFIG_FILE}"
export MYCONFIG_FILE="${COMPILE_PATH}/seed/${CONFIG_FILE}"

LINSHI_COMMON="/tmp/common"
[[ ! -d "${OPERATES_PATH}" ]] && TIME r "缺少编译主文件,正在下载中..." || TIME y "正在执行：判断文件是否缺失"
[[ -d "${LINSHI_COMMON}" ]] && rm -rf "${LINSHI_COMMON}"
if ! git clone -q --single-branch --depth=1 --branch=main https://github.com/281677160/common "${LINSHI_COMMON}"; then
  git clone --depth=1 https://github.com/281677160/common "${LINSHI_COMMON}"
fi
if [ -f "${LINSHI_COMMON}/custom/first.sh" ] && grep -qE "bash" "${LINSHI_COMMON}/custom/first.sh"; then
  chmod -R +x "${LINSHI_COMMON}"
  source "${LINSHI_COMMON}/custom/first.sh"
else
  [[ ! -d "${OPERATES_PATH}" ]] && TIME r "文件下载失败,请检查网络再试" || TIME r "对比版本号文件下载失败，请检查网络再试"
  exit 1
fi
source $COMMON_SH && Diy_menu6
}

function Ben_config() {
clear
echo
if [[ "${MODIFY_CONFIGURATION}" == "true" ]]; then
  TIME g "是否需要增删插件,执行[make menuconfig]?"
  read -t 30 -n 1 -s -r -p "按[Y/y]为需要，按任意键则为否，(不作处理,30秒自动跳过)： " Bendi_Diy
  case ${Bendi_Diy} in
  [Yy])
      Menuconfig_Config="true"
      TIME y "您执行了[make menuconfig]命令,请耐心等待程序运行至窗口弹出进行插件配置!"
      ;;
  *)
      Menuconfig_Config="false"
      TIME r "您已关闭了执行[make menuconfig]命令!"
      ;;
  esac
fi
}

function Ben_xiazai() {
TIME g "开始执行编译固件"
cd ${GITHUB_WORKSPACE}
if [[ "${NUM_BER}" == "1" ]]; then
  TIME y "正在执行：下载${SOURCE}-${LUCI_EDITION}源码中，请耐心等候..."
  tmpdir="$(mktemp -d)"
  if git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" "${tmpdir}"; then
    rm -rf openwrt
    cp -Rf $tmpdir $HOME_PATH
    rm -rf $tmpdir
    source $COMMON_SH && Diy_feedsconf
    TIME g "源码下载完成"
  else
    TIME r "源码下载失败,请检测网络"
    exit 1
  fi
elif [[ "${NUM_BER}" == "2" ]]; then
  TIME y "正在同步上游源码(${SOURCE}-${LUCI_EDITION})"
  tmpdir="$(mktemp -d)"
  if git clone -b "${REPO_BRANCH}" --single-branch "${REPO_URL}" "${tmpdir}"; then
    cd $HOME_PATH
    find . -maxdepth 1 \
      ! -name '.' \
      ! -name 'feeds' \
      ! -name 'dl' \
      ! -name 'build_dir' \
      ! -name 'staging_dir' \
      ! -name 'LICENSES' \
      ! -name '.config' \
      ! -name '.config.old' \
      -exec rm -rf {} +
    rsync -a $tmpdir/ $HOME_PATH/
    rm -rf $tmpdir
  else
    TIME r "源码下载失败,请检查网络"
    exit 1
  fi
elif [[ "${NUM_BER}" == "3" ]]; then
  cd $HOME_PATH
  TIME y "正在执行：更新和安装feeds"
  ./scripts/feeds update -a
  ./scripts/feeds install -a
fi
}

function Ben_configuration() {
    cd "${HOME_PATH}" || exit 1
    if [[ "${Menuconfig_Config}" != "true" ]]; then
        return
    fi
    TIME y "正在执行：选取插件等..."
    while true; do
        if make menuconfig; then
            break  # 配置成功则退出循环
        else
            TIME y "SSH工具窗口分辨率太小，无法弹出设置机型或插件的窗口"
            TIME g "请调整SSH工具窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
            while :; do
                read -p "请输入您的选择[Y/N]：" menu_config
                case "${menu_config}" in
                    [Yy]) 
                        clear
                        break  # 仅退出内层循环，重新尝试 make menuconfig
                        ;;
                    [Nn])
                        exit 1
                        ;;
                    *) 
                        TIME r "输入错误，请重新输入"
                        ;;
                esac
            done
        fi
    done
}

function Ben_download() {
    local max_retries=4 retry=0
    cd "${HOME_PATH}" || { TIME r "目录切换失败"; exit 1; }

    while (( retry++ < max_retries )); do
        [[ "${retry}" == "1" ]] && TIME y "正在执行：下载DL文件..." || TIME y "第${retry}次尝试下载DL文件..."
        rm -f /tmp/build.log
        make -j8 download 2>&1 | tee /tmp/build.log
        local make_status=${PIPESTATUS[0]}

        # 双重验证机制
        if [[ ${make_status} -eq 0 ]] && ! grep -qE 'ERROR|Failed' /tmp/build.log; then
            TIME g "DL文件下载完成"
            return 0
        fi

        TIME r "下载DL失败，更换节点后再尝试重新下载？，日志报错："
        grep -E 'ERROR|Failed|warning' /tmp/build.log | head -n 5

        # 交互式重试逻辑
        TIME g "剩余重试次数: $((max_retries - retry))"
        read -p "[Y]重试/[N]退出：" choice
        [[ "${choice^^}" != "Y" ]] && exit 1
    done

    TIME r "已达最大重试次数"
    exit 1
}

function Ben_buildzuini() {
cat >"${LICENSES_DOC}/buildzu.ini" <<-EOF
SUCCESS_FAILED="${SUCCESS_FAILED}"
SOURCE_CODE="${SOURCE_CODE}"
SOURCE="${SOURCE}"
FOLDER_NAME="${FOLDER_NAME}"
REPO_BRANCH="${REPO_BRANCH}"
REPO_URL="${REPO_URL}"
LUCI_EDITION="${LUCI_EDITION}"
TARGET_BOARD="${TARGET_BOARD}"
MYCONFIG_FILE="${MYCONFIG_FILE}"
TARGET_PROFILE="${TARGET_PROFILE}"
CONFIG_FILE="${CONFIG_FILE}"
EOF
}

function Ben_compile() {
cd ${HOME_PATH}
[[ -f "${op_log}" ]] && rm -rf "${op_log}"
[[ ! -d "${LICENSES_DOC}" ]] && mkdir -p ${LICENSES_DOC}
START_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
Model_Name="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
Cpu_Cores="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"
RAM_total="$(free -h |awk 'NR==2' |awk '{print $(2)}' |sed 's/.$//')"
RAM_available="$(free -h |awk 'NR==2' |awk '{print $(7)}' |sed 's/.$//')"
[[ -d "${FIRMWARE_PATH}" ]] && sudo rm -rf ${FIRMWARE_PATH}/*
echo
TIME g "您的机器CPU型号为[ ${Model_Name} ]"
TIME y "在此ubuntu分配核心数为[ ${Cpu_Cores} ],线程数为[ $(nproc) ]"
TIME g "在此ubuntu分配内存为[ ${RAM_total} ],现剩余内存为[ ${RAM_available} ]"
echo

if [[ "$(nproc)" -ge "8" ]];then
  cpunproc="8"
else
  cpunproc="$(nproc)"
fi

TIME z "即将使用${cpunproc}线程进行编译固件,请耐心等候..."
sleep 5

# 开始编译固件
make -j${cpunproc} || make -j1 V=s 2>&1 | tee $op_log

# 检查编译结果grep -io 'Error 2' "${op_log}"
if [[ -f "${op_log}" ]] && [[ -n "$(grep -io 'Error 2' "${op_log}")" ]]; then
  SUCCESS_FAILED="breakdown"
  Ben_buildzuini
  TIME r "编译失败~~!"
  TIME y "在[operates/build.log]可查看编译日志"
  exit 1
else
  SUCCESS_FAILED="success"
  Ben_buildzuini
fi
}

function Ben_firmware() {
cd ${FIRMWARE_PATH}
# 整理固件
cp -Rf config.buildinfo ${MYCONFIG_FILE}
if [[ -n "$(ls -1 |grep -E 'immortalwrt')" ]]; then
  rename "s/^immortalwrt/openwrt/" *
  sed -i 's/immortalwrt/openwrt/g' `egrep "immortalwrt" -rl ./`
fi

for X in $(cat ${CLEAR_PATH} |sed "s/.*${TARGET_BOARD}//g"); do
  rm -rf *"$X"*
done

if echo "$TARGET_BOARD" | grep -Eq 'armvirt|armsr'; then
  [[ ! -d "$GITHUB_WORKSPACE/amlogic" ]] && mkdir -p $GITHUB_WORKSPACE/amlogic
  rm -rf $GITHUB_WORKSPACE/amlogic/${SOURCE}-armvirt-64-default-rootfs.tar.gz
  cp -Rf *rootfs.tar.gz $GITHUB_WORKSPACE/amlogic/${SOURCE}-armvirt-64-default-rootfs.tar.gz
  rootfs_targz="${SOURCE}-armvirt-64-default-rootfs.tar.gz"
  echo "ARMVIRT_TARGZ=armvirt" >>${LICENSES_DOC}/buildzu.ini
  TIME g "[ Amlogic_Rockchip系列专用固件 ]顺利编译完成~~~"
  TIME y "固件存放路径：amlogic/${SOURCE}-armvirt-64-default-rootfs.tar.gz"
  if [[ ${PACKAGING_FIRMWARE} == "true" ]]; then
    Ben_zidongdabao
  fi
else
  rename -v "s/^openwrt/${GUJIAN_DATE}-${SOURCE}-${LUCI_EDITION}-${LINUX_KERNEL}/" * > /dev/null 2>&1
  TIME g "[ ${FOLDER_NAME}-${LUCI_EDITION}-${TARGET_PROFILE} ]顺利编译完成~~~"
  TIME y "固件存放路径：openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
fi

cd ${HOME_PATH}
# 计算结编译束时间
TIME g "编译日期：$(date +'%Y年%m月%d号')"
END_TIME=`date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s`
SECONDS=$((END_TIME-START_TIME))
HOUR=$(( $SECONDS/3600 ))
MIN=$(( ($SECONDS-${HOUR}*3600)/60 ))
SEC=$(( $SECONDS-${HOUR}*3600-${MIN}*60 ))
if [[ "${HOUR}" == "0" ]]; then
  TIME y "编译总计用时 ${MIN}分${SEC}秒"
else
  TIME g "编译总计用时 ${HOUR}时${MIN}分${SEC}秒"
fi
TIME r "提示：再次输入编译命令可进行二次编译"
}

function Ben_zidongdabao() {
cd ${HOME_PATH}
DIY_PT1_DABAO="${OPERATES_PATH}/${FOLDER_NAME}/diy-part.sh"
echo '#!/bin/bash' > "/tmp/zidong.sh"
grep -E '.*export.*=".*"' "$DIY_PT1_DABAO" >> "/tmp/zidong.sh"
chmod +x "/tmp/zidong.sh" && source "/tmp/zidong.sh"
TIME g "执行自动打包任务"
sleep 2
Ben_packaging2
}

function Ben_packaging() {
# 固件打包
cd ${GITHUB_WORKSPACE}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}\n==== 打包信息采集 ====${NC}\n"
echo -e "\n${YELLOW}请选择固件源码：${NC}"
options=("Lede" "Immortalwrt" "Lienol" "Official" "Xwrt" "Mt798x")
while true; do
    echo "请选择："
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[i]}"
    done
    read -t 0.1 -r dummy
    read -r -p "请输入选项编号: " REPLY
    if [[ -z "$REPLY" ]]; then
        echo -e "${RED}错误：输入不能为空！${NC}"
        continue
    elif ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误：必须输入数字！${NC}"
        continue
    elif (( REPLY < 1 || REPLY > ${#options[@]} )); then
        echo -e "${RED}错误：无效选项编号！${NC}"
        continue
    fi
    index=$((REPLY-1))
    echo -e "已选择: ${GREEN}[${options[index]}-armvirt-64-default-rootfs.tar.gz]${NC}\n"
    rootfs_targz="${options[index]}-armvirt-64-default-rootfs.tar.gz"
    break
done

echo -e "\n${YELLOW}输入机型,比如：s905d 或 s905d_s905x2${NC}"
while :; do
    read -p "请输入打包机型: " amlogic_model
    if [[ -n "$amlogic_model" ]]; then
        echo -e "已设置: ${GREEN}$amlogic_model机型${NC}\n"
        break
    else
        echo -e "${RED}错误：机型不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}输入内核版本,比如：5.15.180 或 6.1.134_6.12.23${NC}"
while :; do
    read -p "请输入内核版本: " amlogic_kernel
    if [[ -n "$amlogic_kernel" ]]; then
        echo -e "已设置内核版本: ${GREEN}$amlogic_kernel${NC}\n"
        break
    else
        echo -e "${RED}错误：内核版本不能为空！${NC}\n"
    fi
done

echo -e "${YELLOW}是否开启自动使用最新版内核${NC}"
echo -e "\n${GREEN}比如您上面设置为[5.15.180]则会自动检测[5.15.x]的最新版本,如果[5.15.215]为最新则用此内核${NC}"
optionnk=("是" "否")
while true; do
    echo "请选择："
    for i in "${!optionnk[@]}"; do
        echo "$((i+1))) ${optionnk[i]}"
    done
    read -t 0.1 -r dummy
    read -r -p "请输入选项编号: " REPLY
    if [[ -z "$REPLY" ]]; then
        echo -e "${RED}错误：输入不能为空！${NC}"
        continue
    elif ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误：必须输入数字！${NC}"
        continue
    elif (( REPLY < 1 || REPLY > ${#optionnk[@]} )); then
        echo -e "${RED}错误：无效选项编号！${NC}"
        continue
    fi
    index=$((REPLY-1))
    echo -e "已选择: ${GREEN}[${optionnk[index]}]${NC}\n"
    auto_kernell="${optionnk[index]}"
    break
done

if [[ "${auto_kernell}" == "否" ]]; then
    auto_kernel="false"
else
    auto_kernel="true"
fi

echo -e "\n${YELLOW}设置rootfs大小(单位：MiB),比如：1024 或 512/2560 的格式类型${NC}"
while :; do
    read -p "请输入数值: " rootfs_size
    if [[ -n "$rootfs_size" ]]; then
        echo -e "已设置rootfs: ${GREEN}$rootfs_size${NC}"
        break
    else
        echo -e "${RED}错误：数值不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}请选择内核仓库(内核的作者,一般为stable)：${NC}"
optionck=("stable" "flippy" "dev" "beta")
while true; do
    echo "请选择："
    for i in "${!optionck[@]}"; do
        echo "$((i+1))) ${optionck[i]}"
    done
    read -t 0.1 -r dummy
    read -r -p "请输入选项编号: " REPLY
    if [[ -z "$REPLY" ]]; then
        echo -e "${RED}错误：输入不能为空！${NC}"
        continue
    elif ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误：必须输入数字！${NC}"
        continue
    elif (( REPLY < 1 || REPLY > ${#optionck[@]} )); then
        echo -e "${RED}错误：无效选项编号！${NC}"
        continue
    fi
    index=$((REPLY-1))
    echo -e "已选择: ${GREEN}[${optionck[index]}]${NC}\n"
    kernel_usage="${optionck[index]}"
    break
done

echo -e "\n${GREEN}==== 录入完成 ====${NC}"
echo -e "▪ 固件名称\t: $rootfs_targz"
echo -e "▪ 打包机型\t: $amlogic_model"
echo -e "▪ 内核版本\t: $amlogic_kernel"
echo -e "▪ 分区大小\t: $rootfs_size"
echo -e "▪ 内核仓库\t: $kernel_usage"
echo -e "▪ 内核选择\t: $auto_kernell"

echo -e "\n${YELLOW}检查信息是否正确,正确输入[Y/y]回车继续,重新输入则[Q/q]回车,[N/n]回车退出打包${NC}\n"
while :; do
read -p "请选择：" SNKC
  case ${SNKC} in
  [Yy])
      TIME g "开始打包固件..."
      Ben_packaging2
      break
  ;;
  [Qq])
      clear
      Ben_packaging
      break
  ;;
  [Nn])
      exit 1
      break
  ;;
  *)
      TIME r "请输入正确选项"
  ;;
  esac
done
}

function Ben_packaging2() {
cd ${GITHUB_WORKSPACE}
kernel_repo="ophub/kernel"
builder_name="ophub"
openwrt_board="${amlogic_model}"
openwrt_kernel="${amlogic_kernel}"
auto_kernel="${auto_kernel}"
openwrt_size="${rootfs_size}"
kernel_usage="${kernel_usage}"

if [[ -z "${openwrt_board}" ]]; then
  TIME r "diy-part.sh文件缺少机型配置"
  exit 1
fi
if [[ -z "${openwrt_kernel}" ]]; then
  TIME r "diy-part.sh文件缺少内核配置"
  exit 1
fi
if [[ -z "${auto_kernel}" ]]; then
  auto_kernel="true"
fi
if [[ -z "${openwrt_size}" ]]; then
  rootfs_size="1024"
fi
if [[ -z "${kernel_usage}" ]]; then
  kernel_usage="stable"
fi

echo
echo "打包机型：${openwrt_board}"
echo "打包内核：${openwrt_kernel}"
echo "是否最新内核：${auto_kernel}"
echo "分区数值：${openwrt_size}"
echo "内核仓库：${kernel_usage}"
echo "固件名称：${rootfs_targz}"
echo
sleep 2

CLONE_DIR="$GITHUB_WORKSPACE/armvirt"
if [[ -d "${CLONE_DIR}/make-openwrt/openwrt-files/common-files" ]]; then
  TIME_THRESHOLD=86400
  LAST_MODIFIED=$(stat -c %Y "$CLONE_DIR" 2>/dev/null || echo 0)
  CURRENT_TIME=$(date +%s)
  TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED))
  if [ "$TIME_DIFF" -gt "$TIME_THRESHOLD" ]; then
    sudo rm -rf "$CLONE_DIR"
    if [[ -d "${CLONE_DIR}" ]]; then
      TIME r "旧的打包程序存在,且无法删除,请重启ubuntu再来操作"
      exit 1
    fi
  fi
else
  sudo rm -rf "$CLONE_DIR"
  if [[ -d "${CLONE_DIR}" ]]; then
    TIME r "旧的打包程序存在,且无法删除,请重启ubuntu再来操作"
    exit 1
  fi
fi

if [[ ! -f "$GITHUB_WORKSPACE/amlogic/${rootfs_targz}" ]]; then
  [[ ! -d "$GITHUB_WORKSPACE/amlogic" ]] && mkdir -p $GITHUB_WORKSPACE/amlogic
  TIME r "请用工具将[${rootfs_targz}]固件存入[$GITHUB_WORKSPACE/amlogic]文件夹中"
  exit 1
else
  find $GITHUB_WORKSPACE/amlogic -type f -name "*.rootfs.tar.gz" -size -2M -delete
  sudo rm -rf $GITHUB_WORKSPACE/amlogic/*Identifier*
  if [[ ! -f "$GITHUB_WORKSPACE/amlogic/${rootfs_targz}" ]]; then
    TIME r "请用工具将[${rootfs_targz}]固件存入[$GITHUB_WORKSPACE/amlogic]文件夹中"
    exit 1
  fi
fi

if [[ ! -d "${CLONE_DIR}" ]]; then
  TIME y "正在下载打包程序,请稍后..."
  if git clone -q --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git $CLONE_DIR; then
    echo "请勿修改和删除此文件夹内的任何文件" > $CLONE_DIR/请勿修改和删除此文件夹内的任何文件.txt
    mkdir -p $CLONE_DIR/openwrt-armvirt
  else
    TIME r "打包程序下载失败,请检查网络"
    exit 1
  fi
fi

if [[ -f "${CLONE_DIR}/remake" ]]; then
  [[ -d "${CLONE_DIR}/openwrt/out" ]] && sudo rm -rf ${CLONE_DIR}/openwrt/out/*
  sudo rm -rf ${CLONE_DIR}/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  cp -Rf $GITHUB_WORKSPACE/amlogic/${rootfs_targz} ${CLONE_DIR}/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz
  if [[ ! -f "${CLONE_DIR}/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz" ]]; then
    TIME r "armvirt-64-default-rootfs.tar.gz不存在,请检查amlogic文件夹内是否有${rootfs_targz}存在"
    exit 1
  fi
  cd ${CLONE_DIR}
  sudo chmod +x remake
  sudo ./remake -b ${openwrt_board} -r ${kernel_repo} -u ${kernel_usage} -k ${openwrt_kernel} -a ${auto_kernel} -s ${openwrt_size} -n ${builder_name}
  if [[ $? -eq 0 ]];then
    TIME g "打包完成，固件存放在[${CLONE_DIR}/openwrt/out]文件夹"
    exit 0
  else
    TIME r "打包失败!"
    exit 1
  fi
else
  TIME r "未知原因打包程序文件不存在,或上游改变了程序文件名称"
  exit 1
fi
}

function jianli_wenjian() {
clear
echo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\n${YELLOW}请选择以什么文件夹为蓝本来建立新文件夹：${NC}"
option=("Lede" "Immortalwrt" "Lienol" "Official" "Xwrt" "Mt798x")
while true; do
    echo "请选择："
    for i in "${!option[@]}"; do
        echo "$((i+1))) ${option[i]}"
    done
    read -t 0.1 -r dummy
    read -r -p "请输入选项编号: " REPLY
    if [[ -z "$REPLY" ]]; then
        echo -e "${RED}错误：输入不能为空！${NC}"
        continue
    elif ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误：必须输入数字！${NC}"
        continue
    elif (( REPLY < 1 || REPLY > ${#option[@]} )); then
        echo -e "${RED}错误：无效选项编号！${NC}"
        continue
    fi
    index=$((REPLY-1))
    echo -e "已选择${GREEN}[${option[index]}]${NC}作为蓝本\n"
    gender_wenjian="${option[index]}"
    break
done

echo -e "\n${YELLOW}请输入您要建立的文件夹名称${NC}"
while :; do
    read -p "请输入文件夹名称: " openwrt_wenjian
    if [[ -n "$openwrt_wenjian" ]]; then
        echo -e "${GREEN}文件夹名称：$openwrt_wenjian${NC}\n"
        break
    else
        echo -e "${RED}错误：文件夹名称不能为空！${NC}\n"
    fi
done

echo -e "\n${YELLOW}正在建立文件夹,请稍后...${NC}"
sudo rm -rf /tmp/actions
if git clone -q --depth 1 https://github.com/281677160/build-actions /tmp/actions; then
  if [[ -d "${OPERATES_PATH}/${openwrt_wenjian}" ]]; then
    echo -e "${RED}错误：${openwrt_wenjian}文件夹已存在,无法再次建立！${NC}\n"
  else
    if [[ -d "/tmp/actions/build/$gender_wenjian" ]]; then
      cp -Rf /tmp/actions/build/$gender_wenjian ${OPERATES_PATH}/${openwrt_wenjian}
    else
      TIME r "上游已经没有$gender_wenjian文件夹存在了,或下载上游过程出现错误！"
      exit 1
    fi
    if [[ -d "${OPERATES_PATH}/${openwrt_wenjian}" ]]; then
      echo -e "${GREEN}$openwrt_wenjian文件夹建立完成！${NC}\n"
    else
      TIME r "未知原因导致文件夹建立失败,请重试看看"
      exit 1
    fi
  fi
else
  clear
  echo -e "${RED}上游文件下载错误,请检查网络${NC}\n"
  jianli_wenjian
fi

echo -e "\n${YELLOW}按Q回车返回主菜单,按N退出程序${NC}\n"
while :; do
read -p "请选择：" SRNKC
  case ${SRNKC} in
  [Qq])
      menu1
      break
  ;;
  [Nn])
      exit 1
      break
  ;;
  *)
      TIME r "请输入正确选项"
  ;;
  esac
done
}

function shanchu_wenjian() {
clear
echo
cd ${OPERATES_PATH}
ls -d */ |cut -d"/" -f1 |awk '{print "  " $0}'
cd ${GITHUB_WORKSPACE}
TIME y "请输入您要删除的文件名称,多个文件名的话请用英文的逗号分隔,输入[N/n]回车则退出"
while :; do
    read -p "请输入：" cc
    if [[ "${cc}" =~ ^[Nn]$ ]]; then
        exit 0
    elif [[ -z "${cc}" ]]; then
        TIME r " 警告：文件夹名称不能为空"
    else
        TIME g " 选择删除[${cc}]文件夹"
        break
    fi
done

bb=(${cc//,/ })
for i in ${bb[@]}; do
  if [[ -d "${OPERATES_PATH}/${i}" ]]; then
    sudo rm -rf ${OPERATES_PATH}/${i}
    TIME y " 已删除[${i}]文件夹"
  else
    TIME r " [${i}]文件夹不存在"
  fi
done

TIME g "按Q回车返回主菜单,按N退出程序"
while :; do
read -p "请选择：" SNTKC
  case ${SNTKC} in
  [Qq])
      menu1
      break
  ;;
  [Nn])
      exit 1
      break
  ;;
  *)
      TIME r "请输入正确选项"
  ;;
  esac
done
}


function Ben_menu() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu
}

function Ben_menu2() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu2
}

function Ben_menu3() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu3
}

function Ben_menuconfig() {
cd $HOME_PATH
Ben_configuration
}

function Ben_menu4() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu4
}

function Ben_menu5() {
cd $HOME_PATH
source $COMMON_SH && Diy_menu5
source $GITHUB_ENV
}

function Ben_menu6() {
cd $HOME_PATH
Ben_download
}

function Ben_menu7() {
cd $HOME_PATH
Ben_compile
Ben_firmware
}


function Diy_main() {
Ben_wslpath
Ben_diskcapacity
Ben_variable
Ben_config
Ben_xiazai
Ben_menu
Ben_menu2
Ben_menu3
Ben_menuconfig
Ben_menu4
Ben_menu5
Ben_menu6
Ben_menu7
}

function Diy_main2() {
Ben_variable
Ben_config
Ben_diskcapacity
Ben_xiazai
Ben_menu
Ben_menu2
Ben_menu3
Ben_menuconfig
Ben_menu4
Ben_menu5
Ben_menu6
Ben_menu7
}

function Diy_main3() {
Ben_variable
Ben_config
Ben_diskcapacity
Ben_xiazai
Ben_menuconfig
Ben_menu4
Ben_download
Ben_menu7
}


function wenjian() {
cd ${GITHUB_WORKSPACE}
clear
echo
TIME y " 1. 添加文件夹"
TIME y " 2. 删除文件夹"
TIME r " 3. 返回主菜单"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  jianli_wenjian
break
;;
2)
  shanchu_wenjian
break
;;
3)
  menu1
break
;;
*)
   XUANZHEOP="请输入正确的数字编号"
;;
esac
done
}

function menu1() {
cd ${GITHUB_WORKSPACE}
clear
echo
TIME y " 1. 进行编译固件"
TIME g " 2. 创建或删除文件夹"
TIME y " 3. 打包aarch64系列固件"
TIME r " 4. 退出程序"
echo
XUANZHEOP="请输入数字"
echo
while :; do
read -p " ${XUANZHEOP}： " CHOOSE
case $CHOOSE in
1)
  menu3
break
;;
2)
  wenjian
break
;;
3)
  Ben_packaging
break
;;
4)
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

function menu2() {
  clear
  echo
  if [[ "${SUCCESS_FAILED}" == "success" ]]; then
    TIME l " 提示：上回使用${SOURCE}-${LUCI_EDITION}源码${Font}${Blue}成功编译${TARGET_PROFILE}固件"
  else
    TIME r " 提示：上回使用${SOURCE}-${LUCI_EDITION}源码${Font}${Blue}编译${TARGET_PROFILE}固件失败"
    TIME l " 提示：需要注意的是,有些情况下编译失败,还保留缓存继续编译的话,会一直编译失败的"
  fi
  if [[ "${ARMVIRT_TARGZ}" == "armvirt" ]]; then
    mydabao="除了读取打包设置,"
  fi
  echo
  TIME y " 1、保留全部缓存,${mydabao}不再读取配置文件,只执行(make menuconfig)再编译"
  TIME g " 2、保留部分缓存(插件源码都重新下载),读取所有配置文件再编译"
  TIME y " 3、放弃缓存,重新编译"
  TIME g " 4、重选择源码编译"
  TIME y " 5. 打包aarch64系列固件"
  TIME g " 6、返回主菜单"
  TIME r " 7、退出"
  echo
  XUANZop="请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    export NUM_BER="3"
    Diy_main3
  break
  ;;
  2)
    export NUM_BER="2"
    Diy_main2
  break
  ;;
  3)
    export NUM_BER="1"
    Diy_main
  break
  ;;
  4)
    export NUM_BER=""
    menu3
  break
  ;;
  5)
    Ben_packaging
  break
  ;;
  6)
    export NUM_BER=""
    menu1
  break
  ;;
  7)
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

function menu3() {
  clear
  echo 
  echo
  cd ${OPERATES_PATH}
  ls -d */ | grep -v 'common\|backups' |cut -d"/" -f1 > /tmp/GITHUB_EVN
  XYZDSZ="$(cat '/tmp/GITHUB_EVN' |awk '$0=NR" "$0'| awk 'END {print}' |awk '{print $(1)}')"
  cat '/tmp/GITHUB_EVN' |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  cd ${GITHUB_WORKSPACE}
  YMXZQ="RpyZm"
  if [[ "${SUCCESS_FAILED}" =~ (success|breakdown) ]]; then
      hx=",输入[Q/q]返回上一步"
      YMXZQ="Q|q"
  fi
  TIME y "请输入您要编译源码前面对应的数值(1~${XYZDSZ})${hx}，输入[N/n]则为退出程序"
  while :; do
    read -p "请输入您的选择：" YMXZ
    if [[ "${YMXZ}" =~ ^[Nn]$ ]]; then
        exit 0
    elif [[ -z "${YMXZ}" ]]; then
        TIME r "敬告,输入不能为空"
    elif [[ "$YMXZ" =~ ^[0-9]+$ ]]; then
      if (( YMXZ >= 1 && YMXZ <= XYZDSZ )); then
        export FOLDER_NAME=$(awk -v line="$YMXZ" 'NR == line {print; exit}' /tmp/GITHUB_EVN)
        export NUM_BER="1"
        TIME g "您选择了使用 ${FOLDER_NAME} 编译固件"
        sleep 3
        Diy_main
        break
      else
        TIME r "敬告,请输入正确数值(1~${XYZDSZ})" >&2
      fi
    elif [[ "${YMXZ}" =~ (${YMXZQ}) ]]; then
        menu2
        break
    else
        TIME r "敬告,请输入正确值"
    fi
  done
}

function main() {
if [[ ! -f "/etc/oprelyonu" ]]; then
  Ben_update
fi
if [[ -f "${LICENSES_DOC}/buildzu.ini" ]]; then
  source ${LICENSES_DOC}/buildzu.ini
fi
if [[ ! -d "${OPERATES_PATH}" ]]; then
  Ben_variable
fi
if [[ -n "${SUCCESS_FAILED}" ]]; then
  required_dirs=("config" "include" "package" "scripts" "target" "toolchain" "tools" "build_dir")
  missing_flag=0
  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$HOME_PATH/$dir" ]]; then
      missing_flag=1
    fi
  done
  
  if [[ $missing_flag -eq 0 ]] && [[ -n "$( grep -E "${TARGET_BOARD}" "$HOME_PATH/.config" 2>/dev/null)" ]] && \
  [[ -n "$( grep -E "${REPO_URL}" "${DIAN_GIT}" 2>/dev/null)" ]] && [[ -n "$( grep -E "${REPO_BRANCH}" "${DIAN_GIT}" 2>/dev/null)" ]]; then
    menu2
  else
    menu1
  fi
else
  menu1
fi
}
main
