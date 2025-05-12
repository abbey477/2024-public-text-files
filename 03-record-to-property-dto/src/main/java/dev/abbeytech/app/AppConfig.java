package dev.abbeytech.app;

import lombok.Builder;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/**
 * Main configuration record that maps to properties with prefix "app.config"
 * Demonstrates mapping various property types to a Java record
 */
@ConfigurationProperties(prefix = "app.config")
public record AppConfig(
        String name,
        String description,
        String version,
        boolean enabled,
        int maxConnections,
        double timeout,
        Environment environment,
        List<String> supportedFormats,
        List<Double> rates,
        DatabaseConfig database,
        SecurityConfig security) {

    /**
     * Lombok builder for the record
     */
    @Builder
    public AppConfig {}

    /**
     * Environment type enum
     */
    public enum Environment {
        DEVELOPMENT, TESTING, STAGING, PRODUCTION
    }

    /**
     * Nested record for database configuration
     * Maps to properties with prefix "app.config.database"
     */
    public record DatabaseConfig(String url, String username,
            String password, int poolSize, long timeout) {

        @Builder
        public DatabaseConfig {}
    }

    /**
     * Nested record for security configuration
     * Maps to properties with prefix "app.config.security"
     */
    public record SecurityConfig(boolean enabled, long tokenExpiration, List<String> allowedOrigins) {

        @Builder
        public SecurityConfig {}
    }
}