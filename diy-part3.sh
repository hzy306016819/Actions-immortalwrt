#!/bin/bash
# diy-part3.sh：生成首次启动网络配置脚本并集成到OpenWrt固件中

NETCONFIG_BOOT_SRC="./openwrt/package/base-files/files/etc/uci-defaults/99-netconfig-boot"

# 创建netconfig-boot启动脚本
cat > "$NETCONFIG_BOOT_SRC" << 'EOF'
#!/bin/sh

# 日志文件位置
LOG_FILE="/root/netconfig-boot.log"

# 记录日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 下载URL配置
DOWNLOAD_URL="http://192.168.100.253/360T7/netconfig"
TEMP_SCRIPT="/tmp/netconfig"

log "开始执行netconfig-boot脚本"

# 检查wget是否存在
if ! command_exists wget; then
    log "错误: 未找到wget命令，无法下载文件"
    exit 0
fi

# 尝试下载网络配置脚本
MAX_RETRIES=10
RETRY_DELAY=6
SUCCESS=0

for i in $(seq 1 $MAX_RETRIES); do
    # 检查目标服务器是否可达
    if ping -c 1 -W 2 192.168.100.253 >/dev/null 2>&1; then
        log "尝试第 $i/$MAX_RETRIES 次下载网络配置脚本"
        
        # 使用wget下载脚本，增加超时参数
        if wget -q -T 5 -O "$TEMP_SCRIPT" "$DOWNLOAD_URL"; then
            # 检查文件是否为空
            if [ -s "$TEMP_SCRIPT" ]; then
                log "下载成功"
                SUCCESS=1
                break
            else
                log "下载的文件为空，等待 ${RETRY_DELAY} 秒后重试"
                rm -f "$TEMP_SCRIPT"
            fi
        else
            log "下载失败，等待 ${RETRY_DELAY} 秒后重试"
        fi
    else
        log "服务器不可达，等待 ${RETRY_DELAY} 秒后重试"
    fi
    
    # 如果不是最后一次尝试，则等待
    if [ $i -lt $MAX_RETRIES ]; then
        sleep $RETRY_DELAY
    fi
done

# 检查下载是否成功
if [ $SUCCESS -eq 0 ]; then
    log "错误: 经过 $MAX_RETRIES 次尝试后仍无法下载网络配置脚本"
    exit 0  # 退出但不阻止系统继续启动
fi

# 给予执行权限
if chmod +x "$TEMP_SCRIPT"; then
    log "已成功给予netconfig脚本执行权限"
else
    log "错误: 无法给予netconfig脚本执行权限"
    rm -f "$TEMP_SCRIPT"
    exit 0
fi

# 执行netconfig脚本
log "开始执行netconfig脚本"
sh "$TEMP_SCRIPT" >> "$LOG_FILE" 2>&1
EXEC_EXIT_CODE=$?
log "netconfig脚本执行完成，退出码: $EXEC_EXIT_CODE"

# 清理临时文件
# rm -f "$TEMP_SCRIPT"
# log "临时文件已清理"

log "netconfig-boot脚本执行完成"
exit 0

EOF

# 赋予执行权限
chmod 755 "$NETCONFIG_BOOT_SRC"
echo "已为 $NETCONFIG_BOOT_SRC 设置755执行权限"

# 验证脚本生成结果
if [ -f "$NETCONFIG_BOOT_SRC" ]; then
    echo "✅ 成功：netconfig-boot 启动脚本已生成"
    echo "📍 位置：$NETCONFIG_BOOT_SRC"
    echo "📋 功能：首次启动自动下载执行网络配置"
    echo "🗑️  特性：执行后自删除，日志永久保留"
else
    echo "❌ 错误：脚本生成失败"
    exit 1
fi

echo "diy-part3.sh 执行完成"
