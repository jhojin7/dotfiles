sudo apt update
sudo apt upgrade

sudo add-apt-repository ppa:neovim-ppa/stable 
sudo apt-get update -y
sudo apt-get install neovim -y


# core stuff
sudo apt install -y \
coreutils \
net-tools \
git \
curl \
wget \
make \
zsh \
neovim \
tmux \
kitty \
google-chrome-stable \
firefox \
gparted \
neofetch \
lolcat \
cowsay \
fortune \
tree \
ncal



# dev
sudo apt install -y \
gh \
python3 \
python3-venv \
pip \
distrobox \
nodejs \
npm \

sudo apt install -y tldr
tldr -u



# # somewhat core
# sudo apt install \
# 	# py
# 	pip \
# 	python3 \
# 	python3-venv \
# 	jupyter-notebook \
# 	jupyter-nbconvert \
# 	graphvis \
# 	# js
# 	nodejs \
# 	npm \
# 	zoom \
# 
# # misc utils
# sudo apt install \
# 	neofetch \
# 	anki \
# 	lolcat \
# 	cowsay \
# 	fortune \
# 	tty-clock \
# 	vlc \
# 	htop \
# 	ncal \
# 	tree \
# 	#gh \
# 
# # more python stuff
# pip install numpy pandas
# 
# # update tldr
# tldr -u
# # touch .hushlogin
# touch ~/.hushlogin
# 
# # set default terminal as kitty
# export TERMINAL=kitty
# 
# # gnome-tweaks: 
# #swap esc caps lock
# #set altR as korean
# # set up docker
# 
# # install pfetch
# wget https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
# chmod +x pfetch
# sudo mv pfetch /usr/local/bin
# pfetch
# 

# # link zshrc
# ln -s ~/dotfiles/zshrc ~/.zshrc
# source ~/.zshrc
# # link kitty.conf
# mkdir -p ~/.config/kitty
# ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
