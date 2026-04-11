#! /bin/bash

private_zsh="$HOME/.zsh/private.zsh"

if [ ! -f "$private_zsh" ]; then
    mkdir -p "$HOME/.zsh"
    touch "$private_zsh"
    echo "# Private ZSH functions and aliases" > "$private_zsh"
    echo "Created $private_zsh"
fi

private_claude="$HOME/.claude/private.md"

if [ ! -f "$private_claude" ]; then
    mkdir -p "$HOME/.claude"
    echo "# Private Claude context (not tracked in git)" > "$private_claude"
    echo "Created $private_claude"
fi

npm_gloal="$HOME/.npm-global"

if [ ! -d $npm_gloal ]; then
    mkdir -p $npm_global
    echo "Created $npm_global directory"
fi
