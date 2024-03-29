# Set up the prompt

autoload -Uz promptinit
promptinit
prompt redhat

setopt histignorealldups sharehistory

typeset -U PATH path
path=("$HOME/.local/bin" "$HOME/bin" "$HOME/go/bin" "$HOME/gosrc/bin" "/usr/local/go/bin" "$path[@]")
export PATH

#alias vim="nvim"
alias nvim="/home/coolbry95/nvim-linux64/bin/nvim"
alias vim="/home/coolbry95/nvim-linux64/bin/nvim"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

export TZ="/usr/share/zoneinfo/America/Detroit"
export EDITOR="nvim"

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
# don't save duplicate history
setopt HIST_SAVE_NO_DUPS
HISTFILE=~/.zsh_history

# aliases
alias ll='ls -alF'
alias ls='ls --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
