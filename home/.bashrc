HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth

shopt -s histappend
shopt -s checkwinsize

export TERM=xterm-256color
export EDITOR=vim

# Enable color support of ls (using solarized theme — see .dircolors)
if [ -x /usr/bin/dircolors -a -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
    PROMPT_COMMAND='SANDBOXED="$(__sandboxed)";GIT_BRANCH="$(__git_branch)";SVN_BRANCH="$(__svn_branch)"'
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
    PS1='\n\[\e[32m\]\u\[\e[0m\]: \[\e[34m\]\w \[\e[33m\]${SANDBOXED}\[\e[35m\]${GIT_BRANCH}\[\e[36m\]${SVN_BRANCH}\[\e[0m\]\n\$ '
else
    PS1='\n\u: \w ${SANDBOXED}${GIT_BRANCH}${SVN_BRANCH}\n\$ '
fi

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Add RVM to PATH for scripting
PATH="$PATH:$HOME/.rvm/bin"

# Haskell binaries (sandboxed binaries, ghc, cabal, happy, alex)
PATH="$HOME/.cabal/bin:$HOME/bin/.cabal-sandbox/bin:/opt/cabal/1.20/bin:$PATH"
PATH="/opt/ghc/7.8.4/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH"

# My bin folder
PATH="$HOME/bin:$PATH"

export PATH

