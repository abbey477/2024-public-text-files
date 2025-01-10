
I'll help you create a shell script to get the Java JDK home path and assign it to a variable. Here are a couple of common approaches:

```bash
# Method 1: Using java command
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Method 2: Using javac command (more reliable for JDK)
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))

# Method 3: If you want to be extra safe and check if java exists first
if command -v javac >/dev/null 2>&1; then
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
    echo "JDK home is: $JAVA_HOME"
else
    echo "Java JDK not found"
    exit 1
fi
```

A more comprehensive version that handles different scenarios:

```bash
#!/bin/bash

# Function to find Java home
find_java_home() {
    # First try javac (JDK) location
    if command -v javac >/dev/null 2>&1; then
        JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
        return 0
    # Fallback to java location
    elif command -v java >/dev/null 2>&1; then
        JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
        return 0
    # Check common installation directories
    elif [ -d "/usr/lib/jvm" ]; then
        JAVA_HOME=$(find /usr/lib/jvm -maxdepth 1 -type d -name "java-*-openjdk-*" | sort -V | tail -n 1)
        [ -n "$JAVA_HOME" ] && return 0
    fi
    return 1
}

# Find Java home
if find_java_home; then
    echo "JAVA_HOME found: $JAVA_HOME"
    export JAVA_HOME
else
    echo "Could not find Java installation"
    exit 1
fi
```

Choose the method that best fits your needs:
- Method 1 is simple but might point to JRE instead of JDK
- Method 2 ensures you get JDK location since it uses javac
- Method 3 (comprehensive version) handles multiple scenarios and common installation paths

You can save this in a script file (e.g., `find_java.sh`) and then source it to use the variable:
```bash
source ./find_java.sh
echo $JAVA_HOME
```
