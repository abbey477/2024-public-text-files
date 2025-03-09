# Spring Boot Test Mocking with Mockito - Complete Example

I'll provide a comprehensive example showing how to test each layer of a Spring Boot application (Controller, Service, Repository) using Mockito annotations.

## Application Structure

Let's build a complete example for a Book management REST API with the following components:

- Entity: `Book`
- Repository: `BookRepository`
- Service: `BookService`
- Controller: `BookController`

## Entity

```java
@Entity
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String author;
    private String isbn;
    
    // Constructors, getters, setters
    public Book() {}
    
    public Book(Long id, String title, String author, String isbn) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.isbn = isbn;
    }
    
    // Getters and setters
}
```

## Repository

```java
public interface BookRepository extends JpaRepository<Book, Long> {
    List<Book> findByAuthor(String author);
    Optional<Book> findByIsbn(String isbn);
}
```

## Service

```java
@Service
public class BookService {
    private final BookRepository bookRepository;
    
    @Autowired
    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }
    
    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }
    
    public Book getBookById(Long id) {
        return bookRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Book not found with id: " + id));
    }
    
    public Book createBook(Book book) {
        // Check if book with same ISBN already exists
        Optional<Book> existingBook = bookRepository.findByIsbn(book.getIsbn());
        if (existingBook.isPresent()) {
            throw new DuplicateResourceException("Book with ISBN " + book.getIsbn() + " already exists");
        }
        return bookRepository.save(book);
    }
    
    public Book updateBook(Long id, Book bookDetails) {
        Book book = getBookById(id);
        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setIsbn(bookDetails.getIsbn());
        return bookRepository.save(book);
    }
    
    public void deleteBook(Long id) {
        Book book = getBookById(id);
        bookRepository.delete(book);
    }
    
    public List<Book> getBooksByAuthor(String author) {
        return bookRepository.findByAuthor(author);
    }
}
```

## Controller

```java
@RestController
@RequestMapping("/api/books")
public class BookController {
    private final BookService bookService;
    
    @Autowired
    public BookController(BookService bookService) {
        this.bookService = bookService;
    }
    
    @GetMapping
    public ResponseEntity<List<Book>> getAllBooks() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        return ResponseEntity.ok(bookService.getBookById(id));
    }
    
    @PostMapping
    public ResponseEntity<Book> createBook(@Valid @RequestBody Book book) {
        Book createdBook = bookService.createBook(book);
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(createdBook.getId())
                .toUri();
        return ResponseEntity.created(location).body(createdBook);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @Valid @RequestBody Book book) {
        return ResponseEntity.ok(bookService.updateBook(id, book));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/author/{author}")
    public ResponseEntity<List<Book>> getBooksByAuthor(@PathVariable String author) {
        return ResponseEntity.ok(bookService.getBooksByAuthor(author));
    }
}
```

Now, let's test each layer:

## 1. Repository Layer Tests

```java
@DataJpaTest
public class BookRepositoryTest {
    
    @Autowired
    private BookRepository bookRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    public void shouldFindBooksByAuthor() {
        // Arrange
        Book book1 = new Book(null, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(null, "The Lord of the Rings", "J.R.R. Tolkien", "978-0261103252");
        Book book3 = new Book(null, "1984", "George Orwell", "978-0451524935");
        
        entityManager.persist(book1);
        entityManager.persist(book2);
        entityManager.persist(book3);
        entityManager.flush();
        
        // Act
        List<Book> foundBooks = bookRepository.findByAuthor("J.R.R. Tolkien");
        
        // Assert
        assertEquals(2, foundBooks.size());
        assertTrue(foundBooks.stream().anyMatch(book -> book.getTitle().equals("The Hobbit")));
        assertTrue(foundBooks.stream().anyMatch(book -> book.getTitle().equals("The Lord of the Rings")));
    }
    
    @Test
    public void shouldFindBookByIsbn() {
        // Arrange
        Book book = new Book(null, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        entityManager.persist(book);
        entityManager.flush();
        
        // Act
        Optional<Book> found = bookRepository.findByIsbn("978-0261103344");
        
        // Assert
        assertTrue(found.isPresent());
        assertEquals("The Hobbit", found.get().getTitle());
    }
    
    @Test
    public void shouldNotFindBookWithNonExistentIsbn() {
        // Act
        Optional<Book> found = bookRepository.findByIsbn("non-existent-isbn");
        
        // Assert
        assertFalse(found.isPresent());
    }
}
```

