// AsyncConfig.java
package com.example.async;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(4);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("AsyncThread-");
        executor.initialize();
        return executor;
    }
}

// AsyncService.java
package com.example.async;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class AsyncService {

    @Async("taskExecutor")
    public CompletableFuture<ResponseObject> processAsyncTask(String input) {
        ResponseObject response = new ResponseObject();
        
        try {
            // Simulate some time-consuming task
            Thread.sleep(2000);
            
            response.setId(1L);
            response.setMessage("Processed: " + input);
            response.setStatus("COMPLETED");
            
            System.out.println("Async task processed by thread: " + 
                Thread.currentThread().getName());
                
        } catch (InterruptedException e) {
            response.setStatus("FAILED");
            response.setMessage("Error: " + e.getMessage());
        }
        
        return CompletableFuture.completedFuture(response);
    }
}

// ResponseObject.java
package com.example.async;

public class ResponseObject {
    private Long id;
    private String message;
    private String status;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}

// AsyncController.java
package com.example.async;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

@RestController
public class AsyncController {

    @Autowired
    private AsyncService asyncService;

    @GetMapping("/async-process")
    public ResponseObject processAsync(@RequestParam String input) 
            throws InterruptedException, ExecutionException {
        
        System.out.println("Request received on thread: " + 
            Thread.currentThread().getName());
            
        CompletableFuture<ResponseObject> future = asyncService.processAsyncTask(input);
        
        // Wait for the result and return it
        return future.get();
    }
}

// Application.java
package com.example.async;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

// application.properties
server.port=8080
