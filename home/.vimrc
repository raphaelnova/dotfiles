"
" see also /etc/vim/vimrc
"
" after editing, reload with :so %
"

" ==== Vundle setup and plugins ==========================================

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"
" Brief help
" :PluginList - list configured bundles
" :PluginInstall(!) - install(update) bundles
" :PluginSearch(!) foo - search(or refresh cache first) for foo
" :PluginClean(!) - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
"

Plugin 'gmarik/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/powerline'
Plugin 'altercation/vim-colors-solarized'

call vundle#end()
filetype plugin indent on

" ==== End Vundle setup ==================================================

if &t_Co >= 256 || has("gui_running")
  syntax enable
  " — not happy...
  "set background=dark
  "colorscheme solarized
  "set cursorline
endif

set encoding=utf-8
autocmd! bufwritepost .vimrc source %

set nobackup
set noswapfile
set tabstop=4    " how many columns a tab counts for
set expandtab    " insert spaces when hit tab
set shiftwidth=4 " how many columns the reindent indents
set autoindent
set number
set nowrap
set list
set listchars=tab:>.,trail:.,extends:~,nbsp:.

set incsearch    " searches as characters are typed
set hlsearch     " highlight all search results
                 " :noh clears highlights (see mappings)

set wildmenu     " list cmd autocomplete options (cycle with tab)
set showmatch    " highlight matches {[()]}

" Paste mode (pasting inside the terminal)
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

let mapleader=","

"
" Key maps:
"
" map: map recursively
" remap: option that makes `map` recursive (on by default)
" noremap: map non-recursively
" n, v and i: prefixes to map and noremap to specify the mode
"             on which the mapping works.
"
" n: normal only
" v: visual and select
" o: operator-pending
" x: visual only
" s: select only
" i: insert
" c: command-line
" l: insert, command-line, regexp-search
"    (and others. Collectively called 'Lang-Arg' pseudo-mode)
"
inoremap <Up>       <NOP>
inoremap <Down>     <NOP>
inoremap <Left>     <NOP>
inoremap <Right>    <NOP>
noremap  <Up>       <NOP>
noremap  <Down>     <NOP>
noremap  <Left>     <NOP>
noremap  <Right>    <NOP>
" easier jumping between ()
nnoremap <tab>      %
nnoremap <leader>b  :buffers<CR>:b<space>
" clear search results highlights
nnoremap <leader><space> :noh<CR>
" center line while navigating up and down
nnoremap j          jzz
nnoremap k          kzz
" quick esc
inoremap kj         <ESC>

