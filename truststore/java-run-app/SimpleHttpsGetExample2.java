import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

public class SimpleHttpsGetExample2 {
    
    public static void main(String[] args) {
        try {
            // Trust all certificates (ONLY FOR DEVELOPMENT)
            trustAllCertificates();
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
        } catch (NoSuchAlgorithmException | KeyManagementException e) {
            System.out.println("Error setting up trust manager: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Creates a trust manager that accepts all certificates
     * WARNING: Only use this in development environments
     */
    private static void trustAllCertificates() throws NoSuchAlgorithmException, KeyManagementException {
        // Create a trust manager that accepts all certificates
        TrustManager[] trustAllCerts = new TrustManager[] {
            new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() {
                    return null;
                }
                
                public void checkClientTrusted(X509Certificate[] certs, String authType) {
                    // Trust all client certificates
                }
                
                public void checkServerTrusted(X509Certificate[] certs, String authType) {
                    // Trust all server certificates
                }
            }
        };
        
        // Create an SSL context with our trust manager
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, trustAllCerts, new SecureRandom());
        
        // Set the default socket factory
        HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
        
        // Also disable hostname verification
        HttpsURLConnection.setDefaultHostnameVerifier((hostname, session) -> true);
    }
}