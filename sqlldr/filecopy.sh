#!/bin/bash

# Define source and destination
SOURCE_FILE="/path/to/source/file.txt"
DESTINATION_FILE="/path/to/destination/newname.txt"
DESTINATION_DIR="$(dirname "$DESTINATION_FILE")"

# Check if destination directory exists
if [ ! -d "$DESTINATION_DIR" ]; then
    echo "ERROR: Destination directory does not exist: $DESTINATION_DIR"
    echo "Please create the directory first or specify a valid destination path."
    exit 1
fi

# Copy the file (will overwrite if exists)
cp -f "$SOURCE_FILE" "$DESTINATION_FILE"

# Validate the copy was successful
if [ $? -eq 0 ] && [ -f "$DESTINATION_FILE" ]; then
    echo "File copied successfully!"
    echo "Source: $SOURCE_FILE"
    echo "Destination: $DESTINATION_FILE"
else
    echo "Failed to copy the file!"
    exit 1
fi
