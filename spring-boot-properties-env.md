I'll create a complete demo showing how to handle multiple environment-specific .env files.



```java
// Project structure:
src/
├── main/
│   ├── resources/
│   │   ├── .env                  # Default/shared values
│   │   ├── .env.development      # Development-specific values
│   │   ├── .env.staging         # Staging-specific values
│   │   ├── .env.production      # Production-specific values
│   │   ├── .env.example         # Example file for documentation
│   │   └── application.properties
│   └── java/
│       └── com/example/demo/
│           ├── DemoApplication.java
│           ├── config/
│           │   └── EnvConfig.java
│           └── controller/
│               └── TestController.java

// .env (default/shared values)
APP_NAME=MySpringApp
APP_VERSION=1.0.0
TIMEZONE=UTC

// .env.development
SERVER_PORT=8080
DATABASE_URL=jdbc:mysql://localhost:3306/devdb
DB_USERNAME=dev_user
DB_PASSWORD=dev_pass
API_KEY=dev-key-123
LOG_LEVEL=DEBUG
MAIL_HOST=smtp.mailtrap.io
CACHE_TYPE=simple

// .env.staging
SERVER_PORT=8081
DATABASE_URL=jdbc:mysql://staging-db:3306/stagingdb
DB_USERNAME=staging_user
DB_PASSWORD=staging_pass
API_KEY=staging-key-456
LOG_LEVEL=INFO
MAIL_HOST=smtp.gmail.com
CACHE_TYPE=caffeine

// .env.production
SERVER_PORT=80
DATABASE_URL=jdbc:mysql://prod-db:3306/proddb
DB_USERNAME=prod_user
DB_PASSWORD=prod_pass
API_KEY=prod-key-789
LOG_LEVEL=WARN
MAIL_HOST=smtp.company.com
CACHE_TYPE=redis

// .env.example
SERVER_PORT=8080
DATABASE_URL=jdbc:mysql://localhost:3306/mydb
DB_USERNAME=user
DB_PASSWORD=pass
API_KEY=your-api-key
LOG_LEVEL=INFO
MAIL_HOST=smtp.example.com
CACHE_TYPE=simple

// pom.xml
<dependency>
    <groupId>me.paulschwarz</groupId>
    <artifactId>spring-dotenv</artifactId>
    <version>4.0.0</version>
</dependency>

// EnvConfig.java
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.beans.factory.annotation.Autowired;
import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

@Configuration
public class EnvConfig {
    
    @Autowired
    private Environment env;
    
    @PostConstruct
    public void loadEnv() {
        try {
            // Load default .env file
            Properties props = new Properties();
            File envFile = new File("src/main/resources/.env");
            if (envFile.exists()) {
                props.load(new FileInputStream(envFile));
            }
            
            // Get active profile
            String activeProfile = env.getProperty("spring.profiles.active", "development");
            
            // Load profile-specific .env file
            File profileEnvFile = new File("src/main/resources/.env." + activeProfile);
            if (profileEnvFile.exists()) {
                Properties profileProps = new Properties();
                profileProps.load(new FileInputStream(profileEnvFile));
                // Override default properties with profile-specific ones
                props.putAll(profileProps);
            }
            
            // Set system properties
            props.forEach((key, value) -> System.setProperty(key.toString(), value.toString()));
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

// application.properties
spring.profiles.active=${SPRING_PROFILE:development}
server.port=${SERVER_PORT}
spring.application.name=${APP_NAME}
spring.application.version=${APP_VERSION}

spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

app.api.key=${API_KEY}
logging.level.root=${LOG_LEVEL}
spring.mail.host=${MAIL_HOST}
spring.cache.type=${CACHE_TYPE}

// TestController.java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class TestController {

    @Value("${spring.application.name}")
    private String appName;
    
    @Value("${spring.profiles.active}")
    private String activeProfile;
    
    @Value("${app.api.key}")
    private String apiKey;
    
    @GetMapping("/config")
    public Map<String, String> getConfig() {
        Map<String, String> config = new HashMap<>();
        config.put("appName", appName);
        config.put("activeProfile", activeProfile);
        config.put("apiKey", apiKey);
        return config;
    }
}

// DemoApplication.java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}

```

To use this configuration:

1. Running with different profiles:
```bash
# Development
java -jar app.jar -Dspring.profiles.active=development

# Staging
java -jar app.jar -Dspring.profiles.active=staging

# Production
java -jar app.jar -Dspring.profiles.active=production
```

2. Key Features:
   - Loads default .env file first
   - Overrides with profile-specific values
   - Fallbacks to development if no profile specified
   - Example endpoint to verify configuration

3. Security Best Practices:
   - Add all .env files (except .env.example) to .gitignore
   - Use encryption for sensitive values in production
   - Document required variables in .env.example
   - Keep different access levels for different environments

4. You can test the configuration by:
   - Running the application with different profiles
   - Accessing the /config endpoint
   - Checking the loaded values in logs

Would you like me to show you how to add encryption for sensitive values or how to handle database migrations with different environments?
