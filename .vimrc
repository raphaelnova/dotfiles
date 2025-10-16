"
" see also /etc/vim/vimrc
"          /usr/share/vim
"

set encoding=utf-8
set foldmethod=indent
" an automatic command (au), triggered when a buffer is read (BufRead),
" matching all files (*) and executes opens all folds (zR)
au BufRead * normal zR

autocmd! bufwritepost .vimrc source %

" set textwidth=80 " autowrap when writing
set nobackup
set noswapfile
set nofixendofline
set modeline     " enable modeline (vim options on beggining of file)
set tabstop=2    " how many columns a tab counts for
set expandtab    " insert spaces when hit tab
set shiftwidth=2 " how many columns the reindent indents or to delimit folds
set autoindent
set number
set relativenumber
set scrolloff=5  " keep some line content on top and bottom of cursor
set ffs=unix " shows <CR>. See ++opt
set fileencoding=utf-8
set list
" I preffered ␤ (u2424) for newline, but Fira Code's glyph is too tiny
set listchars=space:·,trail:·,tab:‣–,precedes:«,extends:»,nbsp:␣,eol:↵
set nowrap          " == Below options are for :set wrap
set showbreak=›››\  " Indicates a wrapped line (instead of a new line).
set breakindent     " Indents the wrapped line accordingly.
set colorcolumn=80
"let &colorcolumn=join(range(81,999),",")

nnoremap <F5> :set list!<CR>:set list?<CR>
nnoremap <F6> :set wrap!<CR>:set wrap?<CR>

" `highlight` is for syntax coloring
" :help listchars:
"   "NonText" highlighting for "eol", "extends" and "precedes"
"   "SpecialKey" for "nbsp", "tab" and "trail"
" see also: https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
highlight NonText ctermfg=238
highlight SpecialKey ctermfg=238
" 089, 053
highlight Search cterm=NONE ctermfg=255 ctermbg=089
highlight ColorColumn ctermbg=235

set ignorecase
set smartcase    " only ignore case if search is all smallcase
set incsearch    " searches as characters are typed
set hlsearch     " highlight all search results
                 " :noh clears highlights (see mappings)

set wildmenu     " list cmd autocomplete options (cycle with tab)
set showmatch    " highlight matches {[()]}

" Paste mode
nnoremap <F2> :set paste!<CR>:set paste?<CR>
set pastetoggle=<F2>
set showmode

" Sets a bg color to highlight the current line, but leaves it disabled to be toggled manually with <F3>
highlight CursorLineNr   cterm=bold ctermfg=NONE ctermbg=233
highlight CursorLine     cterm=bold ctermfg=NONE ctermbg=233
highlight CursorColumnNr cterm=bold ctermfg=NONE ctermbg=233
highlight CursorColumn   cterm=bold ctermfg=NONE ctermbg=233
set cursorline
set nocursorcolumn
nnoremap <F3> :set cursorline!<CR>:set cursorline?<CR>
nnoremap <F4> :set cursorcolumn!<CR>:set cursorcolumn?<CR>

let mapleader="ç"

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

nnoremap <tab> %
inoremap kj <ESC>
nnoremap <leader>b  :buffers<CR>:b<space>
nnoremap <leader><space> :noh<CR>

" Bash utilities
" Exec buffer in Bash
nnoremap <leader>sh :w ! bash<CR>
" Exec buffer in Bash and replace it by its output
nnoremap <leader>sr :% ! bash<CR>
xnoremap <leader>sr : ! bash<CR>
" Inserts an UUID into the buffer
nnoremap <leader>uu :r ! uuidgen<CR>

" Commands
command! -range=% Encode     <line1>,<line2>!base64 | tr -d '\n'
command! -range=% Decode     <line1>,<line2>!base64 -d
command! -range=% Clip       <line1>,<line2>!tee >(xclip -selection clipboard)
command! -range=% XMLFormat  <line1>,<line2>!XMLLINT_INDENT="  " xmllint --format -
command! -range=% JSONFormat <line1>,<line2>!jq -M '.'
command! -range=% JSONSmall  <line1>,<line2>!jq -Mc '.'

" https://stackoverflow.com/a/7236867
"
"    range(0,bufnr('$'))
"       to have a |List| of all possible buffer numbers
"
"    filter(possible_buffers, 'buflisted(v:val)')
"       to restrict the list to the buffers that are actually listed -- you may prefer bufexist() that'll also show the help buffers, etc.
"
"    map(listed_buffer, 'nr_to_fullpath(v:val)')
"       to transform all the buffer numbers into full pathnames
"
"    bufname()
"        to transform a single buffer number into a (simplified) pathname
"
"    fnamemodify(pathname, ':p')
"        to have a full absolute pathname from a relative pathname.
"
" Change :echo to call writefile(pathname_list, 'filename'), and that's all, or to :put=, etc.
"
noremap <silent> <leader>so :call writefile( map(filter(range(0,bufnr('$')), 'buflisted(v:val)'), 'fnamemodify(bufname(v:val), ":p")'), 'open_buffers.txt' )<CR>

