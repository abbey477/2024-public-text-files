# Testing Spring Boot Application with JDBC and @MockBean

I'll update the example to use JDBC for the DAO layer instead of JPA, and show how to use @MockBean in Spring Boot tests. Here's a comprehensive example:

## 1. Entity

```java
public class Book {
    private Long id;
    private String title;
    private String author;
    private String isbn;
    
    // Constructors
    public Book() {}
    
    public Book(Long id, String title, String author, String isbn) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.isbn = isbn;
    }
    
    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
}
```

## 2. DAO Layer (JDBC Implementation)

```java
@Repository
public class BookDao {
    private final JdbcTemplate jdbcTemplate;
    private final RowMapper<Book> bookRowMapper;
    
    @Autowired
    public BookDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.bookRowMapper = (rs, rowNum) -> new Book(
                rs.getLong("id"),
                rs.getString("title"),
                rs.getString("author"),
                rs.getString("isbn")
        );
    }
    
    public List<Book> findAll() {
        return jdbcTemplate.query(
                "SELECT id, title, author, isbn FROM books ORDER BY id",
                bookRowMapper
        );
    }
    
    public Optional<Book> findById(Long id) {
        try {
            Book book = jdbcTemplate.queryForObject(
                    "SELECT id, title, author, isbn FROM books WHERE id = ?",
                    bookRowMapper,
                    id
            );
            return Optional.ofNullable(book);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }
    
    public Optional<Book> findByIsbn(String isbn) {
        try {
            Book book = jdbcTemplate.queryForObject(
                    "SELECT id, title, author, isbn FROM books WHERE isbn = ?",
                    bookRowMapper,
                    isbn
            );
            return Optional.ofNullable(book);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }
    
    public List<Book> findByAuthor(String author) {
        return jdbcTemplate.query(
                "SELECT id, title, author, isbn FROM books WHERE author = ?",
                bookRowMapper,
                author
        );
    }
    
    public Book save(Book book) {
        if (book.getId() == null) {
            // Create new book
            KeyHolder keyHolder = new GeneratedKeyHolder();
            
            jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(
                        "INSERT INTO books (title, author, isbn) VALUES (?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS
                );
                ps.setString(1, book.getTitle());
                ps.setString(2, book.getAuthor());
                ps.setString(3, book.getIsbn());
                return ps;
            }, keyHolder);
            
            book.setId(keyHolder.getKey().longValue());
        } else {
            // Update existing book
            jdbcTemplate.update(
                    "UPDATE books SET title = ?, author = ?, isbn = ? WHERE id = ?",
                    book.getTitle(),
                    book.getAuthor(),
                    book.getIsbn(),
                    book.getId()
            );
        }
        
        return book;
    }
    
    public boolean delete(Long id) {
        int rowsAffected = jdbcTemplate.update("DELETE FROM books WHERE id = ?", id);
        return rowsAffected > 0;
    }
}
```

## 3. Service Layer

```java
@Service
public class BookService {
    private final BookDao bookDao;
    
    @Autowired
    public BookService(BookDao bookDao) {
        this.bookDao = bookDao;
    }
    
    public List<Book> getAllBooks() {
        return bookDao.findAll();
    }
    
    public Book getBookById(Long id) {
        return bookDao.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Book not found with id: " + id));
    }
    
    public Book createBook(Book book) {
        // Check if book with same ISBN already exists
        Optional<Book> existingBook = bookDao.findByIsbn(book.getIsbn());
        if (existingBook.isPresent()) {
            throw new DuplicateResourceException("Book with ISBN " + book.getIsbn() + " already exists");
        }
        return bookDao.save(book);
    }
    
    public Book updateBook(Long id, Book bookDetails) {
        Book book = getBookById(id);
        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setIsbn(bookDetails.getIsbn());
        return bookDao.save(book);
    }
    
    public void deleteBook(Long id) {
        Book book = getBookById(id);
        boolean deleted = bookDao.delete(id);
        if (!deleted) {
            throw new ResourceNotFoundException("Book not found with id: " + id);
        }
    }
    
    public List<Book> getBooksByAuthor(String author) {
        return bookDao.findByAuthor(author);
    }
}
```

## 4. Controller Layer

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

Now, let's implement tests with @MockBean:

## 5. Testing DAO Layer

