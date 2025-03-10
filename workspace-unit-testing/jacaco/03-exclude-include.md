To exclude packages, classes, or methods from JaCoCo coverage in your pom.xml file, you need to configure the JaCoCo Maven plugin with exclusion rules. Here's how you can do it:

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
    <executions>
        <execution>
            <id>prepare-agent</id>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
            <configuration>
                <excludes>
                    <!-- Exclude entire packages -->
                    <exclude>**/generated/**</exclude>
                    <exclude>**/dto/**</exclude>
                    
                    <!-- Exclude specific classes -->
                    <exclude>**/config/*Config.class</exclude>
                    <exclude>**/*DTO.class</exclude>
                    
                    <!-- Exclude by class name pattern -->
                    <exclude>**/*Exception.class</exclude>
                    
                    <!-- Exclude specific methods in specific classes -->
                    <exclude>**/SomeClass.method*(...)</exclude>
                </excludes>
            </configuration>
        </execution>
    </executions>
</plugin>
```

You can use various patterns for exclusion:

1. **Package exclusion**: `**/packagename/**`
2. **Class exclusion**: `**/ClassName.class` or `**/*Pattern*.class`
3. **Method exclusion**: `**/ClassName.methodName(...)`

The wildcards work as follows:
- `*` matches any sequence of characters (not including path separators)
- `**` matches any sequence of characters including path separators

If you want to exclude coverage checks but still collect data, you can configure the check execution separately:

```xml
<execution>
    <id>check</id>
    <goals>
        <goal>check</goal>
    </goals>
    <configuration>
        <excludes>
            <!-- Your exclusions here -->
        </excludes>
        <rules>
            <rule>
                <!-- Your coverage rules here -->
            </rule>
        </rules>
    </configuration>
</execution>
```

Remember that exclusions should be used judiciously, as they reduce the value of your coverage metrics by hiding potentially important code from analysis.
