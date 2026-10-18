# Post-install

## Session

Log in with **Hyprland (uwsm-managed)**.

## Machine-specific

- `.config/hypr/host/`: monitors, workspaces, autostart
- Wallpapers: `~/Pictures/pc-hrz-2.jpg`, `~/Pictures/pc-vert-1.jpg`

## Theme

```bash
plasma-apply-colorscheme FlexokiDark
gsettings set org.gnome.desktop.interface gtk-theme Breeze
```

Also set `gtk-theme-name=Breeze` in `~/.config/gtk-{3,4}.0/settings.ini`, and pick Flexoki Dark inside Dolphin, Konsole and KWrite (outside Plasma, KDE apps need it set per app).

Icons: [Gruvbox Plus Dark](https://github.com/SylEleuth/gruvbox-plus-icon-pack), grey folders:

```bash
cd ~/.local/share/icons/Gruvbox-Plus-Dark/places
find . -type l -lname '*plasma*' | while read l; do t=$(readlink "$l"); ln -sfn "${t/plasma/grey}" "$l"; done
```

Fill its gaps (KDE action icons) from Papirus-Dark, which it's based on:

```bash
sed -i 's/^Inherits=.*/Inherits=Papirus-Dark,breeze-dark,hicolor/' ~/.local/share/icons/Gruvbox-Plus-Dark/index.theme
```

Colourful large versions of two toolbar glyphs KWrite uses in its settings sidebar (toolbars keep the glyphs):

```bash
cd ~/.local/share/icons/Gruvbox-Plus-Dark/apps/scalable
ln -s ../../devices/scalable/media-floppy.svg document-save.svg
ln -s preferences-system-time.svg view-history.svg
```

## Login screen

```bash
sudo cp -r sddm/flexoki /usr/share/sddm/themes/
sudo bash -c "printf '[Theme]\\nCurrent=flexoki\\n' > /etc/sddm.conf.d/theme.conf"
```

Single-monitor prompt (`sddm/kwinoutputconfig.json` is a git-ignored copy of Plasma's `~/.config/kwinoutputconfig.json` with the other outputs disabled):

```bash
sudo install -D -o sddm -g sddm -m 644 sddm/kwinoutputconfig.json /var/lib/sddm/.config/kwinoutputconfig.json
```

## DNS over TLS

```bash
sudo install -D -m 644 etc/systemd/resolved.conf.d/10-dns-over-tls.conf /etc/systemd/resolved.conf.d/10-dns-over-tls.conf
sudo systemctl restart systemd-resolved
```

## CUDA (optional)

```bash
sudo dnf config-manager addrepo --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora44/x86_64/cuda-fedora44.repo
sudo dnf config-manager setopt "cuda-fedora44-x86_64.excludepkgs=nvidia-driver*,nvidia-kmod*,kmod-nvidia*,nvidia-settings*,nvidia-xconfig*,nvidia-persistenced*,nvidia-modprobe*,libnvidia*"
sudo dnf install cuda-toolkit-13-4 gcc15 gcc15-c++
```

## Claude Code status line

Add to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```
