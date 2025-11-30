#!/bin/bash

# This script runs once to install VS Code and set up the CLI command
# It only runs if VS Code is not already installed

set -e

VSCODE_APP="/Applications/Visual Studio Code.app"
CODE_BIN_PATH="/usr/local/bin/code"

# Check if VS Code is already installed
if [ -d "$VSCODE_APP" ]; then
    echo "VS Code is already installed at $VSCODE_APP"

    # Still check if CLI needs setup
    if command -v code &> /dev/null && code --version &> /dev/null; then
        echo "'code' CLI command is already available and working."
        exit 0
    fi
else
    echo "#############################################"
    echo ""
    echo "Installing Visual Studio Code"
    echo ""

    # Install VS Code via homebrew
    brew install --cask visual-studio-code

    echo ""
    echo "VS Code installed successfully"
fi

# Set up the CLI command
echo ""
echo "Setting up VS Code CLI command"
echo ""

VSCODE_CLI="$VSCODE_APP/Contents/Resources/app/bin/code"

if [ -f "$VSCODE_CLI" ]; then
    if [ -L "$CODE_BIN_PATH" ] || [ -f "$CODE_BIN_PATH" ]; then
        echo "Removing existing 'code' command..."
        sudo rm -f "$CODE_BIN_PATH"
    fi

    echo "Creating symlink for 'code' command..."
    sudo ln -sf "$VSCODE_CLI" "$CODE_BIN_PATH"

    # Verify
    if command -v code &> /dev/null && code --version &> /dev/null; then
        echo "✓ 'code' command successfully installed"
        code --version
    else
        echo "Warning: Symlink created but 'code' command not working properly"
    fi
else
    echo "Error: VS Code CLI not found at expected location: $VSCODE_CLI"
    exit 1
fi

echo ""
echo "#############################################"
echo "VS Code setup complete!"
echo "#############################################"
