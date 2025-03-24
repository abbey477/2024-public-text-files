Curl itself doesn't have built-in async functionality, but there are several ways to achieve asynchronous downloads:



```bash
#!/bin/bash

# Method 1: Using curl's built-in parallel transfer
curl --parallel --parallel-max 5 \
     http://example.com/file1.gz \
     http://example.com/file2.gz \
     http://example.com/file3.gz

# Method 2: Using background processes
for url in http://example.com/file{1..3}.gz; do
    curl -O "$url" &
done
wait

# Method 3: Using xargs
echo "http://example.com/file1.gz
http://example.com/file2.gz
http://example.com/file3.gz" | xargs -P 4 -I {} curl -O {}

# Method 4: Using GNU Parallel (most flexible)
parallel -j4 curl -O ::: \
    http://example.com/file1.gz \
    http://example.com/file2.gz \
    http://example.com/file3.gz

```

The `--parallel` flag was added in curl 7.66.0. For older versions, use methods 2-4 instead.
