#!/bin/bash

source functions/base_script.sh

Resource_Path="./resources/source_list"

setting_pip_sources(){
  info "Setting pip sources"
  mkdir -p ~/.config
  execute_with_retry "sudo cp -rf ${Resource_Path}/sources_pip ~/.config/pip"
}

setting_github_dns(){
  info "Setting github dns"
  execute_with_retry "sudo sh -c 'echo \"199.232.4.133 raw.githubusercontent.com\" >> /etc/hosts'"
}

system_update(){
  info "Starting system_update function"

  which_os

  ret=$?
  Source_File=""
  if [[ $ret = 18 ]]; then
    Source_File="sources.list.ubuntu18.04"
  elif [[ $ret = 20 ]]; then
    Source_File="sources.list.ubuntu20.04"
  elif [[ $ret = 22 ]]; then
    Source_File="sources.list.ubuntu22.04"
  fi
  execute_with_retry "sudo cp ${Resource_Path}/${Source_File} /etc/apt/sources.list"

  execute_with_retry "sudo apt update"

  setting_pip_sources

  setting_github_dns

  print_results
}

system_update
