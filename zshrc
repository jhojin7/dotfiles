# https://github.com/ohmyzsh/ohmyzsh/blob/379fe0fe131cff7a480f7975b32b0ea6fc7c2370/templates/zshrc.zsh-template

# start with tmux
#tmux
# print uptime upon new session
uptime --pretty | lolcat

# exports
export PATH=$PATH:$HOME/.local/bin:$HOME/.local/mybin
export LANG=en_US.UTF-8
export HISTSIZE=100000
export ZSH="$HOME/.oh-my-zsh"
export VI_MODE_SET_CURSOR=true #https://unix.stackexchange.com/a/683991

# local variables
#local myzshconfig="$HOME/.config/zsh"

# SSH default shell
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='nvim'
fi

plugins=(
	git
	#zsh-autosuggestions
)

# local themes=("half-life" "steeef" "sporty_256" "zhann" "crunch" "crcandy")
# export ZSH_THEME=${themes[3]}
# export ZSH_THEME='common'
source $ZSH/oh-my-zsh.sh # NEEDED for loading plugins
# vi mode
# #https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
set -o vi
### bindkey -v
### export KEYTIMEOUT=1
### MODE_INDICATOR="%F{white}+%f"
### INSERT_MODE_INDICATOR="%F{yellow}+%f"

# Aliases
alias c='clear'
alias la='ls -a'
alias ll='ls -alF'
alias zshconfig='nvim ~/.zshrc && source ~/.zshrc'
alias tmuxconfig='nvim ~/.config/tmux/tmux.conf && tmux source-file ~/.config/tmux/tmux.conf'
alias sshpi='ssh pi@172.30.1.99'
# https://www.youtube.com/watch?v=rjCvxTJ8Te4
alias mv="mv -iv"
alias rm="rm -v"
alias boj='code ~/coding/problem-solving'
alias clock="tty-clock -C4 -c -s"
#alias vim="nvim"

alias capstoneps='docker network inspect -f "{{json .Containers}}" sejong-reservation_default | jq'

# https://dev.to/cassidoo/customizing-my-zsh-prompt-3417#comment-1p8gh
#source $myzshconfig/aliases.zsh
# alias histgrep="history | grep $$$$" # finds $$ in history
# https://www.appsloveworld.com/bash/100/181/history-and-egrep-in-one-script
histgrep() { history | egrep "$@";}
# alias readme='if there is README.md in current directory,
    # open readme file in default editor (or nvim),
    # else just print out there is no readme file in this directory."




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


# https://superuser.com/a/611582 
countdown() {
    start="$(( $(date +%s) + $1))"
    while [ "$start" -ge $(date +%s) ]; do
        ## Is this more than 24h away?
        days="$(($(($(( $start - $(date +%s) )) * 1 )) / 86400))"
        time="$(( $start - `date +%s` ))"
        printf '%s day(s) and %s\r' "$days" "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

stopwatch() {
    start=$(date +%s)
    while true; do
        days="$(($(( $(date +%s) - $start )) / 86400))"
        time="$(( $(date +%s) - $start ))"
        printf '%s day(s) and %s\r' "$days" "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}



#local endarrow="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$reset_color%}"
#PROMPT='[$(findmybat)|$mycurdir]$endarrow'
#▲▼
#source ~/coding/showbat.sh
#PROMPT='[$(findmybat)|$mycurdir]$endarrow '

# launch tmux at sourcing zshrc
# if [ -z "$TMUX" ]; then
#     tmux
# fi

# starship theme config
# https://starship.rs/guide/#%F0%9F%9A%80-installation
eval "$(starship init zsh)"

