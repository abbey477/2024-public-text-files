# Spring Boot Environment-Specific Configuration

**Created:** 5/12/2025 12:19  
**Updated:** 5/12/2025 12:21  
**Exported:** 5/12/2025 12:24  

## Prompt:
spring boot custom application.properties mapper to java record for uat and prod



## Response:
I'd be happy to help you create a custom application.properties mapper to Java records for different environments (UAT and prod). 

Let's implement a solution that allows you to map properties from different environments to Java records:

```java
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

// Define a record to hold the configuration properties
public record AppConfig(
    String serverUrl,
    int maxConnections,
    long timeout,
    boolean featureFlag
) {}

@Configuration
public class AppConfigurationLoader {
    
    // Configuration for UAT environment
    @Bean
    @Profile("uat")
    @ConfigurationProperties(prefix = "app")
    public AppConfig uatAppConfig() {
        return new AppConfig(null, 0, 0, false); // Default values will be overridden
    }
    
    // Configuration for production environment
    @Bean
    @Profile("prod")
    @ConfigurationProperties(prefix = "app")
    public AppConfig prodAppConfig() {
        return new AppConfig(null, 0, 0, false); // Default values will be overridden
    }
}
```

Then in your application.properties files for each environment:

For UAT (application-uat.properties):
```properties
app.server-url=https://uat-api.example.com
app.max-connections=50
app.timeout=5000
app.feature-flag=true
```

For Production (application-prod.properties):
```properties
app.server-url=https://api.example.com
app.max-connections=200
app.timeout=3000
app.feature-flag=false
```

To use this configuration in your application:

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MyService {
    
    private final AppConfig appConfig;
    
    @Autowired
    public MyService(AppConfig appConfig) {
        this.appConfig = appConfig;
    }
    
    public void doSomething() {
        // Access properties from the record
        String url = appConfig.serverUrl();
        int maxConn = appConfig.maxConnections();
        
        // Use the properties
        System.out.println("Connecting to: " + url + " with " + maxConn + " connections");
    }
}
```

To run your application with a specific profile:
```bash
# For UAT
./mvnw spring-boot:run -Dspring-boot.run.profiles=uat

# For Production
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod
```

Would you like me to explain how this solution works or would you like to see a more complex example with nested properties?



## Prompt:
add more to the variables, show nested objects and collections, e.tc



## Response:
I'll expand the example to include nested objects and collections in your Java record configuration. Here's a more comprehensive implementation:

```java
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.context.properties.ConstructorBinding;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Set;

// Main configuration record
public record AppConfig(
    String applicationName,
    String version,
    DatabaseConfig database,
    ServerConfig server,
    SecurityConfig security,
    CacheConfig cache,
    List<IntegrationConfig> integrations,
    Map<String, FeatureFlag> features,
    Set<String> allowedOrigins
) {}

// Nested record for database configuration
public record DatabaseConfig(
    String url,
    String username,
    String password,
    int poolSize,
    Duration connectionTimeout,
    boolean readOnly,
    Map<String, String> options
) {}

// Nested record for server configuration
public record ServerConfig(
    String host,
    int port,
    String contextPath,
    CompressionConfig compression,
    List<String> supportedProtocols
) {}

// Nested record for compression configuration
public record CompressionConfig(
    boolean enabled,
    int level,
    List<String> mimeTypes
) {}

// Nested record for security configuration
public record SecurityConfig(
    AuthConfig auth,
    boolean sslEnabled,
    List<String> trustedIps
) {}

// Nested record for authentication configuration
public record AuthConfig(
    String provider,
    String tokenEndpoint,
    Duration tokenExpiry,
    Set<String> scopes
) {}

// Nested record for cache configuration
public record CacheConfig(
    String type,
    int maxSize,
    Duration expiration
) {}

// Nested record for integration configurations
public record IntegrationConfig(
    String name,
    String endpoint,
    AuthType authType,
    Map<String, String> headers,
    RetryConfig retry
) {}

// Enum for authentication types
public enum AuthType {
    NONE, BASIC, OAUTH2, API_KEY
}

// Nested record for retry configuration
public record RetryConfig(
    int maxAttempts,
    Duration backoffDelay,
    boolean exponentialBackoff
) {}

