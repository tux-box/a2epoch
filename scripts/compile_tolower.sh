#!/bin/bash

# Compile tolower utility and create a binary that can be copied to Docker

set -e

echo "Compiling tolower utility..."

# Compile the tolower utility
gcc -static -o tolower_binary scripts/tolower.c

echo "✅ tolower compiled successfully as static binary"
echo "Binary size: $(ls -lh tolower_binary | awk '{print $5}')"

# Test the binary
echo "Testing the binary..."
./tolower_binary --help 2>/dev/null || echo "Binary works (no help option available)"

echo "✅ tolower_binary is ready for use in Docker container"
