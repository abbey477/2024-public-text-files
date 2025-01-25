import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.message.StatusLine;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.GZIPInputStream;

public class GzipDownloader {
    
    public void downloadAndDecompress(String url, String outputPath) throws IOException {
        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpGet request = new HttpGet(url);
            request.addHeader("Accept-Encoding", "gzip");
            
            try (CloseableHttpResponse response = httpClient.execute(request)) {
                StatusLine statusLine = new StatusLine(response);
                if (statusLine.getStatusCode() != 200) {
                    throw new IOException("Unexpected response: " + statusLine);
                }
                
                HttpEntity entity = response.getEntity();
                if (entity == null) {
                    throw new IOException("No response entity received");
                }
                
                try (var inputStream = entity.getContent();
                     var gzipStream = new GZIPInputStream(inputStream);
                     var outputStream = new FileOutputStream(outputPath)) {
                    
                    gzipStream.transferTo(outputStream);
                }
            }
        }
    }
    
    public static void main(String[] args) {
        try {
            GzipDownloader downloader = new GzipDownloader();
            downloader.downloadAndDecompress("https://example.com/file.gz", "output_file.txt");
            System.out.println("File downloaded and decompressed successfully");
        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
