#!/bin/bash

# Function to safely move a directory with timestamp and random number
# Can be called from another script by sourcing this file
function move_dir_safe {
  # Function to display usage information
  function show_usage {
    echo "Usage: move_dir_safe <source_directory> <destination_directory>"
    echo "Example: move_dir_safe /path/to/source /path/to/destination"
    return 1
  }

  # Check if correct number of arguments are provided
  if [ $# -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    show_usage
    return 1
  fi

  local SOURCE_DIR="$1"
  local DEST_BASE="$2"
  local RETURN_VALUE=0
  local DEST_DIR=""

  # Check if source directory exists
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    return 1
  fi

  # Check if destination directory exists
  if [ ! -d "$DEST_BASE" ]; then
    echo "Warning: Destination directory '$DEST_BASE' does not exist."
    read -p "Would you like to create it? (y/n): " ANSWER
    if [[ $ANSWER =~ ^[Yy]$ ]]; then
      mkdir -p "$DEST_BASE"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to create destination directory."
        return 1
      fi
      echo "Created destination directory '$DEST_BASE'."
    else
      echo "Operation cancelled."
      return 1
    fi
  fi

  # Get the base name of the source directory
  local DIR_NAME=$(basename "$SOURCE_DIR")

  # Generate timestamp in format YYYYMMDD_HHMMSS
  local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Generate a random number between 1000 and 9999
  local RANDOM_NUM=$((1000 + RANDOM % 9000))

  # Create the new directory name with timestamp and random number
  local NEW_DIR_NAME="${DIR_NAME}_${TIMESTAMP}_${RANDOM_NUM}"

  # Full path to the new directory
  DEST_DIR="$DEST_BASE/$NEW_DIR_NAME"

  # Perform the move
  echo "Moving directory:"
  echo "  From: $SOURCE_DIR"
  echo "  To:   $DEST_DIR"
  echo ""

  mv "$SOURCE_DIR" "$DEST_DIR"
  RETURN_VALUE=$?

  # Check if move was successful
  if [ $RETURN_VALUE -eq 0 ]; then
    echo "Success! Directory moved to '$DEST_DIR'"
    # Export the destination directory name so calling script can use it
    export MOVED_DIR_PATH="$DEST_DIR"
    return 0
  else
    echo "Error: Failed to move directory."
    return 1
  fi
}

# If this script is being run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  move_dir_safe "$@"
  exit $?
fi
