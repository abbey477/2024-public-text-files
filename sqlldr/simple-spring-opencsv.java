// pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>csv-parser</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>csv-parser</name>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>com.opencsv</groupId>
            <artifactId>opencsv</artifactId>
            <version>5.7.1</version>
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

// src/main/java/com/example/csvparser/CsvParserApplication.java
package com.example.csvparser;

import com.opencsv.CSVParserBuilder;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

@SpringBootApplication
public class CsvParserApplication {

    public static void main(String[] args) {
        SpringApplication.run(CsvParserApplication.class, args);
    }
    
    @Bean
    public CommandLineRunner run() {
        return args -> {
            String filePath = "src/main/resources/data.csv";
            parseCSV(filePath);
        };
    }
    
    private void parseCSV(String filePath) {
        List<String[]> result = new ArrayList<>();
        
        try (CSVReader reader = new CSVReaderBuilder(new FileReader(filePath))
                .withCSVParser(new CSVParserBuilder()
                        .withSeparator('|') // Using pipe as separator
                        .build())
                .withSkipLines(1) // Skip the header row
                .build()) {
            
            String[] line;
            int rowIndex = 1;
            
            while ((line = reader.readNext()) != null) {
                if (line.length > 0) {
                    String data = line[0]; // Get first column
                    System.out.println("[index-" + rowIndex + ", " + data + "]");
                    
                    // If you need to store the result
                    result.add(new String[]{"index-" + rowIndex, data});
                }
                rowIndex++;
            }
            
        } catch (Exception e) {
            System.err.println("Error parsing CSV: " + e.getMessage());
        }
    }
}

// Example CSV file (src/main/resources/data.csv):
/*
value1|extra1|extra2
value2|extra3|extra4
value3|extra5|extra6
*/
