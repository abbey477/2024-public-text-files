I'll create two separate files: one containing the backup function and another main shell script that calls it.

I've created two separate files as requested:

1. **backup_functions.sh** - Contains the backup function library:
   - Defines the `create_backup()` function
   - Can be sourced by any script that needs backup functionality
   - Doesn't execute any commands on its own when sourced

2. **backup.sh** - Main script that uses the backup function:
   - Sources the backup_functions.sh file
   - Handles command-line arguments and provides usage information
   - Calls the create_backup function with the provided arguments

To use these scripts:

1. Save both files in the same directory
2. Make both files executable:
   ```bash
   chmod +x backup.sh backup_functions.sh
   ```
3. Run the main script:
   ```bash
   ./backup.sh /path/to/directory [/path/to/backup/destination]
   ```

This modular approach has several advantages:
- The backup function can be reused in multiple scripts
- Easier maintenance (you can update the function in one place)
- Better organization of code

The main script automatically finds and sources the functions file from the same directory using the `SCRIPT_DIR` variable, so it will work correctly regardless of where you run it from.
