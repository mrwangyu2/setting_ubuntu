#!/bin/bash

source functions/base_script.sh

# 设置时区为 China/Shanghai
sudo timedatectl set-timezone Asia/Shanghai

# 显示当前时间和时区
info "Time zone set to Asia/Shanghai"
sudo timedatectl

