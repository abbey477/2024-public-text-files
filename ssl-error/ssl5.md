In that case, since you can only modify the client side and the server cannot be changed, here are the specific client-side solutions:

1. The simplest solution is to add these JVM arguments when starting your Java application:
```java
-Djava.security.properties="unlimited"
-Dhttps.protocols=TLSv1.2
-Djdk.tls.client.protocols=TLSv1.2
```

2. If that doesn't work, you can programmatically enable legacy algorithms before making the connection:
```java
Security.setProperty("crypto.policy", "unlimited");
System.setProperty("https.protocols", "TLSv1.2");
System.setProperty("jdk.tls.client.protocols", "TLSv1.2");
```

3. If you still get the error, you can explicitly disable the DH key size check (though this is less secure):
```java
Security.setProperty("jdk.tls.disabledAlgorithms", 
    Security.getProperty("jdk.tls.disabledAlgorithms")
    .replace(", DHE keySize < 1024", ""));
```

4. As a last resort, you can create a custom SSLContext:
```java
SSLContext sslContext = SSLContext.getInstance("TLS");
sslContext.init(null, new TrustManager[]{new X509TrustManager() {
    public X509Certificate[] getAcceptedIssuers() { return null; }
    public void checkClientTrusted(X509Certificate[] certs, String authType) { }
    public void checkServerTrusted(X509Certificate[] certs, String authType) { }
}}, new SecureRandom());

HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
```

Try implementing these solutions in order - start with the JVM arguments as they're the least invasive. Let me know if you need help with implementing any of these specific approaches.