## 2. Service Layer Tests

```java
@ExtendWith(MockitoExtension.class)
public class BookServiceTest {
    
    @Mock
    private BookRepository bookRepository;
    
    @InjectMocks
    private BookService bookService;
    
    @Test
    public void whenGetAllBooks_thenReturnAllBooks() {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "1984", "George Orwell", "978-0451524935");
        List<Book> books = Arrays.asList(book1, book2);
        
        when(bookRepository.findAll()).thenReturn(books);
        
        // Act
        List<Book> result = bookService.getAllBooks();
        
        // Assert
        assertEquals(2, result.size());
        verify(bookRepository, times(1)).findAll();
    }
    
    @Test
    public void whenGetBookById_thenReturnBook() {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        
        // Act
        Book result = bookService.getBookById(1L);
        
        // Assert
        assertEquals("The Hobbit", result.getTitle());
        verify(bookRepository, times(1)).findById(1L);
    }
    
    @Test
    public void whenGetBookByNonExistentId_thenThrowException() {
        // Arrange
        when(bookRepository.findById(999L)).thenReturn(Optional.empty());
        
        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            bookService.getBookById(999L);
        });
        
        verify(bookRepository, times(1)).findById(999L);
    }
    
    @Test
    public void whenCreateBook_thenSaveBook() {
        // Arrange
        Book bookToCreate = new Book(null, "New Book", "New Author", "978-1234567890");
        Book savedBook = new Book(1L, "New Book", "New Author", "978-1234567890");
        
        when(bookRepository.findByIsbn("978-1234567890")).thenReturn(Optional.empty());
        when(bookRepository.save(any(Book.class))).thenReturn(savedBook);
        
        // Act
        Book result = bookService.createBook(bookToCreate);
        
        // Assert
        assertEquals(1L, result.getId());
        assertEquals("New Book", result.getTitle());
        verify(bookRepository, times(1)).findByIsbn("978-1234567890");
        verify(bookRepository, times(1)).save(bookToCreate);
    }
    
    @Test
    public void whenCreateBookWithExistingIsbn_thenThrowException() {
        // Arrange
        Book existingBook = new Book(1L, "Existing Book", "Existing Author", "978-1234567890");
        Book bookToCreate = new Book(null, "New Book", "New Author", "978-1234567890");
        
        when(bookRepository.findByIsbn("978-1234567890")).thenReturn(Optional.of(existingBook));
        
        // Act & Assert
        assertThrows(DuplicateResourceException.class, () -> {
            bookService.createBook(bookToCreate);
        });
        
        verify(bookRepository, times(1)).findByIsbn("978-1234567890");
        verify(bookRepository, never()).save(any(Book.class));
    }
    
    @Test
    public void whenUpdateBook_thenReturnUpdatedBook() {
        // Arrange
        Book existingBook = new Book(1L, "Old Title", "Old Author", "978-0261103344");
        Book bookDetails = new Book(null, "Updated Title", "Updated Author", "978-0261103344");
        Book updatedBook = new Book(1L, "Updated Title", "Updated Author", "978-0261103344");
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(existingBook));
        when(bookRepository.save(any(Book.class))).thenReturn(updatedBook);
        
        // Act
        Book result = bookService.updateBook(1L, bookDetails);
        
        // Assert
        assertEquals("Updated Title", result.getTitle());
        assertEquals("Updated Author", result.getAuthor());
        verify(bookRepository, times(1)).findById(1L);
        verify(bookRepository, times(1)).save(existingBook);
    }
    
    @Test
    public void whenDeleteBook_thenDeleteFromRepository() {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        doNothing().when(bookRepository).delete(book);
        
        // Act
        bookService.deleteBook(1L);
        
        // Assert
        verify(bookRepository, times(1)).findById(1L);
        verify(bookRepository, times(1)).delete(book);
    }
    
    @Test
    public void whenGetBooksByAuthor_thenReturnFilteredBooks() {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "The Lord of the Rings", "J.R.R. Tolkien", "978-0261103252");
        List<Book> tolkienBooks = Arrays.asList(book1, book2);
        
        when(bookRepository.findByAuthor("J.R.R. Tolkien")).thenReturn(tolkienBooks);
        
        // Act
        List<Book> result = bookService.getBooksByAuthor("J.R.R. Tolkien");
        
        // Assert
        assertEquals(2, result.size());
        verify(bookRepository, times(1)).findByAuthor("J.R.R. Tolkien");
    }
}
```

