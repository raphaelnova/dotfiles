# Colored by default
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -AlF'
alias la='ls -A'
alias l='ls -CF'

alias apropos="apropos -a"
alias tree="tree --dirsfirst"
alias hex="od -tx1 -w16 -Ax"

# $ echo 5b62797465735d | fromhex
# [bytes]
alias fromhex="perl -ne 's/([0-9a-f]{2})/print chr hex \$1/gie'"

# $ echo [bytes] | tohex
# 5b62797465735d
alias tohex="xxd -p"

