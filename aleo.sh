#!/bin/bash

# Declare a global variable for worker_name with a default value
worker_name="akton0208"

# Function to run aleominer and capture output
run_aleominer() {
    if [ -z "$worker_name" ]; then
        echo "Worker name is not set. Please provide it as an argument when running the script."
        return
    fi

    gpu_count=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
    gpu_models=$(nvidia-smi --query-gpu=name --format=csv,noheader)

    if [ $gpu_count -ge 1 ] && [ $gpu_count -le 12 ]; then
        gpu_param=$(seq -s, 0 $((gpu_count - 1)))
    else
        echo "Unsupported number of GPUs: $gpu_count"
        exit 1
    fi

    echo "Running with $gpu_count GPUs:"
    echo "$gpu_models"

    machine_name=$(hostname)

    final_command="./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d $gpu_param -w $worker_name.$machine_name"

    echo "Starting aleominer..."
    eval $final_command | while read -r line; do
        echo "$line" >> aleominer.log
        if [[ "$line" == *"Speed(S/s)"* ]]; then
            speed=$(echo "$line" | awk '{print $3}')
            echo "$(date): Speed(S/s): $speed" >> hashrate.log
            echo "Running with $gpu_count GPUs:" >> hashrate.log
            echo "$gpu_models" >> hashrate.log
        fi
    done &
    aleominer_pid=$!

    echo "aleominer started with PID $aleominer_pid"
}

# Function to stop aleominer
stop_aleominer() {
    pkill -9 aleominer
    echo "aleominer stopped"
}

# Check if worker_name is provided as an argument
if [ $# -eq 1 ]; then
    worker_name=$1
else
    echo "No worker name provided. Using default: $worker_name"
fi

# Display menu
while true; do
    echo "Choose an option:"
    echo "1. Install Aleo F2Pool Miner"
    echo "2. Run aleominer"
    echo "3. Check aleominer log (tail -f aleominer.log)"
    echo "4. Check hashrate log (tail -f hashrate.log)"
    echo "5. Stop aleominer"
    echo "6. Exit"
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            cd ~
            pkill -9 aleominer
            apt-get update
            apt-get install -y screen
            wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
            echo "Aleo F2Pool Miner installed"
            ;;
        2)
            pkill -9 aleominer
            run_aleominer
            ;;
        3)
            tail -f aleominer.log
            ;;
        4)
            tail -f hashrate.log
            ;;
        5)
            stop_aleominer
            ;;
        6)
            echo "Exiting"
            exit 0
            ;;
        *)
            echo "Invalid option, please try again"
            ;;
    esac
done