## 3. Controller Layer Tests

```java
@WebMvcTest(BookController.class)
public class BookControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private BookService bookService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    public void shouldReturnAllBooks() throws Exception {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "1984", "George Orwell", "978-0451524935");
        List<Book> books = Arrays.asList(book1, book2);
        
        when(bookService.getAllBooks()).thenReturn(books);
        
        // Act & Assert
        mockMvc.perform(get("/api/books")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].id", is(1)))
                .andExpect(jsonPath("$[0].title", is("The Hobbit")))
                .andExpect(jsonPath("$[1].id", is(2)))
                .andExpect(jsonPath("$[1].title", is("1984")));
        
        verify(bookService, times(1)).getAllBooks();
    }
    
    @Test
    public void shouldReturnBookById() throws Exception {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookService.getBookById(1L)).thenReturn(book);
        
        // Act & Assert
        mockMvc.perform(get("/api/books/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("The Hobbit")))
                .andExpect(jsonPath("$.author", is("J.R.R. Tolkien")))
                .andExpect(jsonPath("$.isbn", is("978-0261103344")));
        
        verify(bookService, times(1)).getBookById(1L);
    }
    
    @Test
    public void shouldCreateBook() throws Exception {
        // Arrange
        Book bookToCreate = new Book(null, "New Book", "New Author", "978-1234567890");
        Book createdBook = new Book(1L, "New Book", "New Author", "978-1234567890");
        
        when(bookService.createBook(any(Book.class))).thenReturn(createdBook);
        
        // Act & Assert
        mockMvc.perform(post("/api/books")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(bookToCreate)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("New Book")))
                .andExpect(header().string("Location", containsString("/api/books/1")));
        
        verify(bookService, times(1)).createBook(any(Book.class));
    }
    
    @Test
    public void shouldUpdateBook() throws Exception {
        // Arrange
        Book bookDetails = new Book(null, "Updated Title", "Updated Author", "978-0261103344");
        Book updatedBook = new Book(1L, "Updated Title", "Updated Author", "978-0261103344");
        
        when(bookService.updateBook(eq(1L), any(Book.class))).thenReturn(updatedBook);
        
        // Act & Assert
        mockMvc.perform(put("/api/books/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(bookDetails)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("Updated Title")))
                .andExpect(jsonPath("$.author", is("Updated Author")));
        
        verify(bookService, times(1)).updateBook(eq(1L), any(Book.class));
    }
    
    @Test
    public void shouldDeleteBook() throws Exception {
        // Arrange
        doNothing().when(bookService).deleteBook(1L);
        
        // Act & Assert
        mockMvc.perform(delete("/api/books/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNoContent());
        
        verify(bookService, times(1)).deleteBook(1L);
    }
    
    @Test
    public void shouldReturnBooksByAuthor() throws Exception {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "The Lord of the Rings", "J.R.R. Tolkien", "978-0261103252");
        List<Book> tolkienBooks = Arrays.asList(book1, book2);
        
        when(bookService.getBooksByAuthor("J.R.R. Tolkien")).thenReturn(tolkienBooks);
        
        // Act & Assert
        mockMvc.perform(get("/api/books/author/J.R.R. Tolkien")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].title", is("The Hobbit")))
                .andExpect(jsonPath("$[1].title", is("The Lord of the Rings")));
        
        verify(bookService, times(1)).getBooksByAuthor("J.R.R. Tolkien");
    }
    
    @Test
    public void whenGetBookByNonExistentId_thenReturn404() throws Exception {
        // Arrange
        when(bookService.getBookById(999L)).thenThrow(new ResourceNotFoundException("Book not found with id: 999"));
        
        // Act & Assert
        mockMvc.perform(get("/api/books/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
        
        verify(bookService, times(1)).getBookById(999L);
    }
}
```

