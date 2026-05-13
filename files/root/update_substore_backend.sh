#!/bin/sh
# Sub-Store 后端自动更新（优化版）

BACKEND_API="https://api.github.com/repos/sub-store-org/Sub-Store/releases/latest"
BACKEND_URL="https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js"
BACKEND_PATH="/etc/substore/sub-store.bundle.js"
BACKEND_VER_FILE="/etc/substore/backend.version"

UA="Mozilla/5.0 (X11; Linux x86_64)"
WGET="wget -q --header=User-Agent:$UA -T 10 -t 2"

get_latest_version() {
    $WGET -O- "$1" | grep '"tag_name"' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/'
}

rollback_backend() {
    [ -f "${BACKEND_PATH}.bak" ] && mv ${BACKEND_PATH}.bak $BACKEND_PATH
}

echo "=== 检查后端版本 ==="
LATEST_BACKEND_VER=$(get_latest_version "$BACKEND_API")
LOCAL_BACKEND_VER=$(cat $BACKEND_VER_FILE 2>/dev/null)

# 防止 API 失败
if [ -z "$LATEST_BACKEND_VER" ]; then
    echo "获取版本失败，跳过更新"
    exit 1
fi

if [ "$LATEST_BACKEND_VER" = "$LOCAL_BACKEND_VER" ]; then
    echo "后端已最新"
else
    echo "更新后端 → $LATEST_BACKEND_VER"

    mv $BACKEND_PATH ${BACKEND_PATH}.bak 2>/dev/null

    $WGET -O $BACKEND_PATH $BACKEND_URL
    if [ $? -ne 0 ]; then
        echo "后端更新失败，回滚"
        rollback_backend
    else
        echo "$LATEST_BACKEND_VER" > $BACKEND_VER_FILE
        echo "重启 Substore"
        /etc/init.d/substore restart
    fi
fi

echo "=== 后端更新结束 ==="
