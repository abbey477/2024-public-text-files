# Java App Calling Shell Script with Error Handling

**Created:** 5/27/2025 19:55  
**Updated:** 5/27/2025 22:46  
**Exported:** 5/27/2025 22:52  

## Prompt:
create 2 simple java application, the first call the second through a shell script. the second returns a string message, and exit code of 0 if successful and 1 if there is error. get the messages in the first and print it



## Response:
I'll create two Java applications for you - one that calls the other through a shell script, with proper error handling and message passing.

CallerApp.java

```java
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

public class CallerApp {
    public static void main(String[] args) {
        try {
            System.out.println("CallerApp: Starting execution...");
            
            // Execute the shell script
            ProcessBuilder processBuilder = new ProcessBuilder("./run_second_app.sh");
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();
            
            // Read the output from the second application
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream())
            );
            
            String line;
            StringBuilder output = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            
            // Wait for the process to complete and get exit code
            int exitCode = process.waitFor();
            
            // Print results
            System.out.println("CallerApp: Received message from SecondApp:");
            System.out.println(output.toString().trim());
            System.out.println("CallerApp: Exit code: " + exitCode);
            
            if (exitCode == 0) {
                System.out.println("CallerApp: SecondApp executed successfully!");
            } else {
                System.out.println("CallerApp: SecondApp encountered an error!");
            }
            
        } catch (IOException e) {
            System.err.println("CallerApp: IO Exception occurred: " + e.getMessage());
        } catch (InterruptedException e) {
            System.err.println("CallerApp: Process was interrupted: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("CallerApp: Unexpected error: " + e.getMessage());
        }
    }
}
```

SecondApp.java

```java
import java.util.Random;

public class SecondApp {
    public static void main(String[] args) {
        try {
            // Simulate some processing
            Thread.sleep(1000);
            
            // Generate a random number to simulate success/failure
            Random random = new Random();
            boolean success = random.nextBoolean();
            
            if (success) {
                // Success case
                System.out.println("SecondApp: Operation completed successfully!");
                System.out.println("SecondApp: Current timestamp: " + System.currentTimeMillis());
                System.out.println("SecondApp: Message - Hello from SecondApp!");
                System.exit(0); // Exit with code 0 for success
            } else {
                // Error case
                System.out.println("SecondApp: An error occurred during processing!");
                System.out.println("SecondApp: Error message - Something went wrong!");
                System.exit(1); // Exit with code 1 for error
            }
            
        } catch (InterruptedException e) {
            System.err.println("SecondApp: Thread was interrupted: " + e.getMessage());
            System.exit(1);
        } catch (Exception e) {
            System.err.println("SecondApp: Unexpected error: " + e.getMessage());
            System.exit(1);
        }
    }
}
```

run_second_app.sh

```bash
#!/bin/bash

# Shell script to run the SecondApp Java application
# This script compiles and runs SecondApp.java

echo "Shell Script: Compiling SecondApp.java..."
javac SecondApp.java

if [ $? -eq 0 ]; then
    echo "Shell Script: Compilation successful. Running SecondApp..."
    java SecondApp
    exit_code=$?
    echo "Shell Script: SecondApp finished with exit code: $exit_code"
    exit $exit_code
else
    echo "Shell Script: Compilation failed!"
    exit 1
fi
```

compile_and_run.sh

```bash
#!/bin/bash

# Complete setup and execution script
echo "=== Setting up Java Applications ==="

# Compile both Java applications
echo "Compiling CallerApp.java..."
javac CallerApp.java

echo "Compiling SecondApp.java..."
javac SecondApp.java

# Make shell script executable
echo "Making run_second_app.sh executable..."
chmod +x run_second_app.sh

# Run the CallerApp
echo "=== Running CallerApp ==="
java CallerApp

echo "=== Execution Complete ==="
```

I've created a complete Java application system with the following components:

## **CallerApp.java**
- The main application that calls the second app through a shell script
- Uses `ProcessBuilder` to execute the shell script
- Captures both output and exit code from the second application
- Includes comprehensive error handling
- Prints the received messages and indicates success/failure based on exit code

## **SecondApp.java**
- The second application that returns string messages
- Randomly simulates success or failure scenarios
- Returns exit code 0 for success, 1 for error
- Outputs different messages based on the outcome
- Includes timestamp information

## **run_second_app.sh**
- Shell script that compiles and runs SecondApp
- Handles compilation errors
- Passes through the exit code from SecondApp

## **compile_and_run.sh**
- Convenience script to set up and run the entire system
- Compiles both Java files
- Makes the shell script executable
- Runs the CallerApp

## **How to use:**

1. Save all files in the same directory
2. Run: `chmod +x compile_and_run.sh`
3. Execute: `./compile_and_run.sh`

## **Key Features:**

- **Error Handling**: Both applications handle exceptions properly
- **Exit Codes**: SecondApp returns 0 for success, 1 for errors
- **Message Passing**: CallerApp captures and displays all output from SecondApp
- **Random Behavior**: SecondApp randomly succeeds or fails to demonstrate both scenarios
- **Complete Communication**: The first app receives messages, exit codes, and handles both success and error cases

