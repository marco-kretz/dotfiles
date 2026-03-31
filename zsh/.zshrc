# Set ZSH options
setopt autocd          # cd to directory by typing its name
setopt correct         # suggest corrections for command typos
setopt histignoredups  # omit consecutive duplicate history lines
setopt sharehistory    # share and incrementally append history across sessions

# History config
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# PATH (early so plugin hooks resolve commands)
export PATH="$HOME/.symfony5/bin:$HOME/.local/bin:$HOME/.config/composer/vendor/bin:$PATH"

# Antidote plugin manager
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source ~/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh

# Completions (after plugins extend $fpath); -C skips slow security audit when dump exists
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d ${_zcompdump:h} ]] || mkdir -p "${_zcompdump:h}"
if [[ -s $_zcompdump ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Key bindings for Home, End, Delete
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Aliases
alias ls='ls -la --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias gemini-cli='npx https://github.com/google-gemini/gemini-cli'
alias icat='kitty +kitten icat'

# Prompt (after plugins so nothing overrides it)
eval "$(starship init zsh)"

# Terminal: do not override a sensible TERM from the emulator (e.g. xterm-kitty)
if [[ -z $TERM || $TERM == dumb ]]; then
  export TERM=xterm-256color
fi

# FZF
if [[ -f /usr/share/fzf/shell/completion.zsh ]]; then
  source /usr/share/fzf/shell/completion.zsh
fi
if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
  source /usr/share/fzf/shell/key-bindings.zsh
fi

export FZF_CTRL_T_OPTS=$'--walker-skip .git,node_modules,target\n--preview \'bat -n --color=always {}\'\n--bind \'ctrl-/:change-preview-window(down|hidden|)\''

# Lazy-load nvm (sourcing nvm every shell costs hundreds of ms)
if [[ -r /usr/share/nvm/init-nvm.sh ]]; then
  _load_nvm() {
    unset -f _load_nvm nvm node npm npx
    source /usr/share/nvm/init-nvm.sh
  }
  nvm() { _load_nvm && nvm "$@" }
  node() { _load_nvm && command node "$@" }
  npm() { _load_nvm && command npm "$@" }
  npx() { _load_nvm && command npx "$@" }
fi

# Enable gnome-keyring SSH agent
# if [ -z "$SSH_AUTH_SOCK" ]; then
#   export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
# fi
