# Set ZSH options
setopt autocd            # cd to directory by typing its name
setopt correct           # suggest corrections for command typos
setopt histignoredups    # omit consecutive duplicate history lines
setopt sharehistory      # share and incrementally append history across sessions
setopt hist_verify       # expand history line into buffer for editing before run
setopt hist_reduce_blanks
setopt extended_history  # ': timestamp:elapsed;command' in HISTFILE
setopt hist_ignore_space # leading space: do not save (good for secrets / one-offs)
setopt noclobber         # refuse '>' overwrite; use >| to force

# History config (XDG state)
_histr="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
[[ -d $_histr ]] || mkdir -p "$_histr"
HISTFILE=$_histr/history
unset _histr
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
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# Prompt (after plugins so nothing overrides it)
eval "$(starship init zsh)"

# Terminal: do not override a sensible TERM from the emulator (e.g. xterm-kitty)
if [[ -z $TERM || $TERM == dumb ]]; then
  export TERM=xterm-256color
fi

# FZF
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

if [[ -f /usr/share/fzf/shell/completion.zsh ]]; then
  source /usr/share/fzf/shell/completion.zsh
fi
if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
  source /usr/share/fzf/shell/key-bindings.zsh
fi

if command -v bat >/dev/null 2>&1; then
  _fzf_prev='bat -n --color=always {}'
else
  _fzf_prev='cat {}'
fi
export FZF_CTRL_T_OPTS=$'--walker-skip .git,node_modules,target\n--preview '\'$_fzf_prev$'\'\n--bind \'ctrl-/:change-preview-window(down|hidden|)\''
unset _fzf_prev

# nvm (Arch package ships /usr/share/nvm/init-nvm.sh)
[[ -r /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

# Enable gnome-keyring SSH agent
# if [ -z "$SSH_AUTH_SOCK" ]; then
#   export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
# fi
