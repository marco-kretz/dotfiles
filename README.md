# dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>
Use [GNU Stow](https://www.gnu.org/software/stow/) to link the modules like so: `stow -d ~ [module_name]`

**Warning**: These contain Archlinux-specific stuff. Additionally update the .gitconfig with your own name and email.

## Deps

`sudo pacman -S stow fzf fd bat eza starship`

## Tweaks

-   `gsettings set org.gnome.mutter check-alive-timeout 30000` - Increase time to define an application as non-responding (esp. for games)

Still in progress. More to come.

~MK
