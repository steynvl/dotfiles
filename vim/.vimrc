" Don't want vi compatibility
set nocompatible


" ============================================================================ "
" ================================= Plugins ================================== "
" ============================================================================ "

filetype off " Turn off for plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/vundle'

" Tab completion
Plugin 'ervandew/supertab'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

" Better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit= "vertical"

call vundle#end()

" ============================================================================ "
" =========================== File and Filesystem ============================ "
" ============================================================================ "

" Enable filetype plugins
filetype plugin indent on

" Sandard filetype and backups
set ffs=unix,dos,mac
set encoding=utf8
let g:tex_flavor= "tex"

" NOTE: NO BACKUPS!! Assumes using git etc. instead!
set noswapfile
set nobackup
set writebackup

" Per file settings
autocmd FileType tex setlocal spell
autocmd FileType tex set complete+=kspell
" ...

" Remeber where we were when last editing a file
autocmd BufReadPost * 
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
set viminfo^=%

" NetRW file browser settings
let g:netrw_banner=0
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " split to right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'



" ============================================================================ "
" ============================= General Settings ============================= "
" ============================================================================ "

set history=700     " How many lines of history
set autoread        " Reload when file is changed externally
set cmdheight=1
set hidden          " Hide buffer when closed
set showcmd         " Show commands as you type

set incsearch       " Incremental search
set hlsearch        " Highlight search matches; press <esc><esc> to stop

" Match brackets
set showmatch
set matchtime=2

" No error feedback
set noerrorbells
set novisualbell
set t_vb=

" Timeout while waiting for key sequences
set timeoutlen=500

" Extra options for gui
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    " set guitablable=%M\ %t
    set guifont=Inconsolata\ 13
endif

" Copy/Paste from clipboard
if has('unnamedplus')
    set clipboard=unnamedplus
endif



" ============================================================================ "
" ============================= Text and Indent ============================== "
" ============================================================================ "

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

set autoindent
set smartindent
set wrap
set linebreak
set breakindent
set textwidth=80

" Give us nice EOL (end of line) characters
set listchars=tab:>-,space:‧,eol:¬,trail:-,extends:>,precedes:<
" set list      " Used for showing whitespace chars



" ============================================================================ "
" ========================== Windows and Interface =========================== "
" ============================================================================ "

set scrolloff=7
set number
set laststatus=2
set statusline=\ %0.32F\ %y%m%r%h\ %w%=CWD:\ %.25{getcwd()}\ \ \ Line:%4l/%L\ Col:%3c\ \ 

set wildmenu
set wildignore=*.o,*~,*.pyc,*.class,*.toc,*.aux,*.blg,*.log,*.bbl,*.lof,*.pdf
set path+=**    " Search subfolders

" Colors
colorscheme eva01
set background=dark
set t_Co=256
syntax enable



" ============================================================================ "
" ================================= Bindings ================================= "
" ============================================================================ "

" Useful for custom mappings
let mapleader = ","

" Stop highlighting search
nnoremap <silent> <esc><esc> <esc>:nohlsearch<cr>

" Navigating windows
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l 

" Resizing windows, these mappings might not be portable between different
" terminals
map + <c-w>+
map - <c-w>-
map > <c-w>>
map < <c-w><

if has('terminal')
    tmap <c-h> <c-w>h
    tmap <c-j> <c-w>j
    tmap <c-k> <c-w>k
    tmap <c-l> <c-w>l 
    tmap + <c-w>+
    tmap - <c-w>-
    tmap > <c-w>>
    tmap < <c-w><
endif

" Bracket completion
inoremap {{ {
inoremap {<bs> <space><bs>
inoremap { {}<left>
inoremap {<cr> {<cr>}<up><end><cr>
inoremap } <c-r>=CloseBrack('}')<cr>
vnoremap <leader>{ <esc>`>a}<esc>`<i{<esc>

inoremap [[ [
inoremap [<bs> <space><bs>
inoremap [ []<left>
inoremap [<cr> [<cr>]<up><end><cr>
inoremap ] <c-r>=CloseBrack(']')<cr>
vnoremap <leader>[ <esc>`>a]<esc>`<i[<esc>

inoremap (( (
inoremap (<bs> <space><bs>
inoremap ( ()<left>
inoremap (<cr> (<cr>)<up><end><cr>
inoremap ) <c-r>=CloseBrack(')')<cr>
vnoremap <leader>( <esc>`>a)<esc>`<i(<esc>

" Just moves right once if the next char is already a closing brace
function! CloseBrack(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<right>"
    else
        return a:char
    endif
endf

if has('terminal')
    " Notebook like repl
    function! Repl(lang)
        let l:win = win_getid()
        rightbelow vertical let l:term = term_start(a:lang, {"term_finish" : "close"})
        call win_gotoid(l:win)
        let w:notebook = l:term " window local variable to access Repl

        " Sends the current paragraph to the Repl
        map <silent> <buffer> <leader><cr> yip:call term_sendkeys(w:notebook, @" . "\n")<cr>
        " Sends the highlighted text to the Repl
        vmap <silent> <buffer> <leader><cr> y:call term_sendkeys(w:notebook, @" . "\n")<cr>
    endf

    " Starts a Repl in a terminal window
    command! -nargs=1 Repl call Repl("<args>")

    " Starts a continuous latex compiler in a terminal window
    command! -nargs=* Latex rightbelow vertical term++close latexmk -xelatex -pvc <args>
endif

