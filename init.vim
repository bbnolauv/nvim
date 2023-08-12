if has('nvim')
  lua require('lauv')
else
  echoerr "Neovim hasn't been installed!!!"
endif

if filereadable('.local_vimrc')
  source .local_vimrc
endif
