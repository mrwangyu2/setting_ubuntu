#/bin/bash
Janus_Install_Path="/opt/bee/janus"
Base_Dir="$(pwd)/.."
Packages_Dir="${Base_Dir}/packages"
Build_Dir="${Base_Dir}/build"

is_correct(){
  if [[ $? -ne 0 ]]; then
    echo "Error: break off for $1. return code: $?"
    exit $?
  fi
}

is_path_existence(){
  if [[ ! -d $1 ]]; then
    echo "Error: break off for not existence path=$1"
    exit -1
  fi
}

is_directory_existence_to_cancel(){
  if [[ -d $1 ]]; then
    echo "Info: $1 directory existence, operation cancel!"
    return 0
  fi
    return 1
}

is_continue(){
    while true; do
      read -p "Do you continue?[y|n]" yn
      case $yn in
        [Yy])
	  echo "yes"
	  break;
          ;;
        [Nn])
          echo "Interrupt!!!"	
	  exit -1;
          ;;
        *)
          echo "Please answer yes or no."
          ;;
       esac
    done
}

is_continue_by_return_value(){
  if [[ $? -ne 0 ]]; then
    is_continue
  fi
}

# $1: parameter
# $2: default value
# Default_Value: return default value of global:
is_empty_parameter(){
  if [[ $1 = "" ]]; then
    echo "Info: parameter is empty, do you want to default value?"
    is_continue
    Default_Value="$2"
  else
    Default_Value="$1"
  fi 
}

# $1: input install path
# $2: default install path
# Install_Path; return value
check_install_path(){
  Default_Value=""
  is_empty_parameter "$1" "$2"

  Install_Path=${Default_Value}
  Default_Value=""

  is_path_existence "${Install_Path}"
}

cp_if_directory_not_existence(){
  is_directory_existence_to_cancel $2
  if [[ $? -eq 1 ]]; then
    cp -rf $1 $2
  fi
}

get_timestamp(){
  echo "$(date +"%Y-%m-%d_%H_%M_%S")"
}

tar_to_build(){
  if [[ -d "${Build_Dir}/${1}" ]]; then
    rm -rf ${Build_Dir}/${1}
  fi

  if [[ -f "${Packages_Dir}/${1}.tar.gz" ]]; then
    tar -xvzf ${Packages_Dir}/${1}.tar.gz -C ${Build_Dir}/.
  elif [[ -f "${Packages_Dir}/${1}.tar.bz2" ]]; then
    tar -xjvf ${Packages_Dir}/${1}.tar.bz2 -C ${Build_Dir}/.
  elif [[ -f "${Packages_Dir}/${1}.tar" ]]; then
    tar -xvf ${Packages_Dir}/${1}.tar -C ${Build_Dir}/.
  elif [[ -f "${Packages_Dir}/${1}.zip" ]]; then
    unzip ${Packages_Dir}/${1}.zip -d ${Build_Dir}/.
  else
    echo "Error: break off for tar ${1}"
    exit -1
  fi
  is_correct "tar_to_build $1"
}

cd_to_build_dir(){
  cd ${Build_Dir}/$1 
  is_correct "cd $1"
}

executing_autogen(){
  if [[ -f "autogen.sh" ]]; then
    sh ./autogen.sh
    is_continue_by_return_value
  fi
}

executing_configure(){
  if [[ -f "configure" ]]; then
    ./configure --prefix=$1 $2
  elif [[ -f "config" ]]; then
    ./config --prefix=$1 $2
  else
    echo "Error: break off for not configure existence"
    exit -1
  fi
  is_correct "configure"
}

set_system_variable(){
  grep "$1" /etc/profile
  if [[ $? -eq 1 ]]; then
    echo "$1" >> /etc/profile
    source /etc/profile
  else
    echo "Info: $1 already existence in /etc/profile, nothing set everything." 
  fi
  source /etc/profile
}

pause(){
	read -p "$*"
}

