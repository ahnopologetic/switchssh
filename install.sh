#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
REPO="ahnopologetic/switchssh"
VERSION="latest"
INSTALL_DIR="$HOME/.local/bin"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -d|--directory)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --version VERSION    Install specific version (default: latest)"
            echo "  -d, --directory DIR      Install to specific directory (default: ~/.local/bin)"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_status "Installing SwitchSSH..."

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture to GitHub release asset names
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Map OS to GitHub release asset names
case $OS in
    linux)
        OS="linux"
        ;;
    darwin)
        OS="darwin"
        ;;
    *)
        print_error "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Determine binary name
if [[ $OS == "windows" ]]; then
    BINARY_NAME="switchssh-windows-${ARCH}.exe"
else
    BINARY_NAME="switchssh-${OS}-${ARCH}"
fi

print_status "Detected platform: ${OS}-${ARCH}"
print_status "Binary name: ${BINARY_NAME}"

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Determine download URL
if [[ $VERSION == "latest" ]]; then
    # Get latest release
    LATEST_TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z $LATEST_TAG ]]; then
        print_warning "Could not determine latest version from GitHub releases"
        print_status "This might be because no releases exist yet."
        print_status "You can build from source or specify a version manually."
        print_status "To build from source:"
        echo "  git clone https://github.com/${REPO}.git"
        echo "  cd switchssh"
        echo "  go build -o switchssh main.go"
        exit 1
    fi
    VERSION=$LATEST_TAG
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}"

print_status "Downloading SwitchSSH ${VERSION}..."

# Download the binary
if curl -L -o "${INSTALL_DIR}/switchssh" "$DOWNLOAD_URL"; then
    chmod +x "${INSTALL_DIR}/switchssh"
    print_success "Downloaded SwitchSSH to ${INSTALL_DIR}/switchssh"
else
    print_error "Failed to download SwitchSSH"
    exit 1
fi

# Check if the binary is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "The installation directory ($INSTALL_DIR) is not in your PATH"
    print_status "To add it to your PATH, add this line to your shell configuration file (.bashrc, .zshrc, etc.):"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    print_status "Or you can run SwitchSSH directly with:"
    echo "${INSTALL_DIR}/switchssh"
else
    print_success "SwitchSSH is now available as 'switchssh' command"
fi

print_success "Installation completed!"
print_status "You can now use: switchssh --help"
