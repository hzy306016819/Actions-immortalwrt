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


# 1. 清理旧版 Go
rm -rf feeds/packages/lang/golang
rm -rf ./tmp/go-build ./dl/go-mod-cache

# 2. 添加高版本 Go 24.x
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 3. 移除冲突的 v2ray-geodata
rm -rf feeds/packages/net/v2ray-geodata

# 4. 添加 mosdns 和 v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 5. 确保目录权限（GitHub Actions 需要）
chmod -R 755 package/mosdns package/v2ray-geodata

# Add package
# 增加ssid-auto到package/custom
# mkdir -p openwrt/package/custom
# git clone https://github.com/hzy306016819/ssid-auto.git package/custom/ssid-auto
