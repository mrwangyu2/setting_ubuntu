#/bin/bash

TITLE="Linux"
LINES=20
COLUMNS=50

function initialize_os(){
  echo_message header "Starting initialize_os function"
  if [[ $OS = "Ubuntu" ]]; then
    TITLE="Setting Ubuntu16.04 Server LTS"
    return
  elif [[ $OS = "Raspbain" ]]; then
    TITLE="Setting Raspberry Pi"
    LINES=20
    return
  fi
}

function execute_all_operations(){
  system_update
  install_apps
  configure_zsh
  configure_rc_local
}

function main(){
  echo_message header "Starting main function"

  initialize_os

  MAIN=$(eval 'whiptail \
	 --notags \
         --title "$TITLE" \
         --menu "\nWhat would you like to do?" \
         --cancel-button "Quit" \
         $LINES $COLUMNS $(( $LINES -12 )) \
         "system_update"     "Update software source." \
         "install_apps"      "Install preferred applications" \
         "install_clang"      "Install clang" \
         "download_tar_packages" "Download preferred tar packages" \
         "system_configure"  "Configure system evironment" \
         "execute_all_operations"  "Excute all operations" \
         3>&1 1>&2 2>&3')

  if [[ $? = 0 ]]; then
    echo_message header "Starting $MAIN function"
    $MAIN
  else
    echo_message info "Quit"
    #pause_process
    exit 99
  fi

}

function import_functions(){
	DIR="functions"
        for FUNCTION in $(dirname "$0")/$DIR/*; do
          if [ -d $FUNCTION ]; then
	    continue
           elif [ -f $FUNCTION ]; then
	    . $FUNCTION
          fi
        done
}

import_functions
system_checks

while :
do
  main
done




