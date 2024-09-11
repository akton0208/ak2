#!/bin/bash

# Declare a global variable for worker_name
worker_name=""

# Function to load worker_name from file
load_worker_name() {
    if [ -f ~/worker_name.txt ]; then
        worker_name=$(cat ~/worker_name.txt)
    fi
}

# Function to save worker_name to file
save_worker_name() {
    echo "$worker_name" > ~/worker_name.txt
}

# Function to check if aleominer is running
is_aleominer_running() {
    pgrep -f aleominer > /dev/null
    return $?
}

# Function to check if aleominer log is being updated
is_log_updating() {
    log_file="aleominer.log"
    if [ -f $log_file ]; then
        last_update=$(stat -c %Y $log_file)
        current_time=$(date +%s)
        elapsed_time=$((current_time - last_update))
        echo "Elapsed time since last log update: $elapsed_time seconds"
        if [ $elapsed_time -gt 300 ]; then  # 300 seconds = 5 minutes
            return 1
        fi
    else
        echo "Log file not found"
        return 1
    fi
    return 0
}

# Function to check if the connection to the mining pool is active
is_connection_active() {
    if ! command -v nc &> /dev/null; then
        echo "netcat (nc) could not be found"
        return 1
    fi
    nc -z -w5 aleo-asia.f2pool.com 4400
    return $?
}

# Function to restart aleominer if not running, log not updating, or connection inactive
monitor_aleominer() {
    while true; do
        if ! is_aleominer_running || ! is_log_updating; then
            echo "aleominer is not running or log not updating, restarting..."
            pkill -f aleominer
            run_aleominer
        fi
        sleep 60
    done
}

# Function to frequently check connection status
monitor_connection() {
    while true; do
        if ! is_connection_active; then
            echo "Connection to mining pool is inactive, restarting aleominer..."
            pkill -f aleominer
            run_aleominer
        fi
        sleep 10
    done
}

# Function to run aleominer
run_aleominer() {
    load_worker_name

    if [ -z "$worker_name" ]; then
        echo "Worker name is not set. Please install the miner first (option 1)."
        return
    fi

    gpu_count=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)

    if [ $gpu_count -ge 1 ] && [ $gpu_count -le 12 ]; then
        gpu_param=$(seq -s, 0 $((gpu_count - 1)))
    else
        echo "Unsupported number of GPUs: $gpu_count"
        exit 1
    fi

    echo "Running with $gpu_count GPUs"

    machine_name=$(hostname)

    final_command="./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d $gpu_param -w $worker_name.$machine_name >> ./aleominer.log 2>&1 &"

    eval $final_command
    echo "aleominer started"
}

# Function to run aleominer with auto-restart every 30 minutes
run_aleominer_with_restart() {
    run_aleominer
    while true; do
        sleep 1800  # 1800 seconds = 30 minutes
        echo "Restarting aleominer..."
        pkill -f aleominer
        run_aleominer
    done
}

# Function to stop aleominer and monitoring
stop_aleominer() {
    pkill -9 aleominer
    pkill -f monitor_aleominer
    pkill -f monitor_connection
    echo "aleominer and monitoring stopped"
}

# Display menu
while true; do
    echo "Choose an option:"
    echo "1. Install Aleo F2Pool Miner with netcap"
    echo "2. Run aleominer with monitor function"
    echo "3. Tail log (tail -f aleominer.log)"
    echo "4. Stop aleominer"
    echo "5. Run aleominer with auto-restart every 30 minutes"
    echo "6. Exit"
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            read -p "Please enter your pool account: " worker_name
            save_worker_name
            cd ~
            pkill -f aleominer
            sudo apt-get update
            sudo apt-get install -y netcat-openbsd
            if ! command -v nc &> /dev/null; then
                echo "netcat (nc) installation failed"
                exit 1
            fi
            wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
            echo "Aleo F2Pool Miner installed"
            ;;
        2)
            run_aleominer
            monitor_aleominer >> monitor.log 2>&1 &
            monitor_connection >> monitor.log 2>&1 &
            ;;
        3)
            tail -f aleominer.log
            ;;
        4)
            stop_aleominer
            ;;
        5)
            run_aleominer_with_restart >> monitor.log 2>&1 &
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
