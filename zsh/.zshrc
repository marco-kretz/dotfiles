[[ $- != *i* ]] && return

# Omarchy zsh defaults (pacman: omarchy-zsh): options, completion, aliases, functions, mise/starship/zoxide/fzf
source /usr/share/omarchy-zsh/shell/zoptions
source /usr/share/omarchy-zsh/shell/all

# Own options on top of Omarchy's
setopt correct           # suggest corrections for command typos
setopt extended_history  # ': timestamp:elapsed;command' in HISTFILE
setopt noclobber         # refuse '>' overwrite; use >| to force

# History config (XDG state)
_histr="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
[[ -d $_histr ]] || mkdir -p "$_histr"
HISTFILE=$_histr/history
unset _histr

# PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
typeset -U path
path=("$PNPM_HOME/bin" $path)

# Secrets / API keys (not in the repo)
for _env in openai typesafe artificialanalysis openrouter coolify; do
  [[ -f ~/.config/$_env.env ]] && source ~/.config/$_env.env
done
unset _env

# Key bindings for Home, End, Delete, and Page Up/Down
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[5~' beginning-of-buffer-or-history
bindkey '^[[6~' end-of-buffer-or-history

# Aliases (omarchy-zsh already provides ls/eza, .., g, n, ...)
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
# omarchy-zsh still ships the old full-bypass agent aliases; keep Omarchy's current ones
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode auto'
alias cy='codex --approve-for-me'

# FZF
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS=$'--walker-skip .git,node_modules,target\n--preview \'bat -n --color=always {}\'\n--bind \'ctrl-/:change-preview-window(down|hidden|)\''

# pacman: zsh-autosuggestions (not an omarchy-zsh dependency)
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
