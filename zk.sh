#!/bin/bash

# Check if the address parameter is provided
if [ -z "$1" ]; then
    echo "Please provide an address parameter, e.g., ./zk.sh aleo16vqvtd0kr2fupv5rahhxw3hfyc9dc63k6447lee7z4y5ezp4gqys6un25m"
    exit 1
fi

# Get the address parameter
address=$1

# Get GPU model and count
gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader)
gpu_count=$(echo "$gpu_info" | wc -l)
gpu_model=$(echo "$gpu_info" | head -n 1 | grep -oP '\d{4}')  # Extract the numeric part of the model

# Get the machine name
hostname=$(hostname)

# Format as "countXmodel_hostname"
gpu_summary="${gpu_count}X${gpu_model}_${hostname}"

# Define pool addresses
pool1="aleo.asia1.zk.work:10003"
pool2="aleo.hk.zk.work:10003"
current_pool=$pool1

# Function to switch pools
switch_pool() {
    if [ "$current_pool" == "$pool1" ]; then
        current_pool=$pool2
    else
        current_pool=$pool1
    fi
}

# Define your command
command="./aleo_prover --pool $current_pool --address $address --custom_name $gpu_summary"

# Display the final command
echo "Final command: $command"

# Start the command initially
$command &

# Short delay before the first check
sleep 10

# Monitoring loop
while true; do
    # Check if the process is running
    if ! pgrep -f "$command" > /dev/null; then
        echo "Process has stopped, switching pool and restarting..."
        switch_pool
        command="./aleo_prover --pool $current_pool --address $address --custom_name $gpu_summary"
        echo "New command: $command"
        $command &
    fi
    # Check every 60 seconds
    sleep 60
done
