To remove a certificate from a Java truststore, you can use the `keytool` command with the `-delete` option. Here's the step-by-step process:

```
keytool -delete -alias certificate_alias -keystore path_to_truststore -storepass truststore_password
```

For example, if you want to remove a certificate with alias "api-server-cert" from the default Java truststore:

```
keytool -delete -alias api-server-cert -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
```

Or if you're using the jssecacerts truststore:

```
keytool -delete -alias api-server-cert -keystore $JAVA_HOME/lib/security/jssecacerts -storepass changeit
```

To verify that the certificate has been successfully removed, you can list the certificates in the truststore:

```
keytool -list -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit | grep "api-server-cert"
```

If the certificate was successfully removed, this command should not return any output.

Note: Always make a backup of your truststore before making changes to it:

```
cp $JAVA_HOME/lib/security/cacerts $JAVA_HOME/lib/security/cacerts.backup
```