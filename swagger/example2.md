// === MAIN APPLICATION CONFIGURATION ===

// 1. Maven dependency (pom.xml)
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>

// 2. Gradle dependency (build.gradle)
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0'

// 3. Main OpenAPI Configuration Class
package com.example.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenAPIConfig {

    @Value("${spring.application.name:API Application}")
    private String applicationName;

    @Value("${spring.application.description:Spring Boot API Application}")
    private String applicationDescription;

    @Value("${spring.application.version:1.0.0}")
    private String applicationVersion;

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(apiInfo())
                .servers(apiServers())
                .components(apiComponents())
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"));
    }

    private Info apiInfo() {
        return new Info()
                .title(applicationName)
                .description(applicationDescription)
                .version(applicationVersion)
                .contact(new Contact()
                        .name("API Support")
                        .url("https://example.com/support")
                        .email("support@example.com"))
                .license(new License()
                        .name("Apache 2.0")
                        .url("https://www.apache.org/licenses/LICENSE-2.0.html"));
    }

    private List<Server> apiServers() {
        Server productionServer = new Server()
                .url("https://api.example.com")
                .description("Production Server");

        Server stagingServer = new Server()
                .url("https://staging.example.com")
                .description("Staging Server");

        Server localServer = new Server()
                .url("http://localhost:8080")
                .description("Local Development Server");

        return List.of(productionServer, stagingServer, localServer);
    }

    private Components apiComponents() {
        return new Components()
                .addSecuritySchemes("bearerAuth", new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .description("JWT Authentication. Enter the Bearer token in the format 'Bearer {token}'"));
    }
}

// 4. Application Properties (application.properties or application.yml)
# application.properties
spring.application.name=My API Application
spring.application.description=A Spring Boot API with OpenAPI Documentation
spring.application.version=1.0.0