```java
@SpringBootTest
public class BookDaoTest {
    
    @Autowired
    private BookDao bookDao;
    
    @MockBean
    private JdbcTemplate jdbcTemplate;
    
    @Test
    void shouldFindAllBooks() {
        // Arrange
        List<Book> expectedBooks = Arrays.asList(
                new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344"),
                new Book(2L, "1984", "George Orwell", "978-0451524935")
        );
        
        when(jdbcTemplate.query(anyString(), any(RowMapper.class)))
                .thenReturn(expectedBooks);
        
        // Act
        List<Book> result = bookDao.findAll();
        
        // Assert
        assertEquals(2, result.size());
        assertEquals("The Hobbit", result.get(0).getTitle());
        assertEquals("1984", result.get(1).getTitle());
        
        verify(jdbcTemplate).query(eq("SELECT id, title, author, isbn FROM books ORDER BY id"), 
                any(RowMapper.class));
    }
    
    @Test
    void shouldFindBookById() {
        // Arrange
        Book expectedBook = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(jdbcTemplate.queryForObject(
                anyString(), 
                any(RowMapper.class), 
                eq(1L)))
                .thenReturn(expectedBook);
        
        // Act
        Optional<Book> result = bookDao.findById(1L);
        
        // Assert
        assertTrue(result.isPresent());
        assertEquals("The Hobbit", result.get().getTitle());
        
        verify(jdbcTemplate).queryForObject(
                eq("SELECT id, title, author, isbn FROM books WHERE id = ?"), 
                any(RowMapper.class), 
                eq(1L));
    }
    
    @Test
    void shouldReturnEmptyWhenBookNotFound() {
        // Arrange
        when(jdbcTemplate.queryForObject(
                anyString(), 
                any(RowMapper.class), 
                eq(999L)))
                .thenThrow(new EmptyResultDataAccessException(1));
        
        // Act
        Optional<Book> result = bookDao.findById(999L);
        
        // Assert
        assertFalse(result.isPresent());
        
        verify(jdbcTemplate).queryForObject(
                eq("SELECT id, title, author, isbn FROM books WHERE id = ?"), 
                any(RowMapper.class), 
                eq(999L));
    }
    
    @Test
    void shouldFindBookByIsbn() {
        // Arrange
        Book expectedBook = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(jdbcTemplate.queryForObject(
                anyString(), 
                any(RowMapper.class), 
                eq("978-0261103344")))
                .thenReturn(expectedBook);
        
        // Act
        Optional<Book> result = bookDao.findByIsbn("978-0261103344");
        
        // Assert
        assertTrue(result.isPresent());
        assertEquals("The Hobbit", result.get().getTitle());
        
        verify(jdbcTemplate).queryForObject(
                eq("SELECT id, title, author, isbn FROM books WHERE isbn = ?"), 
                any(RowMapper.class), 
                eq("978-0261103344"));
    }
    
    @Test
    void shouldFindBooksByAuthor() {
        // Arrange
        List<Book> expectedBooks = Arrays.asList(
                new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344"),
                new Book(2L, "The Lord of the Rings", "J.R.R. Tolkien", "978-0261103252")
        );
        
        when(jdbcTemplate.query(
                anyString(), 
                any(RowMapper.class), 
                eq("J.R.R. Tolkien")))
                .thenReturn(expectedBooks);
        
        // Act
        List<Book> result = bookDao.findByAuthor("J.R.R. Tolkien");
        
        // Assert
        assertEquals(2, result.size());
        assertEquals("The Hobbit", result.get(0).getTitle());
        assertEquals("The Lord of the Rings", result.get(1).getTitle());
        
        verify(jdbcTemplate).query(
                eq("SELECT id, title, author, isbn FROM books WHERE author = ?"), 
                any(RowMapper.class), 
                eq("J.R.R. Tolkien"));
    }
    
    @Test
    void shouldSaveNewBook() {
        // Arrange
        Book bookToSave = new Book(null, "New Book", "New Author", "978-1234567890");
        KeyHolder keyHolder = mock(KeyHolder.class);
        when(keyHolder.getKey()).thenReturn(1L);
        
        // Using ArgumentCaptor to capture the PreparedStatementCreator
        ArgumentCaptor<PreparedStatementCreator> pscCaptor = ArgumentCaptor.forClass(PreparedStatementCreator.class);
        
        when(jdbcTemplate.update(pscCaptor.capture(), any(KeyHolder.class))).thenAnswer(invocation -> {
            // Simulate the behavior of keyHolder
            KeyHolder kh = invocation.getArgument(1);
            Map<String, Object> keyMap = new HashMap<>();
            keyMap.put("id", 1L);
            ((KeyHolder)kh).getKeyList().add(keyMap);
            return 1;
        });
        
        // Act
        Book result = bookDao.save(bookToSave);
        
        // Assert
        assertEquals(1L, result.getId());
        assertEquals("New Book", result.getTitle());
        
        verify(jdbcTemplate).update(any(PreparedStatementCreator.class), any(KeyHolder.class));
    }
    
    @Test
    void shouldUpdateExistingBook() {
        // Arrange
        Book bookToUpdate = new Book(1L, "Updated Book", "Updated Author", "978-0987654321");
        
        when(jdbcTemplate.update(
                anyString(), 
                eq("Updated Book"), 
                eq("Updated Author"), 
                eq("978-0987654321"), 
                eq(1L)))
                .thenReturn(1);
        
        // Act
        Book result = bookDao.save(bookToUpdate);
        
        // Assert
        assertEquals(1L, result.getId());
        assertEquals("Updated Book", result.getTitle());
        
        verify(jdbcTemplate).update(
                eq("UPDATE books SET title = ?, author = ?, isbn = ? WHERE id = ?"), 
                eq("Updated Book"), 
                eq("Updated Author"), 
                eq("978-0987654321"), 
                eq(1L));
    }
    
    @Test
    void shouldDeleteBook() {
        // Arrange
        when(jdbcTemplate.update(anyString(), eq(1L))).thenReturn(1);
        
        // Act
        boolean result = bookDao.delete(1L);
        
        // Assert
        assertTrue(result);
        
        verify(jdbcTemplate).update(eq("DELETE FROM books WHERE id = ?"), eq(1L));
    }
    
    @Test
    void shouldReturnFalseWhenDeleteBookNotFound() {
        // Arrange
        when(jdbcTemplate.update(anyString(), eq(999L))).thenReturn(0);
        
        // Act
        boolean result = bookDao.delete(999L);
        
        // Assert
        assertFalse(result);
        
        verify(jdbcTemplate).update(eq("DELETE FROM books WHERE id = ?"), eq(999L));
    }
}
```

