#!/bin/bash
#
# backup.sh - Main script to create backups
#

# Source the backup functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/backup_functions.sh"

# Display usage information
show_usage() {
    echo "Usage: $0 <directory_to_backup> [backup_destination]"
    echo
    echo "Options:"
    echo "  <directory_to_backup>   Path to the directory you want to backup"
    echo "  [backup_destination]    Optional: Path where the backup will be stored"
    echo "                          (defaults to current directory)"
    echo
    echo "Example:"
    echo "  $0 /home/user/documents /mnt/backups"
}

# Main script logic
main() {
    # Check if at least one argument was provided
    if [ $# -lt 1 ]; then
        show_usage
        exit 1
    fi

    # Call the backup function with provided arguments
    create_backup "$1" "$2"
    exit $?
}

# Execute main function with all arguments
main "$@"
