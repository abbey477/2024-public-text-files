import java.io.IOException;
import java.net.URL;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLPeerUnverifiedException;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

public class ServerCertificateLoader {
    
    private static KeyStore trustStore;
    private static final long REFRESH_THRESHOLD_DAYS = 30; // Refresh certs 30 days before expiration
    
    static {
        try {
            // Create an empty KeyStore to hold server certificates
            trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStore.load(null); // Initialize empty KeyStore
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize trust store", e);
        }
    }
    
    /**
     * Connects to the server and extracts its certificate chain
     */
    public static Certificate[] getServerCertificates(String serverUrl) throws IOException {
        URL url = new URL(serverUrl);
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
        
        try {
            // Connect to the server to retrieve the certificate chain
            connection.connect();
            return connection.getServerCertificates();
        } catch (SSLPeerUnverifiedException e) {
            throw new IOException("Failed to obtain server certificates", e);
        } finally {
            connection.disconnect();
        }
    }
    
    /**
     * Adds server certificates to the trust store
     */
    public static void updateTrustStoreWithServerCertificates(String serverUrl) throws Exception {
        System.out.println("Retrieving certificates from: " + serverUrl);
        
        // Get certificates from the server
        Certificate[] certificates = getServerCertificates(serverUrl);
        
        if (certificates == null || certificates.length == 0) {
            throw new CertificateException("No certificates received from server");
        }
        
        // Add each certificate to the trust store
        for (int i = 0; i < certificates.length; i++) {
            Certificate cert = certificates[i];
            String alias = serverUrl.replaceAll("[^a-zA-Z0-9]", "_") + "_" + i;
            
            // Print certificate info
            if (cert instanceof X509Certificate) {
                X509Certificate x509 = (X509Certificate) cert;
                System.out.println("Found certificate: " + x509.getSubjectX500Principal().getName());
                System.out.println("  Valid from: " + x509.getNotBefore());
                System.out.println("  Valid until: " + x509.getNotAfter());
            }
            
            // Add to trust store
            trustStore.setCertificateEntry(alias, cert);
        }
        
        // Update the SSL context
        updateSSLContextWithTrustStore();
        
        System.out.println("Added " + certificates.length + " certificates to trust store");
    }
    
    /**
     * Configures the SSL context with our custom trust store
     */
    private static void updateSSLContextWithTrustStore() throws Exception {
        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(trustStore);
        
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, tmf.getTrustManagers(), null);
        
        HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.getSocketFactory());
    }
    
    /**
     * Check if any certificates need to be renewed and update if necessary
     */
    public static boolean refreshCertificatesIfNeeded(String serverUrl) {
        try {
            boolean needsUpdate = false;
            Date now = new Date();
            long refreshThresholdMillis = TimeUnit.DAYS.toMillis(REFRESH_THRESHOLD_DAYS);
            
            // Get aliases in trust store
            for (String alias : Collections.list(trustStore.aliases())) {
                if (alias.startsWith(serverUrl.replaceAll("[^a-zA-Z0-9]", "_"))) {
                    Certificate cert = trustStore.getCertificate(alias);
                    if (cert instanceof X509Certificate) {
                        X509Certificate x509 = (X509Certificate) cert;
                        Date expiryDate = x509.getNotAfter();
                        
                        // Check if certificate is expiring soon or already expired
                        if (expiryDate.getTime() - now.getTime() < refreshThresholdMillis) {
                            System.out.println("Certificate is expiring soon: " + alias);
                            needsUpdate = true;
                            break;
                        }
                    }
                }
            }
            
            if (needsUpdate) {
                System.out.println("Refreshing certificates from server");
                updateTrustStoreWithServerCertificates(serverUrl);
                return true;
            }
            
            return false;
        } catch (Exception e) {
            System.err.println("Error checking certificate expiration: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Makes an HTTPS request using our trust store
     */
    public static void makeSecureRequest(String urlString) throws Exception {
        // Extract the base URL for certificate checks
        URL url = new URL(urlString);
        String baseUrl = url.getProtocol() + "://" + url.getHost();
        
        // If this is the first time connecting, or certificates need rotation, update them
        if (trustStore.size() == 0 || refreshCertificatesIfNeeded(baseUrl)) {
            updateTrustStoreWithServerCertificates(baseUrl);
        }
        
        // Make the actual request
        HttpsURLConnection connection = (HttpsURLConnection) new URL(urlString).openConnection();
        connection.setRequestMethod("GET");
        
        int responseCode = connection.getResponseCode();
        System.out.println("Response Code: " + responseCode);
        
        connection.disconnect();
    }
    
    /**
     * Demonstrates the server certificate loader
     */
    public static void main(String[] args) {
        try {
            // Make a secure request - certificates will be loaded automatically
            makeSecureRequest("https://api.example.com/data");
            
            // Make another request later - will use cached certificates if they're still valid
            System.out.println("\nMaking another request...");
            makeSecureRequest("https://api.example.com/users");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}