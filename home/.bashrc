HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize

force_color_prompt=yes
export TERM=xterm-256color

function __git_branch() {
    git branch 2>/dev/null |\
    grep \*                |\
    sed -Ee's#\* (.*)#[\1]#'
}

function __svn_branch() {
    svn info 2>/dev/null |\
    egrep ^URL           |\
    sed -Ee's#^.*/((trunk|branches|tags).*)#[\1]#'
}

# trim \w
export PROMPT_DIRTRIM=2

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  PS1='\n\[\e[32m\]\u\[\e[00m\]: \[\e[34m\]\w \[\e[35m\]$(__git_branch)\[\e[36m\]$(__svn_branch)\[\e[0m\]\n\$ '
else
  PS1='\n\u@\h: \w\n\$ '
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -AlF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

EDITOR=vim

#Custom alias
alias apropos="apropos -a"
alias grep="grep -F" #force grep to literal; use egrep for regex
alias tree="tree --dirsfirst"
alias hex="od -tx1 -w16 -Ax"

# Java, Maven etc
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
#export M2_HOME=/usr/share/maven/
#export M2=%M2_HOME%/bin/
#export MAVEN_OPTS="-Xms256m -Xmx512m"

# Scala, Haskell
#PATH=$PATH:/opt/sbt/bin:~/.cabal/bin

# RVM
#PATH=$PATH:$HOME/.rvm/bin
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Haskell binaries (ghc, cabal, happy, alex)
PATH=".cabal-sandbox/bin:~/.cabal/bin:/opt/cabal/1.20/bin:$PATH"
PATH="/opt/ghc/7.8.3/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH"

export PATH

eval $(dircolors ~/.dircolors)
