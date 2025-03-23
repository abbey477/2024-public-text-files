#!/bin/bash
#
# main.sh - Example script that calls create_dir from directory_functions.sh
#

# Source the directory functions file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/directory_functions.sh"

# Function that uses create_dir
process_directory() {
    local dir_path="$1"
    
    echo "Starting directory processing..."
    
    # Call create_dir function and check its return value
    create_dir "$dir_path"
    local create_result=$?
    
    if [ $create_result -eq 0 ]; then
        echo "Directory is ready, proceeding with operation..."
        # Continue with your operations here
        # For example:
        echo "Creating a sample file in the directory..."
        touch "$dir_path/sample.txt"
        echo "Operation completed successfully."
        return 0
    else
        echo "Failed to prepare directory, aborting operation."
        return 1
    fi
}

# Main script logic
main() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <directory_path>"
        exit 1
    fi
    
    # Call the function that uses create_dir
    process_directory "$1"
    
    # Get the return value and exit with the same code
    exit $?
}

# Run the main function with all arguments
main "$@"
