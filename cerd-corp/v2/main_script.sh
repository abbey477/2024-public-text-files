#!/bin/bash

# Define the parameters to pass to the called script
param1="Hello"
param2="World"
param3="42"

# Call the second script and pass the parameters
./called_script.sh "$param1" "$param2" "$param3"

echo "Back in main_script.sh"
echo "Script execution completed."
