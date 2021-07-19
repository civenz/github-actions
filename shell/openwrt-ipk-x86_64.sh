#!/bin/bash

OS_TARGET="x86_64"
SDK_NAME="openwrt-sdk-21.02.0-rc3-x86-64_gcc-8.4.0_musl.Linux-x86_64"
SDK_URL="https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/21.02.0-rc3/targets/x86/64/$SDK_NAME.tar.xz"
MAKE_PARAM="-j8 V=s"
IPK_SRC_NAME="luci-app-xray"
IPK_SRC_URL="https://github.com/yichya/luci-app-xray.git"

################################################################################
#### x86-64_gcc-8.4.0_musl 的 ipk 编译
################################################################################

#### 安装 openwrt 对应的 sdk
wget $SDK_URL
tar -xvf $SDK_NAME.tar.xz
mv $SDK_NAME openwrt-sdk && cd openwrt-sdk
cd openwrt-sdk

#### 下载 包源码
git clone $IPK_SRC_URL ./package/$IPK_SRC_NAME

grep CATEGORY:= ./package/$IPK_SRC_NAME/Makefile    # 配置-分类
grep TITLE:= ./package/$IPK_SRC_NAME/Makefile       # 配置-标题

PKG_NAME=$(grep PKG_NAME:= ./package/luci-app-xray/Makefile | sed 's/^PKG_NAME:=//g')           # 包名称
PKG_VERSION=$(grep PKG_VERSION:= ./package/luci-app-xray/Makefile | sed 's/PKG_VERSION:=//g')	# 包版本
PKG_RELEASE=$(grep PKG_RELEASE:= ./package/luci-app-xray/Makefile | sed 's/PKG_RELEASE:=//g')   # 发行号
IPK_NAME=$PKG_NAME\_$PKG_VERSION\-$PKG_RELEASE\_$OS_TARGET

make defconfig          ## make menuconfig 选择它并保存退出: Extra packages > LuCI Support for Xray
make $MAKE_PARAM

cd ..
cp openwrt-sdk/bin/packages/$OS_TARGET/base/$IPK_NAME.ipk $IPK_NAME.ipk
tar -czvf my_files.tar.gz $IPK_NAME.ipk
