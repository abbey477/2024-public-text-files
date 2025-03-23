#!/bin/bash

# Source the first script to access its functions
# This assumes both scripts are in the same directory
source "./functions.sh"

# Define our own parameters
user="Alice"
num1=15
num2=27
show_date_option="yes"

echo "Calling the main function from the first script:"
echo "-----------------------------------------------"

# Call the main function with our parameters
main "$user" "$num1" "$num2" "$show_date_option"

# You can also call other functions directly
echo -e "\nCalling other functions directly:"
echo "-----------------------------------------------"
greet "Bob"
calculate_sum 42 58
