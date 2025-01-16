You can pass arguments to a Spring Boot application running with Maven in several ways:

1. For Java application arguments (args[] in main method), use:
```bash
mvn spring-boot:run -pl module-name -Dspring-boot.run.arguments="--arg1=value1 --arg2=value2"
```

2. For JVM arguments, use:
```bash
mvn spring-boot:run -pl module-name -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8787"
```

3. For Spring properties, you can use either:
```bash
mvn spring-boot:run -pl module-name -Dspring-boot.run.arguments="--spring.profiles.active=dev --server.port=8081"
```

Or the shorter form:
```bash
mvn spring-boot:run -pl module-name -Dspring.profiles.active=dev -Dserver.port=8081
```

If you're passing multiple arguments, make sure to wrap them in quotes if they contain spaces. For example:
```bash
mvn spring-boot:run -pl module-name -Dspring-boot.run.arguments="--name='John Doe' --env=prod"
```
