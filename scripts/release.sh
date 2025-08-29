#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 <version>"
            echo "Example: $0 v1.0.0"
            echo ""
            echo "This script will:"
            echo "  1. Build binaries for all platforms"
            echo "  2. Create a git tag with the specified version"
            echo "  3. Push the tag to trigger GitHub Actions release"
            exit 0
            ;;
        *)
            VERSION=$1
            shift
            ;;
    esac
done

# Check if version is provided
if [[ -z $VERSION ]]; then
    print_error "Usage: $0 <version>"
    print_error "Example: $0 v1.0.0"
    print_error "Use --help for more information"
    exit 1
fi

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Version must be in semantic versioning format (e.g., v1.0.0)"
    exit 1
fi

print_status "Creating release for version: $VERSION"

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ $CURRENT_BRANCH != "main" ]]; then
    print_warning "You're not on the main branch. Current branch: $CURRENT_BRANCH"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if working directory is clean
if [[ -n $(git status --porcelain) ]]; then
    print_error "Working directory is not clean. Please commit or stash your changes."
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$"; then
    print_error "Tag $VERSION already exists"
    exit 1
fi

print_status "Building binaries for all platforms..."

# Build for all platforms
make release

print_success "Binaries built successfully"

# Create and push tag
print_status "Creating git tag: $VERSION"
git tag $VERSION

print_status "Pushing tag to remote..."
git push origin $VERSION

print_success "Release $VERSION created successfully!"
print_status "GitHub Actions will now build and create the release automatically."
print_status "You can monitor the progress at: https://github.com/ahnopologetic/switchssh/actions"
