# Dotfiles

My Hyprland setup on Fedora, themed with [Flexoki Dark](https://stephango.com/flexoki). The look is inspired by [Omarchy](https://omarchy.org), kept to a minimal set of tools.

Packages (plus the `lionheartp/Hyprland` and `errornointernet/quickshell` COPRs):

```
hyprland uwsm quickshell hyprpaper hyprlock hypridle mako fuzzel ghostty foot fish fzf zoxide
cliphist wl-clipboard grimblast swappy playerctl wiremix easyeffects btop nvtop yazi zathura
qt6ct polkit-kde blueman NetworkManager-tui
```

and `starship` from its installer.

```bash
git clone https://github.com/ae-aydin/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks everything into `$HOME` and moves anything in the way to `*.bak-<timestamp>`. The rest is in [docs/post-install.md](docs/post-install.md).

## License

MIT
