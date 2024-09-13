#!/bin/bash

# 檢查是否提供了地址參數
if [ -z "$1" ]; then
    echo "請提供地址參數，例如：./zk.sh aleo16vqvtd0kr2fupv5rahhxw3hfyc9dc63k6447lee7z4y5ezp4gqys6un25m"
    exit 1
fi

# 獲取地址參數
address=$1

# 獲取GPU型號和數量
gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader)
gpu_count=$(echo "$gpu_info" | wc -l)
gpu_model=$(echo "$gpu_info" | head -n 1)

# 格式化為 "數量X型號"
gpu_summary="${gpu_count}X${gpu_model}"

# 定義你的命令
command="./aleo_prover --pool aleo.asia1.zk.work:10003 --address $address --custom_name $gpu_summary"

# 監控循環
while true; do
    # 檢查進程是否在運行
    if ! pgrep -f "$command" > /dev/null; then
        echo "進程已停止，正在重啟..."
        $command &
    fi
    # 每隔60秒檢查一次
    sleep 60
done
