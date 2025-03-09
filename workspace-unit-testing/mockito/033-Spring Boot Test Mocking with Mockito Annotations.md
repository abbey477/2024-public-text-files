# Spring Boot Test Mocking with Mockito Annotations

Mockito provides a set of annotations that make mocking dependencies in Spring Boot tests more straightforward. Here's a comprehensive guide to using these annotations effectively:

## Key Mockito Annotations

1. **@Mock** - Creates a mock instance of a class or interface
2. **@InjectMocks** - Injects mock fields into the tested object automatically
3. **@Spy** - Creates a real object but allows spying or partial mocking
4. **@MockBean** - Spring-specific annotation that adds mocks to the Spring application context
5. **@SpyBean** - Spring-specific annotation that adds spies to the Spring application context
6. **@Captor** - Captures argument values for further assertions

## Basic Test Setup

```java
@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldReturnUserById() {
        // Arrange
        User expectedUser = new User(1L, "John");
        when(userRepository.findById(1L)).thenReturn(Optional.of(expectedUser));
        
        // Act
        User actualUser = userService.getUserById(1L);
        
        // Assert
        assertEquals(expectedUser, actualUser);
        verify(userRepository).findById(1L);
    }
}
```

## Spring Boot Integration Testing

```java
@SpringBootTest
public class UserControllerIntegrationTest {

    @MockBean
    private UserService userService;
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldReturnUserById() throws Exception {
        // Arrange
        User user = new User(1L, "John");
        when(userService.getUserById(1L)).thenReturn(user);
        
        // Act & Assert
        mockMvc.perform(get("/api/users/1"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.id").value(1))
               .andExpect(jsonPath("$.name").value("John"));
    }
}
```

## Using @Spy vs @Mock

```java
@ExtendWith(MockitoExtension.class)
public class CalculatorServiceTest {

    @Mock
    private ExternalApi mockApi;
    
    @Spy
    private Calculator calculatorSpy = new Calculator();
    
    @InjectMocks
    private CalculatorService calculatorService;
    
    @Test
    void shouldUseRealMethodsWithSpy() {
        // Real method will be called on spy
        assertEquals(4, calculatorSpy.add(2, 2));
        
        // But we can still stub when needed
        doReturn(10).when(calculatorSpy).add(4, 4);
        assertEquals(10, calculatorSpy.add(4, 4));
    }
}
```

## Argument Capturing

```java
@ExtendWith(MockitoExtension.class)
public class NotificationServiceTest {

    @Mock
    private EmailSender emailSender;
    
    @InjectMocks
    private NotificationService notificationService;
    
    @Captor
    private ArgumentCaptor<EmailMessage> emailCaptor;
    
    @Test
    void shouldSendWelcomeEmail() {
        // Act
        notificationService.sendWelcomeMessage("john@example.com", "John");
        
        // Capture and verify
        verify(emailSender).send(emailCaptor.capture());
        
        EmailMessage capturedEmail = emailCaptor.getValue();
        assertEquals("john@example.com", capturedEmail.getRecipient());
        assertTrue(capturedEmail.getBody().contains("Welcome John"));
    }
}
```

## Best Practices

1. **Use @ExtendWith(MockitoExtension.class)** for plain JUnit tests
2. **Use @MockBean/@SpyBean** for Spring context integration tests
3. **Be specific with mocking** - only mock what you need
4. **Verify interactions** with verify() to ensure mocks are used correctly
5. **Reset mocks between tests** if necessary with @BeforeEach or reset()
6. **Use strict stubbing** with Mockito.STRICT_STUBS to catch unused stubs

Would you like me to elaborate on any specific aspect of Mockito annotations in Spring Boot testing?