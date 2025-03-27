When using Apache HttpClient 5 without explicitly configuring a trust store manager, you're benefiting from several default behaviors that handle certificate validation automatically:

1. **Default Trust Store Usage**: Apache HttpClient 5 uses the JVM's default trust store (usually `cacerts` located in `$JAVA_HOME/lib/security/`) when no custom trust manager is specified. This trust store contains certificates from well-known Certificate Authorities (CAs).

2. **System Properties Integration**: HttpClient 5 respects the standard Java system properties for SSL configuration:
   - `javax.net.ssl.trustStore`
   - `javax.net.ssl.trustStorePassword`
   - `javax.net.ssl.trustStoreType`

3. **JVM Security Providers**: The default implementation leverages Java's security providers, which handle certificate validation according to the PKIX (Public Key Infrastructure X.509) standard.

4. **Host Verification**: By default, HttpClient performs hostname verification against the certificate's Subject Alternative Names (SANs) or Common Name (CN).

This means that as long as:
- Your OAuth2 server's certificate is issued by a trusted CA already in Java's default trust store
- The certificate has valid dates (not expired)
- The hostname in your request matches the certificate's SAN/CN
- The certificate chain is complete and valid

Then HttpClient 5 will validate the connection successfully without you needing to implement custom trust management.

When certificates are rotated, as long as the new certificate meets these same criteria (especially being issued by a CA already in the trust store), your client application should continue to work without any changes.

You would only need to implement custom trust management if:
- You're using certificates from non-standard/private CAs
- You need to implement certificate pinning
- You require custom validation logic
- You need to bypass certain validations in specific situations

Does this align with what you're experiencing in your application?
