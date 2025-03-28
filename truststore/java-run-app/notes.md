I'll show you how to separate the Java file from the shell script. This is a better approach as it keeps your source code separate and easier to maintain.

Let's create two separate files:

Now you have two separate files:

1. `HelloWorld.java` - Your Java source code
2. `compileAndRun.sh` - A shell script to compile and run your Java program

To use these files:

1. First, make sure the shell script is executable:
```bash
chmod +x compileAndRun.sh
```

2. Then run the script:
```bash
./compileAndRun.sh
```

If you want to pass arguments to your Java program:
```bash
./compileAndRun.sh arg1 arg2 arg3
```

### Making It More Flexible

If you want to make the script more flexible to compile and run different Java files, you can modify it to accept the class name as a parameter:

With this more flexible script, you would use it like this:

```bash
chmod +x javaRunner.sh
./javaRunner.sh HelloWorld arg1 arg2
```

Or for a different Java class:
```bash
./javaRunner.sh Calculator 5 + 3
```

This approach separates your Java code from your build scripts, making your code easier to maintain and your workflow more flexible.