## 6. Testing Service Layer with MockBean

```java
@SpringBootTest
public class BookServiceTest {
    
    @MockBean
    private BookDao bookDao;
    
    @Autowired
    private BookService bookService;
    
    @Test
    void whenGetAllBooks_thenReturnAllBooks() {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "1984", "George Orwell", "978-0451524935");
        List<Book> books = Arrays.asList(book1, book2);
        
        when(bookDao.findAll()).thenReturn(books);
        
        // Act
        List<Book> result = bookService.getAllBooks();
        
        // Assert
        assertEquals(2, result.size());
        verify(bookDao, times(1)).findAll();
    }
    
    @Test
    void whenGetBookById_thenReturnBook() {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookDao.findById(1L)).thenReturn(Optional.of(book));
        
        // Act
        Book result = bookService.getBookById(1L);
        
        // Assert
        assertEquals("The Hobbit", result.getTitle());
        verify(bookDao, times(1)).findById(1L);
    }
    
    @Test
    void whenGetBookByNonExistentId_thenThrowException() {
        // Arrange
        when(bookDao.findById(999L)).thenReturn(Optional.empty());
        
        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            bookService.getBookById(999L);
        });
        
        verify(bookDao, times(1)).findById(999L);
    }
    
    @Test
    void whenCreateBook_thenSaveBook() {
        // Arrange
        Book bookToCreate = new Book(null, "New Book", "New Author", "978-1234567890");
        Book savedBook = new Book(1L, "New Book", "New Author", "978-1234567890");
        
        when(bookDao.findByIsbn("978-1234567890")).thenReturn(Optional.empty());
        when(bookDao.save(any(Book.class))).thenReturn(savedBook);
        
        // Act
        Book result = bookService.createBook(bookToCreate);
        
        // Assert
        assertEquals(1L, result.getId());
        assertEquals("New Book", result.getTitle());
        verify(bookDao, times(1)).findByIsbn("978-1234567890");
        verify(bookDao, times(1)).save(bookToCreate);
    }
    
    @Test
    void whenCreateBookWithExistingIsbn_thenThrowException() {
        // Arrange
        Book existingBook = new Book(1L, "Existing Book", "Existing Author", "978-1234567890");
        Book bookToCreate = new Book(null, "New Book", "New Author", "978-1234567890");
        
        when(bookDao.findByIsbn("978-1234567890")).thenReturn(Optional.of(existingBook));
        
        // Act & Assert
        assertThrows(DuplicateResourceException.class, () -> {
            bookService.createBook(bookToCreate);
        });
        
        verify(bookDao, times(1)).findByIsbn("978-1234567890");
        verify(bookDao, never()).save(any(Book.class));
    }
    
    @Test
    void whenUpdateBook_thenReturnUpdatedBook() {
        // Arrange
        Book existingBook = new Book(1L, "Old Title", "Old Author", "978-0261103344");
        Book bookDetails = new Book(null, "Updated Title", "Updated Author", "978-0261103344");
        Book updatedBook = new Book(1L, "Updated Title", "Updated Author", "978-0261103344");
        
        when(bookDao.findById(1L)).thenReturn(Optional.of(existingBook));
        when(bookDao.save(any(Book.class))).thenReturn(updatedBook);
        
        // Act
        Book result = bookService.updateBook(1L, bookDetails);
        
        // Assert
        assertEquals("Updated Title", result.getTitle());
        assertEquals("Updated Author", result.getAuthor());
        verify(bookDao, times(1)).findById(1L);
        verify(bookDao, times(1)).save(any(Book.class));
    }
    
    @Test
    void whenDeleteBook_thenDeleteFromDao() {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookDao.findById(1L)).thenReturn(Optional.of(book));
        when(bookDao.delete(1L)).thenReturn(true);
        
        // Act
        bookService.deleteBook(1L);
        
        // Assert
        verify(bookDao, times(1)).findById(1L);
        verify(bookDao, times(1)).delete(1L);
    }
    
    @Test
    void whenDeleteNonExistentBook_thenThrowException() {
        // Arrange
        Book book = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        
        when(bookDao.findById(1L)).thenReturn(Optional.of(book));
        when(bookDao.delete(1L)).thenReturn(false);
        
        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            bookService.deleteBook(1L);
        });
        
        verify(bookDao, times(1)).findById(1L);
        verify(bookDao, times(1)).delete(1L);
    }
    
    @Test
    void whenGetBooksByAuthor_thenReturnFilteredBooks() {
        // Arrange
        Book book1 = new Book(1L, "The Hobbit", "J.R.R. Tolkien", "978-0261103344");
        Book book2 = new Book(2L, "The Lord of the Rings", "J.R.R. Tolkien", "978-0261103252");
        List<Book> tolkienBooks = Arrays.asList(book1, book2);
        
        when(bookDao.findByAuthor("J.R.R. Tolkien")).thenReturn(tolkienBooks);
        
        // Act
        List<Book> result = bookService.getBooksByAuthor("J.R.R. Tolkien");
        
        // Assert
        assertEquals(2, result.size());
        verify(bookDao, times(1)).findByAuthor("J.R.R. Tolkien");
    }
}
```

