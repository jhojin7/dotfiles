# dotfiles

- rclone + onedrive
    - Follow install instructions [here](https://www.sussex.ac.uk/its/help/guide.php?id=246)
    - gitignore .config/rcone/
    -`rclone mount OneDrive:/ /home/jhojin/OneDrive --daemon`
- Docker-only install helper script: https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
    - Docker Desktop: https://docs.docker.com/desktop/install/ubuntu/
- Laptop hibernation
- Touchpad gestures

## fonts..
- Install NerdFonts .zip files.
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

