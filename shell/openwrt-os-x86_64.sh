#!/bin/bash

REPO_URL=https://git.openwrt.org/openwrt/openwrt.git
#REPO_URL=https://gitee.com/civenz/openwrt.git
REPO_BRANCH=openwrt-21.02
MAKE_PARAM="-j8 V=s"

sudo apt update && sudo apt install build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools rsync subversion swig time \
xsltproc zlib1g-dev re2c curl \
asciidoc binutils bzip2 libz-dev patch lib32gcc1 libc6-dev-i386 \
flex uglifyjs gcc-multilib p7zip p7zip-full msmtp texinfo libglib2.0-dev \
xmlto qemu-utils upx  autoconf automake libtool autopoint device-tree-compiler \
g++-multilib antlr3 gperf


curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.21.0-rc3/cmake-3.21.0-rc3-linux-x86_64.sh -o cmake.sh
mkdir cmake
sh cmake.sh --skip-license --prefix="./cmake"
sudo ln -sf cmake/bin/cmake /usr/bin/cmake

git clone $REPO_URL -b $REPO_BRANCH openwrt
cd openwrt

################################################################################
#### 这里插入第三方包到 openwrt/package 目录
#cat /dev/null > feeds.conf.default
#cat << EOF >> feeds.conf.default
#src-git packages https://gitee.com/civenz/openwrt-feed-packages.git
#src-git luci https://gitee.com/civenz/openwrt-project-luci.git
#src-git routing https://gitee.com/civenz/openwrt-feed-routing.git
#src-git telephony https://gitee.com/civenz/openwrt-feed-telephony.git
## 
##src-git packages https://git.openwrt.org/feed/packages.git
##src-git luci https://git.openwrt.org/project/luci.git
##src-git routing https://git.openwrt.org/feed/routing.git
##src-git telephony https://git.openwrt.org/feed/telephony.git
## 
##src-git video https://github.com/openwrt/video.git
##src-git targets https://github.com/openwrt/targets.git
##src-git oldpackages http://git.openwrt.org/packages.git
##src-link custom /usr/src/openwrt/custom-feed
#EOF
################################################################################


################################################################################
#### 自定义编译配置文件
cat /dev/null > .config
cat << EOF >> .config
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
CONFIG_TARGET_KERNEL_PARTSIZE=256
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
EOF

sed -i 's/192.168.1.1/192.168.1.2/g' ./package/base-files/files/bin/config_generate
################################################################################



./scripts/feeds update -a
./scripts/feeds install -a
make defconfig					#make menuconfig
make download -j8
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
make $MAKE_PARAM

cd ..
tar -czvf my_files.tar.gz ./openwrt/bin/targets/*
