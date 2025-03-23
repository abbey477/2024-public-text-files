# Shell Script Function Reuse

In shell scripting, there are several ways to reuse functions across multiple files, similar to how classes and methods work in Java. Here are the main approaches:

## 1. Source/Include Files

The most common method is to use the `source` command (or its alias `.`):

```bash
# In functions.sh
function say_hello() {
  echo "Hello, $1!"
}

# In main.sh
source ./functions.sh  # or . ./functions.sh
say_hello "World"
```

This loads all functions from the sourced file into the current shell environment.

## 2. Export Functions

You can export functions to make them available to subshells:

```bash
# In parent.sh
function say_hello() {
  echo "Hello, $1!"
}
export -f say_hello

# Now child processes can use this function
bash -c 'say_hello "from child process"'
```

## 3. Use Libraries with Namespaces

For larger projects, you can implement a simple namespace pattern:

```bash
# In lib/string_utils.sh
string_utils_capitalize() {
  echo "${1^}"
}

# In your script
source ./lib/string_utils.sh
string_utils_capitalize "hello"  # Returns "Hello"
```

## 4. Create Executable Scripts

You can also create executable utility scripts and add them to your PATH:

```bash
# In ~/bin/utils (make executable with chmod +x)
#!/bin/bash
case "$1" in
  "capitalize")
    echo "${2^}"
    ;;
  "to_upper")
    echo "${2^^}"
    ;;
esac

# In your script
result=$(utils capitalize "hello")
```

## 5. Shell Modules

Some advanced shells like Bash 4+ and Zsh support more sophisticated module patterns:

```bash
# In math_lib.sh
math::add() {
  echo $(($1 + $2))
}
math::subtract() {
  echo $(($1 - $2))
}

# In main.sh
source ./math_lib.sh
result=$(math::add 5 3)
```

Unlike Java, shell scripting doesn't have true object-oriented features, but these patterns can help organize and reuse your code effectively.
