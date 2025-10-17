alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# shellcheck disable=SC2139
# SC2139: Expands at definition, not use (that's what I want)
alias dots="git --git-dir=$HOME/data/code/dotfiles --work-tree=$HOME"

alias ps='ps -ww' # no truncating output based on screen width shenanigans

alias vi='nvim .'
alias gitroot='cd "$(git rev-parse --show-toplevel)"'
alias nav='echo pop!; (nautilus . 1>/dev/null 2>&1 &)'

alias ffmpeg="ffmpeg -hide_banner"
alias ffplay="ffplay -hide_banner"
alias ffprobe="ffprobe -hide_banner"
