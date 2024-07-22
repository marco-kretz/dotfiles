# Source .alias
test -s ~/.alias && . ~/.alias || true
source /usr/share/bash-completion/bash_completion

# Init Starship
eval "$(starship init bash)"

# Case-insensitive completions
bind 'set completion-ignore-case on'

# Set $PATH
#export PATH="$PATH:~/go/bin:~/Development/flutter/bin:~/Development/android/cmdline-tools/latest/bin"
#export ANDROID_SDK_ROOT=~/Development/android

# Init NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ---- FZF ---- #
# -- Set up fzf key bindings and fuzzy completion
#eval "$(fzf --bash)"
source /usr/share/fzf/key-bindings.bash

# -- Use fd instead of find for file search
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# -- Use fd for listing path candidates
_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --exclude .git . "$1"
}

# -- Load fzf-git
#source ~/Development/github/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)             fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset)   fzf --preview "eval 'echo \$' {}" "$@" ;;
        ssh)            fzf --preview 'dig {}' "$@" ;;
        *)              fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'" "$@" ;;
    esac
}

# ---- Bat (better cat) ---- #
export BAT_THEME=gruvbox-dark

# ---- Eza (better ls) ---- #
#alias ls="eza --color=always --long --git --icons=always --no-filesize --no-time --no-user --no-permissions"
