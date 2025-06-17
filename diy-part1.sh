#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# 添加 luci-app-overview-widgets 插件
echo 'src-git overview_widgets https://github.com/hzy306016819/luci-app-overview-widgets.git' >> feeds.conf.default

# Add package
# 增加ssid-auto到package/custom
# mkdir -p openwrt/package/custom
# git clone https://github.com/hzy306016819/ssid-auto.git package/custom/ssid-auto