## 4. Integration Test Example

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class BookControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private BookRepository bookRepository;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    public void shouldCreateAndRetrieveBook() throws Exception {
        // Arrange - create a book
        Book bookToCreate = new Book(null, "Integration Test Book", "Test Author", "978-9876543210");
        Book savedBook = new Book(1L, "Integration Test Book", "Test Author", "978-9876543210");
        
        when(bookRepository.findByIsbn("978-9876543210")).thenReturn(Optional.empty());
        when(bookRepository.save(any(Book.class))).thenReturn(savedBook);
        when(bookRepository.findById(1L)).thenReturn(Optional.of(savedBook));
        
        // Act & Assert - create the book
        MvcResult result = mockMvc.perform(post("/api/books")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(bookToCreate)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("Integration Test Book")))
                .andReturn();
        
        // Extract created book ID from response
        Book createdBook = objectMapper.readValue(
                result.getResponse().getContentAsString(), Book.class);
        
        // Act & Assert - retrieve the book
        mockMvc.perform(get("/api/books/" + createdBook.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("Integration Test Book")))
                .andExpect(jsonPath("$.author", is("Test Author")))
                .andExpect(jsonPath("$.isbn", is("978-9876543210")));
        
        verify(bookRepository, times(1)).findByIsbn("978-9876543210");
        verify(bookRepository, times(1)).save(any(Book.class));
        verify(bookRepository, times(1)).findById(1L);
    }
}
```

## 5. Testing Exception Handlers

If you have a global exception handler in your application, you can also test it:

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                ex.getMessage(),
                LocalDateTime.now());
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }
    
    @ExceptionHandler(DuplicateResourceException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateResourceException(DuplicateResourceException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.CONFLICT.value(),
                ex.getMessage(),
                LocalDateTime.now());
        return new ResponseEntity<>(error, HttpStatus.CONFLICT);
    }
    
    // Other exception handlers...
}
```

Test for exception handlers:

```java
@WebMvcTest(BookController.class)
public class BookControllerExceptionTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private BookService bookService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    public void whenBookNotFound_thenReturnNotFoundWithErrorDetails() throws Exception {
        // Arrange
        when(bookService.getBookById(999L))
                .thenThrow(new ResourceNotFoundException("Book not found with id: 999"));
        
        // Act & Assert
        mockMvc.perform(get("/api/books/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status", is(404)))
                .andExpect(jsonPath("$.message", is("Book not found with id: 999")))
                .andExpect(jsonPath("$.timestamp").exists());
    }
    
    @Test
    public void whenDuplicateIsbn_thenReturnConflictWithErrorDetails() throws Exception {
        // Arrange
        Book book = new Book(null, "Duplicate Book", "Some Author", "978-1234567890");
        
        when(bookService.createBook(any(Book.class)))
                .thenThrow(new DuplicateResourceException("Book with ISBN 978-1234567890 already exists"));
        
        // Act & Assert
        mockMvc.perform(post("/api/books")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(book)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status", is(409)))
                .andExpect(jsonPath("$.message", is("Book with ISBN 978-1234567890 already exists")))
                .andExpect(jsonPath("$.timestamp").exists());
    }
}
```

These examples cover most common testing scenarios in a Spring Boot application, including CRUD operations, exception handling, and integration testing. You can adapt these patterns to your specific application needs.
