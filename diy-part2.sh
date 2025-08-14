#!/bin/bash
# diy-part2.sh - 整合mosdns和overview-widgets的添加逻辑

# Modify default IP
sed -i 's/192.168.6.1/192.168.100.10/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
