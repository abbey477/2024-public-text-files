import java.io.*;
import java.util.zip.GZIPInputStream;
import java.nio.channels.FileChannel;
import java.nio.ByteBuffer;

public class LargeGZipFileReader {
    private static final int BUFFER_SIZE = 8192;
    
    public static void processLargeGzipFile(String inputPath, FileProcessor processor) throws IOException {
        try (FileInputStream fileIn = new FileInputStream(inputPath);
             BufferedInputStream bufferedIn = new BufferedInputStream(fileIn, BUFFER_SIZE);
             GZIPInputStream gzipIn = new GZIPInputStream(bufferedIn, BUFFER_SIZE)) {
            
            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;
            
            while ((bytesRead = gzipIn.read(buffer)) != -1) {
                processor.process(buffer, bytesRead);
            }
        }
    }
    
    // Memory-mapped file reading for very large files
    public static void processWithMemoryMapping(String inputPath, FileProcessor processor) throws IOException {
        try (FileInputStream fileIn = new FileInputStream(inputPath);
             FileChannel channel = fileIn.getChannel()) {
            
            long fileSize = channel.size();
            long position = 0;
            long mapSize = Math.min(fileSize, 1024 * 1024 * 1024); // 1GB chunks
            
            while (position < fileSize) {
                long remainingSize = fileSize - position;
                long currentMapSize = Math.min(mapSize, remainingSize);
                
                ByteBuffer buffer = channel.map(FileChannel.MapMode.READ_ONLY, position, currentMapSize);
                
                try (InputStream mappedIn = new ByteBufferBackedInputStream(buffer);
                     GZIPInputStream gzipIn = new GZIPInputStream(mappedIn, BUFFER_SIZE)) {
                    
                    byte[] readBuffer = new byte[BUFFER_SIZE];
                    int bytesRead;
                    
                    while ((bytesRead = gzipIn.read(readBuffer)) != -1) {
                        processor.process(readBuffer, bytesRead);
                    }
                }
                
                position += currentMapSize;
            }
        }
    }
    
    @FunctionalInterface
    public interface FileProcessor {
        void process(byte[] buffer, int bytesRead) throws IOException;
    }
    
    private static class ByteBufferBackedInputStream extends InputStream {
        private final ByteBuffer buffer;
        
        public ByteBufferBackedInputStream(ByteBuffer buffer) {
            this.buffer = buffer;
        }
        
        @Override
        public int read() {
            return buffer.hasRemaining() ? buffer.get() & 0xFF : -1;
        }
        
        @Override
        public int read(byte[] bytes, int off, int len) {
            if (!buffer.hasRemaining()) {
                return -1;
            }
            
            int readLen = Math.min(len, buffer.remaining());
            buffer.get(bytes, off, readLen);
            return readLen;
        }
    }
    
    public static void main(String[] args) {
        String filePath = "large-file.gz";
        
        try {
            // Example usage with standard streaming
            processLargeGzipFile(filePath, (buffer, bytesRead) -> {
                // Process decompressed data here
                System.out.write(buffer, 0, bytesRead);
            });
            
            // Example usage with memory mapping
            processWithMemoryMapping(filePath, (buffer, bytesRead) -> {
                // Process decompressed data here
                System.out.write(buffer, 0, bytesRead);
            });
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
