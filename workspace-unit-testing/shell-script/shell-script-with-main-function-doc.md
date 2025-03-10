I'll create a shell script that uses a main function as an entry point, which is a good practice for more structured shell scripts.

## How to Use This Script

1. **Save the script** to a file (e.g., `script.sh`)

2. **Make it executable**:
   ```bash
   chmod +x script.sh
   ```

3. **Execute the script with the desired option**:

   To convert text to uppercase:
   ```bash
   ./script.sh -u hello world
   ```
   or
   ```bash
   ./script.sh --uppercase hello world
   ```
   Output:
   ```
   HELLO WORLD
   ```

   To count words in a string:
   ```bash
   ./script.sh -c this is a test sentence
   ```
   or
   ```bash
   ./script.sh --count this is a test sentence
   ```
   Output:
   ```
   Word count: 5
   ```

   To display help:
   ```bash
   ./script.sh -h
   ```
   or
   ```bash
   ./script.sh --help
   ```

## Benefits of Using a Main Function

Using a main function as an entry point has several advantages:

1. **Better organization**: It separates the script's logic from its execution
2. **Improved readability**: Makes the code easier to understand and maintain
3. **Easier testing**: You can source the script without executing it
4. **Namespace control**: Keeps variables local to functions
5. **Modularity**: Allows for better organization of code into functions

This approach is especially useful for larger scripts where you want to maintain a clean structure and separate different concerns of your code.
