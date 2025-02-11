Here's the implementation with both SSLSocketFactory and TrustManager in a single method:

```java
import javax.net.ssl.*;
import java.io.IOException;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.net.HttpURLConnection;

public class CustomHttpsClient {

    public static SSLSocketFactory createSSLSocketFactory() {
        try {
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public X509Certificate[] getAcceptedIssuers() {
                        return null;
                    }
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {
                    }
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {
                    }
                }
            };

            SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
            sslContext.init(null, trustAllCerts, new SecureRandom());
            return sslContext.getSocketFactory();
            
        } catch (NoSuchAlgorithmException | KeyManagementException e) {
            throw new RuntimeException("Failed to create SSL socket factory", e);
        }
    }

    public static HttpsURLConnection createConnection(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
        
        conn.setSSLSocketFactory(createSSLSocketFactory());
        conn.setHostnameVerifier((hostname, session) -> true);
        
        // Default connection settings
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        
        return conn;
    }

    public static HttpsURLConnection createPostConnection(String urlString) throws IOException {
        HttpsURLConnection conn = createConnection(urlString);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json");
        return conn;
    }

    // Usage example
    public static void main(String[] args) {
        try {
            String url = "https://your-server-url.com";
            HttpsURLConnection conn = createConnection(url);
            
            int responseCode = conn.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            conn.disconnect();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

Key changes and features:

1. Combined SSL setup into a single `createSSLSocketFactory()` method
2. Simplified error handling with a runtime exception for SSL setup failures
3. Separated basic connection creation from POST-specific setup
4. Works with both JDK 11 and JDK 17
5. Maintains all necessary security bypasses for the DH key exchange issue

To use it for a POST request:

```java
HttpsURLConnection conn = createPostConnection("https://your-url.com");
// Write your POST data
try (OutputStream os = conn.getOutputStream()) {
    String jsonBody = "{\"key\":\"value\"}";
    os.write(jsonBody.getBytes("UTF-8"));
}
// Read response...
conn.disconnect();
```

Let me know if you need any clarification or have specific requirements to add!
