import java.io.*;
import java.util.zip.GZIPInputStream;

public class GZipFileReader {
    public static InputStream readGzippedFile(String filePath) throws IOException {
        // Create FileInputStream for the gzipped file
        FileInputStream fileIn = new FileInputStream(filePath);
        
        // Create buffered input stream for better performance
        BufferedInputStream bufferedIn = new BufferedInputStream(fileIn);
        
        // Create GZIPInputStream to decompress the data
        return new GZIPInputStream(bufferedIn);
    }
    
    public static String readGzippedFileAsString(String filePath) throws IOException {
        try (InputStream gzipStream = readGzippedFile(filePath);
             Reader reader = new InputStreamReader(gzipStream);
             BufferedReader buffered = new BufferedReader(reader)) {
            
            StringBuilder content = new StringBuilder();
            String line;
            
            while ((line = buffered.readLine()) != null) {
                content.append(line).append("\n");
            }
            
            return content.toString();
        }
    }
    
    public static void main(String[] args) {
        String filePath = "example.txt.gz";
        
        try {
            // Example 1: Reading as InputStream
            try (InputStream gzipStream = readGzippedFile(filePath)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                
                while ((bytesRead = gzipStream.read(buffer)) != -1) {
                    // Process bytes here
                    System.out.write(buffer, 0, bytesRead);
                }
            }
            
            // Example 2: Reading as String
            String content = readGzippedFileAsString(filePath);
            System.out.println("File content: " + content);
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
