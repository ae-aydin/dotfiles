export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Nvidia
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

# Rust
source "$HOME/.cargo/env"

# starship.rs
eval "$(starship init zsh)"

# Spicetify
export PATH="$PATH:$HOME/.spicetify"

# MikTeX
export PATH="$PATH:$HOME/bin"

# Java
export JAVA_HOME=/opt/java/jdk-21.0.8+9
export PATH="$JAVA_HOME/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fast os switch
alias to-windows='sudo efibootmgr -n 0000 && sudo reboot'
