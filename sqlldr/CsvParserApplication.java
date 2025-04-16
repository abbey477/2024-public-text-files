package com.example.csvparser;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
public class CsvParserApplication {

    public static void main(String[] args) {
        SpringApplication.run(CsvParserApplication.class, args);
    }
}

@Component
class CsvParser implements CommandLineRunner {

    @Autowired
    private ResourceLoader resourceLoader;
    
    @Override
    public void run(String... args) throws Exception {
        String csvFileName = "data.csv"; // Default filename
        
        // Override default filename if provided as argument
        if (args.length > 0) {
            csvFileName = args[0];
        }
        
        // Path to file in resources directory
        String resourcePath = "classpath:/" + csvFileName;
        Map<Integer, String> csvMap = parseCSV(resourcePath);
        
        // Print the map for verification
        csvMap.forEach((key, value) -> System.out.println("Index: " + key + ", Value: " + value));
    }
    
    private Map<Integer, String> parseCSV(String resourcePath) {
        Map<Integer, String> resultMap = new HashMap<>();
        
        try {
            Resource resource = resourceLoader.getResource(resourcePath);
            BufferedReader br = new BufferedReader(new InputStreamReader(resource.getInputStream()));
            
            String line;
            int index = 1; // Starting index from 1
            
            while ((line = br.readLine()) != null) {
                resultMap.put(index++, line);
            }
            
            br.close();
            
        } catch (Exception e) {
            System.err.println("Error reading CSV file: " + e.getMessage());
        }
        
        return resultMap;
    }
}