The system demonstrates proper inter-process communication through shell scripts with robust error handling and message passing between Java applications.



## Prompt:
what if both java applications are jar and executed with jar -jar jar-file-name, how to pass string message and exit code through shell script from the caller  jar and the called jar



## Response:
I'll modify the applications to work as JAR files with proper parameter passing and exit code handling.

**artifacts**

*Request*

```javascript
{
  "id": "caller_app",
  "command": "rewrite",
  "content": "import java.io.BufferedReader;\nimport java.io.InputStreamReader;\nimport java.io.IOException;\n\npublic class CallerApp {\n    public static void main(String[] args) {\n        try {\n            System.out.println(\"CallerApp: Starting execution...\");\n            \n            // Prepare parameters to pass to the second JAR\n            String messageToSend = \"Hello from CallerApp!\";\n            String shouldSucceed = args.length > 0 ? args[0] : \"random\";\n            \n            System.out.println(\"CallerApp: Sending message: '\" + messageToSend + \"'\");\n            System.out.println(\"CallerApp: Success mode: \" + shouldSucceed);\n            \n            // Execute the shell script with parameters\n            ProcessBuilder processBuilder = new ProcessBuilder(\n                \"./run_second_jar.sh\", \n                messageToSend, \n                shouldSucceed\n            );\n            processBuilder.redirectErrorStream(true);\n            Process process = processBuilder.start();\n            \n            // Read the output from the second application\n            BufferedReader reader = new BufferedReader(\n                new InputStreamReader(process.getInputStream())\n            );\n            \n            String line;\n            StringBuilder output = new StringBuilder();\n            while ((line = reader.readLine()) != null) {\n                output.append(line).append(\"\\n\");\n            }\n            \n            // Wait for the process to complete and get exit code\n            int exitCode = process.waitFor();\n            \n            // Print results\n            System.out.println(\"\\n=== CallerApp: Results ===\");\n            System.out.println(\"Received output from SecondApp JAR:\");\n            System.out.println(output.toString().trim());\n            System.out.println(\"\\nExit code received: \" + exitCode);\n            \n            if (exitCode == 0) {\n                System.out.println(\"CallerApp: SecondApp JAR executed successfully!\");\n            } else {\n                System.out.println(\"CallerApp: SecondApp JAR encountered an error!\");\n            }\n            \n            // Exit with the same code as the second app\n            System.exit(exitCode);\n            \n        } catch (IOException e) {\n            System.err.println(\"CallerApp: IO Exception occurred: \" + e.getMessage());\n            System.exit(1);\n        } catch (InterruptedException e) {\n            System.err.println(\"CallerApp: Process was interrupted: \" + e.getMessage());\n            System.exit(1);\n        } catch (Exception e) {\n            System.err.println(\"CallerApp: Unexpected error: \" + e.getMessage());\n            System.exit(1);\n        }\n    }\n}",
  "version_uuid": "82dd3146-7e66-4630-b6d7-ad112fde47d0"
}
```

**artifacts**

*Request*

```javascript
{
  "id": "second_app",
  "command": "rewrite",
  "content": "import java.util.Random;\n\npublic class SecondApp {\n    public static void main(String[] args) {\n        try {\n            System.out.println(\"SecondApp JAR: Starting execution...\");\n            \n            // Parse command line arguments\n            String receivedMessage = args.length > 0 ? args[0] : \"No message received\";\n            String successMode = args.length > 1 ? args[1] : \"random\";\n            \n            System.out.println(\"SecondApp JAR: Received message: '\" + receivedMessage + \"'\");\n            System.out.println(\"SecondApp JAR: Success mode: \" + successMode);\n            \n            // Simulate some processing\n            Thread.sleep(500);\n            \n            // Determine success or failure based on parameters\n            boolean success;\n            switch (successMode.toLowerCase()) {\n                case \"true\":\n                case \"success\":\n                    success = true;\n                    break;\n                case \"false\":\n                case \"error\":\n                    success = false;\n                    break;\n                default:\n                    // Random behavior\n                    Random random = new Random();\n                    success = random.nextBoolean();\n                    break;\n            }\n            \n            if (success) {\n                // Success case\n                System.out.println(\"\\n=== SecondApp JAR: SUCCESS ===\");\n                System.out.println(\"Operation completed successfully!\");\n                System.out.println(\"Processed message: '\" + receivedMessage + \"'\");\n                System.out.println(\"Current timestamp: \" + System.currentTimeMillis());\n                System.out.println(\"Response: Message processed successfully from SecondApp JAR!\");\n                System.out.println(\"Status: All operations completed without errors\");\n                System.exit(0); // Exit with code 0 for success\n            } else {\n                // Error case\n                System.out.println(\"\\n=== SecondApp JAR: ERROR ===\");\n                System.out.println(\"An error occurred during processing!\");\n                System.out.println(\"Failed to process message: '\" + receivedMessage + \"'\");\n                System.out.println(\"Error timestamp: \" + System.currentTimeMillis());\n                System.out.println(\"Error response: Processing failed in SecondApp JAR!\");\n                System.out.println(\"Status: Operation terminated with errors\");\n                System.exit(1); // Exit with code 1 for error\n            }\n            \n        } catch (InterruptedException e) {\n            System.err.println(\"SecondApp JAR: Thread was interrupted: \" + e.getMessage());\n            System.exit(1);\n        } catch (Exception e) {\n            System.err.println(\"SecondApp JAR: Unexpected error: \" + e.getMessage());\n            System.exit(1);\n        }\n    }\n}",
  "version_uuid": "0ffe6709-1a3d-4d89-b1ba-59c7db052bbf"
}
```

