# SwitchSSH

A simple CLI tool to manage and switch between SSH keys easily.

## Features

- **Setup SSH Keys**: Register PEM files with optional aliases for easy identification
- **Switch Between Keys**: Quickly switch between registered SSH keys
- **Sudo Mode Support**: Optionally use sudo for specific keys
- **Cross-Platform**: Works on macOS and Linux
- **Simple Configuration**: Stores settings in `~/.switchssh`

## Installation

1. Clone this repository
2. Build the binary:
   ```bash
   go build -o switchssh main.go
   ```
3. Add the binary to your PATH or use it directly

## Usage

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

## Future Improvements

- Interactive key selection with arrow keys
- Key removal functionality
- Backup and restore configuration
- SSH key validation
- Integration with SSH config files