// Nested record for feature flags
public record FeatureFlag(
    boolean enabled,
    String description,
    Set<String> allowedRoles,
    Map<String, String> parameters,
    double rolloutPercentage
) {}

@Configuration
@EnableConfigurationProperties
public class AppConfigurationLoader {
    
    // Configuration for UAT environment
    @Bean
    @Profile("uat")
    @ConfigurationProperties(prefix = "app")
    public AppConfig uatAppConfig() {
        return new AppConfig(null, null, null, null, null, null, null, null, null); // Default values will be overridden
    }
    
    // Configuration for production environment
    @Bean
    @Profile("prod")
    @ConfigurationProperties(prefix = "app")
    public AppConfig prodAppConfig() {
        return new AppConfig(null, null, null, null, null, null, null, null, null); // Default values will be overridden
    }
}
```

Now, let's create the corresponding application.properties files for both environments:

For UAT (application-uat.properties):
```properties
# Application info
app.application-name=My Application UAT
app.version=1.0.0-RC

# Database configuration
app.database.url=jdbc:postgresql://uat-db.example.com:5432/myapp
app.database.username=app_user
app.database.password=uat_password
app.database.pool-size=10
app.database.connection-timeout=PT5S
app.database.read-only=false
app.database.options.auto-commit=true
app.database.options.ssl-mode=prefer

# Server configuration
app.server.host=0.0.0.0
app.server.port=8080
app.server.context-path=/api
app.server.compression.enabled=true
app.server.compression.level=6
app.server.compression.mime-types[0]=application/json
app.server.compression.mime-types[1]=text/html
app.server.supported-protocols[0]=HTTP/1.1
app.server.supported-protocols[1]=HTTP/2

# Security configuration
app.security.auth.provider=keycloak
app.security.auth.token-endpoint=https://uat-auth.example.com/token
app.security.auth.token-expiry=PT1H
app.security.auth.scopes[0]=read
app.security.auth.scopes[1]=write
app.security.ssl-enabled=true
app.security.trusted-ips[0]=192.168.1.1
app.security.trusted-ips[1]=10.0.0.0/24

# Cache configuration
app.cache.type=local
app.cache.max-size=1000
app.cache.expiration=PT10M

# Integration configurations
app.integrations[0].name=payment-service
app.integrations[0].endpoint=https://uat-payments.example.com/api
app.integrations[0].auth-type=OAUTH2
app.integrations[0].headers.content-type=application/json
app.integrations[0].retry.max-attempts=3
app.integrations[0].retry.backoff-delay=PT2S
app.integrations[0].retry.exponential-backoff=true

app.integrations[1].name=notification-service
app.integrations[1].endpoint=https://uat-notifications.example.com/api
app.integrations[1].auth-type=API_KEY
app.integrations[1].headers.x-api-key=uat-api-key-123
app.integrations[1].retry.max-attempts=2
app.integrations[1].retry.backoff-delay=PT1S
app.integrations[1].retry.exponential-backoff=false

# Feature flags
app.features.new-ui.enabled=true
app.features.new-ui.description=New user interface
app.features.new-ui.allowed-roles[0]=beta-tester
app.features.new-ui.allowed-roles[1]=admin
app.features.new-ui.parameters.theme=dark
app.features.new-ui.rollout-percentage=50.0

app.features.analytics.enabled=true
app.features.analytics.description=Advanced analytics
app.features.analytics.allowed-roles[0]=admin
app.features.analytics.parameters.track-clicks=true
app.features.analytics.parameters.track-pageviews=true
app.features.analytics.rollout-percentage=100.0

# CORS configuration
app.allowed-origins[0]=https://uat.example.com
app.allowed-origins[1]=https://dev.example.com
```

For Production (application-prod.properties):
```properties
# Application info
app.application-name=My Application
app.version=1.0.0

# Database configuration
app.database.url=jdbc:postgresql://db.example.com:5432/myapp
app.database.username=app_user
app.database.password=prod_password
app.database.pool-size=50
app.database.connection-timeout=PT3S
app.database.read-only=false
app.database.options.auto-commit=true
app.database.options.ssl-mode=require

