I'll create a Spring Boot standalone (non-web) version of the thread executor.

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.PreDestroy;
import java.util.concurrent.*;
import java.util.ArrayList;
import java.util.List;

@SpringBootApplication
@EnableAsync
public class ThreadExecutorApplication implements CommandLineRunner {
    
    @Autowired
    private AsyncTaskService taskService;
    
    public static void main(String[] args) {
        SpringApplication.run(ThreadExecutorApplication.class, args);
    }
    
    @Override
    public void run(String... args) {
        System.out.println("Starting Thread Executor Demo...");
        
        try {
            // Submit tasks that return results
            List<Future<String>> futures = new ArrayList<>();
            futures.add(taskService.submitTask("Task1", 2000L));
            futures.add(taskService.submitTask("Task2", 1000L));
            futures.add(taskService.submitTask("Task3", 3000L));
            
            // Execute fire-and-forget tasks
            taskService.executeTask("BackgroundTask1");
            taskService.executeTask("BackgroundTask2");
            
            // Print executor stats
            taskService.printExecutorStats();
            
            // Wait for completion of submitted tasks
            System.out.println("\nWaiting for submitted tasks to complete...");
            for (Future<String> future : futures) {
                try {
                    String result = future.get(5, TimeUnit.SECONDS);
                    System.out.println("Result: " + result);
                } catch (TimeoutException e) {
                    System.err.println("Task timed out!");
                    future.cancel(true);
                }
            }
            
            // Print final stats
            taskService.printExecutorStats();
            
        } catch (Exception e) {
            System.err.println("Error executing tasks: " + e.getMessage());
        }
    }
}

@Configuration
@EnableAsync
class ThreadConfig {
    
    @Bean(name = "taskExecutor")
    public ThreadPoolTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(4);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("CustomThread-");
        executor.initialize();
        return executor;
    }
}

@Service
class AsyncTaskService {
    
    @Autowired
    private ThreadPoolTaskExecutor taskExecutor;
    
    @Async("taskExecutor")
    public Future<String> submitTask(String taskName, long sleepTime) {
        System.out.println(String.format("Executing %s on thread %s", 
            taskName, Thread.currentThread().getName()));
        try {
            Thread.sleep(sleepTime);
            return new AsyncResult<>(String.format("Task %s completed", taskName));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return new AsyncResult<>(String.format("Task %s interrupted", taskName));
        }
    }
    
    @Async("taskExecutor")
    public void executeTask(String taskName) {
        System.out.println(String.format("Starting task %s on thread %s", 
            taskName, Thread.currentThread().getName()));
        try {
            // Simulate some work
            Thread.sleep(1000);
            System.out.println(String.format("Finished task %s", taskName));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Task interrupted: " + e.getMessage());
        }
    }
    
    public void printExecutorStats() {
        System.out.println("\nExecutor Statistics:");
        System.out.println("Active Threads: " + taskExecutor.getActiveCount());
        System.out.println("Pool Size: " + taskExecutor.getPoolSize());
        System.out.println("Core Pool Size: " + taskExecutor.getCorePoolSize());
        System.out.println("Max Pool Size: " + taskExecutor.getMaxPoolSize());
        System.out.println("Queue Size: " + taskExecutor.getQueueSize());
    }
    
    @PreDestroy
    public void shutdown() {
        System.out.println("Shutting down executor...");
        taskExecutor.shutdown();
    }
}

```

To use this, you'll need these dependencies in your `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
```

Key features of this Spring Boot version:

1. Uses Spring's dependency injection and configuration
2. Implements CommandLineRunner for standalone execution
3. Uses Spring's @Async annotation for asynchronous execution
4. Proper resource cleanup with @PreDestroy
5. Spring Boot's automatic configuration

The main differences from the previous version:

1. Uses Spring's ThreadPoolTaskExecutor instead of raw ThreadPoolExecutor
2. Configuration is handled through Spring's @Configuration
3. Dependency injection instead of manual instantiation
4. Spring Boot lifecycle management
5. Async execution through Spring's @Async annotation

To run the application:
1. Ensure you have the Spring Boot dependencies
2. Run the main class `ThreadExecutorApplication`

The output will show:
- Task execution on different threads
- Executor statistics
- Task completion results
- Proper shutdown

Would you like me to add any additional Spring-specific features like:
- Property-based configuration
- More sophisticated error handling
- Task scheduling
- Custom thread factory configuration?
