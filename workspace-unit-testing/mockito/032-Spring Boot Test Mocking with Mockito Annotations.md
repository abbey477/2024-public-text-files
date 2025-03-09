# Spring Boot Unit Testing Guide

I'll provide a comprehensive guide on writing unit tests in Spring Boot applications, focusing on mocking strategies and database operations.

## Different Types of Mocks

- **@Mock**: Creates a mock implementation of a class or interface
- **@MockBean**: Creates a mock bean and adds it to the Spring application context
- **@InjectMocks**: Injects mock dependencies into the class being tested
- **@Autowired**: Used to inject actual Spring beans in integration tests

Let's see these in action with examples.

## Unit Testing a Service Layer

Here's an example of unit testing a service that uses CRUD operations:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    public void testFindAllUsers() {
        // Arrange
        User user1 = new User(1L, "John", "Doe", "john@example.com");
        User user2 = new User(2L, "Jane", "Doe", "jane@example.com");
        List<User> users = Arrays.asList(user1, user2);
        
        when(userRepository.findAll()).thenReturn(users);
        
        // Act
        List<User> result = userService.findAllUsers();
        
        // Assert
        assertEquals(2, result.size());
        verify(userRepository, times(1)).findAll();
    }
    
    @Test
    public void testSaveUser() {
        // Arrange
        User user = new User(null, "John", "Doe", "john@example.com");
        User savedUser = new User(1L, "John", "Doe", "john@example.com");
        
        when(userRepository.save(user)).thenReturn(savedUser);
        
        // Act
        User result = userService.saveUser(user);
        
        // Assert
        assertNotNull(result.getId());
        assertEquals(savedUser.getFirstName(), result.getFirstName());
        verify(userRepository, times(1)).save(user);
    }
    
    @Test
    public void testDeleteUser_UserExists() {
        // Arrange
        Long userId = 1L;
        when(userRepository.existsById(userId)).thenReturn(true);
        doNothing().when(userRepository).deleteById(userId);
        
        // Act
        boolean result = userService.deleteUser(userId);
        
        // Assert
        assertTrue(result);
        verify(userRepository, times(1)).existsById(userId);
        verify(userRepository, times(1)).deleteById(userId);
    }
    
    @Test
    public void testFindUserById_UserNotFound() {
        // Arrange
        Long userId = 999L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // Act & Assert
        assertThrows(UserNotFoundException.class, () -> {
            userService.findUserById(userId);
        });
        
        verify(userRepository, times(1)).findById(userId);
    }
}
```

## Integration Testing with @MockBean and JdbcTemplate

Here's an example of integration testing using Spring's testing framework with JdbcTemplate:

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import java.util.List;

@SpringBootTest
public class UserDaoIntegrationTest {

    @MockBean
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private UserDao userDao;
    
    @Test
    public void testFindAllUsers() {
        // Arrange
        User user1 = new User(1L, "John", "Doe", "john@example.com");
        User user2 = new User(2L, "Jane", "Doe", "jane@example.com");
        List<User> users = Arrays.asList(user1, user2);
        
        when(jdbcTemplate.query(anyString(), any(RowMapper.class)))
            .thenReturn(users);
        
        // Act
        List<User> result = userDao.findAll();
        
        // Assert
        assertEquals(2, result.size());
        verify(jdbcTemplate, times(1)).query(anyString(), any(RowMapper.class));
    }
    
    @Test
    public void testCreateUser() {
        // Arrange
        User user = new User(null, "John", "Doe", "john@example.com");
        when(jdbcTemplate.update(anyString(), anyString(), anyString(), anyString()))
            .thenReturn(1);
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
            .thenReturn(1L);
        
        // Act
        User result = userDao.create(user);
        
        // Assert
        assertNotNull(result.getId());
        assertEquals(1L, result.getId());
        verify(jdbcTemplate, times(1)).update(anyString(), anyString(), anyString(), anyString());
    }
}
```

## Exception Handling Tests

Testing exception handling is crucial for robust applications:

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
public class UserDaoExceptionTest {

