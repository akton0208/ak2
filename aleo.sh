#!/bin/bash

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
            # Install Aleo F2Pool Miner
            cd ~
            pkill -f aleominer
            wget -O aleominer https://raw.githubusercontent.com/akton0208/ak2/main/aleominer && chmod +x aleominer
            echo "Aleo F2Pool Miner installed"
            ;;
        2)
            # Prompt for pool account
            read -p "Please enter your pool account: " worker_name

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
