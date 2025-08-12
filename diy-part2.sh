#!/bin/bash
# diy-part2.sh - 整合mosdns和overview-widgets的添加逻辑

# 在.config中启用所有需要的包
echo "启用必要组件..."
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_mosdns=y" >> .config
echo "CONFIG_PACKAGE_v2ray-geodata=y" >> .config
echo "CONFIG_PACKAGE_luci-app-overview-widgets=y" >> .config  # 启用overview-widgets

# Modify default IP
sed -i 's/192.168.6.1/192.168.100.10/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
