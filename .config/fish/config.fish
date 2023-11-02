if status is-interactive
    # Commands to run in interactive sessions can go here
end
set -gx EDITOR neovim
fish_add_path ~/.local/bin

starship init fish | source
source $HOME/.config/fish/conf.d/abbr.fish
source $HOME/.config/fish/conf.d/ssh-agent.fish
