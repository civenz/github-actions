#!/bin/bash

REPO_URL="https://git.openwrt.org/openwrt/openwrt.git"
#REPO_URL="https://gitee.com/civenz/openwrt.git"
REPO_BRANCH="openwrt-21.02"
### last or release tag: v21.02.0-rc3
REPO_TAG="v21.02.0-rc3"
MAKE_PARAM="-j8"
CUSTOM_FEEDS="n"
DEPENDS="n"

if [ $DEPENDS == 'y' ]; then
    #apt install build-essential ccache ecj fastjar file g++ gawk \
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
fi

git clone $REPO_URL -b $REPO_BRANCH openwrt
cd openwrt

if [ $REPO_TAG != 'last' ]; then
    git checkout tags/$REPO_TAG
fi

#git checkout $REPO_BRANCH
#git checkout tags/$REPO_TAG
#git tag
git branch -a

################################################################################
#### 这里插入第三方包到 openwrt/package 目录
if [ $CUSTOM_FEEDS == 'y' ]; then
cat /dev/null > feeds.conf.default
cat << EOF >> feeds.conf.default
src-git packages https://gitee.com/civenz/openwrt-feed-packages.git
src-git luci https://gitee.com/civenz/openwrt-project-luci.git
src-git routing https://gitee.com/civenz/openwrt-feed-routing.git
src-git telephony https://gitee.com/civenz/openwrt-feed-telephony.git
# 
#src-link custom /usr/src/openwrt/custom-feed
EOF
fi
################################################################################


################################################################################
#### 自定义编译配置文件
cat /dev/null > .config
cat << EOF >> .config
#CONFIG_TARGET_KERNEL_PARTSIZE=16
#CONFIG_TARGET_ROOTFS_PARTSIZE=100
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_DEVICE_x86_64_DEVICE_generic=y
CONFIG_TARGET_DEVICE_PACKAGES_x86_64_DEVICE_generic=""
CONFIG_IB=n
CONFIG_SDK=n
CONFIG_PACKAGE_cgi-io=y
CONFIG_PACKAGE_libiwinfo=y
CONFIG_PACKAGE_libiwinfo-lua=y
CONFIG_PACKAGE_liblua=y
CONFIG_PACKAGE_liblucihttp=y
CONFIG_PACKAGE_liblucihttp-lua=y
CONFIG_PACKAGE_libubus-lua=y
CONFIG_PACKAGE_lua=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-lib-base=y
CONFIG_PACKAGE_luci-lib-ip=y
CONFIG_PACKAGE_luci-lib-jsonc=y
CONFIG_PACKAGE_luci-lib-nixio=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-mod-network=y
CONFIG_PACKAGE_luci-mod-status=y
CONFIG_PACKAGE_luci-mod-system=y
CONFIG_PACKAGE_luci-proto-ipv6=y
CONFIG_PACKAGE_luci-proto-ppp=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_px5g-wolfssl=y
CONFIG_PACKAGE_rpcd=y
CONFIG_PACKAGE_rpcd-mod-file=y
CONFIG_PACKAGE_rpcd-mod-iwinfo=y
CONFIG_PACKAGE_rpcd-mod-luci=y
CONFIG_PACKAGE_rpcd-mod-rrdns=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
## civen add
CONFIG_PACKAGE_dnsmasq=n
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_fdisk=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_f2fs-tools=y
CONFIG_PACKAGE_resize2fs=y
CONFIG_PACKAGE_tune2fs=y
CONFIG_PACKAGE_eject=y
EOF

sed -i 's/192.168.1.1/192.168.1.2/g' ./package/base-files/files/bin/config_generate
################################################################################

./scripts/feeds update -a
./scripts/feeds install -a
make defconfig                      #make menuconfig
make download -j8
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
make $MAKE_PARAM

git branch -a

cd ..
ls -lah ./openwrt/bin/targets/x86/64/

tar -czvf my_files.tar.gz -C ./openwrt/ .config

### openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz
### openwrt/bin/targets/x86/64/openwrt-sdk-*.tar.xz
