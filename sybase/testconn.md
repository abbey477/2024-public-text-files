First, create this Maven pom.xml:

<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>sybase-test</artifactId>
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
        <!-- You'll need to manually add the Sybase JDBC driver to your local Maven repository
             as it's not available in public Maven repositories -->
        <dependency>
            <groupId>com.sybase.jdbc4</groupId>
            <artifactId>jconn4</artifactId>
            <version>16.0</version>
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

spring.datasource.url=jdbc:sybase:Tds:localhost:5000/your_database
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.sybase.jdbc4.jdbc.SybDriver

Create the main application class in src/main/java/com/example/SybaseTestApplication.java:

package com.example;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootApplication
public class SybaseTestApplication implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public static void main(String[] args) {
        SpringApplication.run(SybaseTestApplication.class, args);
    }

    @Override
    public void run(String... args) {
        try {
            // Test the connection by executing a simple query
            String result = jdbcTemplate.queryForObject("SELECT @@version", String.class);
            System.out.println("Successfully connected to Sybase!");
            System.out.println("Sybase Version: " + result);
        } catch (Exception e) {
            System.err.println("Failed to connect to Sybase:");
            e.printStackTrace();
        }
    }
}
