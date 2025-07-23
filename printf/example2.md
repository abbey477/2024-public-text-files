# Shell to Java Multi-line String Transfer Guide

This guide demonstrates how to pass multi-line strings from shell scripts to Java applications using the `-D` option and convert them to String arrays.

## Shell Script Implementation

### Basic Shell Script (sender.sh)

```bash
#!/bin/bash

get_multiline_data() {
    printf "Line 1: Database Configuration\n"
    printf "Line 2: Server Settings\n" 
    printf "Line 3: Security Parameters\n"
    printf "Line 4: Logging Options\n"
}

# Get the multi-line string and encode it for command line passing
multiline_text=$(get_multiline_data)

# Option 1: Use base64 encoding (recommended for complex strings)
encoded_text=$(echo "$multiline_text" | base64 -w 0)
java -Dconfig.data="$encoded_text" -Dconfig.encoding="base64" MyJavaApp

# Option 2: Use URL encoding (alternative approach)
# encoded_text=$(echo "$multiline_text" | sed 's/ /%20/g' | sed 's/\n/%0A/g')
# java -Dconfig.data="$encoded_text" -Dconfig.encoding="url" MyJavaApp

# Option 3: Simple approach using pipe separator (if content is predictable)
# pipe_separated=$(echo "$multiline_text" | tr '\n' '|')
# java -Dconfig.data="$pipe_separated" -Dconfig.encoding="pipe" MyJavaApp
```

### Advanced Shell Function with Parameters

```bash
#!/bin/bash

get_config_data() {
    local environment="$1"
    local service="$2"
    
    printf "Environment: %s\n" "$environment"
    printf "Service: %s\n" "$service"
    printf "Database URL: jdbc:mysql://localhost:3306/%s\n" "$service"
    printf "Max Connections: 100\n"
    printf "Timeout: 30000\n"
    printf "Debug Mode: %s\n" "${3:-false}"
}

# Usage with parameters
config_text=$(get_config_data "production" "userservice" "true")
encoded_config=$(echo "$config_text" | base64 -w 0)

java -Dapp.config="$encoded_config" \
     -Dapp.encoding="base64" \
     -jar myapp.jar
```

## Java Application Implementation

### Basic Java Application (MyJavaApp.java)

```java
import java.util.Base64;
import java.util.Arrays;

public class MyJavaApp {
    public static void main(String[] args) {
        String configData = System.getProperty("config.data");
        String encoding = System.getProperty("config.encoding", "base64");
        
        if (configData == null) {
            System.err.println("No config data provided");
            return;
        }
        
        String[] lines = decodeToStringArray(configData, encoding);
        
        // Display the results
        System.out.println("Received " + lines.length + " lines:");
        for (int i = 0; i < lines.length; i++) {
            System.out.println("Line " + (i + 1) + ": " + lines[i]);
        }
        
        // Use the string array as needed
        processConfigLines(lines);
    }
    
    private static String[] decodeToStringArray(String data, String encoding) {
        String decodedText;
        
        switch (encoding.toLowerCase()) {
            case "base64":
                byte[] decodedBytes = Base64.getDecoder().decode(data);
                decodedText = new String(decodedBytes);
                break;
                
            case "url":
                decodedText = java.net.URLDecoder.decode(data, java.nio.charset.StandardCharsets.UTF_8)
                    .replace("%0A", "\n");
                break;
                
            case "pipe":
                decodedText = data.replace("|", "\n");
                break;
                
            default:
                decodedText = data;
                break;
        }
        
        // Split by newlines and filter out empty lines
        return Arrays.stream(decodedText.split("\n"))
                    .filter(line -> !line.trim().isEmpty())
                    .toArray(String[]::new);
    }
    
    private static void processConfigLines(String[] lines) {
        System.out.println("\nProcessing configuration:");
        for (String line : lines) {
            // Process each line as needed
            if (line.contains("Database")) {
                System.out.println("Found database config: " + line);
            } else if (line.contains("Server")) {
                System.out.println("Found server config: " + line);
            }
            // Add more processing logic as needed
        }
    }
}
```

### Enhanced Java Configuration Processor

