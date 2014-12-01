echo ".bash_login has been executed ($(date -R))" | tee -a ~/bash_log

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

