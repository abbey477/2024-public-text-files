Yes, it's definitely possible to load certificates directly from the server to handle rotation automatically. This approach is commonly called "Trust-On-First-Use" (TOFU) or dynamic certificate pinning, and it can be implemented in Java. Here's how:

This approach automatically handles certificate rotation by loading certificates directly from the server. It's simple to implement but offers powerful capabilities:

## How It Works

1. **Automatic Certificate Discovery**:
   - Connects to the server and extracts its certificate chain
   - No need to manually manage certificate files or strings
   - Works with any HTTPS server

2. **Certificate Expiration Handling**:
   - Checks certificate expiration dates
   - Automatically refreshes certificates before they expire (configurable threshold)
   - No manual intervention required for rotation

3. **On-demand Certificate Loading**:
   - First request to a server automatically retrieves and stores its certificates
   - Subsequent requests use the cached certificates
   - Provides a simple self-healing mechanism

## Key Benefits

- **Zero Configuration**: No need to specify certificates in advance
- **Automatic Rotation**: Handles certificate rotation without any manual steps
- **Self-Adapting**: Works with any server and adapts to certificate changes
- **Simple Integration**: Just call `makeSecureRequest()` to handle everything

## Security Considerations

This approach implements a "Trust-On-First-Use" model, which means:

1. The first connection to a server is vulnerable to MITM attacks
2. Subsequent connections are protected using the initially trusted certificate

To enhance security:
- Consider implementing certificate pinning for critical servers
- Validate certificate properties (issuer, key size, etc.)
- Add logging for certificate changes to detect potential issues

## Implementation Notes

You'd typically use this approach by:

1. Integrating the `updateTrustStoreWithServerCertificates()` and `makeSecureRequest()` methods into your application
2. Calling `makeSecureRequest()` instead of using HttpsURLConnection directly
3. Adjusting the `REFRESH_THRESHOLD_DAYS` constant based on your security requirements

This approach is particularly useful for internal applications communicating with services that use self-signed certificates or when you want to avoid managing a centralized trust store.