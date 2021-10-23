#/bin/bash

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
export UbuntuName=`cat /etc/issue`
export XTName="Ubuntu"
export XTbit=`getconf LONG_BIT`
if [[ ( $UbuntuName != *$XTName* ) || ( $XTbit != 64 ) ]]; then
	clear
	echo
	TIME y "请使用Ubuntu 64bit，推荐 Ubuntu 18 LTS 或 Ubuntu 20 LTS"
	echo
	sleep 3
	exit 0
fi
if [[ "$USER" == "root" ]]; then
	clear
	echo
	TIME y "警告：请勿使用root用户编译，换一个普通用户吧~~"
	echo
	sleep 3
	exit 0
fi
if [[ ! -e .compile ]]; then
	clear
	echo
	echo
	echo
	TIME z "|*******************************************|"
	TIME g "|                                           |"
	TIME y "|    首次编译,请输入Ubuntu密码继续下一步    |"
	TIME g "|                                           |"
	TIME z "|              编译环境部署                 |"
	TIME g "|                                           |"
	TIME r "|*******************************************|"
	echo
	echo
	sudo apt-get update -y
	sudo apt-get full-upgrade -y
	sudo apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl rename libpcap0.8-dev swig rsync
	[[ ! $? == 0 ]] && {
		clear
		echo
		TIME r "环境部署失败，请检测网络或更换节点再尝试!"
		exit 1
	} || {
		sudo timedatectl set-timezone Asia/Shanghai
		echo "compile" > .compile
	}
fi
rm -rf ${firmware}
if [[ -n "$(ls -A "openwrt/config_bf" 2>/dev/null)" ]]; then
	if [[ -n "$(ls -A "openwrt/.Lede_core" 2>/dev/null)" ]]; then
		export firmware="Lede_source"
		export CODE="lede"
		export Modelfile="Lede_source"
		export Core=".Lede_core"
		source openwrt/.Lede_core
	elif [[ -n "$(ls -A "openwrt/.Lienol_core" 2>/dev/null)" ]]; then
		export firmware="Lienol_source"
		export CODE="lienol"
		export Modelfile="Lienol_source"
		export Core=".Lienol_core"
		source openwrt/.Lienol_core
	elif [[ -n "$(ls -A "openwrt/.Mortal_core" 2>/dev/null)" ]]; then
		export firmware="Mortal_source"
		export CODE="mortal"
		export Modelfile="Mortal_source"
		export Core=".Mortal_core"
		source openwrt/.Mortal_core
	elif [[ -n "$(ls -A "openwrt/.amlogic_core" 2>/dev/null)" ]]; then
		export firmware="openwrt_amlogic"
		export CODE="lede"
		export Modelfile="openwrt_amlogic"
		export Core=".amlogic_core"
		source openwrt/.amlogic_core
	else
		clear
		echo
		echo
		echo
		TIME r "没检测到openwrt文件夹有执行文件，自动转换成首次编译命令编译固件，请稍后..."
		rm -rf {openwrt,.compile}
		rm -rf ${firmware}
		bash <(curl -fsSL git.io/JcGDV)
	fi
	if [[ ! -e openwrt/${Core} ]]; then
		if [[ -e ${firmware}/${Core} ]]; then
			source ${firmware}/${Core}
		fi
	fi
	echo
	if [[ `grep -c "CONFIG_TARGET_x86_64=y" openwrt/config_bf` -eq '1' ]]; then
          	export TARGET_PROFILE="x86-64"
	elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" openwrt/config_bf` -eq '1' ]]; then
          	export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" openwrt/config_bf | sed -r 's/.*DEVICE_(.*)=y/\1/')"
	else
          	export TARGET_PROFILE="armvirt"
	fi
	[[ ${firmware} == "openwrt_amlogic" ]] && {
		clear
		echo
		echo
		echo
		TIME g "正在使用[ ${firmware} ]源码编译[ N1和晶晨系列盒子专用固件 ],是否更换源码?"
	} || {
		clear
		echo
		echo
		echo
		TIME g "正在使用[ ${firmware} ]源码编译[ ${TARGET_PROFILE}固件 ],是否更换源码编译?"
	}
	read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " GHYM
	case $GHYM in
		[Yy])
			clear
			echo
			echo
			TIME r "您选择更改源码，正在清理旧文件中，请稍后..."
			rm -rf openwrt
			rm -rf ${firmware}
		;;
		*)
			export YUAN_MA="false"
			TIME y "您已关闭更换源码，保存配置中，请稍后..."
			mkdir -p ${firmware}
			cp -Rf openwrt/{config_bf,${Core},compile.sh} ${firmware} > /dev/null 2>&1
		;;
	esac
