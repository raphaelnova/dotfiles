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
  PS1='\n\[\033[32m\]@ \h\[\033[00m\]: \[\033[34m\]\w \[\033[35m\]$(__git_branch)\[\033[36m\]$(__svn_branch)\[\033[0m\]\n\$ '
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

# man dircolors
export LS_COLORS="\
rs=0:di=00;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:\
bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:\
ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=32:\
*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:\
*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:\
*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:\
*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:\
*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:\
*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:\
*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:\
*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:\
*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:\
*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:\
*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:\
*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:\
*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:\
*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:\
*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:\
*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:\
*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:\
*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:\
*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"

