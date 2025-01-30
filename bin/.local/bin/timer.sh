#!/bin/bash

# Constants
LOG_FILE="$HOME/SMRE/3.Output/time_tracker.log"

# Function to display time in HH:MM:SS format
display_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$((total_seconds % 3600 / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"
}

# Function to log the task time
log_time() {
    local elapsed_time=$SECONDS
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "    $timestamp: $task_name took $(display_time "$elapsed_time")" >> "$LOG_FILE"
    echo -e "\nTask time logged successfully to $LOG_FILE."
    exit 0
}

# Function to display task log
display_log() {
    if [ -f "$LOG_FILE" ]; then
        echo "Task log sorted by timestamp:"
        sort "$LOG_FILE"
    else
        echo "No log file found at $LOG_FILE."
    fi
    exit 0
}

# Handle "--list" or "-l" argument
if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
    display_log
fi

# Set task name from $1 or prompt the user
if [ -n "$1" ]; then
    task_name="$1"
else
    read -p "Enter the task name: " task_name
fi

# Ensure task name is not empty
if [ -z "$task_name" ]; then
    echo "Error: Task name cannot be empty. Exiting."
    exit 1
fi

# Instructions for the user
echo "Press [CTRL+C] to stop the timer and log the task."
echo "Tracking time for task: $task_name"

# Set trap to handle Ctrl+C (SIGINT)
trap log_time SIGINT

# Start the stopwatch
SECONDS=0
while true; do
    printf "\rElapsed time: %s" "$(display_time "$SECONDS")"
    sleep 1
done
