# -g keeps PATH additions per-session; plain fish_add_path saves them in fish_variables,
# where they outlive their removal from this file
fish_add_path -gm $HOME/bin
fish_add_path -gm $HOME/.local/bin
fish_add_path -gm /usr/local/bin

# CUDA toolkit (NVIDIA repo, cuda-toolkit-13-4); skipped if it's ever uninstalled
if test -d /usr/local/cuda
    fish_add_path -g /usr/local/cuda/bin
    set -gx CUDA_HOME /usr/local/cuda
end

# Rust
fish_add_path -gm $HOME/.cargo/bin

# Java
set -gx JAVA_HOME /opt/java/jdk-21.0.8+9
fish_add_path -g $JAVA_HOME/bin

function to-windows
    sudo efibootmgr -n 0000
    and sudo reboot
end

starship init fish | source
fzf --fish | source
zoxide init fish | source

# opencode
if test -d $HOME/.opencode/bin
    fish_add_path -g $HOME/.opencode/bin
end
