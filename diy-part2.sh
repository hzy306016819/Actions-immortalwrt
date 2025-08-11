#!/bin/bash
# diy-part2.sh - 整合mosdns和overview-widgets的添加逻辑

# 进入OpenWRT源码目录
cd $GITHUB_WORKSPACE/openwrt || exit

# 处理Golang环境（需要1.24.x或更高版本）
echo "替换Golang为24.x版本..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 移除现有v2ray-geodata（避免冲突）
echo "移除旧版v2ray-geodata..."
rm -rf feeds/packages/net/v2ray-geodata

# 移除源码中可能存在的旧版mosdns和v2ray-geodata
echo "清理旧版mosdns相关文件..."
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

# 克隆新版mosdns和v2ray-geodata
echo "克隆mosdns和v2ray-geodata..."
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 拉取luci-app-overview-widgets
echo "拉取luci-app-overview-widgets..."
cd package/feeds/luci/ || exit  # 进入luci feeds目录
git clone https://github.com/hzy306016819/luci-app-overview-widgets.git  # 克隆插件
cd ../../..  # 回到openwrt根目录

# 更新feeds确保所有新包被识别
echo "更新软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

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
