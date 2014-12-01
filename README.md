## raph's dotfiles

Still work in progress, the setup script just overwrites existing files
so do not use it if you care about your current dotfiles. There's a lot
of things I need to fix before trying to make them portable, namely:

* trim bash config (probably depends on Ubuntu configs)
* find my inputrc and xmodmap -- they're here, somewhere, hm...
* fix vim plugins (powerline doesn't work)
* merge my RHEL config into it

### the setup

Whatever goes in ~ is saved inside home/. This is to keep my dotfiles and
repo dotfiles (such as .gitmodules) separated — it makes the setup easier.
Also, I think I'll need to save files from /etc too. I'm not sure yet.

Vim plugins are submodules, when applicable (all of them so far).

### license

Do whatever you want with it, just don't sue me. You've been warned.
This is MIT'd or BSD'd, non-viral, whatever.

