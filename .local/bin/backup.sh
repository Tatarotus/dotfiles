#!/bin/bash

# Variables
SOURCE="/home/sam/"
DESTINATION="/home/sam/Backups/"
EXCLUDE_FILE="/home/sam/.dotfiles/Backups/exclude-list.txt"
BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz.age"
ENCRYPTED_BACKUP_NAME="$BACKUP_NAME"
CHECKSUM_FILE="$BACKUP_NAME.sha256"
PUBLIC_KEY="age1mc3nw403wpzwp3tvh93swms0syxa02resl4hjs6cnc5scm4f7g9stfrqud"
RCLONE_REMOTE="gdrive:backups" 

# Step 1: Create and encrypt a tarball using pipes  and pigz for more efficiency
echo "Compressing and encrypting backup..."
tar --exclude-from="$EXCLUDE_FILE" -cf - "$SOURCE" | pv -s $(du -sb "$SOURCE" | awk '{print $1}') | pigz -4 | age -r "$PUBLIC_KEY" -o "$DESTINATION/$BACKUP_NAME"

# # Step 3: Check if the encryption was successful 
if [ $? -eq 0 ]; then
    echo "successfuly encrypted backup."
else
    echo "Failed to encrypt backup."
    exit 1
fi

# Step 4: Generate a checksum for the encrypted backup
echo "Generating checksum..."
sha256sum "$DESTINATION/$ENCRYPTED_BACKUP_NAME" > "$DESTINATION/$CHECKSUM_FILE"

# Step 5: Upload encrypted backup to Google Drive
echo "Uploading backup to Google Drive..."
rclone copy "$DESTINATION/$ENCRYPTED_BACKUP_NAME" "$RCLONE_REMOTE" --progress
if [ $? -eq 0 ]; then
    echo "Backup successfully uploaded to Google Drive."
else
    echo "Failed to upload backup to Google Drive."
    exit 1
fi

# Step 6: Clean up old backups from Google Drive, keeping only the latest 2
echo "Cleaning up old backups on Google Drive..."

# List files sorted by modification time (newest first), skip the newest two, and delete the rest.
rclone lsjson "$RCLONE_REMOTE" --recursive | \
jq -r '.[] | select(.IsDir == false) | "\(.ModTime) \(.Path)"' | \
sort -r | tail -n +3 | awk '{print $2}' | while read -r file; do
    echo "Deleting old backup: $file"
    rclone deletefile "$RCLONE_REMOTE/$file"
done

if [ $? -eq 0 ]; then
    echo "Old backups removed from Google Drive, keeping only the latest two."
else
    echo "Failed to remove old backups from Google Drive."
    exit 1
fi

# Step 7: Clean up local files
echo "Cleaning up local encrypted backup..."
 rm "$DESTINATION/$ENCRYPTED_BACKUP_NAME"
BACKUP_ARCHIVE_DIR="/home/sam/.dotfiles/Backups"
# Ensure the backup archive directory exists
mkdir -p "$BACKUP_ARCHIVE_DIR"
# Move the checksum file to the archive directory
mv "$DESTINATION/$CHECKSUM_FILE" "$BACKUP_ARCHIVE_DIR/"

echo "Backup process completed successfully."