fi
export Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
export FINAL=`echo ${Ubunkj: -1}`
if [[ "${FINAL}" =~ (M|K) ]]; then
	echo
	TIME r "敬告：可用空间小于[ 1G ]退出编译,建议可用空间大于20G,是否继续?"
	sleep 2
	exit 1
	echo
fi
export Ubuntu_mz="$(cat /etc/group | grep adm | cut -f2 -d,)"
export Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
if [[ "${Ubuntu_kj}" -lt "20" ]];then
	echo
	TIME z "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
	echo
	read -p " [回车退出，Y/y确认继续]： " YN
	case ${YN} in
		[Yy]) 
			TIME g  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
			echo
		;;
		*)
			TIME y  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
			echo ""
			sleep 2s
			exit 0
	esac
fi
[[ ! ${YUAN_MA} == "false" ]] && {
	clear
	echo
	echo
	echo
	TIME l " 1. Lede_5.4内核,LUCI 18.06版本(Lede_source)"
	echo
	TIME l " 2. Lienol_4.14内核,LUCI 19.07版本(Lienol_source)"
	echo
	TIME l " 3. Immortalwrt_5.4内核,LUCI 21.02版本(Mortal_source)"
	echo
	TIME l " 4. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
	echo
	TIME l " 5. 退出编译程序"
	echo
	echo
	echo
	while :; do
	TIME g "请选择编译源码,输入[ 1、2、3、4、5 ]然后回车确认您的选择！"
	read -p " 输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			export firmware="Lede_source"
			export CODE="lede"
			export Core=".Lede_core"
			export Modelfile="Lede_source"
			source Lede_source/.Lede_core > /dev/null 2>&1
			TIME y "您选择了：Lede_5.4内核,LUCI 18.06版本"
		break
		;;
		2)
			export firmware="Lienol_source"
			export CODE="lienol"
			export Core=".Lienol_core"
			export Modelfile="Lienol_source"
			source Lienol_source/.Lienol_core > /dev/null 2>&1
			TIME y "您选择了：Lienol_4.14内核,LUCI 19.07版本"
		break
		;;
		3)
			export firmware="Mortal_source"
			export CODE="mortal"
			export Core=".Mortal_core"
			export Modelfile="Mortal_source"
			source Mortal_source/.Mortal_core > /dev/null 2>&1
			TIME y "您选择了：Immortalwrt_5.4内核,LUCI 21.02版本"
		break
		;;
		4)
			export firmware="openwrt_amlogic"
			export CODE="lede"
			export Core=".amlogic_core"
			export Modelfile="openwrt_amlogic"
			source openwrt_amlogic/.amlogic_core > /dev/null 2>&1
			TIME y "您选择了：N1和晶晨系列CPU盒子专用"
		break
		;;
		5)
			rm -rf compile.sh
			TIME r "您选择了退出编译程序"
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
}
echo
echo
[[ -z ${ipdz} ]] && export ipdz="192.168.1.1"
TIME g "设置openwrt的后台IP地址[ 回车默认 $ipdz ]"
read -p " 请输入后台IP地址：" ip
export ip=${ip:-"$ipdz"}
TIME y "您的后台地址为：$ip"
echo
echo
TIME g "是否需要选择机型和增删插件?"
read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " MENU
case $MENU in
	[Yy])
		export Menuconfig="YES"
		TIME y "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
	;;
	*)
		TIME r "您已关闭选择机型和增删插件设置！"
	;;
esac
echo
echo
TIME g "是否把固件上传到<奶牛快传>?"
read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " NNKC
case $NNKC in
	[Yy])
		export UPCOWTRANSFER="true"
		TIME y "您执行了上传固件到<奶牛快传>!"
	;;
	*)
		TIME r "您已关闭上传固件到<奶牛快传>！"
	;;
