#!/bin/sh
# Sub-Store 前端自动更新（优化版）

FRONTEND_API="https://api.github.com/repos/sub-store-org/Sub-Store-Front-End/releases/latest"
FRONTEND_URL="https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip"
FRONTEND_PATH="/www/substore"
FRONTEND_VER_FILE="/www/substore/frontend.version"

UA="Mozilla/5.0 (X11; Linux x86_64)"
WGET="wget -q --header=User-Agent:$UA -T 10 -t 2"

get_latest_version() {
    $WGET -O- "$1" | grep '"tag_name"' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/'
}

rollback_frontend() {
    [ -d "${FRONTEND_PATH}.bak" ] && {
        rm -rf $FRONTEND_PATH
        mv ${FRONTEND_PATH}.bak $FRONTEND_PATH
    }
}

echo "=== 检查前端版本 ==="
LATEST_FRONTEND_VER=$(get_latest_version "$FRONTEND_API")
LOCAL_FRONTEND_VER=$(cat $FRONTEND_VER_FILE 2>/dev/null)

# 防止 API 失败
if [ -z "$LATEST_FRONTEND_VER" ]; then
    echo "获取版本失败，跳过更新"
    exit 1
fi

if [ "$LATEST_FRONTEND_VER" = "$LOCAL_FRONTEND_VER" ]; then
    echo "前端已最新"
else
    echo "更新前端 → $LATEST_FRONTEND_VER"

    mv $FRONTEND_PATH ${FRONTEND_PATH}.bak 2>/dev/null
    mkdir -p $FRONTEND_PATH

    $WGET -O /tmp/dist.zip $FRONTEND_URL
    if [ $? -ne 0 ]; then
        echo "下载失败，回滚"
        rollback_frontend
    else
        mkdir -p /tmp/substore_dist
        unzip -o /tmp/dist.zip -d /tmp/substore_dist

        if [ -d "/tmp/substore_dist/dist" ]; then
            mv /tmp/substore_dist/dist/* $FRONTEND_PATH/
        else
            mv /tmp/substore_dist/* $FRONTEND_PATH/
        fi

        if [ $? -ne 0 ]; then
            echo "解压失败，回滚"
            rollback_frontend
        else
            echo "$LATEST_FRONTEND_VER" > $FRONTEND_VER_FILE
            echo "Reload nginx（不中断连接）"
            /etc/init.d/nginx reload
        fi
    fi

    rm -rf /tmp/dist.zip /tmp/substore_dist
fi

echo "=== 前端更新结束 ==="
