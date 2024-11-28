Yes, Java records can be used with JSON serialization and deserialization. Records, introduced in Java 14 (and made permanent in Java 16), work particularly well with JSON since they're immutable data carriers with built-in getters.

Here's how you can use records with popular JSON libraries:

With Jackson (most common):
```java
record Person(String name, int age) {}

// Serialization
ObjectMapper mapper = new ObjectMapper();
Person person = new Person("Alice", 30);
String json = mapper.writeValueAsString(person);

// Deserialization
Person deserializedPerson = mapper.readValue(json, Person.class);
```

With Gson:
```java
record Person(String name, int age) {}

// Serialization
Gson gson = new Gson();
Person person = new Person("Alice", 30);
String json = gson.toJson(person);

// Deserialization
Person deserializedPerson = gson.fromJson(json, Person.class);
```

The nice thing about records is that most JSON libraries work with them out of the box - no additional configuration needed. This is because:
1. Records provide canonical constructors that match the JSON structure
2. They automatically generate accessor methods that JSON libraries can use
3. Their immutability makes them ideal for JSON data transfer objects (DTOs)

Would you like to see more complex examples with nested records or collections?