# OpenAPI Configuration
springdoc.api-docs.enabled=true
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.api-docs.path=/v3/api-docs
springdoc.swagger-ui.operationsSorter=method
springdoc.swagger-ui.tagsSorter=alpha
springdoc.swagger-ui.tryItOutEnabled=true
springdoc.swagger-ui.filter=true
springdoc.packages-to-scan=com.example.controller
springdoc.paths-to-match=/api/**,/management/**,/v1/**

# If you have actuator
management.endpoints.web.exposure.include=openapi,swagger-ui
springdoc.show-actuator=true

// 5. Configuration for CORS with OpenAPI
package com.example.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/v3/api-docs/**")
                .allowedOrigins("*")
                .allowedMethods("GET")
                .maxAge(3600);
        
        registry.addMapping("/swagger-ui/**")
                .allowedOrigins("*")
                .allowedMethods("GET")
                .maxAge(3600);
        
        // Your API endpoints CORS configuration
        registry.addMapping("/api/**")
                .allowedOrigins("https://example.com", "http://localhost:3000")
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}

// 6. Example Controller with OpenAPI Annotations
package com.example.controller;

import com.example.model.Product;
import com.example.service.ProductService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@Tag(name = "Product Management", description = "Endpoints for managing products")
@SecurityRequirement(name = "bearerAuth")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    @Operation(
            summary = "Get all products",
            description = "Retrieves a list of all available products",
            tags = {"Product Management"}
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "List of products retrieved successfully",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = Product.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Forbidden",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Internal server error",
                    content = @Content
            )
    })
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(productService.findAllProducts());
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Get product by ID",
            description = "Retrieves a product based on the provided ID",
            tags = {"Product Management"}
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Product found",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = Product.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Product not found",
                    content = @Content
            )
    })
    public ResponseEntity<Product> getProductById(
            @Parameter(description = "ID of the product to retrieve")
            @PathVariable Long id) {
        return productService.findProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @Operation(
            summary = "Create a new product",
            description = "Creates a new product based on the provided data",
            tags = {"Product Management"}
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Product created successfully",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = Product.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input data",
                    content = @Content
            )
    })
    public ResponseEntity<Product> createProduct(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Product data to create",
                    required = true,
                    content = @Content(schema = @Schema(implementation = Product.class))
            )
            @RequestBody Product product) {
        return new ResponseEntity<>(productService.saveProduct(product), HttpStatus.CREATED);
    }

    // Additional endpoints for update and delete operations would follow the same pattern
}

// 7. Model class with OpenAPI annotations
package com.example.model;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Schema(description = "Product information")
public class Product {

    @Schema(description = "Unique identifier of the product", example = "1")
    private Long id;

    @Schema(description = "Name of the product", example = "Smartphone X1", required = true)
    private String name;

    @Schema(description = "Detailed description of the product", example = "Latest smartphone model with advanced features")
    private String description;

    @Schema(description = "Product category", example = "Electronics")
    private String category;

    @Schema(description = "Product price", example = "999.99")
    private BigDecimal price;

    @Schema(description = "Available quantity in stock", example = "50")
    private Integer stockQuantity;

    @Schema(description = "Date and time when the product was created", example = "2023-01-01T12:00:00")
    private LocalDateTime createdAt;

    @Schema(description = "Date and time when the product was last updated", example = "2023-01-10T15:30:00")
    private LocalDateTime updatedAt;

    // Getters, setters, constructors, etc.
}

// === TEST CONFIGURATION ===

// 1. Test-specific OpenAPI Configuration
package com.example.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.util.List;

@Configuration
@Profile("test")
public class TestOpenAPIConfig {

    @Bean
    public OpenAPI testOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Test API Documentation")
                        .description("API Documentation for testing purposes")
                        .version("1.0.0"))
                .servers(List.of(new Server()
                        .url("http://localhost:8080")
                        .description("Test server")));
    }
}

// 2. Test-specific application properties (application-test.properties)
# application-test.properties
spring.application.name=Test API
spring.application.description=API Application in Test Mode
spring.application.version=1.0.0-TEST

# OpenAPI Test Configuration
springdoc.api-docs.enabled=true
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.api-docs.path=/v3/api-docs
springdoc.packages-to-scan=com.example.controller
springdoc.paths-to-match=/api/**

# 3. Test for OpenAPI Documentation
package com.example.test;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.hamcrest.Matchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class OpenAPIDocumentationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void apiDocumentationEndpointShouldBeAvailable() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    public void swaggerUiEndpointShouldBeAvailable() throws Exception {
        mockMvc.perform(get("/swagger-ui.html"))
                .andExpect(status().isOk());
    }

    @Test
    public void apiDocumentationShouldContainCorrectInfo() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.info.title", is("Test API")))
                .andExpect(jsonPath("$.info.version", is("1.0.0-TEST")));
    }

    @Test
    public void apiDocumentationShouldContainProductEndpoints() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paths./api/products", notNullValue()))
                .andExpect(jsonPath("$.paths./api/products.get", notNullValue()))
                .andExpect(jsonPath("$.paths./api/products.post", notNullValue()))
                .andExpect(jsonPath("$.paths./api/products/{id}.get", notNullValue()));
    }
}

// 4. Controller Test with OpenAPI Validation
package com.example.test;

import com.example.controller.ProductController;
import com.example.model.Product;
import com.example.service.ProductService;
import com.example.config.TestOpenAPIConfig;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.hamcrest.Matchers.*;

@WebMvcTest(ProductController.class)
@Import(TestOpenAPIConfig.class)
@ActiveProfiles("test")
public class ProductControllerDocumentationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ProductService productService;

    @Test
    public void productEndpointsShouldBeDocumented() throws Exception {
        // Setup mock data
        Product product1 = new Product();
        product1.setId(1L);
        product1.setName("Test Product");
        
        when(productService.findAllProducts()).thenReturn(Arrays.asList(product1));
        when(productService.findProductById(1L)).thenReturn(Optional.of(product1));

        // Test API docs contain product endpoints
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paths./api/products", notNullValue()))
                .andExpect(jsonPath("$.paths./api/products.get.summary", is("Get all products")))
                .andExpect(jsonPath("$.paths./api/products/{id}.get.summary", is("Get product by ID")));
        
        // Test actual endpoints work
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
                
        mockMvc.perform(get("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }
}

// 5. Spring Boot Main Application Class
package com.example;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@OpenAPIDefinition(info = @Info(
        title = "${spring.application.name}",
        version = "${spring.application.version}",
        description = "${spring.application.description}"
))
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT",
        in = SecuritySchemeIn.HEADER
)
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
