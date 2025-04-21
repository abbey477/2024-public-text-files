I'll create a simplified shell script with just one function that accepts arguments passed during execution. Here's a clean example:

```bash
#!/bin/bash

# Define a function that processes parameters
process_data() {
    local input_file=$1
    local output_format=$2
    local verbose=$3
    
    echo "Processing file: $input_file"
    echo "Output format: $output_format"
    
    if [ "$verbose" = "true" ]; then
        echo "Verbose mode enabled"
        echo "Additional details would be shown here"
    fi
    
    # Simulate processing
    echo "Processing complete!"
}

# Check if correct number of arguments were provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 INPUT_FILE OUTPUT_FORMAT [VERBOSE]"
    echo "Example: $0 data.txt json true"
    exit 1
fi

# Set default value for third parameter if not provided
verbose_mode="false"
if [ $# -ge 3 ]; then
    verbose_mode=$3
fi

# Call the function with the command line arguments
process_data "$1" "$2" "$verbose_mode"
```

To use this script:

1. Save it to a file (e.g., `process.sh`)
2. Make it executable with `chmod +x process.sh`
3. Run it passing parameters:
   - Basic usage: `./process.sh data.txt json`
   - With verbose flag: `./process.sh data.txt json true`

The script takes the arguments directly from the command line and passes them to the function. If fewer than 2 arguments are provided, it shows a usage message and exits.
