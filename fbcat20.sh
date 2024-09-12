#!/bin/bash

# 定義安裝和配置環境的函數
setup_environment() {
    # 檢查並等待 apt-get 鎖定解除
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
       echo "等待 apt-get 鎖定解除..."
       sleep 5
    done

    # 更新包列表並安裝 sudo
    apt update
    apt install sudo -y

    # 更新包列表
    sudo apt-get update

    # 檢查並安裝 Docker
    if ! command -v docker &> /dev/null
    then
        echo "Docker 未安裝，正在安裝..."
        sudo apt-get install docker.io -y
    else
        echo "Docker 已安裝"
    fi

    # 檢查並安裝 docker-compose
    if ! command -v docker-compose &> /dev/null
    then
        echo "docker-compose 未安裝，正在安裝..."
        VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
        DESTINATION=/usr/local/bin/docker-compose
        sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
        sudo chmod 755 $DESTINATION
    else
        echo "docker-compose 已安裝"
    fi

    # 檢查並安裝 Node.js 和 npm
    if ! command -v node &> /dev/null
    then
        echo "Node.js 未安裝，正在安裝..."
        sudo apt-get install npm -y
        sudo npm install n -g
        sudo n stable
    else
        echo "Node.js 已安裝"
    fi

    # 檢查並安裝 yarn
    if ! command -v yarn &> /dev/null
    then
        echo "yarn 未安裝，正在安裝..."
        sudo npm i -g yarn
    else
        echo "yarn 已安裝"
    fi

    # 拉取 Git 項目並編譯
    echo "拉取 Git 項目並編譯..."
    git clone https://github.com/CATProtocol/cat-token-box
    cd cat-token-box
    sudo yarn install
    sudo yarn build

    # 運行 Fractal 節點
    echo "運行 Fractal 節點..."
    cd packages/tracker/
    sudo chmod 777 docker/data
    sudo chmod 777 docker/pgdata
    sudo docker-compose up -d

    # 編譯並運行 CAT Protocol 的本地索引器
    echo "編譯並運行 CAT Protocol 的本地索引器..."
    cd ../../
    sudo docker build -t tracker:latest .
    sudo docker run -d \
        --name tracker \
        --add-host="host.docker.internal:host-gateway" \
        -e DATABASE_HOST="host.docker.internal" \
        -e RPC_HOST="host.docker.internal" \
        -p 3000:3000 \
        tracker:latest

    echo "所有步驟完成！"
    show_menu
}

# 定義創建錢包的函數
create_wallet() {
    cd ~/cat-token-box/packages/cli
    sudo yarn cli wallet create
    show_menu
}

# 定義顯示錢包地址的函數
show_wallet_address() {
    cd ~/cat-token-box/packages/cli
    sudo yarn cli wallet address
    show_menu
}

# 定義顯示錢包餘額的函數
show_wallet_balances() {
    cd ~/cat-token-box/packages/cli
    sudo yarn cli wallet balances
    show_menu
}

# 定義鑄幣的函數
mint_tokens() {
    cd ~/cat-token-box/packages/cli

    # 要求輸入 GAS 費
    read -p "請輸入 GAS 費: " gas_fee

    # 修改 config.json 文件中的 maxFeeRate 值
    sudo sed -i "s/\"maxFeeRate\": [0-9]*/\"maxFeeRate\": $gas_fee/" config.json

    # 執行鑄幣命令
    sudo yarn cli mint -i 45ee725c2c5993b3e4d308842d87e973bf1951f5f7a804b21e4dd964ecd12d6b_0 5
    show_menu
}

# 定義重複鑄幣的函數
repeat_mint_tokens() {
    read -p "輸入重複次數: " count
    read -p "請輸入 GAS 費: " gas_fee

    for ((i=1; i<=count; i++))
    do
        echo "第 $i 次鑄幣..."
        
        # 修改 config.json 文件中的 maxFeeRate 值
        sudo sed -i "s/\"maxFeeRate\": [0-9]*/\"maxFeeRate\": $gas_fee/" ~/cat-token-box/packages/cli/config.json

        # 執行鑄幣命令
        sudo yarn cli mint -i 45ee725c2c5993b3e4d308842d87e973bf1951f5f7a804b21e4dd964ecd12d6b_0 5
    done
    show_menu
}

# 定義停止並刪除所有有關資料的函數
cleanup() {
    cd ~/cat-token-box/packages/tracker/
    sudo docker-compose down
    sudo docker rm $(sudo docker ps -a -q --filter ancestor=tracker:latest)
    sudo docker rmi tracker:latest

    # 刪除 cat-token-box 目錄
    cd ~
    sudo rm -rf cat-token-box

    echo "所有資料已刪除！"
    show_menu
}

# 顯示選單的函數
show_menu() {
    echo "請選擇一個選項："
    echo "1) 安裝和配置環境"
    echo "2) 創建錢包"
    echo "3) 顯示錢包地址"
    echo "4) 顯示錢包餘額以及顯示同步進度"
    echo "5) 鑄幣要求輸入GAS,請到https://explorer.unisat.io/fractal-mainnet/block查看"
    echo "6) 重複鑄幣要求輸入數量及GAS,請到https://explorer.unisat.io/fractal-mainnet/block查看"
    echo "666) 停止並刪除所有有關資料"
    echo "7) 離開選單"
    read -p "輸入選項號碼: " option

    case $option in
        1)
            setup_environment
            ;;
        2)
            create_wallet
            ;;
        3)
            show_wallet_address
            ;;
        4)
            show_wallet_balances
            ;;
        5)
            mint_tokens
            ;;
        6)
            repeat_mint_tokens
            ;;
        666)
            cleanup
            ;;
        7)
            echo "退出選單"
            exit 0
            ;;
        *)
            echo "無效的選項"
            show_menu
            ;;
    esac
}

# 初始顯示選單
show_menu
