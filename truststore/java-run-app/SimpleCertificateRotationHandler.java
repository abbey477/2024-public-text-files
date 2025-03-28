import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.security.KeyStore;
import java.security.cert.CertificateException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

public class SimpleCertificateRotationHandler {

    private static final String trustStorePath = System.getProperty("java.io.tmpdir") + File.separator;
    private static final String TRUST_STORE_PATH = "/home/abiodun/googledrive/workspace-github-code/2024-public-text-files/truststore/java-run-app/truststore.jks";
    private static final String TRUST_STORE_PASSWORD = "your-password";
    private static final long RELOAD_INTERVAL_HOURS = 24; // How often to reload certificates
    
    private static ScheduledExecutorService scheduler;
    
    public static void main(String[] args) throws Exception {
        // Initialize SSL context on startup
        updateSSLContext();
        
        // Schedule periodic updates
        startPeriodicUpdates();
        
        // Make a sample HTTPS request
        makeHttpsRequest("https://untrusted-root.badssl.com/");
        
        // Keep the application running for demonstration
        Thread.sleep(10000);
        
        // Clean up when done
        scheduler.shutdown();
    }
    
    /**
     * Updates the SSL context with the current trust store
     */
    public static void updateSSLContext() {
        try {
            // Load the trust store
            KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
            try (FileInputStream fis = new FileInputStream(TRUST_STORE_PATH)) {
                trustStore.load(fis, TRUST_STORE_PASSWORD.toCharArray());
            }
            
            // Create trust manager factory
            TrustManagerFactory tmf = TrustManagerFactory.getInstance(
                    TrustManagerFactory.getDefaultAlgorithm());
            tmf.init(trustStore);
            
            // Create SSL context
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, tmf.getTrustManagers(), null);
            
            // Set as default
            HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
            
            System.out.println("SSL context updated with current certificates");
        } catch (Exception e) {
            System.err.println("Failed to update SSL context: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Starts periodic updates of the SSL context
     */
    public static void startPeriodicUpdates() {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(
                SimpleCertificateRotationHandler::updateSSLContext,
                RELOAD_INTERVAL_HOURS, 
                RELOAD_INTERVAL_HOURS, 
                TimeUnit.HOURS);
        
        System.out.println("Scheduled certificate updates every " + 
                RELOAD_INTERVAL_HOURS + " hours");
    }
    
    /**
     * Makes an HTTPS request to the specified URL
     */
    private static void makeHttpsRequest(String urlString) {
        try {
            URL url = new URL(urlString);
            HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            connection.disconnect();
        } catch (IOException e) {
            System.err.println("Request failed: " + e.getMessage());
        }
    }
    
    /**
     * Call this method before certificate expiration to reload certificates
     */
    public static void manualCertificateReload() {
        System.out.println("Manual certificate reload triggered");
        updateSSLContext();
    }
}