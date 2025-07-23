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
        
        // Split by newlines and filter out empty lines - return as List
        return Arrays.stream(decodedText.split("\n"))
                    .filter(line -> !line.trim().isEmpty())
                    .collect(Collectors.toList());
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

## Simple Example: Just Getting String Array

### Sample Input Data
```
[28]|[BFA]|[Burkina Faso]|[7]|[7]|[]
[27]|[BGR]|[Bulgaria]|[2]|[2]|[]
[26]|[BRN]|[Brunei Darussalam]|[-]|[-]|[(5)]
[25]|[BRA]|[Brazil]|[4]|[4]|[]
[24]|[BWA]|[Botswana]|[3]|[3]|[]
[23]|[BIH]|[Bosnia and Herzegovina]|[6]|[6]|[]
[22]|[BOL]|[Bolivia]|[7]|[7]|[]
[21]|[BTN]|[Bhutan]|[6]|[6]|[]
```

### Shell Script (simple_data.sh)

```bash
#!/bin/bash

get_data() {
    printf "[28]|[BFA]|[Burkina Faso]|[7]|[7]|[]\n"
    printf "[27]|[BGR]|[Bulgaria]|[2]|[2]|[]\n"
    printf "[26]|[BRN]|[Brunei Darussalam]|[-]|[-]|[(5)]\n"
    printf "[25]|[BRA]|[Brazil]|[4]|[4]|[]\n"
    printf "[24]|[BWA]|[Botswana]|[3]|[3]|[]\n"
    printf "[23]|[BIH]|[Bosnia and Herzegovina]|[6]|[6]|[]\n"
    printf "[22]|[BOL]|[Bolivia]|[7]|[7]|[]\n"
    printf "[21]|[BTN]|[Bhutan]|[6]|[6]|[]\n"
}

# Get data and encode it
data=$(get_data)
encoded_data=$(echo "$data" | base64 -w 0)

java -Dapp.data="$encoded_data" SimpleProcessor
```

### Simple Java Processor

```java
import java.util.Base64;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class SimpleProcessor {
    
    public static void main(String[] args) {
        String data = System.getProperty("app.data");
        
        if (data == null) {
            System.err.println("No data provided");
            return;
        }
        
        // Decode and convert to List<String>
        List<String> lines = getStringList(data);
        
        // Use the List<String>
        System.out.println("Got " + lines.size() + " lines:");
        for (int i = 0; i < lines.size(); i++) {
            System.out.println("Line " + i + ": " + lines.get(i));
        }
    }
    
    private static List<String> getStringList(String encodedData) {
        // Decode base64
        byte[] decodedBytes = Base64.getDecoder().decode(encodedData);
        String decodedText = new String(decodedBytes);
        
        // Split into List and filter empty lines
        return Arrays.stream(decodedText.split("\n"))
                    .filter(line -> !line.trim().isEmpty())
                    .collect(Collectors.toList());
    }
}
```

## Usage Examples

### Example 1: Processing the Sample Data

```bash
# Run the country processor
./process_countries.sh
```

Expected output:
```
Parsed 8 countries:
================================================================================
Rank: 28  | Code: BFA | Name: Burkina Faso            | Scores: 7/7 | Notes: None
Rank: 27  | Code: BGR | Name: Bulgaria                | Scores: 2/2 | Notes: None
Rank: 26  | Code: BRN | Name: Brunei Darussalam       | Scores: -/- | Notes: (5)
Rank: 25  | Code: BRA | Name: Brazil                  | Scores: 4/4 | Notes: None
Rank: 24  | Code: BWA | Name: Botswana                | Scores: 3/3 | Notes: None
Rank: 23  | Code: BIH | Name: Bosnia and Herzegovina  | Scores: 6/6 | Notes: None
Rank: 22  | Code: BOL | Name: Bolivia                 | Scores: 7/7 | Notes: None
Rank: 21  | Code: BTN | Name: Bhutan                  | Scores: 6/6 | Notes: None
```

### Example 2: Reading from File

```bash
# Read structured data from file
country_data=$(cat countries.txt)
encoded_data=$(echo "$country_data" | base64 -w 0)

java -Dcountry.data="$encoded_data" \
     -Dcountry.encoding="base64" \
     CountryProcessor
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
