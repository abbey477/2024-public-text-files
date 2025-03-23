#!/bin/bash

# Define a function that accepts parameters
process_data() {
    local first_param="$1"
    local second_param="$2"
    local third_param="$3"
    
    echo "Function process_data() received the following parameters:"
    echo "  First parameter: $first_param"
    echo "  Second parameter: $second_param"
    echo "  Third parameter: $third_param"
    
    # Do some example processing with the parameters
    echo "Processing data..."
    echo "Combined string: $first_param $second_param"
    echo "Numeric parameter multiplied by 2: $((third_param * 2))"
}

# Main part of the script
echo "Starting called_script.sh"
echo "Received parameters from main script: $@"
echo ""

# Call the function with the parameters received from the main script
process_data "$1" "$2" "$3"

echo ""
echo "Finished processing in called_script.sh"
