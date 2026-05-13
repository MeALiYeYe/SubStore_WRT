#!/bin/sh
set -e

ENV=$(sh ./scripts/detect_env.sh)

echo "Detected: $ENV"

case "$ENV" in
    opkg)
        opkg update
        opkg install ./substore.ipk
        ;;
    apk)
        apk add --allow-untrusted ./substore.apk
        ;;
    *)
        echo "Fallback install..."
        sh ./scripts/postinst.sh
        ;;
esac
