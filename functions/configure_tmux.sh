#!/bin/bash

function configure_tmux(){
  echo_message header "Starting configure_tmux fucntions"
  install_plugins
}

function install_plugins(){
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  cp ./data/tmux_script/tmux.conf ~/.tmux.conf
  tmux
  # prefix + I to install plugins
  tmux source ~/.tmux.conf
  cp ./data/tmux_script/default.sh ~/.tmux/plugins/tmux-powerline/themes/.
} 

