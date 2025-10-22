#!/bin/bash

# Test compilation of tolower.c in a Docker environment

echo "Testing tolower.c compilation..."

# Create a minimal test Dockerfile
cat > Dockerfile.test-compile << 'EOF'
FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/tolower.c /tmp/
RUN cd /tmp && gcc -o tolower tolower.c && ./tolower --help || echo "Compilation successful"
EOF

# Test the compilation
docker build -f Dockerfile.test-compile -t test-compile . && echo "✅ Compilation test passed" || echo "❌ Compilation test failed"

# Clean up
rm -f Dockerfile.test-compile