esac
echo
echo
[[ ! $firmware == "openwrt_amlogic" ]] && {
	TIME g "是否把定时更新插件编译进固件?"
	read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " RELE
	case $RELE in
		[Yy])
			export REG_UPDATE="true"
		;;
		*)
			TIME r "您已关闭把‘定时更新插件’编译进固件！"
			export Github="https://github.com/281677160/build-actions"
		;;
	esac
}
[[ "${REG_UPDATE}" == "true" ]] && {
	[[ -z ${Git} ]] && export Git="https://github.com/281677160/build-actions"
	TIME g "设置Github地址,定时更新固件需要把固件传至对应地址的Releases"
	TIME z "回车默认为：$Git"
	read -p " 请输入Github地址：" Github
	export Github=${Github:-"$Git"}
	TIME y "您的Github地址为：$Github"
	export Apidz="${Github##*com/}"
	export Author="${Apidz%/*}"
	export CangKu="${Apidz##*/}"
}
echo
mkdir -p ${firmware}
cat >${firmware}/${Core} <<-EOF
ipdz=$ip
Git=$Github
EOF
export Begin="$(date "+%Y/%m/%d-%H.%M")"
export date1="$(date +'%m-%d')"
echo
TIME g "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
	rm -rf openwrt && git clone https://github.com/coolsnowwolf/lede openwrt
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		echo
	 	exit 1
	}
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.Lede_core
	echo -e "\nGit=$Github" >> openwrt/.Lede_core
elif [[ $firmware == "Lienol_source" ]]; then
	rm -rf openwrt && git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		echo
	 	exit 1
	}
	export ZZZ="package/default-settings/files/zzz-default-settings"
	export OpenWrt_name="19.07"
	echo -e "\nipdz=$ip" > openwrt/.Lienol_core
	echo -e "\nGit=$Github" >> openwrt/.Lienol_core
elif [[ $firmware == "Mortal_source" ]]; then
	rm -rf openwrt && git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		echo
	 	exit 1
	}
	export ZZZ="package/emortal/default-settings/files/zzz-default-settings"
	export OpenWrt_name="21.02"
	echo -e "\nipdz=$ip" > openwrt/.Mortal_core
	echo -e "\nGit=$Github" >> openwrt/.Mortal_core
elif [[ $firmware == "openwrt_amlogic" ]]; then
	rm -rf openwrt && git clone https://github.com/coolsnowwolf/lede openwrt
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		echo
	 	exit 1
	}
	echo
	TIME g "正在下载打包所需的内核,请耐心等候~~~"
	echo
	rm -rf amlogic-s9xxx && svn co https://github.com/ophub/amlogic-s9xxx-openwrt/trunk/amlogic-s9xxx amlogic-s9xxx
	[[ $? -ne 0 ]] && {
		rm -rf amlogic-s9xxx
		TIME r "内核下载失败，请检测网络或更换节点再尝试!"
		echo
		exit 1
	} || {
	mv amlogic-s9xxx openwrt/amlogic-s9xxx
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/make > openwrt/make
	mkdir -p openwrt/openwrt-armvirt
	chmod 777 openwrt/make
	}
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.amlogic_core
	echo -e "\nGit=$Github" >> openwrt/.amlogic_core
fi
if [[ "${UPCOWTRANSFER}" == "true" ]]; then
	curl -fsSL git.io/file-transfer | sh
