#!/bin/bash

# 获取最大 CPU 线程数
MAX_CORES=$(nproc)

# 检查传入的参数并设置 URL
case "$1" in
  1)
    URL="ws://147.124.221.57:8080"
    ;;
  2)
    URL="ws://147.124.221.57:8081"
    ;;
  3)
    URL="ws://147.124.222.80:8080"
    ;;
  *)
    echo "无效的参数。请使用 1、2 或 3 作为参数。"
    exit 1
    ;;
esac

# 设置矿工客户端参数
RECONNECT=10
WALLET="any"

# 运行矿工客户端
./mine-client --url "$URL" --reconnect "$RECONNECT" --cores "$MAX_CORES" --wallet "$WALLET"
