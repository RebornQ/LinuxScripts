#!/bin/bash
# CentOS Linux release (version?) 系统 初始化脚本
# Powered by Reborn
# 参考 https://github.com/bboysoulcn/centos

add_user() {
  echo "starting add user ..."
  read -p "Username:" username
  read -s "Password:" password
  adduser $username
  if [ "$?" = "0" ]; then
    echo $password | passwd --stdin $username
    read -p "set this user as root?(y)" setroot
    if [[ -n $setroot || $setroot == "y" || $setroot == "Y" ]]; then
      tee /etc/sudoers.d/$username <<<'$username ALL=(ALL) ALL'
      chmod 440 /etc/sudoers.d/$username
      echo "root user created !!!"
    else
      echo "user created !!!"
    fi
  else
    echo "cannot create user" 1>&2
    exit 1
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
  echo "2) exit"
  echo "3) help:"
}

main() {
  print_systeminfo
  centos_funcs="add_user exit help"
  select centos_func in $centos_funcs:; do
    case $REPLY in
    1)
      add_user
      ;;
    2)
      exit
      ;;
    3)
      help
      ;;
    *)
      echo "please select a true num"
      ;;
    esac
  done
}

main
