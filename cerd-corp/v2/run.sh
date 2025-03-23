#!/bin/bash

# Example script that uses the move_dir_safe function

# Source the script containing the move_dir_safe function
source ./move_dir_safe.sh

# Example function that uses move_dir_safe
function backup_project_directory {
  local PROJECT_DIR="$1"
  local BACKUP_DIR="$2"
  
  echo "Starting backup process for $PROJECT_DIR..."
  
  # Validate inputs
  if [ -z "$PROJECT_DIR" ] || [ -z "$BACKUP_DIR" ]; then
    echo "Error: Both project directory and backup directory must be specified."
    echo "Usage: backup_project_directory <project_dir> <backup_dir>"
    return 1
  fi
  
  # Create a temporary copy of the project
  local TEMP_DIR=$(mktemp -d)
  echo "Creating temporary copy in $TEMP_DIR..."
  
  cp -r "$PROJECT_DIR" "$TEMP_DIR/"
  
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary copy."
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  # Get the basename of the project directory
  local PROJECT_NAME=$(basename "$PROJECT_DIR")
  local TEMP_PROJECT_PATH="$TEMP_DIR/$PROJECT_NAME"
  
  # Call the move_dir_safe function to move the temp copy to the backup location
  echo "Moving to backup location with timestamp..."
  move_dir_safe "$TEMP_PROJECT_PATH" "$BACKUP_DIR"
  
  if [ $? -ne 0 ]; then
    echo "Error: Backup failed."
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  # Clean up the temp directory
  rm -rf "$TEMP_DIR"
  
  echo "Backup complete! Backup saved to: $MOVED_DIR_PATH"
  echo "You can restore this backup using:"
  echo "cp -r \"$MOVED_DIR_PATH\" \"$PROJECT_DIR\""
  
  return 0
}

# Example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ $# -ne 2 ]; then
    echo "Usage: $0 <project_directory> <backup_directory>"
    exit 1
  fi
  
  backup_project_directory "$1" "$2"
  exit $?
fi
