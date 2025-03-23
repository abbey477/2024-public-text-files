#!/bin/bash

# Function to greet the user
greet() {
    local name="$1"
    echo "Hello, $name!"
}

# Function to calculate the sum of two numbers
calculate_sum() {
    local num1="$1"
    local num2="$2"
    echo "The sum of $num1 and $num2 is: $(($num1 + $num2))"
}

# Function to show current date
show_date() {
    echo "Today's date is: $(date +"%Y-%m-%d")"
}

# Main function that calls other functions
main() {
    local username="$1"
    local first_number="$2"
    local second_number="$3"
    local show_today="$4"
    
    # Call the greeting function
    greet "$username"
    
    # Call the calculation function
    calculate_sum "$first_number" "$second_number"
    
    # Conditionally call the date function
    if [[ "$show_today" == "yes" ]]; then
        show_date
    fi
}

# Call the main function with parameters
main "John" 5 10 "yes"

# You can also pass variables as parameters
# name="Alice"
# num1=7
# num2=3
# show_date_option="no"
# main "$name" "$num1" "$num2" "$show_date_option"
