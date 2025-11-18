#!/bin/bash
set -e # exit on error

# Define source and destination paths
SOURCE_DIR="/home/duongtc/568E/Haitac/ruffle/web/packages/selfhosted/"
DEST_SERVER="root@10.9.4.10"
DEST_PATH="/home/pirate/static/ruffle/"
SSH_PORT=3232

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

echo "Uploading files from $SOURCE_DIR to $DEST_SERVER:$DEST_PATH..."

# Use scp with recursive flag to copy all files and subdirectories
# -r: recursive copy
# -P: specify port
# Adding /* to the source path to copy contents of directory, not the directory itself
scp -r -P $SSH_PORT "$SOURCE_DIR"* "$DEST_SERVER:$DEST_PATH/"

echo "Upload completed successfully!"
