# Makefile for RedactSecure

APP_NAME=redactsecure
DECRYPT_NAME=redactsecure-decrypt
ENCRYPT_NAME=redactsecure-encrypt
VERSION=0.2.0
BUILD_DIR=bin

# Source directories
CMD_DIR=./cmd
MAIN_CMD=$(CMD_DIR)/$(APP_NAME)
DECRYPT_CMD=$(CMD_DIR)/$(DECRYPT_NAME)
ENCRYPT_CMD=$(CMD_DIR)/$(ENCRYPT_NAME)

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOMOD=$(GOCMD) mod

# Build flags
LDFLAGS=-ldflags "-s -w"

.PHONY: all build clean test windows linux macos-intel macos-arm release help

## all: Build for all platforms (Windows, Linux, macOS Intel & ARM)
all: clean windows linux macos-intel macos-arm
	@echo ""
	@echo "Built all platforms:"
	@ls -lh $(BUILD_DIR)/
	@echo ""
	@echo "Copying native binaries to root..."
	@cp $(BUILD_DIR)/$(APP_NAME)-darwin-arm64 ./$(APP_NAME)
	@cp $(BUILD_DIR)/$(DECRYPT_NAME)-darwin-arm64 ./$(DECRYPT_NAME)
	@cp $(BUILD_DIR)/$(ENCRYPT_NAME)-darwin-arm64 ./$(ENCRYPT_NAME)
	@echo "Done!"

## build: Build for current platform
build:
	@echo "Building for current platform..."
	$(GOBUILD) -o $(APP_NAME) $(LDFLAGS) $(MAIN_CMD)
	$(GOBUILD) -o $(DECRYPT_NAME) $(LDFLAGS) $(DECRYPT_CMD)
	$(GOBUILD) -o $(ENCRYPT_NAME) $(LDFLAGS) $(ENCRYPT_CMD)

## clean: Clean build artifacts
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -f $(APP_NAME) $(APP_NAME).exe $(DECRYPT_NAME) $(DECRYPT_NAME).exe $(ENCRYPT_NAME) $(ENCRYPT_NAME).exe

## test: Run tests
test:
	@echo "Running tests..."
	$(GOTEST) -v ./...

## windows: Build for Windows (64-bit)
windows:
	@echo "Building for Windows (64-bit)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(APP_NAME)-windows-amd64.exe $(LDFLAGS) $(MAIN_CMD)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(DECRYPT_NAME)-windows-amd64.exe $(LDFLAGS) $(DECRYPT_CMD)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(ENCRYPT_NAME)-windows-amd64.exe $(LDFLAGS) $(ENCRYPT_CMD)

## linux: Build for Linux (64-bit)
linux:
	@echo "Building for Linux (64-bit)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(APP_NAME)-linux-amd64 $(LDFLAGS) $(MAIN_CMD)
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(DECRYPT_NAME)-linux-amd64 $(LDFLAGS) $(DECRYPT_CMD)
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(ENCRYPT_NAME)-linux-amd64 $(LDFLAGS) $(ENCRYPT_CMD)

## macos-intel: Build for macOS (Intel)
macos-intel:
	@echo "Building for macOS (Intel)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(APP_NAME)-darwin-amd64 $(LDFLAGS) $(MAIN_CMD)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(DECRYPT_NAME)-darwin-amd64 $(LDFLAGS) $(DECRYPT_CMD)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(ENCRYPT_NAME)-darwin-amd64 $(LDFLAGS) $(ENCRYPT_CMD)

## macos-arm: Build for macOS (Apple Silicon)
macos-arm:
	@echo "Building for macOS (Apple Silicon)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) -o $(BUILD_DIR)/$(APP_NAME)-darwin-arm64 $(LDFLAGS) $(MAIN_CMD)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) -o $(BUILD_DIR)/$(DECRYPT_NAME)-darwin-arm64 $(LDFLAGS) $(DECRYPT_CMD)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) -o $(BUILD_DIR)/$(ENCRYPT_NAME)-darwin-arm64 $(LDFLAGS) $(ENCRYPT_CMD)
## release: Alias for 'all' - Build for all platforms
release: all

## deps: Download dependencies
deps:
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy

## help: Show this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

