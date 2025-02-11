Here are the Java command line parameters that work for both JDK 11 and JDK 17:

```bash
# For JAR files
java -Djdk.tls.disabledAlgorithms="SSLv3, RC4, DES, MD5withRSA, DHE keySize < 1024, ECDHE keySize < 1024" -Djdk.tls.client.protocols="TLSv1.2,TLSv1.3" -jar yourapp.jar

# For Java class files
java -Djdk.tls.disabledAlgorithms="SSLv3, RC4, DES, MD5withRSA, DHE keySize < 1024, ECDHE keySize < 1024" -Djdk.tls.client.protocols="TLSv1.2,TLSv1.3" YourMainClass
```

Key changes for compatibility:
1. Added `DHE` and `ECDHE` explicitly for key size constraints
2. Added `-Djdk.tls.client.protocols` to specify TLS versions
3. Included both TLS 1.2 and 1.3 support

For shell scripts:
```bash
JAVA_OPTS="$JAVA_OPTS -Djdk.tls.disabledAlgorithms=SSLv3, RC4, DES, MD5withRSA, DHE keySize < 1024, ECDHE keySize < 1024 -Djdk.tls.client.protocols=TLSv1.2,TLSv1.3"
```

These parameters ensure:
- Compatible SSL/TLS handshakes across both JDK versions
- Proper security standards
- Support for modern cipher suites
