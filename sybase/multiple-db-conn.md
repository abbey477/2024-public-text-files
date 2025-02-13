First, create pom.xml:

<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>multi-db-demo</artifactId>
    <version>1.0-SNAPSHOT</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.5</version>
    </parent>

    <properties>
        <java.version>11</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <!-- Add your database drivers here -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.27</version>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <version>42.3.1</version>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>

Create application.properties in src/main/resources:

# First Database Configuration (MySQL)
db1.datasource.url=jdbc:mysql://localhost:3306/db1
db1.datasource.username=user1
db1.datasource.password=pass1
db1.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# Second Database Configuration (PostgreSQL)
db2.datasource.url=jdbc:postgresql://localhost:5432/db2
db2.datasource.username=user2
db2.datasource.password=pass2
db2.datasource.driver-class-name=org.postgresql.Driver

Create the database configuration classes in src/main/java/com/example/config:

DB1Config.java:

package com.example.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
public class DB1Config {

    @Primary
    @Bean(name = "db1DataSource")
    @ConfigurationProperties(prefix = "db1.datasource")
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }

    @Primary
    @Bean(name = "db1JdbcTemplate")
    public JdbcTemplate jdbcTemplate(@Qualifier("db1DataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}

DB2Config.java:

package com.example.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
public class DB2Config {

    @Bean(name = "db2DataSource")
    @ConfigurationProperties(prefix = "db2.datasource")
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean(name = "db2JdbcTemplate")
    public JdbcTemplate jdbcTemplate(@Qualifier("db2DataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}

Create a service class to demonstrate database operations in src/main/java/com/example/service:

DatabaseService.java:

package com.example.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class DatabaseService {

    private final JdbcTemplate db1JdbcTemplate;
    private final JdbcTemplate db2JdbcTemplate;

    public DatabaseService(
            @Qualifier("db1JdbcTemplate") JdbcTemplate db1JdbcTemplate,
            @Qualifier("db2JdbcTemplate") JdbcTemplate db2JdbcTemplate) {
        this.db1JdbcTemplate = db1JdbcTemplate;
        this.db2JdbcTemplate = db2JdbcTemplate;
    }

    public void testConnections() {
        // Test first database connection
        try {
            String db1Version = db1JdbcTemplate.queryForObject("SELECT version()", String.class);
            System.out.println("DB1 (MySQL) connected successfully!");
            System.out.println("DB1 Version: " + db1Version);
        } catch (Exception e) {
            System.err.println("Failed to connect to DB1 (MySQL):");
            e.printStackTrace();
        }

        // Test second database connection
        try {
            String db2Version = db2JdbcTemplate.queryForObject("SELECT version()", String.class);
            System.out.println("DB2 (PostgreSQL) connected successfully!");
            System.out.println("DB2 Version: " + db2Version);
        } catch (Exception e) {
            System.err.println("Failed to connect to DB2 (PostgreSQL):");
            e.printStackTrace();
        }
    }
}

Create the main application class in src/main/java/com/example:

MultiDbApplication.java:

package com.example;

import com.example.service.DatabaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MultiDbApplication implements CommandLineRunner {

    @Autowired
    private DatabaseService databaseService;

    public static void main(String[] args) {
        SpringApplication.run(MultiDbApplication.class, args);
    }

    @Override
    public void run(String... args) {
        databaseService.testConnections();
    }
}