**artifacts**

*Request*

```javascript
{
  "id": "shell_script",
  "title": "run_second_jar.sh",
  "command": "rewrite",
  "content": "#!/bin/bash\n\n# Shell script to run the SecondApp JAR with parameters\n# Parameters: $1 = message to pass, $2 = success mode\n\nMESSAGE=\"$1\"\nSUCCESS_MODE=\"$2\"\n\necho \"Shell Script: Executing SecondApp.jar...\"\necho \"Shell Script: Message parameter: '$MESSAGE'\"\necho \"Shell Script: Success mode: '$SUCCESS_MODE'\"\n\n# Run the SecondApp JAR with parameters\njava -jar SecondApp.jar \"$MESSAGE\" \"$SUCCESS_MODE\"\n\n# Capture the exit code\nexit_code=$?\necho \"Shell Script: SecondApp.jar finished with exit code: $exit_code\"\n\n# Pass through the exit code\nexit $exit_code",
  "version_uuid": "4368ddae-5436-4595-9240-4edaf56c908a"
}
```

**artifacts**

*Request*

```javascript
{
  "id": "compile_and_run",
  "title": "build_and_run.sh",
  "command": "rewrite",
  "content": "#!/bin/bash\n\n# Complete build and execution script for JAR applications\necho \"=== Building Java JAR Applications ===\"\n\n# Clean up previous builds\necho \"Cleaning up previous builds...\"\nrm -f *.class *.jar\n\n# Compile CallerApp\necho \"Compiling CallerApp.java...\"\njavac CallerApp.java\nif [ $? -ne 0 ]; then\n    echo \"ERROR: Failed to compile CallerApp.java\"\n    exit 1\nfi\n\n# Compile SecondApp\necho \"Compiling SecondApp.java...\"\njavac SecondApp.java\nif [ $? -ne 0 ]; then\n    echo \"ERROR: Failed to compile SecondApp.java\"\n    exit 1\nfi\n\n# Create manifest files\necho \"Creating manifest files...\"\necho \"Main-Class: CallerApp\" > caller-manifest.txt\necho \"Main-Class: SecondApp\" > second-manifest.txt\n\n# Create JAR files\necho \"Creating CallerApp.jar...\"\njar cfm CallerApp.jar caller-manifest.txt CallerApp.class\nif [ $? -ne 0 ]; then\n    echo \"ERROR: Failed to create CallerApp.jar\"\n    exit 1\nfi\n\necho \"Creating SecondApp.jar...\"\njar cfm SecondApp.jar second-manifest.txt SecondApp.class\nif [ $? -ne 0 ]; then\n    echo \"ERROR: Failed to create SecondApp.jar\"\n    exit 1\nfi\n\n# Make shell script executable\necho \"Making run_second_jar.sh executable...\"\nchmod +x run_second_jar.sh\n\n# Clean up temporary files\nrm -f *.class *-manifest.txt\n\necho \"=== Build Complete ===\"\necho \"Created JARs: CallerApp.jar and SecondApp.jar\"\necho \"\"\n\n# Run examples\necho \"=== Running Examples ===\"\n\necho \"1. Running with random success/failure:\"\njava -jar CallerApp.jar\necho \"\"\n\necho \"2. Running with forced success:\"\njava -jar CallerApp.jar success\necho \"\"\n\necho \"3. Running with forced error:\"\njava -jar CallerApp.jar error\necho \"\"\n\necho \"=== Execution Complete ===\"",
  "version_uuid": "8f43153d-a391-498a-81eb-f4e6ad087dc6"
}
```

manual_test.sh

```bash
#!/bin/bash

# Manual testing script for individual JAR execution
echo "=== Manual JAR Testing ==="

echo "1. Testing SecondApp.jar directly with success:"
java -jar SecondApp.jar "Direct test message" "success"
echo "Exit code: $?"
echo ""

echo "2. Testing SecondApp.jar directly with error:"
java -jar SecondApp.jar "Error test message" "error"
echo "Exit code: $?"
echo ""

echo "3. Testing CallerApp.jar (which calls SecondApp.jar through shell script):"
java -jar CallerApp.jar "random"
echo "Final exit code: $?"
echo ""

echo "=== Testing Complete ==="
```

I've modified the applications to work as JAR files with proper parameter passing and exit code handling. Here's how the system now works:

## **Key Changes for JAR Implementation:**

### **CallerApp.jar**
- Accepts command line arguments to control behavior
- Passes parameters to the shell script (message and success mode)
- Captures both output and exit code from SecondApp.jar
- Exits with the same code as the called application

