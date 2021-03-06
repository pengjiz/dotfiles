" Editing
set list
set expandtab
set shiftwidth=2

" Window
set splitright
set splitbelow

" Buffer and file
set hidden
let g:netrw_home = stdpath('data').'/netrw'

" Search
set ignorecase
set smartcase
if executable('rg')
  set grepprg=rg\ -S\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