# Server configuration
app.server.host=0.0.0.0
app.server.port=8080
app.server.context-path=/api
app.server.compression.enabled=true
app.server.compression.level=9
app.server.compression.mime-types[0]=application/json
app.server.compression.mime-types[1]=text/html
app.server.compression.mime-types[2]=application/xml
app.server.supported-protocols[0]=HTTP/1.1
app.server.supported-protocols[1]=HTTP/2

# Security configuration
app.security.auth.provider=keycloak
app.security.auth.token-endpoint=https://auth.example.com/token
app.security.auth.token-expiry=PT30M
app.security.auth.scopes[0]=read
app.security.auth.scopes[1]=write
app.security.ssl-enabled=true
app.security.trusted-ips[0]=192.168.1.1

# Cache configuration
app.cache.type=redis
app.cache.max-size=10000
app.cache.expiration=PT5M

# Integration configurations
app.integrations[0].name=payment-service
app.integrations[0].endpoint=https://payments.example.com/api
app.integrations[0].auth-type=OAUTH2
app.integrations[0].headers.content-type=application/json
app.integrations[0].retry.max-attempts=5
app.integrations[0].retry.backoff-delay=PT1S
app.integrations[0].retry.exponential-backoff=true

app.integrations[1].name=notification-service
app.integrations[1].endpoint=https://notifications.example.com/api
app.integrations[1].auth-type=API_KEY
app.integrations[1].headers.x-api-key=prod-api-key-456
app.integrations[1].retry.max-attempts=3
app.integrations[1].retry.backoff-delay=PT500MS
app.integrations[1].retry.exponential-backoff=true

# Feature flags
app.features.new-ui.enabled=true
app.features.new-ui.description=New user interface
app.features.new-ui.allowed-roles[0]=user
app.features.new-ui.allowed-roles[1]=admin
app.features.new-ui.parameters.theme=light
app.features.new-ui.rollout-percentage=100.0

app.features.analytics.enabled=true
app.features.analytics.description=Advanced analytics
app.features.analytics.allowed-roles[0]=admin
app.features.analytics.parameters.track-clicks=true
app.features.analytics.parameters.track-pageviews=true
app.features.analytics.rollout-percentage=100.0

# CORS configuration
app.allowed-origins[0]=https://example.com
app.allowed-origins[1]=https://admin.example.com
```

Here's how you can use this configuration in your application:

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MyService {
    
    private final AppConfig appConfig;
    
    @Autowired
    public MyService(AppConfig appConfig) {
        this.appConfig = appConfig;
    }
    
    public void connectToDatabase() {
        // Access nested properties
        DatabaseConfig dbConfig = appConfig.database();
        System.out.println("Connecting to: " + dbConfig.url());
        System.out.println("With pool size: " + dbConfig.poolSize());
        
        // Access map properties
        Map<String, String> options = dbConfig.options();
        System.out.println("SSL Mode: " + options.get("ssl-mode"));
    }
    
    public boolean isFeatureEnabled(String featureName, String role) {
        // Access map with complex objects
        FeatureFlag feature = appConfig.features().get(featureName);
        if (feature == null || !feature.enabled()) {
            return false;
        }
        
        // Check if user has required role
        return feature.allowedRoles().contains(role);
    }
    
    public void processIntegrations() {
        // Access list of complex objects
        for (IntegrationConfig integration : appConfig.integrations()) {
            System.out.println("Processing integration: " + integration.name());
            System.out.println("Endpoint: " + integration.endpoint());
            
            // Process retry logic
            RetryConfig retry = integration.retry();
            System.out.println("Max attempts: " + retry.maxAttempts());
        }
    }
}
```

To make this work properly with Spring Boot, you'll need to ensure you have the configuration processor dependency:

```xml
<!-- Maven -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

or in Gradle:

```groovy
annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'
```

This more comprehensive example demonstrates:
1. Nested records for hierarchical configuration
2. Collections of primitives (List<String>, Set<String>)
3. Maps with simple values (Map<String, String>)
4. Maps with complex objects (Map<String, FeatureFlag>)
5. Lists of complex objects (List<IntegrationConfig>)
6. Enum values (AuthType)
7. Special types like Duration for time-based properties

This structure provides a type-safe, immutable configuration that can be easily validated and used throughout your application.





---
Powered by [Claude Exporter](https://www.claudexporter.com)