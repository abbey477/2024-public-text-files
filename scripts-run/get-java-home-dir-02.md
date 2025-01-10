Here's how to get the directory path from $JAVA_HOME in a shell script:

```bash
#!/bin/bash

# Get the absolute path of JAVA_HOME
java_path=$(dirname "$JAVA_HOME")
echo "JAVA_HOME directory path: $java_path"

# Or use readlink for canonical path (resolves symlinks)
java_canonical_path=$(readlink -f "$JAVA_HOME")
echo "JAVA_HOME canonical path: $java_canonical_path"

# Get parent directory
java_parent=$(dirname "$JAVA_HOME")
echo "Parent directory: $java_parent"

# Get base directory name
java_base=$(basename "$JAVA_HOME")
echo "Base directory name: $java_base"
```

A simpler version just using `dirname`:
```bash
java_dir=$(dirname "$JAVA_HOME")
echo $java_dir
```

If you need to verify it exists:
```bash
if [ -d "$JAVA_HOME" ]; then
    java_dir=$(dirname "$JAVA_HOME")
    echo "Directory path: $java_dir"
else
    echo "Error: Invalid JAVA_HOME path"
fi
```

The `dirname` command will give you the directory path, while `readlink -f` will resolve any symbolic links and return the actual physical path.
