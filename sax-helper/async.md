
I'll help you create a Spring Boot example that demonstrates asynchronous processing using @Async annotation with a thread pool and returning an Object.



I've created a complete Spring Boot application that demonstrates asynchronous processing using @Async annotation. Here's a breakdown of the key components:

1. **AsyncConfig**: Configures the thread pool executor with:
   - Core pool size: 2 threads
   - Max pool size: 4 threads
   - Queue capacity: 100 tasks
   - Custom thread name prefix for easy identification

2. **AsyncService**: Contains the asynchronous business logic:
   - Uses @Async annotation with the custom executor
   - Returns CompletableFuture for non-blocking operations
   - Simulates a time-consuming task with Thread.sleep()
   - Returns a custom ResponseObject

3. **ResponseObject**: A simple POJO to hold the response data

4. **AsyncController**: REST controller to handle incoming requests:
   - Exposes an endpoint at `/async-process`
   - Demonstrates how to work with CompletableFuture
   - Shows thread information for debugging

To test the application:

1. Start the Spring Boot application
2. Make a GET request to: `http://localhost:8080/async-process?input=test`

You'll notice that:
- The initial request is handled by the main thread
- The actual processing happens in a separate thread from the pool (AsyncThread-X)
- The response includes the processed data

The thread pool configuration can be adjusted based on your needs by modifying the values in AsyncConfig.

Would you like me to explain any particular part in more detail or make any modifications to the code?


==============================================================================

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
