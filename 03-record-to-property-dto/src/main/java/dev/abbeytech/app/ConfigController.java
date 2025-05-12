package dev.abbeytech.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * REST controller that exposes configuration information
 */
@RestController
@RequestMapping("/api/config")
public class ConfigController {

    private final AppConfig appConfig;

    public ConfigController(AppConfig appConfig) {
        this.appConfig = appConfig;
    }

    /**
     * Returns the full configuration
     */
    @GetMapping
    public AppConfig getConfig() {
        return appConfig;
    }

    /**
     * Returns just the database configuration
     */
    @GetMapping("/database")
    public AppConfig.DatabaseConfig getDatabaseConfig() {
        return appConfig.database();
    }

    /**
     * Returns just the security configuration
     */
    @GetMapping("/security")
    public AppConfig.SecurityConfig getSecurityConfig() {
        return appConfig.security();
    }

    /**
     * Returns application status information
     */
    @GetMapping("/status")
    public Map<String, Object> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("name", appConfig.name());
        status.put("version", appConfig.version());
        status.put("environment", appConfig.environment().toString());
        status.put("timestamp", LocalDateTime.now());
        status.put("enabled", appConfig.enabled());

        Map<String, Object> database = new HashMap<>();
        database.put("url", appConfig.database().url());
        database.put("poolSize", appConfig.database().poolSize());
        database.put("timeout", appConfig.database().timeout());

        status.put("database", database);

        return status;
    }

    /**
     * Returns environment-specific information
     */
    @GetMapping("/environment-info")
    public Map<String, Object> getEnvironmentInfo() {
        Map<String, Object> info = new HashMap<>();

        switch (appConfig.environment()) {
            case DEVELOPMENT:
                info.put("type", "development");
                info.put("connectionCount", appConfig.maxConnections());
                break;
            case PRODUCTION:
                info.put("type", "production");
                info.put("databaseUrl", appConfig.database().url());
                info.put("tokenExpiration", appConfig.security().tokenExpiration());
                break;
            case TESTING:
            case STAGING:
                info.put("type", "non-production");
                info.put("message", "Non-production environment");
                info.put("environmentName", appConfig.environment().toString());
                break;
        }

        return info;
    }
}