### **SecondApp.jar**
- Accepts command line parameters: `[message] [success_mode]`
- Success modes: `"success"`, `"error"`, or `"random"`
- Returns appropriate exit codes (0 for success, 1 for error)
- Outputs detailed messages that CallerApp can capture

### **run_second_jar.sh**
- Receives parameters from CallerApp
- Executes: `java -jar SecondApp.jar "$MESSAGE" "$SUCCESS_MODE"`
- Passes through the exit code from SecondApp.jar

## **How to Use:**

1. **Build the JARs:**
   ```bash
   chmod +x build_and_run.sh
   ./build_and_run.sh
   ```

2. **Manual Testing:**
   ```bash
   chmod +x manual_test.sh
   ./manual_test.sh
   ```

3. **Direct JAR Execution:**
   ```bash
   # Random behavior
   java -jar CallerApp.jar
   
   # Force success
   java -jar CallerApp.jar success
   
   # Force error
   java -jar CallerApp.jar error
   
   # Test SecondApp directly
   java -jar SecondApp.jar "Test message" "success"
   ```

## **Parameter Flow:**

1. **CallerApp.jar** → **run_second_jar.sh** → **SecondApp.jar**
2. **Parameters passed:** Message string + Success mode
3. **Return flow:** SecondApp output + Exit code → Shell script → CallerApp

## **Exit Code Handling:**

- **SecondApp.jar**: Returns 0 (success) or 1 (error)
- **Shell script**: Passes through SecondApp's exit code
- **CallerApp.jar**: Receives and uses the exit code to determine success/failure

## **Message Passing:**

- CallerApp sends a message to SecondApp through the shell script
- SecondApp processes the message and returns detailed output
- CallerApp captures all output and displays it with the exit code status

The system now properly handles JAR-to-JAR communication through shell scripts with full parameter passing and exit code propagation!



## Prompt:
include command to comiple and create jar file



## Response:
I'll add the compilation and JAR creation commands to the build script and also create a separate compilation guide.

compile_and_run.sh

```bash
#!/bin/bash

# Complete setup and execution script
echo "=== Setting up Java Applications ==="

# Compile both Java applications
echo "Compiling CallerApp.java..."
javac CallerApp.java

echo "Compiling SecondApp.java..."
javac SecondApp.java

# Make shell script executable
echo "Making run_second_app.sh executable..."
chmod +x run_second_app.sh

# Run the CallerApp
echo "=== Running CallerApp ==="
java CallerApp

echo "=== Execution Complete ==="
```

COMPILATION_GUIDE.md

```markdown
# Java JAR Compilation and Execution Guide

## Prerequisites
- Java Development Kit (JDK) installed
- `javac` and `jar` commands available in PATH

## Manual Compilation Steps

### Step 1: Compile Java Source Files
```bash
# Compile the first application
javac CallerApp.java

# Compile the second application  
javac SecondApp.java
```

### Step 2: Create Manifest Files
```bash
# Create manifest for CallerApp
echo "Main-Class: CallerApp" > caller-manifest.txt

# Create manifest for SecondApp
echo "Main-Class: SecondApp" > second-manifest.txt
```

### Step 3: Create JAR Files
```bash
# Create CallerApp JAR with manifest
jar cfm CallerApp.jar caller-manifest.txt CallerApp.class

# Create SecondApp JAR with manifest
jar cfm SecondApp.jar second-manifest.txt SecondApp.class
```

### Step 4: Make Shell Script Executable
```bash
chmod +x run_second_jar.sh
```

### Step 5: Clean Up (Optional)
```bash
# Remove temporary files
rm -f *.class *-manifest.txt
```

## Alternative JAR Creation Methods

### Method 1: Create JAR then add manifest
```bash
# Compile
javac CallerApp.java

# Create JAR without manifest
jar cf CallerApp.jar CallerApp.class

# Add manifest to existing JAR
jar umf caller-manifest.txt CallerApp.jar
```

### Method 2: Create JAR with inline manifest
```bash
# Compile
javac CallerApp.java

# Create JAR with manifest in one command
jar cfe CallerApp.jar CallerApp CallerApp.class
```

### Method 3: Using manifest file with additional attributes
```bash
# Create enhanced manifest
cat > caller-manifest.txt << EOF
Manifest-Version: 1.0
Main-Class: CallerApp
Created-By: Manual Build
Implementation-Version: 1.0
EOF

# Create JAR
jar cfm CallerApp.jar caller-manifest.txt CallerApp.class
```

## Execution Commands

### Run Individual JARs
```bash
# Run CallerApp (which calls SecondApp through shell script)
java -jar CallerApp.jar

# Run CallerApp with parameters
java -jar CallerApp.jar success
java -jar CallerApp.jar error
java -jar CallerApp.jar random

# Run SecondApp directly
java -jar SecondApp.jar "Test message" "success"
java -jar SecondApp.jar "Test message" "error"
java -jar SecondApp.jar "Test message" "random"
```

### Automated Build and Run
```bash
# Make build script executable
chmod +x build_and_run.sh

