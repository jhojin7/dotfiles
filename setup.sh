sudo apt update
sudo apt upgrade

# core stuff
sudo apt install \
	# installs
	curl \
	wget \
	make \
	# apps
	zsh \
	neovim \
	tmux \
	kitty \
	google-chrome-stable \
	firefox \
	gparted \

# somewhat core
sudo apt install \
	# ricing
	gnome-tweaks \
	awesome \
	i3lock \
	# py
	pip \
	python3 \
	python3-venv \
	jupyter-notebook \
	graphvis \
	jupyter-nbconvert \
	# js
	nodejs \
	npm \

# misc utils
sudo apt install \
	neofetch \
	anki \
	lolcat \
	cowsay \
	fortune \
	tty-clock \
	vlc \
	htop \
	tldr \
	ncal \
	tree \
	gh \

# more python stuff
pip install numpy pandas

# update tldr
tldr -u
# touch .hushlogin
touch ~/.hushlogin

# set default terminal as kitty
export TERMINAL=kitty

# gnome-tweaks: 
#swap esc caps lock
#set altR as korean
# set up docker

# install pfetch
wget https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
chmod +x pfetch
sudo mv pfetch /usr/local/bin
pfetch

# link zshrc
ln -s ~/dotfiles/zshrc ~/.zshrc
source ~/.zshrc
# link kitty.conf
mkdir -p ~/.config/kitty
ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
