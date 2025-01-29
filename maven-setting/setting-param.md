I'll explain the different places where you can set environment variables for Maven settings.xml:

1. System-wide Environment Variables (Permanent):

For Windows:
```
1. Open System Properties > Advanced > Environment Variables
2. Add under either User or System variables:
   Variable name: MAVEN_USERNAME
   Variable value: yourvalue
```

For Linux/Mac (choose one):
```bash
# In ~/.bashrc or ~/.zshrc
export MAVEN_USERNAME=yourvalue
export MAVEN_PASSWORD=yourpass

# In ~/.bash_profile
export MAVEN_USERNAME=yourvalue
export MAVEN_PASSWORD=yourpass

# In /etc/environment
MAVEN_USERNAME=yourvalue
MAVEN_PASSWORD=yourpass
```

2. IDE-specific Environment Variables:

In Eclipse:
```
1. Run > Run Configurations
2. Select Maven Build
3. Environment tab
4. Add variables
```

In IntelliJ IDEA:
```
1. Run > Edit Configurations
2. Maven Settings
3. Runner tab > Environment Variables
```

3. Project-specific .env file (with maven-env-plugin):
```
# .env file in project root
MAVEN_USERNAME=yourvalue
MAVEN_PASSWORD=yourpass
```

4. CI/CD Platform Variables:

Jenkins:
```
1. Jenkins > Project > Configure
2. Build Environment > Add Environment Variables
```

GitHub Actions:
```yaml
env:
  MAVEN_USERNAME: ${{ secrets.MAVEN_USERNAME }}
  MAVEN_PASSWORD: ${{ secrets.MAVEN_PASSWORD }}
```

GitLab CI:
```yaml
variables:
  MAVEN_USERNAME: ${CI_MAVEN_USERNAME}
  MAVEN_PASSWORD: ${CI_MAVEN_PASSWORD}
```

5. Command line (Temporary):
```bash
# Windows
set MAVEN_USERNAME=yourvalue

# Linux/Mac
export MAVEN_USERNAME=yourvalue
```

Best Practices:

1. Avoid storing sensitive values in plain text
2. Use CI/CD secret management when possible
3. Keep production credentials separate from development
4. Consider using a credentials management system for production environments
5. Document required environment variables in your project README

Remember that environment variables set at a more specific level (like project-level) typically override those set at a more general level (like system-wide).