# Run complete build and test
./build_and_run.sh
```

## JAR Command Reference

| Command | Description |
|---------|-------------|
| `jar cf jarfile.jar classfiles` | Create JAR file |
| `jar cfm jarfile.jar manifest classfiles` | Create JAR with manifest |
| `jar cfe jarfile.jar entrypoint classfiles` | Create JAR with entry point |
| `jar tf jarfile.jar` | List contents of JAR |
| `jar xf jarfile.jar` | Extract JAR contents |
| `jar uf jarfile.jar files` | Update JAR file |

## Troubleshooting

### Common Issues:

1. **"Main class not found"**
   - Ensure Main-Class is correctly specified in manifest
   - Verify class file exists in JAR: `jar tf YourApp.jar`

2. **"Could not find or load main class"**
   - Check manifest file format (no extra spaces/newlines)
   - Ensure main class has correct package declaration

3. **"Permission denied" for shell script**
   - Run: `chmod +x run_second_jar.sh`

4. **Shell script not found**
   - Ensure all files are in the same directory
   - Check script path in CallerApp.java

### Verification Commands:
```bash
# Check JAR contents
jar tf CallerApp.jar
jar tf SecondApp.jar

# Test JARs individually
java -jar SecondApp.jar "test" "success"
echo "Exit code: $?"

# Check manifest
unzip -q -c CallerApp.jar META-INF/MANIFEST.MF
```

## File Structure
```
project-directory/
├── CallerApp.java
├── SecondApp.java
├── run_second_jar.sh
├── build_and_run.sh
├── manual_test.sh
├── CallerApp.jar          (generated)
├── SecondApp.jar          (generated)
└── COMPILATION_GUIDE.md   (this file)
```
```

quick_build.sh

```bash
#!/bin/bash

# Quick build script with individual commands shown
echo "=== Quick JAR Build Script ==="
echo "This script shows each command as it executes"
echo ""

set -x  # Enable command echoing

# Step 1: Clean previous builds
rm -f *.class *.jar *-manifest.txt

# Step 2: Compile Java files
javac CallerApp.java
javac SecondApp.java

# Step 3: Create manifest files
echo "Main-Class: CallerApp" > caller-manifest.txt
echo "Main-Class: SecondApp" > second-manifest.txt

# Step 4: Create JAR files
jar cfm CallerApp.jar caller-manifest.txt CallerApp.class
jar cfm SecondApp.jar second-manifest.txt SecondApp.class

# Step 5: Make shell script executable
chmod +x run_second_jar.sh

# Step 6: Clean up temporary files
rm -f *.class *-manifest.txt

set +x  # Disable command echoing

echo ""
echo "=== Build Complete ==="
echo "Files created:"
ls -la *.jar
echo ""
echo "Ready to run with: java -jar CallerApp.jar"
```

I've enhanced the compilation and JAR creation process with detailed commands and multiple options:

## **Enhanced Build System:**

### **1. Detailed Build Script (build_and_run.sh)**
- Shows each command as it executes
- Includes file size information
- Comprehensive error checking
- Step-by-step progress indication

### **2. Compilation Guide (COMPILATION_GUIDE.md)**
- Complete manual compilation steps
- Alternative JAR creation methods
- Command reference table
- Troubleshooting section
- File structure overview

### **3. Quick Build Script (quick_build.sh)**
- Minimal script with command echoing
- Shows exactly what commands are being run
- Perfect for learning the process

## **Key Compilation Commands:**

### **Basic Compilation:**
```bash
# Compile source files
javac CallerApp.java
javac SecondApp.java

# Create manifest files
echo "Main-Class: CallerApp" > caller-manifest.txt
echo "Main-Class: SecondApp" > second-manifest.txt

# Create JAR files
jar cfm CallerApp.jar caller-manifest.txt CallerApp.class
jar cfm SecondApp.jar second-manifest.txt SecondApp.class
```

### **Alternative JAR Creation:**
```bash
# Method 1: Using -e flag (entry point)
jar cfe CallerApp.jar CallerApp CallerApp.class

# Method 2: Create then update
jar cf CallerApp.jar CallerApp.class
jar umf caller-manifest.txt CallerApp.jar
```

## **Usage Options:**

1. **Automated Build:**
   ```bash
   chmod +x build_and_run.sh
   ./build_and_run.sh
   ```

2. **Quick Build:**
   ```bash
   chmod +x quick_build.sh
   ./quick_build.sh
   ```

3. **Manual Commands:** Follow the COMPILATION_GUIDE.md

## **Verification:**
```bash
# Check JAR contents
jar tf CallerApp.jar
jar tf SecondApp.jar

# Test execution
java -jar CallerApp.jar success
java -jar SecondApp.jar "test message" "success"
```

The system now provides multiple ways to build the JARs with clear visibility into each compilation step and comprehensive documentation for manual compilation!



## Prompt:
put all together in one project



## Response:
I'll create a comprehensive project structure with all files organized together.

Java JAR Communication Project

