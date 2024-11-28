import java.io.*;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.zip.GZIPInputStream;
import java.nio.file.Path;
import java.nio.file.Files;

public class GzipDownloadHandler {
    private static final int BUFFER_SIZE = 8192;
    
    public static void downloadAndDecompress(String url, String outputPath) throws IOException, InterruptedException {
        HttpClient client = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();
            
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .header("Accept-Encoding", "gzip")
            .GET()
            .build();
            
        // Create a temporary file for the compressed data
        Path tempFile = Files.createTempFile("download", ".gz");
        
        try {
            // Download the file with progress tracking
            HttpResponse<Path> response = client.send(request,
                HttpResponse.BodyHandlers.ofFile(tempFile));
                
            if (response.statusCode() != 200) {
                throw new IOException("Download failed with status code: " + response.statusCode());
            }
            
            // Decompress the file with progress tracking
            try (GZIPInputStream gzipInputStream = new GZIPInputStream(
                     new BufferedInputStream(
                         Files.newInputStream(tempFile), BUFFER_SIZE));
                 BufferedOutputStream outputStream = new BufferedOutputStream(
                     Files.newOutputStream(Path.of(outputPath)), BUFFER_SIZE)) {
                
                byte[] buffer = new byte[BUFFER_SIZE];
                long totalBytesRead = 0;
                int bytesRead;
                
                while ((bytesRead = gzipInputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                    totalBytesRead += bytesRead;
                    
                    // Print progress every 100MB
                    if (totalBytesRead % (100 * 1024 * 1024) == 0) {
                        System.out.printf("Decompressed %d MB%n", totalBytesRead / (1024 * 1024));
                    }
                }
            }
        } finally {
            // Clean up temporary file
            Files.deleteIfExists(tempFile);
        }
    }
    
    // Example usage with exception handling
    public static void main(String[] args) {
        String url = "https://example.com/large-file.gz";
        String outputPath = "decompressed-file.txt";
        
        try {
            System.out.println("Starting download and decompression...");
            downloadAndDecompress(url, outputPath);
            System.out.println("Download and decompression completed successfully!");
        } catch (IOException e) {
            System.err.println("Error during download or decompression: " + e.getMessage());
            e.printStackTrace();
        } catch (InterruptedException e) {
            System.err.println("Download was interrupted: " + e.getMessage());
            Thread.currentThread().interrupt();
        }
    }
}
