# dotfiles

- rclone + onedrive
  - Follow install instructions [here](https://www.sussex.ac.uk/its/help/guide.php?id=246)
  - gitignore .config/rcone/
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
