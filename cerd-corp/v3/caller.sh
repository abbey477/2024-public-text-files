#!/bin/bash
#
# caller.sh - Example script that calls main.sh
#

# Function to call main.sh with parameters
call_main_script() {
    local target_dir="$1"
    local main_script_path="$2"
    
    echo "Calling main.sh with target directory: $target_dir"
    
    # Ensure main script exists and is executable
    if [ ! -f "$main_script_path" ]; then
        echo "Error: Main script not found at $main_script_path"
        return 1
    fi
    
    if [ ! -x "$main_script_path" ]; then
        echo "Warning: Main script is not executable, attempting to make it executable"
        chmod +x "$main_script_path"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to make main script executable"
            return 1
        fi
    fi
    
    # Call the main script with the target directory
    "$main_script_path" "$target_dir"
    local main_result=$?
    
    # Handle the result
    if [ $main_result -eq 0 ]; then
        echo "Main script executed successfully."
        return 0
    else
        echo "Main script execution failed with exit code: $main_result"
        return $main_result
    fi
}

# Main caller logic
main() {
    # Check if arguments are provided
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <target_directory> [path_to_main_script]"
        exit 1
    fi
    
    local target_dir="$1"
    
    # Determine the path to main.sh (default is same directory as this script)
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local main_script="${2:-$script_dir/main.sh}"
    
    # Call the function
    call_main_script "$target_dir" "$main_script"
    
    # Exit with the same result
    exit $?
}

# Run the main function with all arguments
main "$@"