```java
import java.util.*;
import java.util.stream.Collectors;

public class ConfigProcessor {
    
    public static Map<String, String> parseConfigLines(String[] lines) {
        Map<String, String> config = new HashMap<>();
        
        for (String line : lines) {
            if (line.contains(":")) {
                String[] parts = line.split(":", 2);
                if (parts.length == 2) {
                    String key = parts[0].trim().toLowerCase().replace(" ", ".");
                    String value = parts[1].trim();
                    config.put(key, value);
                }
            }
        }
        
        return config;
    }
    
    private static String[] decodeToStringArray(String data, String encoding) {
        String decodedText;
        
        switch (encoding.toLowerCase()) {
            case "base64":
                byte[] decodedBytes = Base64.getDecoder().decode(data);
                decodedText = new String(decodedBytes);
                break;
                
            case "url":
                decodedText = java.net.URLDecoder.decode(data, java.nio.charset.StandardCharsets.UTF_8)
                    .replace("%0A", "\n");
                break;
                
            case "pipe":
                decodedText = data.replace("|", "\n");
                break;
                
            default:
                decodedText = data;
                break;
        }
        
        return Arrays.stream(decodedText.split("\n"))
                    .filter(line -> !line.trim().isEmpty())
                    .toArray(String[]::new);
    }
    
    public static void main(String[] args) {
        String configData = System.getProperty("app.config");
        String encoding = System.getProperty("app.encoding", "base64");
        
        if (configData != null) {
            String[] lines = decodeToStringArray(configData, encoding);
            
            // Convert to key-value pairs
            Map<String, String> configMap = parseConfigLines(lines);
            
            System.out.println("Configuration loaded:");
            configMap.forEach((key, value) -> 
                System.out.println(key + " = " + value));
        }
    }
}
```

## Usage Examples

### Example 1: Basic Usage

```bash
# Run the shell script
./sender.sh
```

### Example 2: Parameterized Configuration

```bash
# Generate configuration for different environments
config_text=$(get_config_data "staging" "authservice" "false")
encoded_config=$(echo "$config_text" | base64 -w 0)

java -Dapp.config="$encoded_config" \
     -Dapp.encoding="base64" \
     -cp ".:lib/*" \
     ConfigProcessor
```

### Example 3: Direct Command Line

```bash
# Direct execution with inline configuration
java -Dconfig.data="$(printf 'Host: localhost\nPort: 8080\nSSL: enabled' | base64 -w 0)" \
     -Dconfig.encoding="base64" \
     MyJavaApp
```

## Encoding Methods Comparison

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Base64** | Handles all characters, reliable | Slightly larger size | Complex strings with special chars |
| **URL Encoding** | Human readable when decoded | Limited character support | Simple strings |
| **Pipe Separator** | Simple, fast | Fails if content contains pipes | Predictable content |

## Key Implementation Points

### Shell Script Best Practices

- **Always use quotes** around the encoded string when passing to Java
- **Use `base64 -w 0`** to avoid line wrapping in the encoded output
- **Test with special characters** to ensure proper encoding/decoding
- **Handle empty results** gracefully in your functions

### Java Application Best Practices

- **Filter empty lines** when splitting to avoid null entries in arrays
- **Handle encoding errors** with try-catch blocks for production code
- **Validate input data** before processing
- **Use appropriate character encoding** (UTF-8) for international characters

### Error Handling Example

```java
private static String[] safeDecodeToStringArray(String data, String encoding) {
    try {
        return decodeToStringArray(data, encoding);
    } catch (Exception e) {
        System.err.println("Failed to decode configuration data: " + e.getMessage());
        return new String[0];  // Return empty array on failure
    }
}
```

## Common Issues and Solutions

### Issue 1: Special Characters Not Displaying Correctly
**Solution**: Use Base64 encoding and ensure UTF-8 character set handling

### Issue 2: Command Line Too Long
**Solution**: Write the encoded string to a temporary file and read it in Java

```bash
# In shell script
echo "$encoded_text" > /tmp/config.encoded
java -Dconfig.file="/tmp/config.encoded" MyJavaApp
```

### Issue 3: Newlines Not Preserved
**Solution**: Ensure proper encoding and use the correct split method in Java

## Conclusion

This approach provides a robust method for transferring multi-line configuration data from shell scripts to Java applications. Base64 encoding is recommended for most use cases due to its reliability with special characters and cross-platform compatibility.
