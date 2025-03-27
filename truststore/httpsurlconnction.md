# HttpsUrlConnection Certificate Rotation Handling

For HttpsUrlConnection, here are specific considerations and solutions when dealing with OAuth2 server certificate rotation:

## Common Issues

When using HttpsUrlConnection, certificate validation is handled through the JVM's default trust store or a custom trust manager you've configured. Here's what to check:

### 1. Default Trust Store Configuration

If you're using the default trust store (typically cacerts):

```java
URL url = new URL("https://oauth2server.example.com/token");
HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
// Default trust manager is used automatically
```

The JVM's default trust store is usually located at `$JAVA_HOME/lib/security/cacerts`. If the new certificate is signed by a well-known CA already in this trust store, you shouldn't have issues.

### 2. Custom Trust Store Configuration

If you've configured a custom trust store:

```java
System.setProperty("javax.net.ssl.trustStore", "/path/to/truststore.jks");
System.setProperty("javax.net.ssl.trustStorePassword", "password");
```

You'll need to ensure this trust store contains the new CA certificates.

### 3. Custom TrustManager Implementation

If you've implemented a custom TrustManager:

```java
SSLContext sslContext = SSLContext.getInstance("TLS");
TrustManager[] trustManagers = { myCustomTrustManager };
sslContext.init(null, trustManagers, new SecureRandom());
HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
```

You'll need to update your TrustManager to accept the new certificate.

## Solutions

### 1. Update Trust Stores

If you're using custom trust stores:

```java
// Use keytool to import the new certificate
// keytool -importcert -alias newoauthserver -file newcert.pem -keystore truststore.jks
```

### 2. Implement Certificate Rotation-Aware TrustManager

For a more dynamic approach that can handle certificate changes better:

```java
public class FlexibleTrustManager implements X509TrustManager {
    private final X509TrustManager defaultTrustManager;
    
    public FlexibleTrustManager() throws Exception {
        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init((KeyStore) null); // Use default keystore
        defaultTrustManager = (X509TrustManager) tmf.getTrustManagers()[0];
    }
    
    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        defaultTrustManager.checkClientTrusted(chain, authType);
    }
    
    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        try {
            defaultTrustManager.checkServerTrusted(chain, authType);
        } catch (CertificateException e) {
            // Implement additional validation logic
            // For example, check if this is your OAuth server by domain
            // and implement additional validation
            if (!isKnownOAuthServer(chain[0])) {
                throw e;
            }
        }
    }
    
    @Override
    public X509Certificate[] getAcceptedIssuers() {
        return defaultTrustManager.getAcceptedIssuers();
    }
    
    private boolean isKnownOAuthServer(X509Certificate cert) {
        // Validate by subject alternative names or other attributes
        try {
            Collection<List<?>> subjectAlternativeNames = cert.getSubjectAlternativeNames();
            if (subjectAlternativeNames != null) {
                for (List<?> san : subjectAlternativeNames) {
                    if ((Integer) san.get(0) == 2) { // DNS name
                        String dnsName = (String) san.get(1);
                        if (dnsName.endsWith("oauth2server.example.com")) {
                            return true;
                        }
                    }
                }
            }
        } catch (CertificateParsingException e) {
            return false;
        }
        return false;
    }
}
```

### 3. Implement Connection Retry Logic

Add retry logic with exponential backoff to handle temporary certificate issues:

```java
public String getOAuthToken(String tokenEndpoint, String clientId, String clientSecret) {
    int maxRetries = 3;
    long retryDelayMs = 1000;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
        try {
            URL url = new URL(tokenEndpoint);
            HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
            // Set up connection and make request
            // ...
            return parseResponse(conn);
        } catch (SSLHandshakeException e) {
            if (attempt == maxRetries) {
                throw new RuntimeException("Failed to connect to OAuth server after certificate rotation", e);
            }
            try {
                Thread.sleep(retryDelayMs * (long) Math.pow(2, attempt));
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                break;
            }
            // Log retry attempt
        }
    }
    throw new RuntimeException("Failed to connect to OAuth server");
}
```

### 4. Monitor Certificate Expiration

Implement proactive monitoring of the server certificate to be prepared for rotations:

```java
public void checkCertificateExpiration(String host, int port) throws Exception {
    SSLSocket socket = null;
    try {
        SSLSocketFactory factory = (SSLSocketFactory) SSLSocketFactory.getDefault();
        socket = (SSLSocket) factory.createSocket(host, port);
        socket.startHandshake();
        SSLSession session = socket.getSession();
        X509Certificate[] certs = (X509Certificate[]) session.getPeerCertificates();
        
        Date expirationDate = certs[0].getNotAfter();
        Date now = new Date();
        long daysToExpiration = (expirationDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24);
        
        if (daysToExpiration < 30) {
            // Log warning about upcoming expiration
            System.out.println("WARNING: OAuth server certificate expires in " + daysToExpiration + " days");
        }
    } finally {
        if (socket != null) socket.close();
    }
}
```

Would you like to see how to handle certificate rotation with Apache HttpClient 5 next?
