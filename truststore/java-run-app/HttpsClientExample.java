import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.net.ssl.HttpsURLConnection;

public class HttpsClientExample {
    
    private static final String BASE_URL = "https://api.example.com";
    private static final String CLIENT_ID = "your-client-id";
    private static final String CLIENT_SECRET = "your-client-secret";
    private static final String TOKEN_ENDPOINT = "/oauth/token";
    private static final String RESOURCE_ENDPOINT = "/api/resource";
    
    private String accessToken;
    
    /**
     * Main method to demonstrate HTTP client usage
     */
    public static void main(String[] args) {
        HttpsClientExample client = new HttpsClientExample();
        try {
            // Get OAuth token
            client.obtainAccessToken();
            
            // Make GET request
            String getResponse = client.makeGetRequest("/api/data");
            System.out.println("GET Response: " + getResponse);
            
            // Make POST request
            String postData = "{\"name\":\"Test\",\"value\":\"123\"}";
            String postResponse = client.makePostRequest("/api/create", postData);
            System.out.println("POST Response: " + postResponse);
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Obtains an OAuth access token using client credentials grant
     */
    public void obtainAccessToken() throws IOException {
        URL url = new URL(BASE_URL + TOKEN_ENDPOINT);
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
        
        // Set up the request
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        
        // Add Basic Authentication header for client credentials
        String auth = CLIENT_ID + ":" + CLIENT_SECRET;
        String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
        connection.setRequestProperty("Authorization", "Basic " + encodedAuth);
        
        // Enable output for POST
        connection.setDoOutput(true);
        
        // Send request parameters
        try (DataOutputStream outputStream = new DataOutputStream(connection.getOutputStream())) {
            String params = "grant_type=client_credentials";
            outputStream.write(params.getBytes(StandardCharsets.UTF_8));
        }
        
        // Read the response
        int responseCode = connection.getResponseCode();
        if (responseCode == HttpsURLConnection.HTTP_OK) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                
                // For simplicity, we're just assuming the response format and extracting token
                // In a real app, you would parse the JSON properly
                // Example: {"access_token":"abc123","token_type":"bearer","expires_in":3600}
                String responseBody = response.toString();
                accessToken = responseBody.split("\"access_token\":\"")[1].split("\"")[0];
                System.out.println("Access token obtained successfully");
            }
        } else {
            System.out.println("Failed to obtain access token. Response code: " + responseCode);
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()))) {
                StringBuilder errorResponse = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    errorResponse.append(line);
                }
                System.out.println("Error response: " + errorResponse.toString());
            }
        }
        
        connection.disconnect();
    }
    
    /**
     * Makes a GET request to the specified endpoint
     */
    public String makeGetRequest(String endpoint) throws IOException {
        URL url = new URL(BASE_URL + endpoint);
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
        
        // Set the request method
        connection.setRequestMethod("GET");
        
        // Add authorization header
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        // Optional settings
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);
        
        // Get the response
        int responseCode = connection.getResponseCode();
        StringBuilder response = new StringBuilder();
        
        if (responseCode == HttpsURLConnection.HTTP_OK) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }
        } else {
            System.out.println("GET request failed. Response code: " + responseCode);
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }
        }
        
        connection.disconnect();
        return response.toString();
    }
    
    /**
     * Makes a POST request to the specified endpoint with the given data
     */
    public String makePostRequest(String endpoint, String postData) throws IOException {
        URL url = new URL(BASE_URL + endpoint);
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
        
        // Set the request method and headers
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        // Enable output for POST
        connection.setDoOutput(true);
        
        // Send the request body
        try (DataOutputStream outputStream = new DataOutputStream(connection.getOutputStream())) {
            outputStream.write(postData.getBytes(StandardCharsets.UTF_8));
        }
        
        // Get the response
        int responseCode = connection.getResponseCode();
        StringBuilder response = new StringBuilder();
        
        if (responseCode == HttpsURLConnection.HTTP_OK || responseCode == HttpsURLConnection.HTTP_CREATED) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }
        } else {
            System.out.println("POST request failed. Response code: " + responseCode);
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }
        }
        
        connection.disconnect();
        return response.toString();
    }
}