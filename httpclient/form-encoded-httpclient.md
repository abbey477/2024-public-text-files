I'll help you create a Spring Boot example that sends a POST request with form-urlencoded data using Apache HttpClient and processes a JSON response, without using lambda expressions.



```java
import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class HttpClientService {
    
    public JSONObject sendPostRequest(String url, String param1, String param2) throws IOException {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost(url);
        
        // Create form parameters
        List<NameValuePair> params = new ArrayList<NameValuePair>();
        params.add(new BasicNameValuePair("parameter1", param1));
        params.add(new BasicNameValuePair("parameter2", param2));
        
        // Set headers
        httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded");
        httpPost.setEntity(new UrlEncodedFormEntity(params));
        
        CloseableHttpResponse response = null;
        try {
            // Execute request
            response = httpClient.execute(httpPost);
            
            // Process response
            HttpEntity entity = response.getEntity();
            String jsonResponse = EntityUtils.toString(entity);
            return new JSONObject(jsonResponse);
            
        } finally {
            // Close resources
            if (response != null) {
                response.close();
            }
            httpClient.close();
        }
    }
}

// Example controller using the service
@RestController
@RequestMapping("/api")
public class ApiController {
    
    @Autowired
    private HttpClientService httpClientService;
    
    @PostMapping("/example")
    public ResponseEntity<String> makeRequest() {
        try {
            JSONObject response = httpClientService.sendPostRequest(
                "https://api.example.com/endpoint",
                "value1",
                "value2"
            );
            
            return ResponseEntity.ok(response.toString());
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error: " + e.getMessage());
        }
    }
}

```

This implementation includes:

1. A service class `HttpClientService` that handles the HTTP request
2. Method to send POST request with form parameters
3. Proper resource management with try-finally blocks
4. JSON response processing
5. A sample controller showing how to use the service

To use this code, you'll need these dependencies in your `pom.xml`:

```xml
<dependencies>
    <dependency>
        <groupId>org.apache.httpcomponents</groupId>
        <artifactId>httpclient</artifactId>
        <version>4.5.13</version>
    </dependency>
    <dependency>
        <groupId>org.json</groupId>
        <artifactId>json</artifactId>
        <version>20210307</version>
    </dependency>
</dependencies>
```

Would you like me to modify any part of the implementation or add additional features like error handling or custom headers?
