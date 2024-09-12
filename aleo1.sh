#!/bin/bash

# Function to load worker_name from file
load_worker_name() {
    if [ -f ~/worker_name.txt ]; then
        worker_name=$(cat ~/worker_name.txt)
    else
        worker_name="akton0208"
    fi
}

# Function to save worker_name to file
save_worker_name() {
    echo "$worker_name" > ~/worker_name.txt
}

# Check if worker_name is provided as an argument, otherwise load from file
if [ -z "$1" ]; then
    load_worker_name
else
    worker_name="$1"
    save_worker_name
fi

# Function to get GPU info
get_gpu_info() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo "nvidia-smi could not be found. Please install NVIDIA drivers."
        exit 1
    fi

    gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader)
    gpu_count=$(echo "$gpu_info" | wc -l)
}

# Get GPU info
get_gpu_info

# Output the current worker_name and GPU info
echo "Running with worker_name: $worker_name"
echo "GPU Count: $gpu_count"
echo "GPU Info: $gpu_info"

# Function to log hashrate
log_hashrate() {
    echo "Logging hashrate with GPU Count: $gpu_count, GPU Info: $gpu_info" >> hashrate.log

    tail -f aleominer.log | while read -r line; do
        if [[ "$line" == *"Speed(S/s)"* ]]; then
            speed=$(echo "$line" | awk '{print $3}')
            echo "$(date): Speed(S/s): $speed" >> hashrate.log
            echo "Running with $gpu_count GPUs:" >> hashrate.log
            echo "$gpu_info" >> hashrate.log
        fi
    done &
}

# Function to run aleominer
run_aleominer() {
    if [ -z "$worker_name" ]; then
        echo "Worker name is not set. Please provide the worker name as an argument."
        return
    fi

    get_gpu_info

    if [ $gpu_count -ge 1 ] && [ $gpu_count -le 12 ]; then
        gpu_param=$(seq -s, 0 $((gpu_count - 1)))
    else
        echo "Unsupported number of GPUs: $gpu_count"
        exit 1
    fi

    echo "Running with $gpu_count GPUs: $gpu_info"

    machine_name=$(hostname)

    final_command="screen -dmS aleominer bash -c 'script -f -c \"./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d $gpu_param -w $worker_name.$machine_name\" ./aleominer.log'"

    eval $final_command
    echo "aleominer started in screen session"

    log_hashrate
}

# Function to monitor and restart aleominer if it stops
monitor_aleominer() {
    while true; do
        if ! pgrep -f "aleominer" > /dev/null; then
            echo "aleominer stopped, restarting..."
            run_aleominer
        fi
        sleep 60
    done
}

# Function to stop aleominer
stop_aleominer() {
    pkill -9 aleominer
    pkill -9 aleo_prover
    screen -S aleominer -X quit
    screen -wipe
    pkill -f "tail -n 100 -f aleominer.log"
    pkill -f "monitor_aleominer"
    echo "aleominer stopped and screen session terminated"
}

# Function to view hashrate log
view_hashrate_log() {
    if [ -f hashrate.log ]; then
        tail -n 100 -f hashrate.log
    else
        echo "hashrate.log does not exist."
    fi
}

# Function to install Aleo F2Pool Miner
install_aleominer() {
    cd ~
    pkill -9 aleominer
    pkill -9 aleo_prover
    screen -S aleominer -X quit
    screen -wipe
    apt-get update
    apt-get install -y screen
    wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
    touch aleominer.log hashrate.log
    echo "Aleo F2Pool Miner installed and log files created"
}

# Function to install ZK Miner
install_zkminer() {
    cd ~
    pkill -9 aleominer
    pkill -9 aleo_prover
    screen -S aleominer -X quit
    screen -wipe
    apt-get update
    apt-get install -y screen
    wget https://github.com/6block/zkwork_aleo_gpu_worker/releases/download/v0.1.1-hot/aleo_prover-v0.1.1_hot.tar.gz
    tar -xvzf aleo_prover-v0.1.1_hot.tar.gz
    echo "ZK Miner installed"
}

# Function to tail aleominer log
aleominer_log() {
    if [ -f aleominer.log ]; then
        tail -f aleominer.log
    else
        echo "aleominer.log does not exist."
    fi
}

# Function to run ZK Miner
run_zkminer() {
    cd ~/aleo_prover
    read -p "Enter your address : " address
    machine_name=$(hostname)
    screen -dmS aleominer bash -c "./aleo_prover --pool aleo.hk.zk.work:10003 --address $address --custom_name $machine_name >> ~/aleominer.log 2>&1"
    echo "ZK Miner started in screen session"

    # Monitor and restart ZK Miner if it stops
    while true; do
        if ! pgrep -f "aleo_prover" > /dev/null; then
            echo "ZK Miner stopped, restarting..."
            screen -dmS aleominer bash -c "./aleo_prover --pool aleo.hk.zk.work:10003 --address $address --custom_name $machine_name >> ~/aleominer.log 2>&1"
        fi
        sleep 60
    done
}

# Display menu
while true; do
    echo "Choose an option:"
    echo "1. Install Aleo F2Pool Miner"
    echo "2. Run aleominer"
    echo "3. Tail log (tail -f aleominer.log)"
    echo "4. View hashrate log"
    echo "5. Install ZK Miner"
    echo "6. Run ZK Miner"
    echo "7. Stop aleominer"
    echo "8. Exit"
    read -p "Enter your choice (1-8): " choice

    case $choice in
        1)
            install_aleominer
            ;;
        2)
            run_aleominer
            ;;
        3)
            aleominer_log
            ;;
        4)
            view_hashrate_log
            ;;
        5)
            install_zkminer
            ;;
        6)
            run_zkminer
            ;;
        7)
            stop_aleominer
            ;;
        8)
            echo "Exiting"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 8."
            ;;
    esac
done
