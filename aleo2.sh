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

# Display menu
while true; do
    echo "Choose an option:"
    echo "1. Install Aleo F2Pool Miner"
    echo "2. Run aleominer"
    echo "3. Tail log (tail -f aleominer.log)"
    echo "4. Stop aleominer (pkill -9 aleominer)"
    echo "5. Exit"
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            # Prompt for pool account
            read -p "Please enter your pool account: " worker_name

            # Save worker_name to file
            save_worker_name

            # Install Aleo F2Pool Miner
            cd ~
            pkill -f aleominer
            wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
            echo "Aleo F2Pool Miner installed"
            ;;
        2)
            # Load worker_name from file
            load_worker_name

            # Check if worker_name is set
            if [ -z "$worker_name" ]; then
                echo "Worker name is not set. Please install the miner first (option 1)."
                continue
            fi

            # Check GPU count
            gpu_count=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)

            # Set parameters based on GPU count
            if [ $gpu_count -ge 1 ] && [ $gpu_count -le 12 ]; then
                gpu_param=$(seq -s, 0 $((gpu_count - 1)))
            else
                echo "Unsupported number of GPUs: $gpu_count"
                exit 1
            fi

            # Display running GPU count
            echo "Running with $gpu_count GPUs"

            # Get machine name
            machine_name=$(hostname)

            # Final command
            final_command="./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d $gpu_param -w $worker_name.$machine_name >> ./aleominer.log 2>&1 &"

            # Run aleominer
            eval $final_command
            echo "aleominer started"
            ;;
        3)
            # Tail log
            tail -f aleominer.log
            ;;
        4)
            # Stop aleominer
            pkill -9 aleominer
            echo "aleominer stopped"
            ;;
        5)
            # Exit
            echo "Exiting"
            exit 0
            ;;
        *)
            echo "Invalid option, please try again"
            ;;
    esac
done
