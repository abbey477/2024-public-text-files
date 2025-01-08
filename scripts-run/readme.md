I'll create a shell script that handles different environment configurations using .env files.



Now let's create the sample .env files for each environment:

To use this setup:

1. Save the shell script as `setup-env.sh`
2. Create three separate .env files: `.env.prod`, `.env.uat`, and `.env.dev`
3. Make the script executable:
```bash
chmod +x setup-env.sh
```

4. Run the script with the desired environment:
```bash
./setup-env.sh dev   # For development environment
./setup-env.sh uat   # For UAT environment
./setup-env.sh prod  # For production environment
```

The script includes several key features:
- Environment variable validation
- Safe loading of .env files
- Configuration display (hiding sensitive data)
- Error handling for missing files or variables
- Different configurations for each environment

Important security notes:
1. Never commit .env files to version control
2. Use appropriate file permissions to protect sensitive data
3. Consider using a secret management service for production credentials
4. Keep different credentials for each environment

Would you like me to explain any specific part of the setup in more detail?
