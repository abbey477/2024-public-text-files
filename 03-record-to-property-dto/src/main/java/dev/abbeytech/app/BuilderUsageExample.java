package dev.abbeytech.app;


import org.springframework.stereotype.Component;

import java.util.List;

/**
 * This class demonstrates how to use the Lombok builder with records in Java 17
 */
@Component
public class BuilderUsageExample {

    /**
     * Demonstrates various ways to use record builders
     */
    public void demonstrateBuilders() {
        // Create DatabaseConfig using the builder
        AppConfig.DatabaseConfig dbConfig = AppConfig.DatabaseConfig.builder()
                .url("jdbc:h2:mem:test")
                .username("test")
                .password("test")
                .poolSize(5)
                .timeout(2000L)
                .build();

        // Create SecurityConfig using the builder
        AppConfig.SecurityConfig securityConfig = AppConfig.SecurityConfig.builder()
                .enabled(true)
                .tokenExpiration(1800L)
                .allowedOrigins(List.of("https://test.com"))
                .build();

        // Create the main AppConfig using the builder
        AppConfig appConfig = AppConfig.builder()
                .name("Test Config")
                .description("Test Configuration")
                .version("0.1.0")
                .enabled(true)
                .maxConnections(50)
                .timeout(15.5)
                .environment(AppConfig.Environment.DEVELOPMENT)
                .supportedFormats(List.of("JSON", "YAML"))
                .rates(List.of(1.1, 2.2, 3.3))
                .database(dbConfig)
                .security(securityConfig)
                .build();

        // Get database details using standard methods
        String dbInfo = "Database URL: " + appConfig.database().url() +
                ", Username: " + appConfig.database().username();

        System.out.println("Created config: " + appConfig);
        System.out.println(dbInfo);

        // Extract values using standard methods
        String url = appConfig.database().url();
        String user = appConfig.database().username();
        int size = appConfig.database().poolSize();
        System.out.printf("Connected to %s as %s with connection pool size %d%n", url, user, size);
    }

    /**
     * Shows how to use records as method return types
     */
    public ConfigInfo getConfigSummary(AppConfig config) {
        return new ConfigInfo(
                config.name(),
                config.version(),
                config.environment(),
                config.supportedFormats());
    }

    /**
     * Simple record as a DTO
     */
    public record ConfigInfo(
            String name,
            String version,
            AppConfig.Environment environment,
            List<String> formats) {}
}