```xml
<!-- JaCoCo configuration for dev and prod environments in pom.xml -->
<project>
    <!-- ... other project configurations ... -->
    
    <properties>
        <!-- JaCoCo properties -->
        <jacoco.version>0.8.11</jacoco.version>
        <jacoco.dev.destFile>${project.build.directory}/coverage-reports/jacoco-dev.exec</jacoco.dev.destFile>
        <!-- For prod, we use instrumentation which creates jacoco.exec in the build directory -->
        <jacoco.prod.destFile>${project.build.directory}/jacoco.exec</jacoco.prod.destFile>
        <sonar.coverage.jacoco.xmlReportPaths>${project.build.directory}/site/jacoco-aggregate/jacoco.xml</sonar.coverage.jacoco.xmlReportPaths>
    </properties>
    
    <build>
        <plugins>
            <!-- ... other plugins ... -->
            
            <!-- JaCoCo plugin configuration -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>${jacoco.version}</version>
                <executions>
                    <!-- Dev environment configuration -->
                    <execution>
                        <id>dev-prepare-agent</id>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                        <configuration>
                            <destFile>${jacoco.dev.destFile}</destFile>
                            <propertyName>jacoco.dev.agent.argLine</propertyName>
                            <append>true</append>
                            <!-- Inclusion/Exclusion patterns for on-the-fly approach -->
                            <includes>
                                <include>com/example/important/**/*</include>
                                <include>com/example/critical/**/*</include>
                            </includes>
                            <excludes>
                                <exclude>com/example/generated/**/*</exclude>
                                <exclude>com/example/dto/**/*</exclude>
                                <exclude>**/*Config.*</exclude>
                            </excludes>
                        </configuration>
                    </execution>
                    <execution>
                        <id>dev-report</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                        <configuration>
                            <dataFile>${jacoco.dev.destFile}</dataFile>
                            <outputDirectory>${project.reporting.outputDirectory}/jacoco-dev</outputDirectory>
                        </configuration>
                    </execution>
                    
                    <!-- Prod environment configuration using instrumentation -->
                    <execution>
                        <id>prod-instrument</id>
                        <goals>
                            <goal>instrument</goal>
                        </goals>
                        <phase>process-classes</phase>
                        <configuration>
                            <!-- Inclusion/Exclusion patterns for offline instrumentation approach -->
                            <includes>
                                <include>com/example/important/**/*</include>
                                <include>com/example/critical/**/*</include>
                            </includes>
                            <excludes>
                                <exclude>com/example/generated/**/*</exclude>
                                <exclude>com/example/dto/**/*</exclude>
                                <exclude>**/*Config.*</exclude>
                            </excludes>
                        </configuration>
                    </execution>
                    <execution>
                        <id>prod-restore-instrumented-classes</id>
                        <goals>
                            <goal>restore-instrumented-classes</goal>
                        </goals>
                        <phase>test</phase>
                    </execution>
                    <execution>
                        <id>prod-report</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                        <configuration>
                            <dataFile>${project.build.directory}/jacoco.exec</dataFile>
                            <outputDirectory>${project.reporting.outputDirectory}/jacoco-prod</outputDirectory>
                        </configuration>
                    </execution>
                    
                    <!-- Aggregate report (combining both dev and prod) -->
                    <execution>
                        <id>merge-results</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>merge</goal>
                        </goals>
                        <configuration>
                            <fileSets>
                                <fileSet>
                                    <directory>${project.build.directory}/coverage-reports</directory>
                                    <includes>
                                        <include>*.exec</include>
                                    </includes>
                                </fileSet>
                            </fileSets>
                            <destFile>${project.build.directory}/coverage-reports/jacoco-aggregate.exec</destFile>
                        </configuration>
                    </execution>
                    <execution>
                        <id>aggregate-report</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                        <configuration>
                            <dataFile>${project.build.directory}/coverage-reports/jacoco-aggregate.exec</dataFile>
                            <outputDirectory>${project.reporting.outputDirectory}/jacoco-aggregate</outputDirectory>
                        </configuration>
                    </execution>
                    
                    <!-- Optional: Enforce minimum code coverage rules -->
                    <execution>
                        <id>check</id>
                        <goals>
                            <goal>check</goal>
                        </goals>
                        <configuration>
                            <dataFile>${project.build.directory}/coverage-reports/jacoco-aggregate.exec</dataFile>
                            <!-- Global exclusions that apply to checks -->
                            <excludes>
                                <exclude>com/example/generated/**/*</exclude>
                                <exclude>com/example/dto/**/*</exclude>
                                <exclude>**/*Config.*</exclude>
                            </excludes>
                            <rules>
                                <rule>
                                    <element>BUNDLE</element>
                                    <limits>
                                        <limit>
                                            <counter>INSTRUCTION</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.70</minimum>
                                        </limit>
                                    </limits>
                                </rule>
                                <!-- Example of class-specific rules -->
                                <rule>
                                    <element>CLASS</element>
                                    <includes>
                                        <include>com.example.important.*</include>
                                    </includes>
                                    <limits>
                                        <limit>
                                            <counter>METHOD</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.80</minimum>
                                        </limit>
                                    </limits>
                                </rule>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
            
            <!-- Configure Surefire plugin to use JaCoCo agent -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
                <configuration>
                    <argLine>@{jacoco.dev.agent.argLine}</argLine>
                </configuration>
            </plugin>
            
            <!-- Configure Failsafe plugin to use JaCoCo agent for integration tests -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-failsafe-plugin</artifactId>
                <version>3.2.5</version>
                <configuration>
                    <!-- No argLine needed for instrumentation method -->
                </configuration>
            </plugin>
        </plugins>
    </build>
    
    <!-- Profiles for selectively activating environments -->
    <profiles>
        <profile>
            <id>dev</id>
            <!-- Dev configuration is no longer the default -->
        </profile>
        
        <profile>
            <id>prod</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-surefire-plugin</artifactId>
                        <configuration>
                            <argLine>@{jacoco.prod.agent.argLine}</argLine>
                        </configuration>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
    
    <!-- ... other configurations ... -->
</project>
```