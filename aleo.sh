#!/bin/bash

# Declare a global variable for worker_name
worker_name=""

# Function to run aleominer
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

    final_command="screen -dmS aleominer bash -c 'script -f -c \"./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d $gpu_param -w $worker_name.$machine_name\" ./aleominer.log'"

    eval $final_command
    echo "aleominer started in screen session"
}

# Function to stop aleominer
stop_aleominer() {
    pkill -9 aleominer
    screen -S aleominer -X quit
    echo "aleominer stopped and screen session terminated"
}

# Function to monitor and restart aleominer if it stops
monitor_aleominer() {
    while true; do
        if ! pgrep -x "aleominer" > /dev/null; then
            echo "aleominer stopped, restarting..."
            run_aleominer
        fi
        sleep 60
    done
}

# Check if worker_name is provided as an argument
if [ $# -eq 1 ]; then
    worker_name=$1
else
    echo "Please provide the worker name as an argument when running the script."
    exit 1
fi

# Display menu
while true; do
    echo "Choose an option:"
    echo "1. Install Aleo F2Pool Miner"
    echo "2. Run aleominer"
    echo "3. Tail log (tail -f aleominer.log)"
    echo "4. Stop aleominer"
    echo "5. Exit"
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            cd ~
            pkill -9 aleominer
            screen -S aleominer -X quit
            apt-get update
            apt-get install -y netcat-openbsd screen
            if ! command -v nc &> /dev/null; then
                echo "netcat (nc) installation failed"
                exit 1
            fi
            wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
            echo "Aleo F2Pool Miner installed"
            ;;
        2)
            pkill -9 aleominer
            screen -S aleominer -X quit
            run_aleominer
            monitor_aleominer &
            ;;
        3)
            tail -f aleominer.log
            ;;
        4)
            stop_aleominer
            ;;
        5)
            echo "Exiting"
            exit 0
            ;;
        *)
            echo "Invalid option, please try again"
            ;;
    esac
done
