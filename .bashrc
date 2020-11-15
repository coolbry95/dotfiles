# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#    xterm-color) color_prompt=yes;;
#esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

#if [ -n "$force_color_prompt" ]; then
#    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#	# We have color support; assume it's compliant with Ecma-48
#	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
#	# a case would tend to support setf rather than setaf.)
#	color_prompt=yes
#    else
#	color_prompt=
#    fi
#fi

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# for golang
export PATH=$PATH:/usr/local/go/bin
# this one is for random stuff
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
# this one is for projects
export GOPATH=$GOPATH:$HOME/gosrc
export PATH=$PATH:$HOME/gosrc/bin

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vim='nvim'

# Things added
# Time zone
export TZ="/usr/share/zoneinfo/America/Detroit"
export EDITOR="nvim"

# ESC ]     OSC      (Should be: Operating system command) ESC ] P
#                          nrrggbb: set palette, with parameter given in 7
#                          hexadecimal digits after the final P :-(.  Here n
#                          is the color (0-15), and rrggbb indicates the
#                          red/green/blue values (0-255).  ESC ] R: reset
#                          palette

#24 bit color ansi escape
#echo -en "\e]P0000000" #black
#echo -en "\e]P82e3436" #darkgrey
#echo -en "\e]P1a40000" #darkred
#echo -en "\e]P9cc0000" #red
#echo -en "\e]P24e9a06" #darkgreen
#echo -en "\e]PA73d216" #green
#echo -en "\e]P3c17d11" #brown
#echo -en "\e]PBedd400" #yellow
#echo -en "\e]P4204a87" #darkblue
#echo -en "\e]PC3465a4" #blue
#echo -en "\e]P55c3566" #darkmagenta
#echo -en "\e]PD75507b" #magenta
#echo -en "\e]P692b19e" #darkcyan
#echo -en "\e]PEa1cdcd" #cyan
#echo -en "\e]P7d3d7cf" #lightgrey
#echo -en "\e]PFeeeeec" #brwhite base3 fdf6e3

echo -en "\e]P0073642" #black
echo -en "\e]P8002b36" #darkgrey
echo -en "\e]P1dc322f" #darkred
echo -en "\e]P9cb4b16" #red
echo -en "\e]P2859900" #darkgreen
echo -en "\e]PA586e75" #green
echo -en "\e]P3b58900" #brown
echo -en "\e]PB657b83" #yellow
echo -en "\e]P4268bd2" #darkblue
echo -en "\e]PC839496" #blue
echo -en "\e]P5d33682" #darkmagenta
echo -en "\e]PD6c71c4" #magenta
echo -en "\e]P62aa198" #darkcyan
echo -en "\e]PE93a1a1" #cyan
echo -en "\e]P7eee8d5" #lightgrey
echo -en "\e]PFfdf6e3" #white

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
