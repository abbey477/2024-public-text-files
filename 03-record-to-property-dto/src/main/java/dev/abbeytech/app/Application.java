package dev.abbeytech.app;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Main Spring Boot application class for record properties demo
 */
@SpringBootApplication
@EnableConfigurationProperties(AppConfig.class)
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    /**
     * Demonstrates using CommandLineRunner with AppConfig record
     */
    @Bean
    public CommandLineRunner commandLineRunner(ApplicationContext ctx, AppConfig appConfig) {
        return args -> {
            System.out.println("Spring Boot application started with record configuration");

            // Using standard switch with enums
            String environmentInfo;
            switch (appConfig.environment()) {
                case DEVELOPMENT:
                    environmentInfo = "Running in development mode";
                    break;
                case TESTING:
                    environmentInfo = "Running in testing mode";
                    break;
                case STAGING:
                    environmentInfo = "Running in staging mode";
                    break;
                case PRODUCTION:
                    environmentInfo = "Running in production mode";
                    break;
                default:
                    environmentInfo = "Unknown environment";
            }

            System.out.println(environmentInfo);

            // Accessing properties using standard record accessors
            System.out.println("Application: " + appConfig.name() + " v" + appConfig.version());
            System.out.println("Status: " + (appConfig.enabled() ? "Enabled" : "Disabled"));
            System.out.println("Database URL: " + appConfig.database().url());

            // Using Java 17 collection methods
            List<String> formats = appConfig.supportedFormats();
            System.out.println("Supported formats: " + String.join(", ", formats));

            // Reversing a list in Java 17
            List<String> reversedFormats = new ArrayList<>(formats);
            Collections.reverse(reversedFormats);
            System.out.println("Supported formats (reversed): " + String.join(", ", reversedFormats));

            // Creating a simple record for data transfer
            record AppSummary(String name, String version, int connectionCount) {}
            var summary = new AppSummary(appConfig.name(), appConfig.version(), appConfig.maxConnections());

            System.out.println("Application summary: " + summary);
        };
    }
}