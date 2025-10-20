#!/bin/bash
# Build script for KrankyBear RedactSecure
# Builds binaries for Windows, Linux, and macOS

set -e

echo "Building KrankyBear RedactSecure..."
echo ""

# Create bin directory
mkdir -p bin

# Build for Windows
echo "Building for Windows (amd64)..."
GOOS=windows GOARCH=amd64 go build -o bin/redactsecure-windows-amd64.exe ./cmd/redactsecure
GOOS=windows GOARCH=amd64 go build -o bin/redactsecure-decrypt-windows-amd64.exe ./cmd/redactsecure-decrypt
GOOS=windows GOARCH=amd64 go build -o bin/redactsecure-encrypt-windows-amd64.exe ./cmd/redactsecure-encrypt

# Build for Linux
echo "Building for Linux (amd64)..."
GOOS=linux GOARCH=amd64 go build -o bin/redactsecure-linux-amd64 ./cmd/redactsecure
GOOS=linux GOARCH=amd64 go build -o bin/redactsecure-decrypt-linux-amd64 ./cmd/redactsecure-decrypt
GOOS=linux GOARCH=amd64 go build -o bin/redactsecure-encrypt-linux-amd64 ./cmd/redactsecure-encrypt
# Note: setIcon.sh should not be used on raw executables as it can corrupt them

# Build for macOS Intel
echo "Building for macOS (amd64)..."
GOOS=darwin GOARCH=amd64 go build -o bin/redactsecure-darwin-amd64 ./cmd/redactsecure
GOOS=darwin GOARCH=amd64 go build -o bin/redactsecure-decrypt-darwin-amd64 ./cmd/redactsecure-decrypt
GOOS=darwin GOARCH=amd64 go build -o bin/redactsecure-encrypt-darwin-amd64 ./cmd/redactsecure-encrypt
# Note: setIcon.sh should not be used on raw executables as it can corrupt them

# Build for macOS Apple Silicon
echo "Building for macOS (arm64)..."
GOOS=darwin GOARCH=arm64 go build -o bin/redactsecure-darwin-arm64 ./cmd/redactsecure
GOOS=darwin GOARCH=arm64 go build -o bin/redactsecure-decrypt-darwin-arm64 ./cmd/redactsecure-decrypt
GOOS=darwin GOARCH=arm64 go build -o bin/redactsecure-encrypt-darwin-arm64 ./cmd/redactsecure-encrypt
# Note: setIcon.sh should not be used on raw executables as it can corrupt them

echo ""
echo "Build complete! Binaries are in the 'bin/' directory:"
ls -lh bin/
cp bin/redactsecure-darwin-arm64 ./redactsecure
cp bin/redactsecure-decrypt-darwin-arm64 ./redactsecure-decrypt
cp bin/redactsecure-encrypt-darwin-arm64 ./redactsecure-encrypt
