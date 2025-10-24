" Vim Configuration

" Basic settings
set nocompatible              " Use Vim settings rather than Vi
set encoding=utf-8            " Use UTF-8 encoding
set fileencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis

" Display
syntax on                     " Enable syntax highlighting
set number                    " Show line numbers
set ruler                     " Show cursor position
set showcmd                   " Show command in bottom bar
set wildmenu                  " Visual autocomplete for command menu
set showmatch                 " Highlight matching brackets
set laststatus=2              " Always show status line
set cursorline                " Highlight current line

" Colors
set background=dark
colorscheme default

" Search
set incsearch                 " Search as characters are entered
set hlsearch                  " Highlight matches
set ignorecase                " Ignore case when searching
set smartcase                 " Unless search contains uppercase

" Indentation
set autoindent                " Auto indent
set smartindent               " Smart indent
set tabstop=4                 " Number of visual spaces per TAB
set shiftwidth=4              " Number of spaces for autoindent
set expandtab                 " Tabs are spaces
set smarttab

" Backups
set nobackup                  " No backup files
set nowritebackup
set noswapfile

" Performance
set lazyredraw                " Redraw only when needed

" Clipboard
if has('mac') || has('macunix')
  set clipboard=unnamed       " Use system clipboard on Mac
else
  set clipboard=unnamedplus   " Use system clipboard on other systems
endif

" Mouse
set mouse=a                   " Enable mouse support

" Key mappings
let mapleader = ","           " Leader key

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Save with Ctrl+S
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Move between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" File type specific settings
filetype plugin indent on
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType typescript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab
