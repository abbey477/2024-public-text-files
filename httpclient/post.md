```java
// Apache HttpClient Example
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class HttpPostExample {
    
    public void apacheHttpClientPost() throws Exception {
        // Create HttpClient instance
        HttpClient httpClient = HttpClients.createDefault();
        
        // Create POST request
        HttpPost httpPost = new HttpPost("https://api.example.com/endpoint");
        
        // Set headers
        httpPost.setHeader("Content-Type", "application/json");
        httpPost.setHeader("Accept", "application/json");
        
        // Create request body
        String jsonBody = "{\"key\":\"value\"}";
        StringEntity entity = new StringEntity(jsonBody);
        httpPost.setEntity(entity);
        
        // Execute request
        HttpResponse response = httpClient.execute(httpPost);
        
        // Handle response
        String responseBody = EntityUtils.toString(response.getEntity());
        int statusCode = response.getStatusLine().getStatusCode();
        
        System.out.println("Status Code: " + statusCode);
        System.out.println("Response: " + responseBody);
    }
    
    // JDK HttpClient Example (Java 11+)
    public void jdkHttpClientPost() throws Exception {
        // Create HttpClient instance
        java.net.http.HttpClient httpClient = java.net.http.HttpClient.newBuilder()
                .build();
        
        // Create request body
        String jsonBody = "{\"key\":\"value\"}";
        java.net.http.HttpRequest.BodyPublisher bodyPublisher = 
                java.net.http.HttpRequest.BodyPublishers.ofString(jsonBody);
        
        // Create POST request
        java.net.http.HttpRequest request = java.net.http.HttpRequest.newBuilder()
                .uri(new java.net.URI("https://api.example.com/endpoint"))
                .header("Content-Type", "application/json")
                .header("Accept", "application/json")
                .POST(bodyPublisher)
                .build();
        
        // Execute request
        java.net.http.HttpResponse<String> response = httpClient.send(request,
                java.net.http.HttpResponse.BodyHandlers.ofString());
        
        // Handle response
        int statusCode = response.statusCode();
        String responseBody = response.body();
        
        System.out.println("Status Code: " + statusCode);
        System.out.println("Response: " + responseBody);
    }
}

```

I've provided two complete implementations for making HTTP POST requests in Java:

1. Using Apache HttpClient:
   - Creates a default HttpClient instance
   - Sets up POST request with headers and JSON body
   - Uses StringEntity for the request body
   - Executes request and processes response

2. Using JDK HttpClient (Java 11+):
   - Creates HttpClient instance using builder
   - Sets up request with headers and body
   - Uses BodyPublisher for the request body
   - Executes request and processes response

Both examples include:
- Setting Content-Type and Accept headers
- Sending a JSON body
- Getting the response status code and body
- Error handling through exceptions

Would you like me to explain any specific part in more detail?
