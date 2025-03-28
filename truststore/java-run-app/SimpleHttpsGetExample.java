import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import javax.net.ssl.HttpsURLConnection;

public class SimpleHttpsGetExample {
    
    public static void main(String[] args) {
        try {
            // Define the URL to connect to
            String urlString = "https://untrusted-root.badssl.com/";
            URL url = new URL(urlString);
            
            // Open connection
            HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
            
            // Set request method
            connection.setRequestMethod("GET");
            
            // Optional settings
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(5000);
            
            // If authentication is needed
            // connection.setRequestProperty("Authorization", "Bearer your-access-token");
            
            // Get response code
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            // Read the response
            BufferedReader reader;
            if (responseCode >= 200 && responseCode < 300) {
                reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            } else {
                reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
            }
            
            String line;
            StringBuilder response = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            
            // Print response
            System.out.println("Response: " + response.toString());
            
            // Close connection
            connection.disconnect();
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}