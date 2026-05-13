#!/bin/sh

if command -v opkg >/dev/null 2>&1; then
    echo "opkg"
elif command -v apk >/dev/null 2>&1; then
    echo "apk"
else
    echo "unknown"
fi
