#!/bin/bash
#
# backup_functions.sh - Library of backup functions
#

# Function to create a tar backup with timestamp
create_backup() {
    local source_dir="$1"
    local backup_dir="${2:-.}"  # Default to current directory if not specified
    
    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        echo "Error: Directory '$source_dir' does not exist."
        return 1
    fi
    
    # Get current timestamp in format YYYY-MM-DD_HH-MM-SS
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    
    # Get the basename of the source directory
    local dir_name=$(basename "$source_dir")
    
    # Create backup destination if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
        if [ $? -ne 0 ]; then
            echo "Error: Could not create backup destination directory."
            return 1
        fi
    fi
    
    # Create the backup filename with timestamp
    local backup_file="${backup_dir}/${dir_name}_backup_${timestamp}.tar.gz"
    
    # Create the tar.gz backup
    tar -czf "$backup_file" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"
    
    # Check if backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $backup_file"
        echo "Backup size: $(du -h "$backup_file" | cut -f1)"
        return 0
    else
        echo "Error: Backup creation failed."
        return 1
    fi
}
