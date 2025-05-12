# Spring Boot Record Properties Demo (Java 17, Spring Boot 3.4.0)

This project demonstrates how to use Java records with Lombok's `@Builder` annotation to map Spring Boot properties.

## Features

- Using Java records with Spring Boot's `@ConfigurationProperties`
- Lombok `@Builder` support for records
- Mapping different property types:
    - Simple properties (String, boolean, int, double, long)
    - Enum properties
    - List properties
    - Nested object properties

## Project Structure

The project is structured as follows:

```
record-properties-demo/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── recordpropertiesdemo/
│   │   │               ├── AppConfig.java
│   │   │               ├── BuilderUsageExample.java
│   │   │               ├── ConfigController.java
│   │   │               └── RecordPropertiesDemoApplication.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/
│           └── com/
│               └── example/
│                   └── recordpropertiesdemo/
│                       └── RecordPropertiesDemoApplicationTests.java
```

## Key Components

### AppConfig.java

Contains the main record and nested records for configuration:
- Main `AppConfig` record with simple properties, enum, lists, and nested records
- Nested records: `DatabaseConfig` and `SecurityConfig`
- Uses Lombok's `@Builder` annotation for builder pattern

### application.properties

Contains all the property configurations:
- Simple properties (strings, boolean, numbers)
- Enum property
- List properties
- Nested object properties

### ConfigController.java

A REST controller that exposes the configuration:
- `/api/config` - Returns the full configuration
- `/api/config/database` - Returns just the database configuration
- `/api/config/security` - Returns just the security configuration

### BuilderUsageExample.java

Demonstrates how to use the Lombok builder pattern with the records.

## Prerequisites

- Java 17 or higher
- Maven

## Running the Application

```bash
mvn spring-boot:run
```

Then access http://localhost:8080/api/config to see the configuration.

## Building the Application

```bash
mvn clean package
```

## Notes on Implementation

### Constructor Binding

The `@ConstructorBinding` annotation is used to tell Spring Boot to use the record's constructor for binding the properties. This is required when using records with `@ConfigurationProperties`.

### Lombok Builder Support

The `@Builder` annotation from Lombok works with records since Lombok version 1.18.20. It generates a builder that is compatible with the immutable nature of records. In this project, we're using Lombok 1.18.30 which has good support for Java 17 features.

### Spring Boot Configuration

The `@EnableConfigurationProperties(AppConfig.class)` annotation in the main application class enables the configuration properties processing.