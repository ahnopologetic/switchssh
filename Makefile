.PHONY: build clean test release help

# Default target
help:
	@echo "Available targets:"
	@echo "  build    - Build the binary for current platform"
	@echo "  clean    - Remove build artifacts"
	@echo "  test     - Run tests"
	@echo "  release  - Build for all platforms"
	@echo "  install  - Install to ~/.local/bin"
	@echo "  help     - Show this help message"

# Build for current platform
build:
	go build -ldflags="-s -w" -o switchssh main.go

# Clean build artifacts
clean:
	rm -f switchssh
	rm -f switchssh-*

# Run tests
test:
	go test ./...

# Build for all platforms
release:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-s -w" -o switchssh-linux-amd64 main.go
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="-s -w" -o switchssh-linux-arm64 main.go
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-s -w" -o switchssh-darwin-amd64 main.go
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="-s -w" -o switchssh-darwin-arm64 main.go
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-s -w" -o switchssh-windows-amd64.exe main.go

# Install to ~/.local/bin
install: build
	mkdir -p ~/.local/bin
	cp switchssh ~/.local/bin/
	@echo "Installed to ~/.local/bin/switchssh"
	@echo "Make sure ~/.local/bin is in your PATH"

# Format code
fmt:
	go fmt ./...

# Run linter
lint:
	golangci-lint run

# Update dependencies
deps:
	go mod tidy
	go mod download
