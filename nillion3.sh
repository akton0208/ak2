#!/bin/bash
# 停止 Docker 容器
docker stop nillion_verifier
# 等待幾秒鐘以確保容器完全停止
sleep 5
# 移除 Docker 容器
docker rm nillion_verifier
# 獲取最新的區塊高度
latest_block_height=$(curl -s https://nillion-testnet.rpc.kjnodes.com/status | jq -r .result.sync_info.latest_block_height)
# 運行新的 Docker 容器
docker run -d --name nillion_verifier -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.1 accuse --rpc-endpoint "https://nillion-testnet.rpc.kjnodes.com" --block-start $latest_block_height
# 顯示 Docker 容器的最新日誌
docker logs -f nillion_verifier --tail 100
