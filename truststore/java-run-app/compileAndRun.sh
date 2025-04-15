#!/bin/bash

# Check if class name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ClassName> [program arguments...]"
    exit 1
fi

# Get the class name from the first argument
CLASS_NAME=$1
JAVA_FILE="${CLASS_NAME}.java"
CLASS_FILE="${CLASS_NAME}.class"

# Remove the first argument (class name) from the arguments list
shift

# Check if Java file exists
if [ ! -f "$JAVA_FILE" ]; then
    echo "Error: $JAVA_FILE not found."
    exit 1
fi

# Compile Java file
echo "Compiling $JAVA_FILE..."
javac $JAVA_FILE

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful."
    
    # Run the Java program with remaining arguments
    echo "Running $CLASS_NAME..."
    java $CLASS_NAME "$@"
    
    # Clean up (optional, uncomment if you want to remove the compiled class)
    # echo "Cleaning up..."
    # rm $CLASS_FILE
else
    echo "Compilation failed."
fi