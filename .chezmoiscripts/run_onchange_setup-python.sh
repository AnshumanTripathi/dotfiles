#!/bin/bash

# This script runs only if no Python versions are installed via pyenv
# It ensures the latest stable Python version is installed and set as global default

set -e

# Ensure pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "pyenv is not installed. Installing via homebrew..."
    brew install pyenv pyenv-virtualenv
fi

# Check if any Python versions are already installed
INSTALLED_VERSIONS=$(pyenv versions --bare 2>/dev/null || echo "")

if [ -n "$INSTALLED_VERSIONS" ]; then
    echo "Python versions already installed via pyenv. Skipping setup."
    echo "Installed versions:"
    pyenv versions
    exit 0
fi

echo "#############################################"
echo ""
echo "No Python versions found. Setting up Python with pyenv"
echo ""

# Get the latest stable Python version
LATEST_PYTHON=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | xargs)

echo "Latest stable Python version: $LATEST_PYTHON"
echo "Installing Python $LATEST_PYTHON..."
pyenv install "$LATEST_PYTHON"

# Set as global default
echo "Setting Python $LATEST_PYTHON as global default..."
pyenv global "$LATEST_PYTHON"

# Verify
echo ""
echo "Current Python version:"
python --version

echo ""
echo "Python setup complete!"
echo "#############################################"
