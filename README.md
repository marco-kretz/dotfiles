# dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>
Use [GNU Stow](https://www.gnu.org/software/stow/) to link the modules like so: `stow -t ~ [module_name]`

**Warning**: These contain Fedora-specific stuff. Additionally update the .gitconfig with your own name and email.

## OS

[**Fedora**](https://fedoraproject.org/)

## Deps

### Install distro packages

`sudo dnf install stow fzf fd bat eza`

### Install starship prompt

`curl -sS https://starship.rs/install.sh | sh`

## Tweaks

### GNOME

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

-   `gsettings set org.gnome.mutter check-alive-timeout 30000`

Still in progress. More to come.

~MK
