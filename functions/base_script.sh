#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 结果数组
declare -a g_results

# 打印信息函数
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 打印成功信息函数
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 打印警告信息函数
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 打印错误信息函数
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 记录结果函数
record_result() {
    local command=$1
    local status=$2
    if [ $status -eq 0 ]; then
        g_results+=("${GREEN}[SUCCESS]${NC} $command")
    else
        g_results+=("${RED}[FAILED]${NC} $command")
    fi
}

# 定义 superuser_do 函数
# 示例用法
# superuser_do ls /root
function superuser_do() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: superuser_do <command>"
        return 1
    fi

    # 拼接命令行参数
    local command="$*"

    # 使用 sudo 执行命令
    # echo -e "\n${GREEN}Executing command as superuser:${NC} ${command}"
    sudo bash -c "$command"
}

# $1="Ubuntu" or "Raspbian"
function is_valid_os(){
    lsb_release -ds | grep -qE "$1"
    if [[ $? = 0 ]]; then
      export OS=$1
      return 0
    else
      return 1
    fi
}

function which_os(){
  is_valid_os "Ubuntu 16.04" 
  if [[ $? = 0 ]]; then
    export OS="Ubuntu 16.04 LTS"
    return 16
  fi

  is_valid_os "Ubuntu 18.04" 
  if [[ $? = 0 ]]; then
    export OS="Ubuntu 18.04 LTS"
    return 18
  fi
  
  is_valid_os "Ubuntu 20.04" 
  if [[ $? = 0 ]]; then
    export OS="Ubuntu 20.04 LTS"
    return 20
  fi
  
  is_valid_os "Ubuntu 22.04" 
  if [[ $? = 0 ]]; then
    export OS="Ubuntu 22.04 LTS"
    return 22
  fi

  is_valid_os "Raspbian"
  if [[ $? = 0 ]]; then
    export OS="Raspbain"
    return 0
  fi

  return 1
}


# 执行命令并处理失败情况函数
execute_with_retry() {
    local command=$1
    local retry=false

    while true; do
        echo
        info "Executing command: $command"
        eval "$command"

        if [ $? -eq 0 ]; then
            success "Command executed successfully."
            record_result "$command" 0
            break
        else
            error "Command failed."
            record_result "$command" 1
            warn "Do you want to retry? (r to retry, any other key to skip)"
            read -n 1 choice
            if [ "$choice" == "r" ]; then
                retry=true
            else
                retry=false
            fi

            if ! $retry; then
                warn "Skipping command: $command"
                break
            fi
        fi
    done
}

print_results() {
  # 显示结果汇总
  echo
  info "Execution summary:"

  for result in "${g_results[@]}"; do
    echo -e "$result"
  done

  g_results=()
}

# 从文件读取命令并执行
execute_commands_from_file() {
  local file=$1
  if [ ! -f $file ]; then
    error "File not found: $file"
    exit 1
  fi

  IFS=$'\n'

  # 读取文件并将每一行存储到数组中
  commands=()
  while IFS= read -r line || [ -n "$line" ]; do
    # 跳过空行
    [ -z "$line" ] && continue
    commands+=("$line")
  done < "$file"

  # 遍历数组并执行每一行命令
  for cmd in "${commands[@]}"; do
    execute_with_retry $cmd
  done

  print_results
}
