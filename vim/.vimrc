" Disable compatibility with vi which can cause unexpected issues
set nocompatible

" Do not save backup files.
set nobackup

" Set the commands to save in history default number is 20.
set history=1000

" FILE TYPE  ---------------------------------------------------------------- {{{

" Enable type file detection
filetype on

" Load plugin for the detected file type
filetype plugin on

" Load an indent file for the detected file type
filetype indent on

" }}}

" DISPLAY  ------------------------------------------------------------------ {{{

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" }}}

" FORMATTING ---------------------------------------------------------------- {{{

" Syntax highlighting on
syntax on

" Use highlighting when doing a search.
set hlsearch

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" }}}

" SPACING ------------------------------------------------------------------- {{{

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" }}}
