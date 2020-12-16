#!/bin/bash
# CentOS Linux release (version?) 系统 初始化脚本
# Powered by Reborn
# 参考 https://github.com/bboysoulcn/centos

add_user() {
  echo "starting add user ..."
  read -p "Username:" username
  echo "Password:"
  read -s password
  sudo adduser $username
  if [ "$?" = "0" ]; then
    echo $password | sudo passwd --stdin $username
    read -p "set this user as sudoer? (y)" setroot
    if [[ -n $setroot || $setroot == "y" || $setroot == "Y" ]]; then
      sudo tee /etc/sudoers.d/$username <<<$username' ALL=(ALL) ALL'
      sudo chmod 440 /etc/sudoers.d/$username
      echo "root user created !!!"
    else
      echo "user created !!!"
    fi
  else
    echo "cannot create user" 1>&2
    exit 1
  fi
}

del_user() {
  echo "deleting add user ..."
  cat /etc/passwd | grep -v nologin | grep -v halt | grep -v shutdown | awk -F":" '{ print $1"|"$3"|"$4 }' | more
  read -p "Username:" username
  read -p "Confirm: Do you really want to del this user? (y)" del
  if [[ -n $del || $del == "y" || $del == "Y" ]]; then
    sudo userdel -r $username
    if [ "$?" = "0" ]; then
      echo "user $username has been deleted !!!"
    else
      echo "cannot delete user" 1>&2
      exit 1
    fi
  fi
}

print_systeminfo() {
  echo "**********************************"
  echo "Powered by Reborn"
  echo "Email: ren.xiaoyao@gmail.com"
  echo "Hostname:" $(hostname)
  # virtualization
  cat /proc/cpuinfo | grep vmx >>/dev/null
  if [ $? == 0 ]; then
    echo "Supporting virtualization"
  else
    echo "Virtualization is not supported"
  fi
  echo "Cpu:" $(cat /proc/cpuinfo | grep "model name" | awk '{ print $4" "$5""$6" "$7 ; exit }')
  echo "Memory:" $(free -m | grep Mem | awk '{ print $2 }') "M"
  echo "Swap: " $(free -m | grep Swap | awk '{ print $2 }') "M"
  echo "Kernel version: " $(cat /etc/redhat-release)
  echo "**********************************"
}

help() {
  echo "1) add_user"
  echo "2) del_user"
  echo "3) exit"
  echo "4) help:"
}

main() {
  print_systeminfo
  centos_funcs="add_user del_user exit help"
  select centos_func in $centos_funcs:; do
    case $REPLY in
    1)
      add_user
      ;;
    2)
      del_user
      ;;
    3)
      exit
      ;;
    4)
      help
      ;;
    *)
      echo "please select a true num"
      ;;
    esac
  done
}

main
