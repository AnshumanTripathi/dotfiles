#! /bin/bash

oh_my_zsh="$HOME/.oh-my-zsh"

if [ ! -f "$oh_my_zsh/oh-my-zsh.sh" ]; then
    tmp=$(mktemp -d)
    curl -fsSL https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz | tar -xz -C "$tmp" --strip-components=1
    mkdir -p "$oh_my_zsh"
    for item in "$tmp"/*; do
        [ "$(basename "$item")" = "custom" ] && continue
        cp -a "$item" "$oh_my_zsh"/
    done
    rm -rf "$tmp"
    echo "Installed oh-my-zsh core to $oh_my_zsh"
fi
