# Set ZSH options
setopt autocd		# Auto change directory without `cd`
setopt correct		# Auto correct small typos
setopt histignoredups	# Ignore duplicate commands in history
setopt sharehistory	# Share command history across terminals

# History config
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Prompt cusomization with Starship
eval "$(starship init zsh)"

# Antidote plugin manager
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source ~/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh

# Aliases
alias ls='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias vim='nvim'

# Enable completions
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Key bindings for keys like END, DEL, etc.
bindkey '^[[1~' beginning-of-line  # Home key
bindkey '^[[4~' end-of-line        # End key
bindkey '^[[3~' delete-char        # Delete key
bindkey '^[[H' beginning-of-line   # Home (alternate)
bindkey '^[[F' end-of-line         # End (alternate)

# PATH management
export PATH="$HOME/.symfony5/bin:$HOME/.local/bin:$HOME/.config/composer/vendor/bin:$PATH"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# Terminal settings
export TERM="xterm-256color"

# Enable color in `ls` and grep
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Load FZF
if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Cursor workaround
alias cursor='env XDG_DATA_DIRS=/usr/share:/usr/local/share cursor'
