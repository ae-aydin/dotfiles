#!/bin/bash
# Symlink dotfiles into $HOME. Each path mirrors its location under $HOME.
# Safe to re-run: existing links are kept, anything else is moved aside to *.bak-<timestamp>.
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

TARGETS=(
    .bashrc
    .claude/statusline.sh
    .config/autostart/blueman.desktop
    .config/autostart/nvidia-settings-user.desktop
    .config/autostart/org.freedesktop.problems.applet.desktop
    .config/autostart/imsettings-start.desktop
    .config/btop/btop.conf
    .config/fastfetch
    .config/fish
    .config/foot
    .config/fuzzel
    .config/ghostty
    .config/hypr
    .config/mako
    .config/pipewire/pipewire.conf.d/10-no-airplay.conf
    .config/qt6ct
    .config/quickshell
    .config/swappy
    .config/yazi
    .config/zathura
    .config/zed
    .local/share/color-schemes/FlexokiDark.colors
    .local/share/konsole/FlexokiDark.colorscheme
    .local/share/org.kde.syntax-highlighting/themes/flexoki-dark.theme
)

link() {
    local src="$DOTFILES_DIR/$1" dst="$HOME/$1"
    if [[ ! -e "$src" ]]; then
        echo "missing  $1"
        return
    fi
    if [[ "$(readlink "$dst" 2>/dev/null)" == "$src" ]]; then
        echo "ok       $1"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "$dst.bak-$STAMP"
        echo "backup   $1 -> $1.bak-$STAMP"
    fi
    ln -s "$src" "$dst"
    echo "linked   $1"
}

for target in "${TARGETS[@]}"; do
    link "$target"
done
