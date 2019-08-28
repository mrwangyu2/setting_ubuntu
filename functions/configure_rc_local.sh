#!/bin/bash

function configure_rc_local(){
  echo_message header "Starting configure_zsh fucntions"
  superuser_do cp ./data/rc-local.service /etc/systemd/system/.
  superuser_do cp ./data/rc.local /etc/.

}

