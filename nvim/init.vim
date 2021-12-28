" Editing
set list
set expandtab
set shiftwidth=2

" Buffer and file
set hidden
let g:netrw_home = stdpath('data').'/netrw'

" Search
set ignorecase
set smartcase
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
