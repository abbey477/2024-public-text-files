Here's how to add the fix as a Java command line parameter when starting your application:

```bash
java -Djdk.tls.disabledAlgorithms="SSLv3, RC4, DES, MD5withRSA, DH keySize < 1024" YourMainClass
```

If you're using a JAR file:
```bash
java -Djdk.tls.disabledAlgorithms="SSLv3, RC4, DES, MD5withRSA, DH keySize < 1024" -jar yourapp.jar
```

If you need an even less restrictive setting, you could use:
```bash
java -Djdk.tls.disabledAlgorithms="SSLv3, RC4, DES, MD5withRSA" -jar yourapp.jar
```

If you're using a shell script to start your application, you can add this parameter to your existing JAVA_OPTS:
```bash
JAVA_OPTS="$JAVA_OPTS -Djdk.tls.disabledAlgorithms=SSLv3, RC4, DES, MD5withRSA, DH keySize < 1024"
```
