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
            read -p "Please enter your pool account: " worker_name
            save_worker_name
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
            read -p "Please enter your pool account: " worker_name
            save_worker_name
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
            read -p "Please enter your pool account: " worker_name
            save_worker_name
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
