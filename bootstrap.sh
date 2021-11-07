#!/bin/bash

set -euxo pipefail

apt-get update -y
apt-get install nginx curl vim wget screen git -y
ln -s /usr/bin/vim /usr/bin/nvim

tee ~/.vimrc <<'EOF'
syntax off set nohlsearch set t_C
set laststatus=0
set expandtab
set autoindent
set ignorecase
set ruler
set mouse=
set ttyfast
set hidden
set foldenable
set foldmethod=indent
hi clear texItalStyle
highlight Search ctermbg=gray
highlight Visual cterm=NONE ctermbg=233 ctermfg=NONE

set pastetoggle=<F10>
set clipboard=unnamedplus

filetype plugin indent on
set sts=2 sw=2
au FileType python setlocal tabstop=4
au FileType python setlocal softtabstop=4
au FileType html setlocal tabstop=2
au FileType html setlocal shiftwidth=2
au FileType javascript setlocal tabstop=2
au FileType javascript setlocal shiftwidth=2
au FileType css setlocal tabstop=2
au FileType css setlocal shiftwidth=2
autocmd FileType go setlocal noexpandtab
autocmd FileType go setlocal sts=8
autocmd FileType go setlocal sw=8
autocmd FileType make setlocal noexpandtab
autocmd FileType make setlocal sts=8
autocmd FileType make setlocal sw=8
EOF

tee ~/.bashrc <<'EOF'
PS1='[\u@\h \W ${VIRTUAL_ENV##*/}]\$ '

set -o vi

alias ll='ls -lash'
alias ipython='ipython --TerminalInteractiveShell.editing_mode=vi'
alias ipython2='ipython2 --TerminalInteractiveShell.editing_mode=vi'
alias ssh2='ssh -o ServerAliveInterval=90 -o StrictHostKeyChecking=no $1'
alias k='/usr/local/bin/kubectl'

export EDITOR=nvim
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
EOF

git clone https://github.com/karrug/karrug-com
cp karrug-com/index.html /var/www/html/index.html

rm /etc/nginx/sites-enabled/default

tee /etc/nginx/sites-available/karrug-com <<'EOF'
server {
  listen       80;
  server_name  _;

  root /var/www/html;
  index index.html;

  location / {
    try_files $uri $uri/ =404;
  }
}
EOF

ln -s /etc/nginx/sites-available/karrug-com /etc/nginx/sites-enabled/karrug-com
nginx -t
systemctl restart nginx

curl http://karrug.com
