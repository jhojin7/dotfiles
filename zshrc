# https://github.com/ohmyzsh/ohmyzsh/blob/379fe0fe131cff7a480f7975b32b0ea6fc7c2370/templates/zshrc.zsh-template

# start with tmux
#tmux
# print uptime upon new session
uptime --pretty | lolcat

# exports
export LANG=en_US.UTF-8
export PATH=$HOME/.local/*:$HOME/usr/.local/*:$HOME/bin/*:/usr/local/bin/*:/usr/.local/*:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
export VI_MODE_SET_CURSOR=true #https://unix.stackexchange.com/a/683991

# local variables
local myzshconfig="$HOME/.config/zsh"

# SSH default shell
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vi'
fi

plugins=(
	git
	#zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh # NEEDED for loading plugins
# $ZSH/plugins/. $ZSH_CUSTOM/plugins/.

# vi mode
# #https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
set -o vi
### bindkey -v
### export KEYTIMEOUT=1
export VI_MODE_SET_CURSOR=true
### MODE_INDICATOR="%F{white}+%f"
### INSERT_MODE_INDICATOR="%F{yellow}+%f"


# Aliases
alias zshconfig='nvim ~/dotfiles/zshrc && source ~/.zshrc'
alias sshpi='ssh pi@172.30.1.99'
alias c='clear'
# https://dev.to/cassidoo/customizing-my-zsh-prompt-3417#comment-1p8gh
#source $myzshconfig/aliases.zsh

############################
########## PROMPT ##########
############################
# https://zsh-prompt-generator.site/
# https://loige.co/random-emoji-in-your-prompt-how-and-why/

local red(){echo "\e[31m${1}\e[0m"}
local green(){echo "\e[32m${1}\e[0m"}
local yellow(){echo "\e[33m${1}\e[0m"}

local mycurdir='%F{12}%~%f';
local findmybat(){
	local capacity_=$(cat /sys/class/power_supply/BAT0/capacity)
	local status_=$(cat /sys/class/power_supply/BAT0/status)

	if [[ $capacity_ -le 20 ]]; then
		if [[ "$status_" == "Charging" ]]; then
			yellow $capacity_"▲"
		else 
			red $capacity_"▼"
		fi
	elif [[ $capacity_ -le 50 ]]; then
		if [[ "$status_" == "Charging" ]]; then
			yellow $capacity_"▲"
		else
			yellow $capacity_"%%"
		fi
	elif [[ $capacity_ -le 75 ]]; then
		if [[ "$status_" == "Charging" ]]; then
			green $capacity_"▲"
		else
			green $capacity_"%%"
		fi
	elif [[ "$status_" == "Full" ]]; then
		green "!@@"
	else
		green $capacity_"%%"
	fi
}

#local endarrow='%F{10}➜%f';
local endarrow="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$reset_color%}"
PROMPT='[$(findmybat)|$mycurdir]$endarrow'
#▲▼
#source ~/coding/showbat.sh
#PROMPT='[$(findmybat)|$mycurdir]$endarrow '
