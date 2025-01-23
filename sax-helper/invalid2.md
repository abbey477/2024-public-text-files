import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import java.io.*;
import java.util.zip.GZIPInputStream;

public class GZippedXMLParser {
    
    public static void main(String[] args) {
        String gzippedXmlFile = "path/to/your/file.xml.gz";
        parseGZippedXML(gzippedXmlFile);
    }

    public static void parseGZippedXML(String filePath) {
        try {
            // Create SAX Parser Factory and Parser
            SAXParserFactory factory = SAXParserFactory.newInstance();
            factory.setValidating(false);
            factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
            SAXParser saxParser = factory.newSAXParser();

            // Create Custom Handler
            CustomXMLHandler handler = new CustomXMLHandler();

            // Create GZIPInputStream
            try (FileInputStream fileIn = new FileInputStream(filePath);
                 GZIPInputStream gzipIn = new GZIPInputStream(fileIn);
                 InputStreamReader reader = new InputStreamReader(gzipIn, "UTF-8")) {

                // Create InputSource with proper encoding
                InputSource inputSource = new InputSource(reader);
                inputSource.setEncoding("UTF-8");

                // Parse the XML
                saxParser.parse(inputSource, handler);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class CustomXMLHandler extends DefaultHandler {
    private StringBuilder currentValue = new StringBuilder();
    private static final char REPLACEMENT_CHAR = '\uFFFD';

    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) 
            throws SAXException {
        // Reset the StringBuilder for new element
        currentValue.setLength(0);
        
        // Process attributes if needed
        if (attributes != null && attributes.getLength() > 0) {
            for (int i = 0; i < attributes.getLength(); i++) {
                String attrName = attributes.getQName(i);
                String attrValue = cleanInvalidChars(attributes.getValue(i));
                // Process attribute here
                System.out.println("Attribute: " + attrName + " = " + attrValue);
            }
        }
    }

    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        // Append the cleaned character data
        String cleanedData = cleanInvalidChars(new String(ch, start, length));
        currentValue.append(cleanedData);
    }

    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        // Get the cleaned element content
        String elementContent = currentValue.toString().trim();
        
        // Process element content here
        if (!elementContent.isEmpty()) {
            System.out.println("Element: " + qName + " = " + elementContent);
        }
    }

    private String cleanInvalidChars(String input) {
        if (input == null) {
            return "";
        }

        StringBuilder cleaned = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            // Check for invalid XML characters according to XML 1.0 specification
            if (isValidXMLChar(c)) {
                cleaned.append(c);
            } else {
                cleaned.append(REPLACEMENT_CHAR);
            }
        }
        return cleaned.toString();
    }

    private boolean isValidXMLChar(char c) {
        // XML 1.0 valid character ranges
        return (c == 0x9) ||                  // Tab
               (c == 0xA) ||                  // Line feed
               (c == 0xD) ||                  // Carriage return
               ((c >= 0x20) && (c <= 0xD7FF)) ||
               ((c >= 0xE000) && (c <= 0xFFFD)) ||
               ((c >= 0x10000) && (c <= 0x10FFFF));
    }
}

// Usage Example
class XMLParserExample {
    public static void main(String[] args) {
        String gzippedXmlFile = "data.xml.gz";
        
        try {
            GZippedXMLParser.parseGZippedXML(gzippedXmlFile);
        } catch (Exception e) {
            System.err.println("Error parsing XML: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
