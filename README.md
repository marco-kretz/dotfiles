# dotfiles

These are the dotfiles I use on my linux-machines. Feel free to use, share or whatever.<br>
Use [GNU Stow](https://www.gnu.org/software/stow/) to link the modules like so: `stow -t ~ [module_name]`

**Warning**: These contain Archlinux-specific stuff. Additionally update the .gitconfig with your own name and email.

## OS

[**EndeavourOS**](https://endeavouros.com/)

## Deps

`sudo pacman -S stow fzf fd bat eza starship`

## Tweaks

### GNOME

#### Handle SSH Key Authentication

To let GNOME unlock your SSH keys and save the password, you need to enable the `gcr-ssg-agent` and let apps know where to find the socket:

1.  `systemctl enable --now --user gcr-ssh-agent.socket`
2.  `export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh` (This is already done within my `environment` module)

#### Increase window timeout

This increases the grace period for GNOME thinking that a window has crashed. Most useful for some games.

-   `gsettings set org.gnome.mutter check-alive-timeout 30000`

Still in progress. More to come.

~MK
