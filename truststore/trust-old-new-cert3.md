If you place your truststore in the Java default location (`$JAVA_HOME/lib/security/jssecacerts` or `$JAVA_HOME/lib/security/cacerts`), it will work automatically without requiring additional configuration in your client application.

Here's how it works:

1. When a Java application makes HTTPS connections, it first checks if custom SSL properties have been set (via system properties or programmatic configuration).

2. If no custom configuration is found, Java automatically looks for a truststore in these locations in this order:
   - `$JAVA_HOME/lib/security/jssecacerts` (preferred)
   - `$JAVA_HOME/lib/security/cacerts` (fallback)

3. The default password for these stores is usually `changeit` or `changeme`.

This approach is convenient because:
- No code changes are needed
- The configuration is system-wide
- It's the same approach used by the JVM itself

However, there are a few considerations:

- Modifying the system-wide truststore affects all Java applications on that machine
- You need admin/root privileges to modify these files
- During Java upgrades, you may need to migrate your custom certificates

If you want to use the default location but with a custom password, you would still need to set:
```java
System.setProperty("javax.net.ssl.trustStorePassword", "your_password");
```

For most standard HTTPS connections to public websites, the default truststore already contains the necessary certificate authorities, so no modifications are needed at all.