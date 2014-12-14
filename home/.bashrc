HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth

shopt -s histappend
shopt -s checkwinsize

force_color_prompt=yes
export TERM=xterm-256color
export EDITOR=vim

# Enable color support of ls (using solarized theme — see .dircolors)
if [ -x /usr/bin/dircolors -a -r ~/.dircolors ]; then
    test x && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# trim \w
export PROMPT_DIRTRIM=3

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  PS1='\n\[\e[32m\]\u\[\e[00m\]: \[\e[34m\]\w \
\[\e[35m\]$(__git_branch)\[\e[36m\]$(__svn_branch)\[\e[0m\]\n\$ '
else
  PS1='\n\u@\h: \w\n\$ '
fi

# Haskell binaries (sandboxed binaries, ghc, cabal, happy, alex)
PATH="./.cabal-sandbox/bin:~/.cabal/bin:/opt/cabal/1.20/bin:$PATH"
PATH="/opt/ghc/7.8.3/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH"

PATH="~/bin:$PATH"

export PATH

