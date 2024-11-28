I'll show you how to map Spring Boot properties to a Java record class. This is a great way to handle configuration properties in a clean, immutable way.



```java
// application.properties or application.yml
// app.email.host=smtp.example.com
// app.email.port=587
// app.email.username=user
// app.email.password=pass
// app.email.from=sender@example.com

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.bind.ConstructorBinding;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app.email")
public record EmailProperties(
    String host,
    int port,
    String username,
    String password,
    String from
) {
    // No need for getters/setters/constructors - record handles it all!
}

// Usage example in a service class
@Service
public class EmailService {
    private final EmailProperties emailProperties;

    public EmailService(EmailProperties emailProperties) {
        this.emailProperties = emailProperties;
    }

    public void sendEmail(String to, String subject, String body) {
        // Access properties
        String host = emailProperties.host();
        int port = emailProperties.port();
        String username = emailProperties.username();
        // ... implement email sending logic
    }
}

```

Here's what's happening in this example:

1. The record class `EmailProperties` is annotated with:
   - `@Configuration` to make it a Spring configuration class
   - `@ConfigurationProperties` with a prefix to map properties from your configuration file

2. The record's parameters automatically become the properties to be mapped. Spring Boot will:
   - Match property names from your configuration files to the record parameters
   - Handle type conversion automatically
   - Create an immutable object with the properties

3. You can inject and use the properties record in your services/components:
   - Access values using the generated accessor methods (like `host()`, `port()`)
   - Get compile-time safety and immutability
   - Have clean, concise code without boilerplate

To enable configuration properties scanning, add this to your main class or configuration:

```java
@EnableConfigurationProperties
```

Or add this dependency if not already present:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

Would you like me to show you how to handle nested properties or validation with records as well?
