#!/bin/sh
set -e

SUBSTORE_DIR="/etc/substore"
FRONTEND_DIR="/www/substore"

mkdir -p "$SUBSTORE_DIR" "$FRONTEND_DIR" "$SUBSTORE_DIR/logs"

# ---------------- 1. 安装 Node.js ----------------
if ! command -v node >/dev/null 2>&1; then
    if command -v opkg >/dev/null 2>&1; then
        opkg update && opkg install node
    elif command -v apk >/dev/null 2>&1; then
        apk update && apk add nodejs npm
    else
        echo "Node.js 未安装，请手动安装"
        exit 1
    fi
fi

# ---------------- 2. 下载后端 ----------------
BUNDLE_URL="https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js"
wget -O "$SUBSTORE_DIR/sub-store.bundle.js" "$BUNDLE_URL"

# ---------------- 3. 下载前端 ----------------
FRONTEND_URL="https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip"
TMP_ZIP="/tmp/substore_dist.zip"
TMP_DIR="/tmp/substore_dist"
wget -O "$TMP_ZIP" "$FRONTEND_URL"
unzip -o "$TMP_ZIP" -d "$TMP_DIR"

# 移动到最终目录
cp -a "$TMP_DIR/dist/"* "$FRONTEND_DIR/"
rm -rf "$TMP_ZIP" "$TMP_DIR"

# ---------------- 4. 安装 Node 依赖 ----------------
cd "$SUBSTORE_DIR"
if [ -f package.json ]; then
    npm install --production
fi

# ---------------- 5. 安装 init.d ----------------
if [ ! -f /etc/init.d/substore ]; then
    cp ./scripts/substore.init /etc/init.d/substore
    chmod +x /etc/init.d/substore
    [ -f /etc/openwrt_release ] && /etc/init.d/substore enable
fi

# ---------------- 6. 安装 LuCI 控件（仅 OpenWrt） ----------------
if [ -f /etc/openwrt_release ]; then
    mkdir -p /usr/lib/lua/luci/controller/substore
    cp ./files/luci/* /usr/lib/lua/luci/controller/substore/
fi

# ---------------- 7. 启动服务 ----------------
/etc/init.d/substore restart

echo "=== 安装完成 ==="
