#/bin/bash

TITLE="Setting Ubuntu16.04 Server LTS"

function main(){
  echo_message header "Starting main function"

  MAIN=$(eval `resize` && whiptail \
         --notags \
         --title "$TITLE" \
         --menu "\nWhat would you like to do?" \
         --cancel-button "Quit" \
         $LINES $COLUMNS $(( $LINES - 12 )) \
         "system_update"     "Update software source." \
         "install_apps"      "Install preferred applications" \
         "install_clang"      "Install clang" \
         "download_tar_packages" "Download preferred tar packages" \
         "system_configure"  "Configure system evironment" \
         3>&1 1>&2 2>&3)

  if [[ $? = 0 ]]; then
    echo_message header "Starting $MAIN function"
    $MAIN
  else
    echo_message info "Quit"
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




