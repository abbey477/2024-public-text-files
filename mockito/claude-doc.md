# Using Mockito for Java 17 Maven Application Testing

**Created:** 5/21/2025 17:31  
**Updated:** 5/21/2025 17:32  
**Exported:** 5/21/2025 20:32  

## Prompt:
I have an existing java application,  I need to use mockito for the maven application, show me code snippets with annotation , working on java 17 to run some test with mocks. also note that it's not a spring boot application



## Response:
I'd be happy to show you how to use Mockito for testing your Java 17 Maven application without Spring Boot. Let's go through the essential components.

First, you'll need to add Mockito dependencies to your Maven pom.xml:

```xml
<dependencies>
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.9.2</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito Core -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.3.1</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Mockito JUnit Jupiter -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-junit-jupiter</artifactId>
        <version>5.3.1</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

Now let's look at some code examples using Mockito annotations:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

// Use this extension to enable Mockito annotations
@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    // Mock dependencies
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    // Inject mocks into the class under test
    @InjectMocks
    private UserService userService;
    
    @Test
    void createUser_shouldSaveUserAndSendEmail() {
        // Arrange
        User user = new User("john@example.com", "John Doe");
        when(userRepository.save(any(User.class))).thenReturn(user);
        doNothing().when(emailService).sendWelcomeEmail(any(String.class));
        
        // Act
        User result = userService.createUser("john@example.com", "John Doe");
        
        // Assert
        assertNotNull(result);
        assertEquals("john@example.com", result.getEmail());
        assertEquals("John Doe", result.getName());
        
        // Verify interactions
        verify(userRepository).save(any(User.class));
        verify(emailService).sendWelcomeEmail("john@example.com");
    }
}
```

Here's another example with `@Spy`, which allows partial mocking:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class OrderServiceTest {

    @Mock
    private PaymentGateway paymentGateway;
    
    @Spy
    private List<Order> orders = new ArrayList<>();
    
    @Captor
    private ArgumentCaptor<Double> amountCaptor;
    
    @InjectMocks
    private OrderService orderService;
    
    @Test
    void processOrder_shouldChargeCustomerAndUpdateOrderStatus() {
        // Arrange
        Order order = new Order("12345", 99.99, "PENDING");
        when(paymentGateway.processPayment(anyString(), anyDouble())).thenReturn(true);
        orders.add(order);  // Use the real list behavior
        
        // Act
        boolean result = orderService.processOrder("12345");
        
        // Assert
        assertTrue(result);
        verify(paymentGateway).processPayment(eq("12345"), amountCaptor.capture());
        assertEquals(99.99, amountCaptor.getValue(), 0.01);
        
        // Real method was called on the spy
        verify(orders).add(any(Order.class));
        assertEquals("COMPLETED", order.getStatus());
    }
}
```

For testing private methods or dealing with static methods in Java 17, you can use Mockito's MockedStatic:

```java
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UtilityClassTest {

    @Test
    void testStaticMethod() {
        // Mock static method
        try (MockedStatic<FileUtils> fileUtils = mockStatic(FileUtils.class)) {
            // Stubbing static methods
            fileUtils.when(() -> FileUtils.readFile("config.json"))
                    .thenReturn("{\"enabled\": true}");
            
            // Class under test uses the static method
            ConfigService configService = new ConfigService();
            boolean result = configService.isFeatureEnabled();
            
            // Assertions
            assertTrue(result);
            
            // Verify static method was called
            fileUtils.verify(() -> FileUtils.readFile("config.json"));
        }
    }
}
```

For BDD-style testing with Mockito, you can use the BDDMockito class:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.BDDMockito;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.BDDMockito.*;

@ExtendWith(MockitoExtension.class)
public class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;
    
    @InjectMocks
    private ProductService productService;
    
    @Test
    void givenProductExists_whenGetProductById_thenProductIsReturned() {
        // Given
        Product expected = new Product("1", "Laptop", 999.99);
        given(productRepository.findById("1")).willReturn(expected);
        
        // When
        Product actual = productService.getProductById("1");
        
        // Then
        assertNotNull(actual);
        assertEquals("Laptop", actual.getName());
        assertEquals(999.99, actual.getPrice(), 0.01);
        
        then(productRepository).should().findById("1");
        then(productRepository).shouldHaveNoMoreInteractions();
    }
}
```

Would you like me to explain any of these examples or provide more specific code for your particular use case?





---
Powered by [Claude Exporter](https://www.claudexporter.com)
