# Adding Swagger to Spring Boot 3 with Java 17

Spring Boot 3 uses SpringDoc OpenAPI instead of SpringFox Swagger since the latter isn't compatible with newer Spring versions. Here's how to add Swagger documentation to your Spring Boot 3 application:

## 1. Add Maven Dependencies

First, add the SpringDoc OpenAPI dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

## 2. Configure OpenAPI in application.properties/yml

Add these properties to your `application.properties`:

```properties
# Swagger UI path
springdoc.swagger-ui.path=/swagger-ui.html
# API docs path
springdoc.api-docs.path=/api-docs
# Enable or disable API docs
springdoc.api-docs.enabled=true
# Enable or disable Swagger UI
springdoc.swagger-ui.enabled=true
# Packages to include
springdoc.packagesToScan=com.example.controller
# Paths to include
springdoc.pathsToMatch=/api/**
```

Or in `application.yml`:

```yaml
springdoc:
  api-docs:
    enabled: true
    path: /api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
  packagesToScan: com.example.controller
  pathsToMatch: /api/**
```

## 3. Create OpenAPI Configuration Class

Create a configuration class to customize the OpenAPI documentation:

```java
package com.example.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("My Application API")
                        .version("1.0")
                        .description("This is a sample Spring Boot REST API with OpenAPI documentation")
                        .termsOfService("https://example.com/terms")
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0"))
                        .contact(new Contact()
                                .name("API Support")
                                .url("https://example.com")
                                .email("support@example.com")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080")
                                .description("Development server"),
                        new Server()
                                .url("https://example.com")
                                .description("Production server")
                ));
    }
}
```

## 4. Document REST Controllers with Annotations

Use OpenAPI annotations in your controllers:

```java
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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@Tag(name = "Product Controller", description = "APIs for managing products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Operation(summary = "Get all products", description = "Retrieves a list of all available products")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved products",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Product.class))),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(productService.findAll());
    }

    @Operation(summary = "Get product by ID", description = "Returns a product based on ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved the product"),
            @ApiResponse(responseCode = "404", description = "Product not found")
    })
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(
            @Parameter(description = "Product ID", required = true) @PathVariable Long id) {
        return productService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Create a new product")
    @PostMapping
    public ResponseEntity<Product> createProduct(
            @Parameter(description = "Product to create", required = true, 
                    schema = @Schema(implementation = Product.class))
            @RequestBody Product product) {
        Product savedProduct = productService.save(product);
        return new ResponseEntity<>(savedProduct, HttpStatus.CREATED);
    }
}
```

## 5. Group APIs (Optional)

If you want to group APIs, you can use the `@Tag` annotation at the controller level and add this configuration:

```java
@Bean
public GroupedOpenApi publicApi() {
    return GroupedOpenApi.builder()
            .group("public-apis")
            .pathsToMatch("/api/public/**")
            .build();
}

@Bean
public GroupedOpenApi adminApi() {
    return GroupedOpenApi.builder()
            .group("admin-apis")
            .pathsToMatch("/api/admin/**")
            .build();
}
```

## 6. Add Security Scheme (If Using Security)

If your API is secured, add a security scheme configuration:

```java
@Bean
public OpenAPI customOpenAPI() {
    return new OpenAPI()
            .info(/* your info configuration */)
            .components(new Components()
                    .addSecuritySchemes("bearer-jwt", 
                            new SecurityScheme()
                                    .type(SecurityScheme.Type.HTTP)
                                    .scheme("bearer")
                                    .bearerFormat("JWT")
                                    .in(SecurityScheme.In.HEADER)
                                    .name("Authorization"))
            )
            .addSecurityItem(new SecurityRequirement().addList("bearer-jwt"));
}
```

## 7. Access Swagger UI

After starting your application, access the Swagger UI at:
- `http://localhost:8080/swagger-ui.html`

And access the OpenAPI documentation at:
- `http://localhost:8080/api-docs`

## Complete Example with Custom Configuration

Here's a complete `pom.xml` section and an alternative configuration approach:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

```java
@Configuration
public class OpenAPIConfiguration {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(apiInfo())
                .externalDocs(externalDocumentation());
    }

    private Info apiInfo() {
        return new Info()
                .title("Spring Boot 3 API")
                .description("API Documentation for Spring Boot 3 Application")
                .version("1.0.0")
                .contact(new Contact()
                        .name("Your Name")
                        .email("your.email@example.com")
                        .url("https://example.com"))
                .license(new License()
                        .name("Apache 2.0")
                        .url("https://www.apache.org/licenses/LICENSE-2.0"));
    }

    private ExternalDocumentation externalDocumentation() {
        return new ExternalDocumentation()
                .description("Wiki Documentation")
                .url("https://example.com/docs");
    }
}
```

These steps will give you a fully functional Swagger UI for your Spring Boot 3 application using SpringDoc OpenAPI.