## 7. Testing Controller Layer with MockBean

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

## 8. Integration Test with @MockBean for External Dependencies

```java
@SpringBootTest
@AutoConfigureMockMvc
public class BookControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    // Mock only external dependencies (like a payment gateway) but use real DAO and service
    @MockBean
    private ExternalPaymentGateway paymentGateway;
    
    // Use real components in the main flow
    @Autowired
    private BookDao bookDao;
    
    @Autowired
    private BookService bookService;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    // Setup test database
    @BeforeEach
    public void setup() {
        // Clear existing data
        jdbcTemplate.execute("DELETE FROM books");
        
        // Insert test data
        jdbcTemplate.execute("INSERT INTO books (id, title, author, isbn) VALUES " +
                "(1, 'The Hobbit', 'J.R.R. Tolkien', '978-0261103344')");
    }
    
    @Test
    public void shouldGetBookById() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/books/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.title", is("The Hobbit")))
                .andExpect(jsonPath("$.author", is("J.R.R. Tolkien")))
                .andExpect(jsonPath("$.isbn", is("978-0261103344")));
    }
    
    @Test
    public void shouldCreateAndRetrieveBook() throws Exception {
        // Arrange - create book
        Book bookToCreate = new Book(null, "Integration Test Book", "Test Author", "978-9876543210");
        
        // Mock external service if needed
        when(paymentGateway.processPayment(anyDouble())).thenReturn(true);
        
        // Act & Assert - create book
        MvcResult result = mockMvc.perform(post("/api/books")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(bookToCreate)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title", is("Integration Test Book")))
                .andReturn();
        
        // Extract created book from response
        Book createdBook = objectMapper.readValue(
                result.getResponse().getContentAsString(), Book.class);
        
        // Act & Assert - retrieve created book
        mockMvc.perform(get("/api/books/" + create