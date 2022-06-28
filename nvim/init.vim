set list
set expandtab
set shiftwidth=2
set hidden

set ignorecase
set smartcase
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