    @Mock
    private JdbcTemplate jdbcTemplate;
    
    @InjectMocks
    private UserDaoImpl userDao;
    
    @Test
    public void testFindById_ThrowsEmptyResultException() {
        // Arrange
        Long userId = 999L;
        when(jdbcTemplate.queryForObject(anyString(), any(RowMapper.class), eq(userId)))
            .thenThrow(new EmptyResultDataAccessException(1));
        
        // Act & Assert
        assertThrows(UserNotFoundException.class, () -> {
            userDao.findById(userId);
        });
        
        verify(jdbcTemplate, times(1)).queryForObject(anyString(), any(RowMapper.class), eq(userId));
    }
    
    @Test
    public void testUpdate_ThrowsDataAccessException() {
        // Arrange
        User user = new User(1L, "John", "Doe", "john@example.com");
        when(jdbcTemplate.update(anyString(), anyString(), anyString(), anyString(), eq(1L)))
            .thenThrow(new DataAccessException("Database error") {});
        
        // Act & Assert
        assertThrows(DatabaseOperationException.class, () -> {
            userDao.update(user);
        });
        
        verify(jdbcTemplate, times(1)).update(anyString(), anyString(), anyString(), anyString(), eq(1L));
    }
}
```

## Complete Example with Entity and Repository

Here are the supporting classes referenced in the tests above:

```java
// Entity
public class User {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    
    // Constructor, getters, setters
}

// Exception classes
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }
}

public class DatabaseOperationException extends RuntimeException {
    public DatabaseOperationException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Repository interface
public interface UserRepository {
    List<User> findAll();
    Optional<User> findById(Long id);
    User save(User user);
    void deleteById(Long id);
    boolean existsById(Long id);
}

// Service interface and implementation
public interface UserService {
    List<User> findAllUsers();
    User findUserById(Long id);
    User saveUser(User user);
    boolean deleteUser(Long id);
}

public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    
    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    @Override
    public List<User> findAllUsers() {
        return userRepository.findAll();
    }
    
    @Override
    public User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
    }
    
    @Override
    public User saveUser(User user) {
        return userRepository.save(user);
    }
    
    @Override
    public boolean deleteUser(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
}

// DAO implementation using JdbcTemplate
public class UserDaoImpl implements UserDao {
    private final JdbcTemplate jdbcTemplate;
    
    public UserDaoImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }
    
    @Override
    public List<User> findAll() {
        String sql = "SELECT id, first_name, last_name, email FROM users";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            User user = new User();
            user.setId(rs.getLong("id"));
            user.setFirstName(rs.getString("first_name"));
            user.setLastName(rs.getString("last_name"));
            user.setEmail(rs.getString("email"));
            return user;
        });
    }
    
    @Override
    public User findById(Long id) {
        try {
            String sql = "SELECT id, first_name, last_name, email FROM users WHERE id = ?";
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setEmail(rs.getString("email"));
                return user;
            }, id);
        } catch (EmptyResultDataAccessException e) {
            throw new UserNotFoundException("User not found with id: " + id);
        }
    }
    
    @Override
    public User create(User user) {
        String sql = "INSERT INTO users (first_name, last_name, email) VALUES (?, ?, ?)";
        jdbcTemplate.update(sql, user.getFirstName(), user.getLastName(), user.getEmail());
        
        // Get the generated ID
        Long id = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class);
        user.setId(id);
        return user;
    }
    
    @Override
    public User update(User user) {
        try {
            String sql = "UPDATE users SET first_name = ?, last_name = ?, email = ? WHERE id = ?";
            int rowsAffected = jdbcTemplate.update(sql, 
                user.getFirstName(), 
                user.getLastName(), 
                user.getEmail(), 
                user.getId());
                
            if (rowsAffected == 0) {
                throw new UserNotFoundException("User not found with id: " + user.getId());
            }
            
            return user;
        } catch (DataAccessException e) {
            throw new DatabaseOperationException("Error updating user: " + e.getMessage(), e);
        }
    }
}
```

Would you like me to explain any specific part of these examples in more detail?