# SwitchSSH

A simple CLI tool to manage and switch between SSH keys easily.

## Features

- **Setup SSH Keys**: Register PEM files with optional aliases for easy identification
- **Switch Between Keys**: Quickly switch between registered SSH keys
- **Sudo Mode Support**: Optionally use sudo for specific keys
- **Cross-Platform**: Works on macOS and Linux
- **Simple Configuration**: Stores settings in `~/.switchssh`

## Installation

### Quick Install (Recommended)

The easiest way to install SwitchSSH is using our installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/ahnopologetic/switchssh/main/install.sh | bash
```

This will:
- Automatically detect your platform (macOS/Linux)
- Download the latest release
- Install to `~/.local/bin`
- Make the binary executable

### Manual Installation

1. **Download the binary** for your platform from the [latest release](https://github.com/ahnopologetic/switchssh/releases/latest):
   - `switchssh-darwin-amd64` - macOS (Intel)
   - `switchssh-darwin-arm64` - macOS (Apple Silicon)
   - `switchssh-linux-amd64` - Linux (x86_64)
   - `switchssh-linux-arm64` - Linux (ARM64)
   - `switchssh-windows-amd64.exe` - Windows

2. **Make it executable** (macOS/Linux):
   ```bash
   chmod +x switchssh-*
   ```

3. **Move to your PATH**:
   ```bash
   # Option 1: Install to ~/.local/bin (recommended)
   mkdir -p ~/.local/bin
   mv switchssh-* ~/.local/bin/switchssh
   
   # Option 2: Install to /usr/local/bin (requires sudo)
   sudo mv switchssh-* /usr/local/bin/switchssh
   ```

4. **Add to PATH** (if using ~/.local/bin):
   ```bash
   # Add this line to your ~/.bashrc, ~/.zshrc, or ~/.profile
   export PATH="$HOME/.local/bin:$PATH"
   ```

### From Source

If you want to build from source:

1. Clone this repository
2. Build the binary:
   ```bash
   go build -o switchssh main.go
   ```
3. Add the binary to your PATH or use it directly

## Usage

After installation, you can use SwitchSSH directly from anywhere in your terminal:

```bash
switchssh <command>
```

### Setup a new SSH key

```bash
./switchssh setup
```

This will prompt you for:
- Path to your SSH key file
- An optional alias (if not provided, uses the filename)
- Whether to use sudo mode for this key

### Switch to a different SSH key

```bash
./switchssh switch
```

This will:
1. Display all registered SSH keys
2. Let you select one by number
3. Clear existing SSH keys from ssh-agent
4. Add the selected key

### List all registered SSH keys

```bash
./switchssh list
```

Shows all registered keys with their aliases, paths, and sudo mode status.

## Configuration

The tool stores configuration in `~/.switchssh` as a JSON file. The structure is:

```json
{
  "keys": [
    {
      "path": "/path/to/your/key.pem",
      "alias": "my-key",
      "sudo_mode": false
    }
  ]
}
```

## Requirements

- Go 1.25.0 or later
- SSH key files (PEM format)
- `ssh-add` command available in PATH

## Dependencies

- `github.com/spf13/cobra` - CLI framework
- Standard Go libraries

## Example Workflow

1. **Setup your first key**:
   ```bash
   ./switchssh setup
   # Enter: /Users/username/.ssh/id_rsa
   # Enter: personal
   # Enter: n (for sudo mode)
   ```

2. **Setup another key**:
   ```bash
   ./switchssh setup
   # Enter: /Users/username/.ssh/work_key.pem
   # Enter: work
   # Enter: y (for sudo mode)
   ```

3. **Switch between keys**:
   ```bash
   ./switchssh switch
   # Select 1 for personal key
   # Select 2 for work key
   ```

## Error Handling

- Validates that SSH key files exist before registration
- Checks for duplicate aliases
- Handles SSH agent errors gracefully
- Provides clear error messages for common issues

## Project Structure

```
switchssh/
├── .github/workflows/    # GitHub Actions workflows
├── scripts/              # Utility scripts
│   └── release.sh        # Release automation script
├── main.go               # Main application code
├── go.mod                # Go module definition
├── go.sum                # Go module checksums
├── Makefile              # Build and development tasks
├── install.sh            # Installation script
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Development

### Building

To build the project locally:

```bash
go build -o switchssh main.go
```

### Creating a Release

1. **Update version** and commit changes
2. **Use the release script** (recommended):
   ```bash
   ./scripts/release.sh v1.0.0
   ```
   
   Or manually create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. **GitHub Actions** will automatically:
   - Build binaries for all platforms
   - Create a release with the tag
   - Attach all binary files to the release

### Release Workflow

The project uses GitHub Actions to automatically build and release binaries when you push a semantic versioned tag (e.g., `v1.0.0`). The workflow:

- Builds for: Linux (amd64, arm64), macOS (amd64, arm64), Windows (amd64)
- Creates optimized binaries with stripped symbols
- Attaches all binaries to the GitHub release

## Future Improvements

- Interactive key selection with arrow keys
- Key removal functionality
- Backup and restore configuration
- SSH key validation
- Integration with SSH config files

