#!/bin/sh
set -e

mkdir -p files/etc/substore
mkdir -p files/www/substore

echo "下载后端 bundle.js"
wget -O files/etc/substore/sub-store.bundle.js \
https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js

echo "下载前端 dist.zip 并解压"
wget -O /tmp/dist.zip \
https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip

unzip -o /tmp/dist.zip -d /tmp/substore_dist

# 拷贝到 files/www/substore
if [ -d /tmp/substore_dist/dist ]; then
    cp -a /tmp/substore_dist/dist/* files/www/substore/
else
    cp -a /tmp/substore_dist/* files/www/substore/
fi

rm -rf /tmp/dist.zip /tmp/substore_dist
