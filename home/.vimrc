"
" see also /etc/vim/vimrc
"
" after editing, reload with :so %
"

set nocompatible
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
"noremap <esc> :nohlsearch<return><esc> " :noh clears highlights
"  OR
nnoremap <leader><space> :noh<CR>

set wildmenu     " list cmd autocomplete options (cycle with tab)
set showmatch    " highlight matches {[()]}

let mapleader=","

"
" Key maps:
"
" remap: option that makes `map` recursive (on by default)
" map: map recursively
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
" l: insert, command-line, regexp-search (and others. Collectively called 'Lang-Arg' pseudo-mode)
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
" center line while navigating up and down
nnoremap j          jzz
nnoremap k          kzz
" quick esc
inoremap kj         <ESC>

" dafuq is this?
set pastetoggle=<F2>

" filetype plugin indent on
" autocmd filetype python set expandtab

" install plugins on ~/.vim/bundle
" Installed
"   nerdtree
"   vim-colors-solarized
"   powerline
" shit won't work and I don't know why
"set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
execute pathogen#infect()
syntax on
filetype plugin indent on
" ctrlp
" silver surfer
" gist.vim

" gvim
if &t_Co >= 256 || has("gui_running")
  syntax enable
  set background=dark
  colorscheme solarized
  set cursorline " highlight current line
endif

"if &t_Co > 2 || has("gui_running")
"  " switch syntax highlighting on, when the terminal has colors
"  syntax on
"endif

