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

source ~/.config/bash/aliases.bash
source ~/.config/bash/functions.bash
eval "$(dircolors -b ~/.config/bash/dircolors)"

# Enable programmable completion features.
# You don't need to enable this, if it's already
# enabled in /etc/bash.bashrc.
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
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

# ~/data/dir [1]  j21  project  master
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

export EDITOR=nvim
export XMLLINT_INDENT="    " # Four spaces

export VIRTUAL_ENV_DISABLE_PROMPT=1
eval "$(direnv hook bash)"

# PATHs reside in an external file now (easier to manipulate with Ansible)
mapfile -t path_dirs < "${HOME}/.config/bash/path"
PATH="${PATH}$(printf ":%s" "${path_dirs[@]}")"
export PATH

# Lazy loading NVM - creates shims / wrapper functions to
# replace the real commands. When called, these shims load
# NVM with the real functions and unsets themselves. Bash
# completion is eagerly loaded since it works fine with the
# shims and it loads fast.

nvm_cmds=(nvm npm node npx)
export NVM_DIR="$HOME/.nvm"

nvm_lazy_load() {
  unset nvm_lazy_load "$@"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

for cmd in "${nvm_cmds[@]}"; do
  # Embed all commands in the new fn so I can unset the array.
  # nvm () { nvm_lazy_load 'nvm' 'npm' 'node' 'npx'; nvm "$@"; }
  eval "${cmd} () {
      nvm_lazy_load ${nvm_cmds[*]@Q}
      ${cmd} \"\$@\"
    }"
done

unset nvm_cmds

[[ -s "$NVM_DIR/bash_completion" ]] &&
  source "$NVM_DIR/bash_completion"

# Not lazy loading SDKMAN anymore because it's quick
# to load and not doing it leaves my shell javaless.

export SDKMAN_DIR="$HOME/.sdkman"
SDKMAN_COMPLETION="$SDKMAN_DIR/contrib/completion/bash/sdk"

[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] &&
  source "$SDKMAN_DIR/bin/sdkman-init.sh"

[[ -s "$SDKMAN_COMPLETION" ]] && source "$SDKMAN_COMPLETION"

[[ -s ~/gradle-completion.bash ]] && source ~/gradle-completion.bash
