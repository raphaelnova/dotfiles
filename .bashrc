# shellcheck disable=SC1090,SC1091
# SC1090 = Can't follow non-constant source
# SC1091 = Not following: openBinaryFile

# Check for TTY, interactive non-login shell and no tmux session
if tty -s && ! shopt -q login_shell && [[ "$-" == *i* && -z "$TMUX" ]]; then
  if [[ "$TERM_PROGRAM" != "vscode" ]]; then
    tmux
    exit
  fi
fi

HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth # No duplicates or empty lines
shopt -s histappend
shopt -s cdspell
#shopt -s checkwinsize

source ~/.config/bash/aliases.sh
source ~/.config/bash/functions.sh
eval "$(dircolors -b ~/.config/bash/dircolors)"

# Enable programmable completion features.
# You don't need to enable this, if it's already
# enabled in /etc/bash.bashrc.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

export PROMPT_DIRTRIM=3
export GIT_PS1_SHOWDIRTYSTATE=1

RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
MAGENTA='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
RESET='\[\033[00m\]'
# shellcheck disable=SC2034
JAVA_BLUE='\[\033[38;2;0;115;150m\]'   # From Oracle's design guide
JAVA_ORANGE='\[\033[38;2;237;139;0m\]' # From Oracle's design guide

# ~/data/dir [1]  j21  proj  master
# $
PS1="\\n${BLUE}\\w"
PS1+="${RESET}"
PS1+="${GREEN}\$(__bg_jobs)"
PS1+="${JAVA_ORANGE}\$(__javaversion)"
PS1+="${RED}\$(__mvn_proj)"
PS1+="${CYAN}\$(__nodejsversion)"
PS1+="${YELLOW}\$(__pyvenv)"
PS1+="${MAGENTA}\$(__git_ps1 \" \\\ue702 %s\")"
PS1+="${RESET}\\n\\$ "

update_java_home >/dev/null

export EDITOR=nvim
export XMLLINT_INDENT="    " # Four spaces

export VIRTUAL_ENV_DISABLE_PROMPT=1
eval "$(direnv hook bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[ -s ~/gradle-completion.bash ] && source ~/gradle-completion.bash

path_dirs=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "/opt/gradle/gradle-8.14.1/bin"
  "/opt/apache-maven-3.9.10/bin"
)
PATH="${PATH}$(printf ":%s" "${path_dirs[@]}")"
export PATH

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

