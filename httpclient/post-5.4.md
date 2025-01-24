import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class HttpClientExample {
    public static void main(String[] args) {
        // Create the HttpClient with try-with-resources to ensure proper closure
        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            // Create POST request
            HttpPost httpPost = new HttpPost("http://api.example.com/endpoint");

            // Set headers
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setHeader("Connection", "close");  // Explicitly request connection closure

            // Create request body
            String jsonBody = "{\"key\": \"value\"}";
            StringEntity entity = new StringEntity(jsonBody);
            httpPost.setEntity(entity);

            // Execute request with try-with-resources for response
            try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                // Get response
                HttpEntity responseEntity = response.getEntity();
                if (responseEntity != null) {
                    String result = EntityUtils.toString(responseEntity);
                    System.out.println("Response: " + result);
                    
                    // Ensure the entity content is fully consumed
                    EntityUtils.consume(responseEntity);
                }
                
                // Print status code
                System.out.println("Status code: " + response.getStatusLine().getStatusCode());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
