I'll create a Java main class that programmatically runs jsonschema2pojo. This is useful when you want to generate POJOs during runtime or need more control over the generation process.



```java
import com.sun.codemodel.JCodeModel;
import org.jsonschema2pojo.*;
import org.jsonschema2pojo.rules.RuleFactory;

import java.io.File;
import java.io.IOException;
import java.net.URL;

public class JsonSchema2PojoGenerator {
    public static void main(String[] args) {
        generateJavaClassesFromSchema();
    }

    public static void generateJavaClassesFromSchema() {
        String inputJson = "src/main/resources/schema/person.json";  // Your schema location
        String outputDirectory = "src/main/java";  // Where to output the generated classes
        String targetPackage = "com.example.model";  // Target package for generated classes

        try {
            // Configure generation
            JCodeModel codeModel = new JCodeModel();

            GenerationConfig config = new DefaultGenerationConfig() {
                @Override
                public boolean isGenerateBuilders() {
                    return true;
                }

                @Override
                public SourceType getSourceType() {
                    return SourceType.JSON_SCHEMA;
                }

                @Override
                public boolean isIncludeConstructors() {
                    return true;
                }

                @Override
                public boolean isIncludeToString() {
                    return true;
                }

                @Override
                public boolean isIncludeHashcodeAndEquals() {
                    return true;
                }

                @Override
                public AnnotationStyle getAnnotationStyle() {
                    return AnnotationStyle.JACKSON2;
                }
            };

            // Create schema mapper and generate classes
            SchemaMapper mapper = new SchemaMapper(
                new RuleFactory(config, new Jackson2Annotator(config), new SchemaStore()),
                new SchemaGenerator()
            );

            // Generate Java classes
            mapper.generate(
                codeModel,
                "Person",  // Name for the main generated class
                targetPackage,
                new File(inputJson).toURI().toURL()
            );

            // Write generated classes to disk
            File outputDir = new File(outputDirectory);
            outputDir.mkdirs();
            codeModel.build(outputDir);

            System.out.println("Successfully generated Java classes from JSON Schema!");
            System.out.println("Output directory: " + outputDir.getAbsolutePath());
            
        } catch (IOException e) {
            System.err.println("Error generating Java classes: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Optional: Helper method to generate from multiple schemas
    public static void generateFromSchema(String schemaPath, String className, 
                                        String targetPackage, String outputDirectory) 
            throws IOException {
        JCodeModel codeModel = new JCodeModel();
        URL sourceUrl = new File(schemaPath).toURI().toURL();

        GenerationConfig config = new DefaultGenerationConfig() {
            @Override
            public boolean isGenerateBuilders() { return true; }
            @Override
            public AnnotationStyle getAnnotationStyle() { 
                return AnnotationStyle.JACKSON2; 
            }
        };

        SchemaMapper mapper = new SchemaMapper(
            new RuleFactory(config, new Jackson2Annotator(config), new SchemaStore()),
            new SchemaGenerator()
        );

        mapper.generate(codeModel, className, targetPackage, sourceUrl);
        codeModel.build(new File(outputDirectory));
    }
}

```

To use this generator, you'll need these dependencies in your `pom.xml`:

```xml
<dependencies>
    <dependency>
        <groupId>org.jsonschema2pojo</groupId>
        <artifactId>jsonschema2pojo-core</artifactId>
        <version>1.2.1</version>
    </dependency>
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.15.2</version>
    </dependency>
</dependencies>
```

This generator provides:

1. A main method that generates classes from a single schema
2. Configurable options through the `DefaultGenerationConfig` override
3. Support for Jackson 2 annotations
4. Generation of builders, constructors, toString, equals, and hashCode methods
5. A helper method for generating from multiple schemas

To use it:

1. Place your JSON schema file in `src/main/resources/schema/`
2. Run the main method
3. Find the generated classes in your specified output directory

The generator supports customization through the `GenerationConfig` interface, where you can configure:
- Annotation style (Jackson, Gson, etc.)
- Builder pattern generation
- Constructor generation
- Method generation
- Package naming
- And more

Would you like me to show you how to:
1. Handle more complex schema configurations?
2. Add custom annotations to the generated classes?
3. Set up different output formats or styles?
