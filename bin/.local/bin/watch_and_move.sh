#!/bin/bash

# Directory to watch for new .mp4 files
WATCH_DIR="/home/sam/Videos/Youtube/t/"

# USB drive mount point
USB_MOUNT_POINT="/mnt/usb/"

# Function to check if file size has changed
has_size_changed() {
    local file="$1"
    local old_size="$2"
    [ -f "$file" ] && [ $(stat -c%s "$file") -ne "$old_size" ]
}

# Function to check available space on USB drive
has_enough_space() {
    # Get the available space in kilobytes on the USB mount point
    # local free_space=$(df "$USB_MOUNT_POINT" | awk 'NR==2 {print $4}') * 1000
    local free_space=$(df "$USB_MOUNT_POINT" | awk 'NR==2 {print $4 * 1024}')
    local required_space="$1"  # required space in KB (size of the file being transferred)

    echo "Free space on USB: $free_space bytes"
    echo "Required space for video file: $required_space bytes"
    
    # Compare available space to the required space for the file
    if [ "$free_space" -ge "$required_space" ]; then
        return 0  # True: there is enough space
    else
        return 1  # False: not enough space
    fi
}

# Initialize a hash table to store sizes of existing files
declare -A file_sizes

# Loop indefinitely to watch for changes
while true; do
    # Find all new or modified .mp4 files
    for new_file in "$WATCH_DIR"/*.mp4; do
        base_name=$(basename "$new_file")
        
        # Check if the file name does not end with ".f135.mp4", ".f138.mp4", or ".temp.mp4"
        if [[ ! "$base_name" =~ \.f[0-9]{3}\.mp4$ && ! "$base_name" =~ \.temp\.mp4$ ]]; then
            # Get the size of the current file in kilobytes
            file_size_kb=$(stat -c%s "$new_file")
            
            # Check if there is enough space on the USB drive for the file
            if has_enough_space "$file_size_kb"; then
                # Check if file size has changed
                if [[ -z ${file_sizes[$base_name]} || $(has_size_changed "$new_file" "${file_sizes[$base_name]}") ]]; then
                    # File is new or fully downloaded, move it to USB drive
                    rsync -av --progress "$new_file" "$USB_MOUNT_POINT/"
                    
                    # Update file size hash table
                    file_sizes[$base_name]=$(stat -c%s "$new_file")
                fi
            else
                echo "Not enough space on USB drive to transfer $base_name. Skipping transfer."
            fi
        fi
    done
    
    # Sleep for a while before checking again
    sleep 5
done

