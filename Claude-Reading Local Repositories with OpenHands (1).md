# Reading Local Repositories with OpenHands

**Created:** 5/12/2025 13:25  
**Updated:** 5/12/2025 13:25  
**Exported:** 5/12/2025 13:44  

## Prompt:
can openhands read from local repo



## Response:
I'd be happy to help you understand if OpenHands can read from a local repository. Let me search for the most up-to-date information about OpenHands.

**web_search**

*Request*

```javascript
{
  "query": "OpenHands AI local repository access"
}
```

**web_fetch**

*Request*

```javascript
{
  "url": "https://github.com/All-Hands-AI/OpenHands"
}
```

**web_fetch**

*Request*

```javascript
{
  "url": "https://docs.all-hands.dev/modules/usage/customization/repository"
}
```

**web_fetch**

*Request*

```javascript
{
  "url": "https://docs.all-hands.dev/modules/usage/runtimes/docker#connecting-to-your-filesystem"
}
```

**web_search**

*Request*

```javascript
{
  "query": "OpenHands access local repository code"
}
```

Based on my research, yes, OpenHands can read from local repositories. Here's how it works:

## Local Repository Access in OpenHands

OpenHands provides functionality to connect to your local filesystem, which allows it to access and work with local code repositories. This is done through mounting your local filesystem into the OpenHands runtime environment.

### Connecting Your Local Filesystem

There are two main methods to connect OpenHands to your local repository:

1. **Using SANDBOX_VOLUMES (Recommended Method):**
   You can mount your local filesystem by using the SANDBOX_VOLUMES environment variable when running the Docker container. The format is `host_path:container_path[:mode]` where:
   - `host_path` is the path on your machine to the repository
   - `container_path` is where it will be mounted in the container (typically `/workspace`)
   - `mode` can be either `rw` (read-write) or `ro` (read-only)

   Example:
   ```bash
   export SANDBOX_VOLUMES=/path/to/your/repo:/workspace:rw
   # Include this in your docker run command
   ```

2. **Deprecated Method (WORKSPACE_* variables):**
   This involves setting the WORKSPACE_BASE variable and adding specific mount options to your docker run command.

### Repository Customization

OpenHands also provides ways to customize how it interacts with your repository:

You can create a `.openhands` directory at the root level of your repository for customization. This can include:
- Microagents to extend OpenHands prompts with information specific to your project
- A setup script (`.openhands/setup.sh`) that runs whenever OpenHands works with your repository

### Working with Local Code

Once connected, OpenHands can:
- Modify code in your repository
- Commit and push changes (when configured with appropriate GitHub/GitLab tokens)
- Read and understand your codebase structure
- Refactor code
- Fix bugs
- Write and run tests

### Security Considerations

When mounting your local filesystem, be aware that OpenHands can modify any files in the mounted directories. Using the proper user ID (with `-e SANDBOX_USER_ID=$(id -u)`) helps prevent permission issues.

Would you like more specific information about how to set up OpenHands with your local repository or any particular aspect of working with local code?





---
Powered by [Claude Exporter](https://www.claudexporter.com)