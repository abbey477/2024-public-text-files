# Combining @MockBean and @InjectMocks in Spring Boot Tests

Yes, you can combine `@MockBean` and `@InjectMocks` in the same Spring Boot project, but typically not within the same test class due to their different purposes and contexts. Let me explain why and how you might use them together.

## Different Test Classes in the Same Project

The most common approach is to use them in different test classes within the same project:

1. **Unit Test Classes**: Use `@Mock` and `@InjectMocks` for focused unit tests
2. **Integration Test Classes**: Use `@MockBean` and `@Autowired` for integration tests

## Why They're Usually Not Combined in a Single Test Class

The primary reason is that they serve different testing approaches:

- `@InjectMocks` is for pure unit tests without Spring context
- `@MockBean` is for Spring-aware tests that load an application context

## Possible but Unusual Combination

While not common, you can technically combine them in a specific scenario:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@SpringBootTest
@ExtendWith(SpringExtension.class)
public class CombinedTest {

    // Spring-managed mocks - these will be in the application context
    @MockBean
    private ExternalService externalService;
    
    @MockBean
    private DatabaseRepository databaseRepository;
    
    // This is a manually created instance that Mockito will inject mocks into
    // Note: This service is NOT managed by Spring in this test
    @InjectMocks
    private ServiceUnderTest serviceUnderTest;
    
    @Test
    public void testServiceWithMockedDependencies() {
        // Test implementation
    }
}
```

In this unusual case:
- The `@MockBeans` will be created and placed in the Spring context
- The `@InjectMocks` object is created directly by Mockito and NOT managed by Spring
- Mockito would try to inject fields that match the type of the `@MockBean` objects, but they won't be the same instances that Spring created

## Better Approach: Testing Hierarchy

A more maintainable approach is to organize your tests into a hierarchy:

```java
// Base unit tests with @Mock and @InjectMocks
@ExtendWith(MockitoExtension.class)
public class UserServiceUnitTest {
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    // Unit tests
}

// Integration tests with @MockBean and @Autowired
@SpringBootTest
public class UserServiceIntegrationTest {
    @MockBean
    private EmailService emailService; // Mock external dependency
    
    @Autowired
    private UserService userService; // Real service with mocked dependencies
    
    @Autowired
    private UserRepository userRepository; // Real repository
    
    // Integration tests
}
```

## Practical Example of a Combined Approach in Different Classes

Here's a practical example showing how you might organize tests in a project:

```java
// Entity and Repositories
public class User {
    private Long id;
    private String email;
    // ... other fields, getters, setters
}

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}

// Service Layer
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    @Autowired
    public UserServiceImpl(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
    
    @Override
    public User registerUser(User user) {
        // Check if user exists
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new UserAlreadyExistsException();
        }
        
        // Save user
        User savedUser = userRepository.save(user);
        
        // Send welcome email
        emailService.sendWelcomeEmail(savedUser);
        
        return savedUser;
    }
}

// Unit Test - focuses on logic only
@ExtendWith(MockitoExtension.class)
public class UserServiceUnitTest {
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    public void registerUser_newUser_shouldSaveAndSendEmail() {
        // Arrange
        User user = new User();
        user.setEmail("test@example.com");
        
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.empty());
        when(userRepository.save(user)).thenReturn(user);
        
        // Act
        User result = userService.registerUser(user);
        
        // Assert
        verify(userRepository).save(user);
        verify(emailService).sendWelcomeEmail(user);
        assertEquals(user, result);
    }
}

// Integration Test - tests actual Spring components together
@SpringBootTest
public class UserServiceIntegrationTest {
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @MockBean
    private EmailService emailService; // Mock external service
    
    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }
    
    @Test
    public void registerUser_shouldSaveToDatabase() {
        // Arrange
        User user = new User();
        user.setEmail("test@example.com");
        
        // Act
        User savedUser = userService.registerUser(user);
        
        // Assert
        assertNotNull(savedUser.getId());
        verify(emailService).sendWelcomeEmail(any(User.class));
        
        // Verify user is in database
        Optional<User> fromDb = userRepository.findByEmail("test@example.com");
        assertTrue(fromDb.isPresent());
    }
}
```

This approach gives you the best of both worlds: fast unit tests with `@InjectMocks` and comprehensive integration tests with `@MockBean` when needed.