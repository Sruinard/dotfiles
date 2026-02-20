" --- Appearance ---
syntax on            " Enable syntax highlighting
set number           " Show line numbers
set cursorline       " Highlight the current line
set termguicolors    " Better colors (works in zsh/tmux)

" --- Behavior ---
set mouse=a          " Enable mouse support
set clipboard=unnamedplus " Use system clipboard
set ignorecase       " Search case-insensitive...
set smartcase        " ...unless search contains uppercase
set noswapfile       " Don't create annoying .swp files

" --- Indentation ---
set expandtab        " Use spaces instead of tabs
set shiftwidth=4     " 1 tab = 4 spaces
set softtabstop=4
set autoindent