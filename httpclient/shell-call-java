I'll show you how to call Java methods from a shell script by creating both a Java class and a shell script wrapper.



```java
// HelloWorld.java
public class HelloWorld {
    public static String greet(String name) {
        return "Hello, " + name + "!";
    }
    
    public static int add(int a, int b) {
        return a + b;
    }
    
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: java HelloWorld <method> <args>");
            System.exit(1);
        }
        
        String method = args[0];
        
        try {
            switch (method) {
                case "greet":
                    if (args.length != 2) {
                        throw new IllegalArgumentException("greet method requires one argument");
                    }
                    System.out.println(greet(args[1]));
                    break;
                    
                case "add":
                    if (args.length != 3) {
                        throw new IllegalArgumentException("add method requires two arguments");
                    }
                    int a = Integer.parseInt(args[1]);
                    int b = Integer.parseInt(args[2]);
                    System.out.println(add(a, b));
                    break;
                    
                default:
                    throw new IllegalArgumentException("Unknown method: " + method);
            }
            System.exit(0);
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            System.exit(1);
        }
    }
}

```

```bash
#!/bin/bash

# call_java.sh
# Make sure to set the correct path to your Java installation and classpath
JAVA_HOME=${JAVA_HOME:-"/usr/lib/jvm/java-11-openjdk"}
CLASSPATH=${CLASSPATH:-"."}

# Function to call Java method and capture output
call_java_method() {
    local method=$1
    shift  # Remove the first argument (method name)
    
    # Run Java and capture both stdout and stderr
    output=$("$JAVA_HOME/bin/java" -cp "$CLASSPATH" HelloWorld "$method" "$@" 2>&1)
    exit_code=$?
    
    # Return the output and exit code
    echo "$output"
    return $exit_code
}

# Example usage of the greet method
greet_person() {
    local name=$1
    call_java_method "greet" "$name"
}

# Example usage of the add method
add_numbers() {
    local a=$1
    local b=$2
    call_java_method "add" "$a" "$b"
}

# Main script logic
case "$1" in
    "greet")
        if [ $# -ne 2 ]; then
            echo "Usage: $0 greet <name>"
            exit 1
        fi
        greet_person "$2"
        ;;
    "add")
        if [ $# -ne 3 ]; then
            echo "Usage: $0 add <number1> <number2>"
            exit 1
        fi
        add_numbers "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {greet <name>|add <number1> <number2>}"
        exit 1
        ;;
esac

# Preserve the exit code from the Java call
exit $?

```

To use this integration:

1. First, compile the Java class:
```bash
javac HelloWorld.java
```

2. Make the shell script executable:
```bash
chmod +x call_java.sh
```

3. Call Java methods from the shell:
```bash
# Call the greet method
./call_java.sh greet "John"
# Output: Hello, John!

# Call the add method
./call_java.sh add 5 3
# Output: 8
```

Key features:

1. Error handling in both Java and shell script
2. Exit code preservation
3. Flexible method dispatch
4. Environment variable support for JAVA_HOME and CLASSPATH
5. Clear usage messages

Important considerations:

1. Path setup:
   - Make sure JAVA_HOME is set correctly
   - Ensure the Java class is in the CLASSPATH
   - The shell script and Java class should be in the same directory (or adjust CLASSPATH)

2. Performance:
   - Each call starts a new JVM instance
   - For frequent calls, consider using a long-running Java service instead

3. Security:
   - Validate input parameters
   - Consider using absolute paths
   - Be careful with string interpolation

Would you like me to add more methods or explain any part in more detail?
