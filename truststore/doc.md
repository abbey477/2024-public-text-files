When you use Apache HttpClient 5 without explicitly setting a truststore, it's able to obtain access tokens from servers with rotated certificates because of how the default trust mechanism works. Here's why:

# Why HttpClient 5 Works Without Setting a Truststore

1. **Default System Truststore**: By default, HttpClient 5 uses the JVM's default truststore, which contains certificates from major Certificate Authorities (CAs). This default truststore is located at `$JAVA_HOME/lib/security/cacerts`.

2. **Automatic Chain Validation**: When a server presents its certificate, HttpClient verifies if it was issued by a trusted CA from this default truststore.

3. **No Extra Configuration Needed**: If the server's certificate is issued by a well-known CA already in the default truststore, HttpClient will trust it automatically without any explicit configuration.

Here's a basic example of HttpClient 5 making a request without any explicit truststore configuration:

```java
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.io.entity.StringEntity;

public class OAuthTokenClient {
    public static void main(String[] args) {
        try {
            // Create default HttpClient (uses system truststore)
            try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
                
                // Create POST request for token endpoint
                HttpPost httpPost = new HttpPost("https://oauth-server.example.com/oauth/token");
                
                // Set up request headers
                httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded");
                String auth = "your-client-id:your-client-secret";
                String encodedAuth = java.util.Base64.getEncoder().encodeToString(auth.getBytes());
                httpPost.setHeader("Authorization", "Basic " + encodedAuth);
                
                // Set up request body
                StringEntity entity = new StringEntity("grant_type=client_credentials", 
                                                     ContentType.APPLICATION_FORM_URLENCODED);
                httpPost.setEntity(entity);
                
                // Execute request
                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    // Process response
                    int statusCode = response.getCode();
                    String responseBody = new String(response.getEntity().getContent().readAllBytes());
                    
                    System.out.println("Status code: " + statusCode);
                    System.out.println("Response: " + responseBody);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## When You Would Need to Set a Truststore

You would only need to explicitly set a truststore if:

1. The server uses a certificate from a CA not in the default truststore
2. The server uses a self-signed certificate
3. You're using a custom CA in your organization
4. You want to restrict which CAs your application trusts

## Key Difference from HttpsURLConnection

HttpClient 5 and HttpsURLConnection both use the JVM's default truststore, but:

- HttpClient 5 has better defaults and is more modern
- HttpClient 5 handles connection pooling and reuse automatically
- HttpClient 5 tends to be more robust with various SSL/TLS implementations

This is why HttpClient 5 might seem to "just work" in situations where HttpsURLConnection requires more explicit configuration.

In summary, HttpClient 5 works without setting a truststore because it's using the JVM's default truststore which already contains certificates from major public CAs.
