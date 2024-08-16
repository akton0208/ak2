#!/bin/bash

# 获取最大 CPU 线程数
MAX_CORES=$(nproc)

# 设置矿工客户端参数
URL="ws://147.124.221.57:8081"
RECONNECT=10
WALLET="any"

# 运行矿工客户端
./mine-client --url "$URL" --reconnect "$RECONNECT" --cores "$MAX_CORES" --wallet "$WALLET"
