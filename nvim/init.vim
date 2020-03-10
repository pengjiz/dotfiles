" {{{ Buffers, files, windows
set hidden
set autoread
set autowrite
set splitright
set splitbelow
" }}}

" {{{ Editing
set list
set expandtab
set shiftwidth=2
" }}}

" {{{ Search
" Smart case
set ignorecase
set smartcase

" Use ripgrep
if executable('rg')
  set grepprg=rg\ -S\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" Quick jump
let g:sneak#label = 1
let g:sneak#map_netrw = 0
" }}}

" {{{ Misc
" File explorer
let g:netrw_home = $HOME.'/.local/share/nvim/netrw'
" }}}

" {{{ Key bindings
let mapleader = ' '
let maplocalleader = ' '

" General
nnoremap Y y$
nnoremap <Leader>w :update<CR>

" Switch state
inoremap jk <Esc>
cnoremap jk <C-C>
" }}}
