```bash
curl --compressed \
  -H "Accept-Encoding: gzip" \
  -H "Authorization: Bearer ${OAUTH_TOKEN}" \
  http://example.com/endpoint
```

To use a variable:
```bash
OAUTH_TOKEN="your_token_here"
```

Or pass directly:
```bash 
curl -H "Authorization: Bearer your_token_here" ...
```
