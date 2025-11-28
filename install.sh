#!/bin/bash

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.config"

link() {
    local src="$1"
    local dst="$2"
    if [[ ! -e "$src" ]]; then
        echo "Source not found: $src"
        return
    fi
    echo "Linking: $src -> $dst"
    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "Successfully linked to: $dst"
    echo
}

echo "===DOTFILE INSTALLER==="
echo

link "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
# link "$DOTFILES_DIR/.config/dunst" "$HOME/.config/dunst"
link "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch"
link "$DOTFILES_DIR/.config/fish" "$HOME/.config/fish"
link "$DOTFILES_DIR/.config/foot" "$HOME/.config/foot"
link "$DOTFILES_DIR/.config/fuzzel" "$HOME/.config/fuzzel"
link "$DOTFILES_DIR/.config/ghostty" "$HOME/.config/ghostty"
link "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"
link "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
link "$DOTFILES_DIR/.config/mako" "$HOME/.config/mako"
link "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"
link "$DOTFILES_DIR/.config/yazi" "$HOME/.config/yazi"
link "$DOTFILES_DIR/.config/zathura" "$HOME/.config/zathura"
link "$DOTFILES_DIR/.config/zed" "$HOME/.config/zed"

echo "Done linking"
