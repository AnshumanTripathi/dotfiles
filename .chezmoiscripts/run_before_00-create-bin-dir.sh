#!/bin/bash

HOME_BIN_DIR="$HOME/bin"

# 1. Check if it exists as a FILE and delete it if so (to fix your specific issue)
if [ -f "$HOME_BIN_DIR" ]; then
    echo "Found file at $HOME_BIN_DIR. Removing it to create directory."
    rm "$HOME_BIN_DIR"
fi

# 2. Create the directory if it doesn't exist
if [ ! -d "$HOME_BIN_DIR" ]; then
    mkdir -p "$HOME_BIN_DIR"
    chmod -R +x $HOME_BIN_DIR
    echo "Created $HOME_BIN_DIR directory"
fi
