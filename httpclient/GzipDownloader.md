import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.io.entity.EntityUtils;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.zip.GZIPInputStream;

public class GzipDownloader {
    
    public void downloadAndDecompress(String url, Path outputPath) {
        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpGet httpGet = new HttpGet(url);
            
            // Add appropriate headers
            httpGet.addHeader("Accept-Encoding", "gzip");
            
            // Execute the request and process the response
            httpClient.execute(httpGet, response -> {
                HttpEntity entity = response.getEntity();
                if (entity != null) {
                    try (InputStream inputStream = entity.getContent();
                         GZIPInputStream gzipInputStream = new GZIPInputStream(inputStream);
                         FileOutputStream outputStream = new FileOutputStream(outputPath.toFile())) {
                         
                        // Copy the decompressed content to the output file
                        byte[] buffer = new byte[8192];
                        int bytesRead;
                        while ((bytesRead = gzipInputStream.read(buffer)) != -1) {
                            outputStream.write(buffer, 0, bytesRead);
                        }
                        
                        outputStream.flush();
                    }
                }
                EntityUtils.consume(entity);
                return null;
            });
        } catch (Exception e) {
            throw new RuntimeException("Error downloading or decompressing file", e);
        }
    }
    
    // Example usage
    public static void main(String[] args) {
        GzipDownloader downloader = new GzipDownloader();
        String url = "https://example.com/file.gz";
        Path outputPath = Path.of("decompressed_file.txt");
        
        downloader.downloadAndDecompress(url, outputPath);
        System.out.println("File downloaded and decompressed successfully!");
    }
}