```markdown
# Java JAR Communication Project

Complete project demonstrating JAR-to-JAR communication through shell scripts with parameter passing and exit code handling.

## Project Structure
```
java-jar-communication/
├── src/
│   ├── CallerApp.java          # Main application that calls second JAR
│   └── SecondApp.java          # Second application that processes messages
├── scripts/
│   ├── run_second_jar.sh       # Shell script to execute SecondApp.jar
│   ├── build_and_run.sh        # Complete build and test script
│   ├── quick_build.sh          # Simple build script
│   └── manual_test.sh          # Manual testing script
├── docs/
│   └── COMPILATION_GUIDE.md    # Detailed compilation guide
├── build/                      # Generated JAR files (created during build)
├── README.md                   # This file
└── setup.sh                   # Project setup script
```

## Quick Start

1. **Setup Project:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Build and Run:**
   ```bash
   cd java-jar-communication
   ./scripts/build_and_run.sh
   ```

## Project Files

### Source Files

#### **src/CallerApp.java**
```java
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

public class CallerApp {
    public static void main(String[] args) {
        try {
            System.out.println("CallerApp: Starting execution...");
            
            // Prepare parameters to pass to the second JAR
            String messageToSend = "Hello from CallerApp!";
            String shouldSucceed = args.length > 0 ? args[0] : "random";
            
            System.out.println("CallerApp: Sending message: '" + messageToSend + "'");
            System.out.println("CallerApp: Success mode: " + shouldSucceed);
            
            // Execute the shell script with parameters
            ProcessBuilder processBuilder = new ProcessBuilder(
                "./scripts/run_second_jar.sh", 
                messageToSend, 
                shouldSucceed
            );
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();
            
            // Read the output from the second application
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream())
            );
            
            String line;
            StringBuilder output = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            
            // Wait for the process to complete and get exit code
            int exitCode = process.waitFor();
            
            // Print results
            System.out.println("\n=== CallerApp: Results ===");
            System.out.println("Received output from SecondApp JAR:");
            System.out.println(output.toString().trim());
            System.out.println("\nExit code received: " + exitCode);
            
            if (exitCode == 0) {
                System.out.println("CallerApp: SecondApp JAR executed successfully!");
            } else {
                System.out.println("CallerApp: SecondApp JAR encountered an error!");
            }
            
            // Exit with the same code as the second app
            System.exit(exitCode);
            
        } catch (IOException e) {
            System.err.println("CallerApp: IO Exception occurred: " + e.getMessage());
            System.exit(1);
        } catch (InterruptedException e) {
            System.err.println("CallerApp: Process was interrupted: " + e.getMessage());
            System.exit(1);
        } catch (Exception e) {
            System.err.println("CallerApp: Unexpected error: " + e.getMessage());
            System.exit(1);
        }
    }
}
```

#### **src/SecondApp.java**
```java
import java.util.Random;

public class SecondApp {
    public static void main(String[] args) {
        try {
            System.out.println("SecondApp JAR: Starting execution...");
            
            // Parse command line arguments
            String receivedMessage = args.length > 0 ? args[0] : "No message received";
            String successMode = args.length > 1 ? args[1] : "random";
            
            System.out.println("SecondApp JAR: Received message: '" + receivedMessage + "'");
            System.out.println("SecondApp JAR: Success mode: " + successMode);
            
            // Simulate some processing
            Thread.sleep(500);
            
            // Determine success or failure based on parameters
            boolean success;
            switch (successMode.toLowerCase()) {
                case "true":
                case "success":
                    success = true;
                    break;
                case "false":
                case "error":
                    success = false;
                    break;
                default:
                    // Random behavior
                    Random random = new Random();
                    success = random.nextBoolean();
                    break;
            }
            
            if (success) {
                // Success case
                System.out.println("\n=== SecondApp JAR: SUCCESS ===");
                System.out.println("Operation completed successfully!");
                System.out.println("Processed message: '" + receivedMessage + "'");
                System.out.println("Current timestamp: " + System.currentTimeMillis());
                System.out.println("Response: Message processed successfully from SecondApp JAR!");
                System.out.println("Status: All operations completed without errors");
                System.exit(0); // Exit with code 0 for success
            } else {
                // Error case
                System.out.println("\n=== SecondApp JAR: ERROR ===");
                System.out.println("An error occurred during processing!");
                System.out.println("Failed to process message: '" + receivedMessage + "'");
                System.out.println("Error timestamp: " + System.currentTimeMillis());
                System.out.println("Error response: Processing failed in SecondApp JAR!");
                System.out.println("Status: Operation terminated with errors");
                System.exit(1); // Exit with code 1 for error
            }
            
        } catch (InterruptedException e) {
            System.err.println("SecondApp JAR: Thread was interrupted: " + e.getMessage());
            System.exit(1);
        } catch (Exception e) {
            System.err.println("SecondApp JAR: Unexpected error: " + e.getMessage());
            System.exit(1);
        }
    }
}
```

### Script Files

#### **scripts/run_second_jar.sh**
```bash
#!/bin/bash

# Shell script to run the SecondApp JAR with parameters
# Parameters: $1 = message to pass, $2 = success mode

MESSAGE="$1"
SUCCESS_MODE="$2"

echo "Shell Script: Executing SecondApp.jar..."
echo "Shell Script: Message parameter: '$MESSAGE'"
echo "Shell Script: Success mode: '$SUCCESS_MODE'"

