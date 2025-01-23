import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import java.io.*;

public class SAXInvalidCharacterParser {
    
    public static void main(String[] args) {
        String xmlFile = "path/to/your/xml/file.xml";
        try {
            parseXMLFile(xmlFile);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void parseXMLFile(String filePath) throws Exception {
        // Create input stream with gzip decompression if needed
        InputStream inputStream = new FileInputStream(filePath);
        if (filePath.endsWith(".gz")) {
            inputStream = new java.util.zip.GZIPInputStream(inputStream);
        }
        Reader reader = new InvalidCharacterFilterReader(
            new InputStreamReader(inputStream, "UTF-8")
        );

        // Create SAX parser
        SAXParserFactory factory = SAXParserFactory.newInstance();
        factory.setValidating(false);
        factory.setNamespaceAware(true);
        
        SAXParser parser = factory.newSAXParser();
        CustomHandler handler = new CustomHandler();
        
        // Parse with custom input source
        InputSource is = new InputSource(reader);
        is.setEncoding("UTF-8");
        parser.parse(is, handler);
    }
}

// Custom handler for processing XML elements
class CustomHandler extends DefaultHandler {
    private StringBuilder currentValue = new StringBuilder();
    
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) {
        // Clear the string builder for new element
        currentValue.setLength(0);
        
        // Process attributes if needed
        if (attributes != null && attributes.getLength() > 0) {
            for (int i = 0; i < attributes.getLength(); i++) {
                String attrName = attributes.getQName(i);
                String attrValue = cleanInvalidCharacters(attributes.getValue(i));
                System.out.println("Attribute: " + attrName + " = " + attrValue);
            }
        }
    }
    
    @Override
    public void characters(char[] ch, int start, int length) {
        // Append text content
        currentValue.append(ch, start, length);
    }
    
    @Override
    public void endElement(String uri, String localName, String qName) {
        // Process element content
        String elementValue = cleanInvalidCharacters(currentValue.toString().trim());
        if (!elementValue.isEmpty()) {
            System.out.println("Element: " + qName + " = " + elementValue);
        }
    }
    
    private String cleanInvalidCharacters(String input) {
        if (input == null) return "";
        // Remove invalid XML characters while preserving valid ones
        return input.replaceAll("[^\\x09\\x0A\\x0D\\x20-\\xD7FF\\xE000-\\xFFFD\\x10000-x10FFFF]", "");
    }
}

// Custom reader to filter out invalid XML characters
class InvalidCharacterFilterReader extends Reader {
    private final Reader reader;
    
    public InvalidCharacterFilterReader(Reader reader) {
        this.reader = reader;
    }
    
    @Override
    public int read(char[] cbuf, int off, int len) throws IOException {
        int read = reader.read(cbuf, off, len);
        if (read == -1) return -1;
        
        // Filter invalid characters
        for (int i = off; i < off + read; i++) {
            char c = cbuf[i];
            if (!isValidXMLCharacter(c)) {
                cbuf[i] = ' '; // Replace invalid character with space
            }
        }
        return read;
    }
    
    @Override
    public void close() throws IOException {
        reader.close();
    }
    
    private boolean isValidXMLCharacter(char c) {
        return c == 0x9 || c == 0xA || c == 0xD ||
               (c >= 0x20 && c <= 0xD7FF) ||
               (c >= 0xE000 && c <= 0xFFFD) ||
               (c >= 0x10000 && c <= 0x10FFFF);
    }
}
