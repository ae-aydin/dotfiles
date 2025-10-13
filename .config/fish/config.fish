fish_add_path -m $HOME/bin
fish_add_path -m $HOME/.local/bin
fish_add_path -m usr/local/bin

# CUDA
fish_add_path /usr/local/cuda/bin
set -gx LD_LIBRARY_PATH /usr/local/cuda/lib64 $LD_LIBRARY_PATH

# Rust
fish_add_path -m $HOME/.cargo/bin

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

# rg
# eza
# fd
