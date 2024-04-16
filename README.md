# dotfiles

## TODO
- (maybe?) nix conifg?
- Laptop hibernation
- Touchpad gestures
- syncthing setup (host + devices)
- firewall (ufw)
- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/
- https://github.com/krapjost/nvim-lua-guide-kr


## ahk on windows
- Win+r, `shell:startup`
- move ahk files to folder

## - fstab config. mounting home,files,swap partitions
```
cat /etc/mtab
sudo blkid or/and4 sudo lsblk
sudo nvim /etc/fstab
```
- https://www.howtogeek.com/444814/how-to-write-an-fstab-file-on-linux/

## ubuntu apt kakao mirror
- https://askubuntu.com/a/1376664
- https://gist.github.com/lesstif/8185f143ba7b8881e767900b1c8e98ad

## switch to workspace with `Super+i` (modified from [this answer](https://askubuntu.com/a/1295037))
```
gsettings list-recursively | grep "gnome.*workspace"
for i in {1..9}; do gsettings set org.gnome.shell.extensions.dash-to-dock app-hotkey-$i "[]"; done
for i in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"; done
```
- other workspace related config...
```
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10
gsettings set org.gnome.mutter dynamic-workspaces false
```

## rlcone
- rclone + onedrive
    - Follow install instructions [here](https://www.sussex.ac.uk/its/help/guide.php?id=246)
    - gitignore .config/rcone/
    - USE [`rclone {copy | sync}`](https://rclone.org/commands/rclone_copy/)!!! if local synced copies are needed.
    - else use `mount` command.

## docker
- https://get.docker.com/
- Docker-only install helper script: https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
    - Docker Desktop: https://docs.docker.com/desktop/install/ubuntu/

## fonts..
- Install NerdFonts .zip files.
- https://www.nerdfonts.com/font-downloads
- unzip and `sudo cp *.ttf /usr/share/fonts/truetype`
- update fonts `sudo fc-cache -fv`
- verify font install `sudo fc-list | grep "JetBrains"`
- modify kitty config `font_family JetBrainsMono Nerd Font`

## rofi
- install xbindkeys
- edit .xbindkeysrc `"rofi -show run" Alt + R`
- start `xbindkeys -f ~/.xbindkeysrc`
    TODO: 
    wifi 
    bluetooth (connect quickly, 
        list previous connections? pinned connections?)
    power control (lock, suspend, logout, shutdown, restart, )
    volume control 

- https://gitlab.com/vahnrr/rofi-menus
- https://github.com/ericmurphyxyz/rofi-wifi-menu
- https://github.com/nickclyde/rofi-bluetooth

## keybindings
- xbindkeys
- https://sites.google.com/a/keizie.net/linux/x-window/xbindkeys
- https://github.com/tmux/tmux/wiki/Modifier-Keys


