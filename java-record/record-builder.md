public record Person(String name, int age, String email) {
    
    // Method to update age
    public Person withAge(int newAge) {
        return new Person(this.name, newAge, this.email);
    }
    
    // Method to update name
    public Person withName(String newName) {
        return new Person(newName, this.age, this.email);
    }
    
    // Method to update email
    public Person withEmail(String newEmail) {
        return new Person(this.name, this.age, newEmail);
    }
}

// Usage
Person original = new Person("John", 25, "john@example.com");
Person updated = original.withAge(26);



public record ComplexPerson(String firstName, String lastName, int age, 
                           String email, String address, String phone) {
    
    public static Builder builder() {
        return new Builder();
    }
    
    public Builder toBuilder() {
        return new Builder()
            .firstName(this.firstName)
            .lastName(this.lastName)
            .age(this.age)
            .email(this.email)
            .address(this.address)
            .phone(this.phone);
    }
    
    public static class Builder {
        private String firstName;
        private String lastName;
        private int age;
        private String email;
        private String address;
        private String phone;
        
        public Builder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }
        
        public Builder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }
        
        public Builder age(int age) {
            this.age = age;
            return this;
        }
        
        public Builder email(String email) {
            this.email = email;
            return this;
        }
        
        public Builder address(String address) {
            this.address = address;
            return this;
        }
        
        public Builder phone(String phone) {
            this.phone = phone;
            return this;
        }
        
        public ComplexPerson build() {
            return new ComplexPerson(firstName, lastName, age, email, address, phone);
        }
    }
}

// Usage
ComplexPerson original = new ComplexPerson("John", "Doe", 25, "john@example.com", "123 Main St", "555-1234");
ComplexPerson updated = original.toBuilder()
    .age(26)
    .address("456 Oak Ave")
    .build();




import lombok.Builder;
import lombok.With;

@Builder
@With
public record LombokPerson(String name, int age, String email) {}

// Usage
LombokPerson original = LombokPerson.builder()
    .name("John")
    .age(25)  
    .email("john@example.com")
    .build();

// Using @With annotation for updates
LombokPerson updated1 = original.withAge(26);
LombokPerson updated2 = original.withName("Jane");

// Using builder for complex updates
LombokPerson updated3 = original.toBuilder()
    .age(30)
    .email("john.doe@example.com")
    .build();



