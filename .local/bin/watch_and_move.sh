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

# Initialize a hash table to store sizes of existing files
declare -A file_sizes

# Loop indefinitely to watch for changes
while true; do
    # Find all new or modified .mp4 files
    for new_file in "$WATCH_DIR"/*.mp4; do
        base_name=$(basename "$new_file")
        
        # Check if the file name does not end with ".f135.mp4", ".f138.mp4", or ".temp.mp4"
        # if [[ ! "$base_name" == *.f135.mp4 && ! "$base_name" == *.f138.mp4 && ! "$base_name" == *.temp.mp4 ]]; then
if [[ ! "$base_name" =~ \.f[0-9]{3}\.mp4$ && ! "$base_name" =~ \.temp\.mp4$ ]]; then
            # Check if file size has changed
            if [[ -z ${file_sizes[$base_name]} || $(has_size_changed "$new_file" "${file_sizes[$base_name]}") ]]; then
                # File is new or fully downloaded, move it to USB drive
                rsync -av --progress "$new_file" "$USB_MOUNT_POINT/"
                
                # Update file size hash table
                file_sizes[$base_name]=$(stat -c%s "$new_file")
            fi
        fi
    done
    
    # Sleep for a while before checking again
    sleep 5
done