fi
export GITHUB_WORKSPACE="$PWD"
export Home="$PWD/openwrt"
export PATH1="$PWD/openwrt/build/${firmware}"
export NETIP="package/base-files/files/etc/networkip"
[[ -e "${firmware}" ]] && cp -Rf "${firmware}"/${Core} "${Home}"/${Core}
echo "Compile_Date=$(date +%Y%m%d%H%M)" > $Home/Openwrt.info
[ -f $Home/Openwrt.info ] && . $Home/Openwrt.info
svn co https://github.com/281677160/build-actions/trunk/build $Home/build > /dev/null 2>&1
[[ $? -ne 0 ]] && {
	TIME r "编译脚本下载失败，请检测网络或更换节点再尝试!"
	exit 1
}
git clone https://github.com/281677160/common $Home/build/common
[[ $? -ne 0 ]] && {
	TIME r "脚本扩展下载失败，请检测网络或更换节点再尝试!"
	exit 1
}
chmod -R +x $Home/build/common
chmod -R +x $Home/build/${firmware}
source $Home/build/${firmware}/settings.ini
export REGULAR_UPDATE="${REG_UPDATE}"
cp -Rf $Home/build/common/Custom/compile.sh openwrt/compile.sh
cp -Rf $Home/build/common/*.sh openwrt/build/${firmware}
echo
TIME g "正在加载自定义文件和下载插件,请耐心等候~~~"
echo
cd $Home
./scripts/feeds update -a > /dev/null 2>&1
if [[ "${REPO_BRANCH}" == "master" ]]; then
	source "${PATH1}/common.sh" && Diy_lede
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
	source "${PATH1}/common.sh" && Diy_lienol
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
	source "${PATH1}/common.sh" && Diy_mortal
fi
source build/${firmware}/common.sh && Diy_all
[[ $? -ne 0 ]] && {
	TIME r "插件包下载失败，请检测网络或更换节点再尝试!"
	echo
	exit 1
}
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
cat >$NETIP <<-EOF
uci set network.lan.ipaddr='$ip'
uci commit network
EOF
sed -i "s/OpenWrt /${Ubuntu_mz} compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ
sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ
echo
sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./feeds/luci/applications`
sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./package`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./feeds/luci/applications`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./feeds/luci/applications`
./scripts/feeds update -a
./scripts/feeds install -a > /dev/null 2>&1
./scripts/feeds install -a
[[ -e ${Home}/config_bf ]] && {
	cp -rf ${Home}/config_bf ${Home}/.config
} || {
	cp -rf ${Home}/build/${firmware}/.config ${Home}/.config
}
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${Home}/.config` -eq '0' ]]; then
	echo -e "\nCONFIG_PACKAGE_luci-theme-argon=y" >> ${Home}/.config
fi
find . -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'DEVICE_NAME' | xargs -i rm -rf {}
[ "${Menuconfig}" == "YES" ] && {
make menuconfig
}
echo
TIME g "正在生成配置文件，请稍后..."
echo
source build/${firmware}/common.sh && Diy_chajian
make defconfig
./scripts/diffconfig.sh > ${Home}/config_bf
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	clear
	echo
	echo
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
	echo
	TIME g "如需重新编译请按 Ctrl+c 结束此次编译，否则30秒后继续编译!"
	make defconfig > /dev/null 2>&1
	sleep 30s
fi
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
if [[ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          export TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
rm -rf ../{Lede_source,Lienol_source,Mortal_source,openwrt_amlogic}
# 为编译做最后处理
BY_INFORMATION="false"
source build/${firmware}/common.sh && Diy_chuli
COMFIRMWARE="openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
TIME g "正在下载DL文件,请耐心等待..."
make -j8 download 2>&1 |tee build.log
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
	clear
	echo
	echo
	TIME g "下载DL失败，更换节点后再尝试下载？"
	read -p " [输入[ Y/y ]回车,退出下载，更换节点后按回车继续尝试下载DL]： " XZDL
	case $XZDL in
		[Yy])
			exit 1
			echo
		;;
		*)
			rm -rf build.log
			make -j8 download 2>&1 |tee build.log
			find dl -size -1024c -exec ls -l {} \;
			find dl -size -1024c -exec rm -f {} \;
		;;
	esac
fi
if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
	clear
	echo
	echo
	TIME g "下载DL失败，继续更换节点后再尝试下载？"
	read -p " [输入[ Y/y ]回车,退出下载，更换节点后按回车继续尝试下载DL]： " XZDLE
	case $XZDLE in
		[Yy])
			exit 1
			echo
		;;
		*)	
			rm -rf build.log
			make -j8 download 2>&1 |tee build.log
			find dl -size -1024c -exec ls -l {} \;
			find dl -size -1024c -exec rm -f {} \;
		;;
	esac
fi
if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
	echo
	rm -rf build.log
	TIME r "下载DL失败，请检查网络或者更换节点后再尝试编译!"
	exit 1
	echo
fi
rm -rf build.log
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
rm -rf CPU
clear
echo
echo
echo
TIME g "您的CPU型号为[ ${CPUNAME} ]"
echo
echo
TIME g "在Ubuntu使用核心数为[ ${CPUCORES} ],线程数为[ $(nproc) ]"
echo
echo
if [[ "$(nproc)" == "1" ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[3.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (2|3) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[3]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (4|5) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[2.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (6|7) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[2]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (8|9) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[1.5]小时左右,请耐心等待..."
else
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[1]小时左右,请耐心等待..."
fi
sleep 15
make -j$(nproc) V=s 2>&1 |tee build.log

if [ "$?" == "0" ]; then
	if [[ ${firmware} == "Mortal_source" ]]; then
		if [[ `ls ${COMFIRMWARE} | grep -c "immortalwrt"` == '0' ]]; then
			echo
			echo
			echo "编译失败，没发现固件存在~~!"
			echo
			echo "请不要使用桌面版ubuntu或者子系统编译，或者您的翻墙网络有问题，油管或者是飞快，但是不能用于编译"
			sleep 3
			exit 1
		fi
	else
		if [[ `ls ${COMFIRMWARE} | grep -c "openwrt"` == '0' ]]; then
			echo
			echo
			echo "编译失败，没发现固件存在~~!"
			echo
			echo "请不要使用桌面版ubuntu或者子系统编译，或者您的翻墙网络有问题，油管或者是飞快，但是不能用于编译"
			sleep 3
			exit 1
		fi
	
	fi
	export byend="1"
	export End="$(date "+%Y/%m/%d-%H.%M")"
	rm -rf $Home/build.log
	clear
	echo
	echo
	echo
	[[ ${firmware} == "openwrt_amlogic" ]] && {
		TIME y "使用[ ${firmware} ]文件夹，编译[ N1和晶晨系列盒子专用固件 ]顺利编译完成~~~"
	} || {
		TIME y "使用[ ${firmware} ]文件夹，编译[ ${TARGET_PROFILE} ]顺利编译完成~~~"
	}
	echo
	TIME y "后台地址: $ip"
	echo
	TIME y "用户名: root"
	echo
	TIME y "密 码: 无"
	echo
	TIME g "开始时间：${Begin}"
	echo
	TIME g "结束时间：${End}"
	echo
	TIME y "固件已经存入${COMFIRMWARE}文件夹中"
	echo
	if [[ "${REGULAR_UPDATE}" == "true" ]]; then
		[ -f $Home/Openwrt.info ] && . $Home/Openwrt.info
		cp -Rf ${Home}/bin/targets/*/* ${Home}/upgrade
		source build/${firmware}/upgrade.sh && Diy_Part3
		TIME g "加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
		echo
	fi
	if [[ $firmware == "openwrt_amlogic" ]]; then
		cp -Rf ${Home}/bin/targets/*/*/*.tar.gz ${Home}/openwrt-armvirt/ && sync
		TIME l "请输入一键打包命令进行打包固件，打包成功后，固件存放在[openwrt/out]文件夹中"
	fi
	echo
	cd ${Home}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}
	rename -v "s/^openwrt/${date1}-${CODE}/" * > /dev/null 2>&1
	rename -v "s/^immortalwrt/${date1}-${CODE}/" * > /dev/null 2>&1
	cd ${GITHUB_WORKSPACE}
	if [[ "${UPCOWTRANSFER}" == "true" ]]; then
		TIME g "正在上传固件至奶牛快传中，请稍后..."
		echo
		WETCOMFIRMWARE="${Home}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
		mv ${WETCOMFIRMWARE}/packages ${Home}/bin/targets/${TARGET_BOARD}/packages
		./transfer cow --block 2621440 -s -p 64 --no-progress ${WETCOMFIRMWARE} 2>&1 | tee cowtransfer.log > /dev/null 2>&1
		cow="$(cat cowtransfer.log | grep https | cut -f3 -d" ")"
		echo
		TIME y "奶牛快传：${cow}"
		echo "${cow}" > openwrt/bin/奶牛快传链接
		echo
	fi
	rm -rf $Home/Openwrt.info
	rm -rf ${Home}/upgrade
	rm -rf {transfer,cowtransfer.log,wetransfer.log}
	sleep 5
	exit 0
else
	echo
	echo
	TIME r "编译失败~~!"
	echo
	TIME y "请用WinSCP工具连接ubuntu然后把openwrt文件夹里面的[build.log]文件拖至电脑上"
	echo
	TIME y "在电脑上查看build.log文件日志详情！"
	echo
	byend="1"
	sleep 5
	exit 1
fi
if [[ "${byend}" == "1" ]]; then
	sleep 5
	exit 0
fi
