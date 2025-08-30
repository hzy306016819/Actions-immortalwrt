#!/bin/bash
# diy-part3.sh：生成首次启动网络配置脚本并集成到OpenWrt固件中

NETCONFIG_BOOT_SRC="./openwrt/package/base-files/files/etc/init.d/netconfig-boot"

# 创建netconfig-boot启动脚本
cat > "$NETCONFIG_BOOT_SRC" << 'EOF'
#!/bin/sh /etc/rc.common
# OpenWrt首次启动脚本：netconfig-boot
START=99

boot() {
    # 日志文件保存在/root目录（永久存储）
    LOG_FILE="/root/netconfig-boot.log"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] netconfig-boot 首次启动执行..." > "$LOG_FILE"

    # 阶段1：检查网络连通性
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 开始检查局域网192.168.100.253连通性..." >> "$LOG_FILE"
    PING_RETRY=0
    PING_MAX=10
    PING_OK=0
    
    while [ $PING_RETRY -lt $PING_MAX ]; do
        if ping -c 1 -W 2 192.168.100.253 > /dev/null 2>&1; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] 成功连接到192.168.100.253" >> "$LOG_FILE"
            PING_OK=1
            break
        fi
        PING_RETRY=$((PING_RETRY + 1))
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 第$PING_RETRY次检查失败，等待6秒后重试..." >> "$LOG_FILE"
        sleep 6
    done

    if [ $PING_OK -eq 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误：10次重试后仍无法连接到192.168.100.253" >> "$LOG_FILE"
        return 1
    fi

    # 阶段2：下载网络配置脚本
    REMOTE_URL="http://192.168.100.253/360T7/netconfig"
    LOCAL_FILE="/tmp/netconfig"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 尝试下载：$REMOTE_URL" >> "$LOG_FILE"
    
    if ! wget -O "$LOCAL_FILE" "$REMOTE_URL" >> "$LOG_FILE" 2>&1; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误：配置文件下载失败" >> "$LOG_FILE"
        return 1
    fi

    chmod +x "$LOCAL_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 已下载并设置执行权限：$LOCAL_FILE" >> "$LOG_FILE"

    # 阶段3：执行网络配置
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 开始执行网络配置脚本..." >> "$LOG_FILE"
    START_TIME=$(date +%s)
    if "$LOCAL_FILE" >> "$LOG_FILE" 2>&1; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 成功：netconfig 执行完成，耗时 ${DURATION}秒" >> "$LOG_FILE"
    else
        EXEC_CODE=$?
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误：netconfig 执行失败，退出码：$EXEC_CODE" >> "$LOG_FILE"
        return $EXEC_CODE
    fi

    # 阶段4：自删除处理
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 开始执行自删除操作..." >> "$LOG_FILE"
    
    # 删除主脚本文件（必须）
    SELF_PATH="/etc/init.d/netconfig-boot"
    if [ -f "$SELF_PATH" ]; then
        rm -f "$SELF_PATH"
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 已删除自身脚本：$SELF_PATH" >> "$LOG_FILE"
    fi

    # 删除启动符号链接（推荐，保持系统整洁）
    RC_LINK="/etc/rc.d/S99netconfig-boot"
    if [ -L "$RC_LINK" ]; then
        rm -f "$RC_LINK"
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] 已删除启动链接：$RC_LINK" >> "$LOG_FILE"
    fi

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] netconfig-boot 流程执行完毕" >> "$LOG_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 脚本已自删除，日志保留在：$LOG_FILE" >> "$LOG_FILE"
}

start() { :; }
stop() { :; }
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
