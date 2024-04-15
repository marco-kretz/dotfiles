HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v

zstyle :compinstall filename '/home/marco/.zshrc'

# Init completion system
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive autocomplete
autoload -Uz compinit
compinit

# Antidote
# # source antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

# Init Starship
eval "$(starship init zsh)"

export PATH="$HOME/.symfony5/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
