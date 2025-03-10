#!/bin/bash

# Function 1: Convert text to uppercase
to_uppercase() {
    local input_text="$1"
    echo "${input_text^^}"
}

# Function 2: Count words in a string
count_words() {
    local input_text="$1"
    local word_count=$(echo "$input_text" | wc -w)
    echo "Word count: $word_count"
}

# Display help message
show_help() {
    echo "Usage: $0 [option] [text]"
    echo "Options:"
    echo "  -u, --uppercase TEXT    Convert TEXT to uppercase"
    echo "  -c, --count TEXT        Count words in TEXT"
    echo "  -h, --help              Display this help message"
}

# Main function - entry point of the script
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    # Parse command line arguments
    case "$1" in
        -u|--uppercase)
            if [ -z "$2" ]; then
                echo "Error: No text provided for uppercase conversion"
                exit 1
            fi
            shift  # Remove the option argument
            to_uppercase "$*"
            ;;
        -c|--count)
            if [ -z "$2" ]; then
                echo "Error: No text provided for word count"
                exit 1
            fi
            shift  # Remove the option argument
            count_words "$*"
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Call the main function with all script arguments
main "$@"
