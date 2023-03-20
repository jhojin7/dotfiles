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

tldr -u
# touch .hushlogin
touch ~/.hushlogin

# set default terminal as kitty
export TERMINAL=kitty

# gnome-tweaks: 
# swap esc caps lock
# set altR as korean

# install pfetch
#wget https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
#chmod +x pfetch
#sudo mv pfetch /usr/local/bin
#pfetch

# link dotfiles
# source different dotfiles

# set up docker

