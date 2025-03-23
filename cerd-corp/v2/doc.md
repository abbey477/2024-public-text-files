I'll modify the script to wrap it in a function so it can be called from another shell script. This is a useful approach for reusing this functionality across multiple scripts.

I've made two important changes to fulfill your request:

1. First, I've modified the original script to wrap the code in a reusable function called `move_dir_safe`. Key changes include:

   - Converting to a proper function that can be sourced by other scripts
   - Using `local` variables to avoid namespace conflicts
   - Using `return` instead of `exit` to not terminate the calling script
   - Added a mechanism to export the destination path via `MOVED_DIR_PATH` environment variable
   - Added logic to detect if the script is being run directly or sourced

2. Then, I created an example script that demonstrates how to call this function:

   - The example creates a backup function that:
     - Makes a temporary copy of a project directory
     - Uses `move_dir_safe` to safely move it to a backup location
     - Provides recovery instructions

### How to use these scripts:

1. Save the first script as `move_dir_safe.sh`
2. Save the second script as `backup_project.sh` (or any name you prefer)
3. Make both executable: `chmod +x move_dir_safe.sh backup_project.sh`

You can now either:
- Source and use the function directly in your scripts: `source ./move_dir_safe.sh`
- Run the example backup script: `./backup_project.sh /path/to/project /path/to/backups`

The key benefit of this approach is that the function can now be included in any of your scripts, allowing you to reuse this functionality across your system.