# Run the SecondApp JAR with parameters
java -jar build/SecondApp.jar "$MESSAGE" "$SUCCESS_MODE"

# Capture the exit code
exit_code=$?
echo "Shell Script: SecondApp.jar finished with exit code: $exit_code"

# Pass through the exit code
exit $exit_code
```

#### **scripts/build_and_run.sh**
```bash
#!/bin/bash

# Complete build and execution script for JAR applications
cd "$(dirname "$0")/.."  # Navigate to project root

echo "=== Building Java JAR Applications ==="

# Create build directory
mkdir -p build

# Clean up previous builds
echo "Cleaning up previous builds..."
rm -f build/*.jar src/*.class *-manifest.txt

echo ""
echo "Step 1: Compiling Java source files..."
echo "Command: javac src/CallerApp.java"
javac src/CallerApp.java
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile CallerApp.java"
    exit 1
fi
echo "✓ CallerApp.java compiled successfully"

echo "Command: javac src/SecondApp.java"
javac src/SecondApp.java
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to compile SecondApp.java"
    exit 1
fi
echo "✓ SecondApp.java compiled successfully"

echo ""
echo "Step 2: Creating manifest files..."
echo "Command: echo \"Main-Class: CallerApp\" > caller-manifest.txt"
echo "Main-Class: CallerApp" > caller-manifest.txt
echo "✓ Created caller-manifest.txt"

echo "Command: echo \"Main-Class: SecondApp\" > second-manifest.txt"
echo "Main-Class: SecondApp" > second-manifest.txt
echo "✓ Created second-manifest.txt"

echo ""
echo "Step 3: Creating JAR files..."
echo "Command: jar cfm build/CallerApp.jar caller-manifest.txt -C src CallerApp.class"
jar cfm build/CallerApp.jar caller-manifest.txt -C src CallerApp.class
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create CallerApp.jar"
    exit 1
fi
echo "✓ CallerApp.jar created successfully"

echo "Command: jar cfm build/SecondApp.jar second-manifest.txt -C src SecondApp.class"
jar cfm build/SecondApp.jar second-manifest.txt -C src SecondApp.class
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create SecondApp.jar"
    exit 1
fi
echo "✓ SecondApp.jar created successfully"

echo ""
echo "Step 4: Setting up shell script permissions..."
echo "Command: chmod +x scripts/run_second_jar.sh"
chmod +x scripts/run_second_jar.sh
echo "✓ run_second_jar.sh made executable"

echo ""
echo "Step 5: Cleaning up temporary files..."
echo "Command: rm -f src/*.class *-manifest.txt"
rm -f src/*.class *-manifest.txt
echo "✓ Temporary files cleaned up"

echo ""
echo "=== Build Complete ==="
echo "Created JAR files:"
echo "  - build/CallerApp.jar ($(ls -lh build/CallerApp.jar | awk '{print $5}'))"
echo "  - build/SecondApp.jar ($(ls -lh build/SecondApp.jar | awk '{print $5}'))"
echo ""

# Run examples
echo "=== Running Examples ==="

echo "1. Running with random success/failure:"
java -jar build/CallerApp.jar
echo ""

echo "2. Running with forced success:"
java -jar build/CallerApp.jar success
echo ""

echo "3. Running with forced error:"
java -jar build/CallerApp.jar error
echo ""

echo "=== Execution Complete ==="
```

#### **scripts/quick_build.sh**
```bash
#!/bin/bash

# Quick build script with individual commands shown
cd "$(dirname "$0")/.."  # Navigate to project root

echo "=== Quick JAR Build Script ==="
echo "This script shows each command as it executes"
echo ""

set -x  # Enable command echoing

# Create build directory
mkdir -p build

# Step 1: Clean previous builds
rm -f build/*.jar src/*.class *-manifest.txt

# Step 2: Compile Java files
javac src/CallerApp.java
javac src/SecondApp.java

# Step 3: Create manifest files
echo "Main-Class: CallerApp" > caller-manifest.txt
echo "Main-Class: SecondApp" > second-manifest.txt

# Step 4: Create JAR files
jar cfm build/CallerApp.jar caller-manifest.txt -C src CallerApp.class
jar cfm build/SecondApp.jar second-manifest.txt -C src SecondApp.class

# Step 5: Make shell script executable
chmod +x scripts/run_second_jar.sh

# Step 6: Clean up temporary files
rm -f src/*.class *-manifest.txt

set +x  # Disable command echoing

echo ""
echo "=== Build Complete ==="
echo "Files created:"
ls -la build/*.jar
echo ""
echo "Ready to run with: java -jar build/CallerApp.jar"
```

#### **scripts/manual_test.sh**
```bash
#!/bin/bash

# Manual testing script for individual JAR execution
cd "$(dirname "$0")/.."  # Navigate to project root

echo "=== Manual JAR Testing ==="

echo "1. Testing SecondApp.jar directly with success:"
java -jar build/SecondApp.jar "Direct test message" "success"
echo "Exit code: $?"
echo ""

echo "2. Testing SecondApp.jar directly with error:"
java -jar build/SecondApp.jar "Error test message" "error"
echo "Exit code: $?"
echo ""

echo "3. Testing CallerApp.jar (which calls SecondApp.jar through shell script):"
java -jar build/CallerApp.jar "random"
echo "Final exit code: $?"
echo ""

echo "=== Testing Complete ==="
```

### Setup Script

#### **setup.sh**
```bash
#!/bin/bash

echo "=== Java JAR Communication Project Setup ==="

# Create project directory structure
PROJECT_DIR="java-jar-communication"

if [ -d "$PROJECT_DIR" ]; then
    echo "Project directory already exists. Updating..."
else
    echo "Creating project directory structure..."
    mkdir -p "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Create subdirectories
mkdir -p src scripts docs build

echo "✓ Directory structure created"

# Note: In a real setup, you would copy the actual files here
# For this example, the files would need to be created separately

echo ""
echo "=== Setup Complete ==="
echo "Project structure:"
echo "java-jar-communication/"
echo "├── src/                 # Java source files"
echo "├── scripts/             # Shell scripts"
echo "├── docs/                # Documentation"
echo "├── build/               # Generated JAR files"
echo "└── README.md            # This guide"
echo ""
echo "Next steps:"
echo "1. Copy Java source files to src/"
echo "2. Copy shell scripts to scripts/"
echo "3. Run: ./scripts/build_and_run.sh"
```

## Usage Instructions

### 1. Build the Project
```bash
# Quick build
./scripts/quick_build.sh

# Full build with testing
./scripts/build_and_run.sh
```

### 2. Run Applications
```bash
# Run with random behavior
java -jar build/CallerApp.jar

# Force success
java -jar build/CallerApp.jar success

# Force error
java -jar build/CallerApp.jar error

# Test SecondApp directly
java -jar build/SecondApp.jar "Test message" "success"
```

### 3. Manual Testing
```bash
./scripts/manual_test.sh
```

## Key Features

- **JAR-to-JAR Communication**: CallerApp.jar calls SecondApp.jar through shell script
- **Parameter Passing**: Messages and control parameters passed between applications
- **Exit Code Handling**: Proper exit code propagation (0=success, 1=error)
- **Error Handling**: Comprehensive exception handling in both applications
- **Flexible Testing**: Multiple modes (success, error, random)
- **Clean Build Process**: Organized build system with proper cleanup
- **Documentation**: Complete compilation guide and usage instructions

## Architecture Flow

1. **CallerApp.jar** → **scripts/run_second_jar.sh** → **SecondApp.jar**
2. Parameters: Message string + Success mode
3. Return: Output messages + Exit code
4. CallerApp receives and processes results

This project demonstrates enterprise-level JAR communication patterns with proper error handling, parameter passing, and exit code management.
```

I've created a complete, organized project structure that brings all the components together. Here's what's included:

## **Complete Project Structure:**

```
java-jar-communication/
├── src/
│   ├── CallerApp.java          # Main JAR application
│   └── SecondApp.java          # Called JAR application
├── scripts/
│   ├── run_second_jar.sh       # Shell script for JAR execution
│   ├── build_and_run.sh        # Complete build and test
│   ├── quick_build.sh          # Simple build script
│   └── manual_test.sh          # Individual testing
├── docs/
│   └── COMPILATION_GUIDE.md    # Detailed documentation
├── build/                      # Generated JAR files
├── README.md                   # Complete project guide
└── setup.sh                   # Project setup script
```

## **Key Improvements in the Unified Project:**

### **1. Organized Structure**
- Clean separation of source code, scripts, and documentation
- Dedicated `build/` directory for generated JARs
- Proper script navigation with `cd "$(dirname "$0")/.."`

### **2. Enhanced Build Process**
- Scripts automatically navigate to project root
- JAR files created in `build/` directory using `-C` flag
- Proper path handling for organized structure

### **3. Complete Documentation**
- Comprehensive README with all components
- Usage instructions and architecture flow
- Quick start guide and feature list

### **4. Professional Setup**
- Enterprise-level organization
- Proper error handling and cleanup
- Multiple testing scenarios

## **How to Use the Complete Project:**

### **Option 1: Quick Setup**
```bash
# Create project structure
chmod +x setup.sh
./setup.sh

# Copy all files to appropriate directories
# Then build and run
cd java-jar-communication
./scripts/build_and_run.sh
```

### **Option 2: Manual Setup**
```bash
# Create directory structure
mkdir -p java-jar-communication/{src,scripts,docs,build}

# Copy files to respective directories
# - Java files → src/
# - Shell scripts → scripts/
# - Documentation → docs/

# Build and run
cd java-jar-communication
./scripts/build_and_run.sh
```

## **Key Features of the Unified Project:**

✅ **Complete JAR-to-JAR communication system**
✅ **Parameter passing and exit code handling**
✅ **Multiple build and test scripts**
✅ **Comprehensive documentation**
✅ **Clean, professional project structure**
✅ **Enterprise-ready organization**
✅ **Error handling and logging**
✅ **Flexible testing scenarios**

This unified project provides everything needed for JAR-to-JAR communication through shell scripts, organized in a professional, maintainable structure!





---
Powered by [Claude Exporter](https://www.claudexporter.com)