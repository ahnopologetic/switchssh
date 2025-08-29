package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

// SSHKey represents a registered SSH key
type SSHKey struct {
	Path     string `json:"path"`
	Alias    string `json:"alias"`
	SudoMode bool   `json:"sudo_mode"`
}

// Config represents the configuration file structure
type Config struct {
	Keys []SSHKey `json:"keys"`
}

var (
	configPath string
	config     Config
)

func init() {
	// Get user's home directory
	usr, err := user.Current()
	if err != nil {
		fmt.Printf("Error getting user home directory: %v\n", err)
		os.Exit(1)
	}

	configPath = filepath.Join(usr.HomeDir, ".switchssh")
}

func main() {
	var rootCmd = &cobra.Command{
		Use:   "switchssh",
		Short: "A CLI tool to manage and switch between SSH keys",
		Long:  `SwitchSSH is a command-line tool that allows you to easily manage and switch between different SSH keys.`,
	}

	var setupCmd = &cobra.Command{
		Use:   "setup",
		Short: "Setup a new SSH key",
		Long:  `Register a new SSH key file with an optional alias for easy identification.`,
		Run:   setupCommand,
	}

	var switchCmd = &cobra.Command{
		Use:   "switch",
		Short: "Switch to a different SSH key",
		Long:  `Select and switch to a different SSH key from your registered keys.`,
		Run:   switchCommand,
	}

	var listCmd = &cobra.Command{
		Use:   "list",
		Short: "List all registered SSH keys",
		Long:  `Display all registered SSH keys with their aliases and paths.`,
		Run:   listCommand,
	}

	rootCmd.AddCommand(setupCmd, switchCmd, listCmd)
	rootCmd.Execute()
}

func setupCommand(cmd *cobra.Command, args []string) {
	loadConfig()

	reader := bufio.NewReader(os.Stdin)

	// Get key file path
	fmt.Print("Enter the path to your SSH key file: ")
	keyPath, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error reading input: %v\n", err)
		return
	}
	keyPath = strings.TrimSpace(keyPath)

	// Check if file exists
	if _, err := os.Stat(keyPath); os.IsNotExist(err) {
		fmt.Printf("Error: SSH key file not found at %s\n", keyPath)
		return
	}

	// Get alias (optional)
	fmt.Print("Enter an alias for this key (optional, press Enter to skip): ")
	alias, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error reading input: %v\n", err)
		return
	}
	alias = strings.TrimSpace(alias)

	// If no alias provided, use filename
	if alias == "" {
		alias = filepath.Base(keyPath)
	}

	// Ask for sudo mode
	fmt.Print("Use sudo mode for this key? (y/N): ")
	sudoInput, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error reading input: %v\n", err)
		return
	}
	sudoMode := strings.ToLower(strings.TrimSpace(sudoInput)) == "y"

	// Create new SSH key entry
	newKey := SSHKey{
		Path:     keyPath,
		Alias:    alias,
		SudoMode: sudoMode,
	}

	// Check if alias already exists
	for _, key := range config.Keys {
		if key.Alias == alias {
			fmt.Printf("Error: Alias '%s' already exists. Please choose a different alias.\n", alias)
			return
		}
	}

	// Add to config
	config.Keys = append(config.Keys, newKey)

	// Save config
	if err := saveConfig(); err != nil {
		fmt.Printf("Error saving configuration: %v\n", err)
		return
	}

	fmt.Printf("Successfully registered SSH key: %s (%s)\n", alias, keyPath)
}

func switchCommand(cmd *cobra.Command, args []string) {
	loadConfig()

	if len(config.Keys) == 0 {
		fmt.Println("No SSH keys registered. Use 'switchssh setup' to add your first key.")
		return
	}

	// Display available keys
	fmt.Println("Available SSH keys:")
	for i, key := range config.Keys {
		sudoText := ""
		if key.SudoMode {
			sudoText = " (sudo)"
		}
		fmt.Printf("%d. %s%s - %s\n", i+1, key.Alias, sudoText, key.Path)
	}

	// Get user selection
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("\nSelect a key (enter number): ")
	selection, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error reading input: %v\n", err)
		return
	}

	// Parse selection
	var index int
	_, err = fmt.Sscanf(strings.TrimSpace(selection), "%d", &index)
	if err != nil || index < 1 || index > len(config.Keys) {
		fmt.Println("Invalid selection. Please enter a valid number.")
		return
	}

	selectedKey := config.Keys[index-1]

	// Clear existing SSH keys
	fmt.Println("Clearing existing SSH keys...")
	clearCmd := exec.Command("ssh-add", "-D")
	clearCmd.Stdout = os.Stdout
	clearCmd.Stderr = os.Stderr
	if err := clearCmd.Run(); err != nil {
		fmt.Printf("Warning: Could not clear existing SSH keys: %v\n", err)
	}

	// Add selected key
	fmt.Printf("Adding SSH key: %s\n", selectedKey.Alias)

	var addCmd *exec.Cmd
	if selectedKey.SudoMode {
		addCmd = exec.Command("sudo", "ssh-add", selectedKey.Path)
	} else {
		addCmd = exec.Command("ssh-add", selectedKey.Path)
	}

	addCmd.Stdout = os.Stdout
	addCmd.Stderr = os.Stderr
	addCmd.Stdin = os.Stdin

	if err := addCmd.Run(); err != nil {
		fmt.Printf("Error adding SSH key: %v\n", err)
		return
	}

	fmt.Printf("Successfully switched to SSH key: %s\n", selectedKey.Alias)
}

func listCommand(cmd *cobra.Command, args []string) {
	loadConfig()

	if len(config.Keys) == 0 {
		fmt.Println("No SSH keys registered. Use 'switchssh setup' to add your first key.")
		return
	}

	fmt.Println("Registered SSH keys:")
	fmt.Println("====================")
	for i, key := range config.Keys {
		sudoText := ""
		if key.SudoMode {
			sudoText = " (sudo)"
		}
		fmt.Printf("%d. %s%s\n   Path: %s\n\n", i+1, key.Alias, sudoText, key.Path)
	}
}

func loadConfig() {
	// Create config directory if it doesn't exist
	configDir := filepath.Dir(configPath)
	if err := os.MkdirAll(configDir, 0755); err != nil {
		fmt.Printf("Error creating config directory: %v\n", err)
		os.Exit(1)
	}

	// Read existing config
	data, err := os.ReadFile(configPath)
	if err != nil {
		if os.IsNotExist(err) {
			// Create new config
			config = Config{Keys: []SSHKey{}}
			return
		}
		fmt.Printf("Error reading config file: %v\n", err)
		os.Exit(1)
	}

	// Parse config
	if err := json.Unmarshal(data, &config); err != nil {
		fmt.Printf("Error parsing config file: %v\n", err)
		os.Exit(1)
	}
}

func saveConfig() error {
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(configPath, data, 0644)
}
