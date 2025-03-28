When the old certificate in your trust store expires, the behavior of your Java client depends on how the SSL/TLS handshake process works and your specific configuration. Here's what happens:

## Certificate Selection During SSL/TLS Handshake

When your Java client connects to an HTTPS server:

1. The server presents its current certificate (which would be the new one after rotation)
2. Your Java client checks if this certificate is trusted by looking in its trust store
3. If the new certificate is already in your trust store, the connection succeeds regardless of whether the old certificate has expired

The expiration of the old certificate in your trust store generally doesn't affect this process as long as:
- The server is presenting its new, valid certificate
- Your trust store contains this new certificate

## No Automatic Switching Required

There's no "switching" that needs to happen in your trust store because:

- Trust stores don't actively select which certificate to trust - they simply contain a collection of trusted certificates
- During the TLS handshake, the client checks if the server's presented certificate (or its issuing CA) is in the trust store
- The expiration date of other certificates in your trust store doesn't affect this validation process

## Important Considerations

1. **Trust Store Maintenance**: While Java doesn't automatically remove expired certificates from your trust store, it's good practice to periodically clean up expired certificates to maintain good security hygiene.

2. **Validation Behavior**: By default, Java will check certificate validity dates during validation. The `checkValidity()` method is called on certificates to ensure they haven't expired.

3. **Certificate Chain Validation**: Remember that Java validates the entire certificate chain, so if your server certificate is signed by an intermediate CA, that CA certificate must also be valid and trusted.

4. **Server-side Certificate**: The critical factor is what certificate the server presents, not what's in your trust store. If the server continues presenting an expired certificate, your connection will fail even if you have the new certificate in your trust store.

## Code Example with Default Validation

The standard Java HTTPS client behavior includes date validation:

```java
// This standard configuration will check certificate expiration dates
HttpsURLConnection connection = (HttpsURLConnection) new URL("https://example.com").openConnection();
connection.connect(); // Will fail if server presents an expired certificate
```

In summary, you don't need special configuration for your Java client to "switch" to the new certificate. As long as both certificates are in your trust store during the transition period, and the server starts presenting the new certificate before the old one expires, your client will continue to function without interruption. The presence of the expired certificate in your trust store doesn't cause problems, though it's good practice to remove it eventually.