sudo apt update
sudo apt upgrade

sudo apt install -y gnome-tweaks i3lock zoom
sudo apt install -y vlc htop
sudo apt install -y neofetch gparted kitty

# install obs
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install -y ffmpeg obs-studio

sudo snap install --classic code
sudo snap install --classic nvim
sudo snap install --classic intellij-idea-community



# gnome-tweaks: 
#swap esc caps lock
#set altR as korean
# set up docker

# gnome settings
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10
gsettings set org.gnome.mutter dynamic-workspaces false
for i in {1..9}; 
    do gsettings set org.gnome.shell.extensions.dash-to-dock app-hotkey-$i "[]";
done
for i in {1..9};
    do gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']";
done
