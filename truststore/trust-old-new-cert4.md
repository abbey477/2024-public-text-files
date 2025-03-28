Here's how to add a certificate to your Java truststore using keytool:

1. Download the certificate from the API server using a browser or command-line tool like curl:
   ```
   curl -O https://api-server-url/certificate.crt
   ```

2. Verify if the jssecacerts file exists in your Java lib/security directory:
   ```
   ls $JAVA_HOME/lib/security/jssecacerts
   ```

3. If jssecacerts doesn't exist, make a copy of cacerts to create it:
   ```
   cp $JAVA_HOME/lib/security/cacerts $JAVA_HOME/lib/security/jssecacerts
   ```

4. Import the certificate into jssecacerts (this is the preferred truststore):
   ```
   keytool -importcert -file certificate.crt -alias api-server-cert -keystore $JAVA_HOME/lib/security/jssecacerts -storepass changeit
   ```

5. If you need to add it to cacerts as well:
   ```
   keytool -importcert -file certificate.crt -alias api-server-cert -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
   ```

6. Verify the certificate was imported correctly:
   ```
   keytool -list -alias api-server-cert -keystore $JAVA_HOME/lib/security/jssecacerts -storepass changeit
   ```

7. Restart any Java applications that need to use the updated truststore.

Note: The default password for Java keystores is typically "changeit" - adjust if your environment uses a different password.