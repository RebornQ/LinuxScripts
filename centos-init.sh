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
  echo "starting del user ..."
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

install_software() {
  echo "starting install software ..."
  yum install epel-release -y
  yum update -y
  yum install git wget screen nmap vim htop iftop iotop zip telnet nano -y
  echo "software installed !!!"
}

install_oh_my_zsh(){
  echo "starting install oh_my_zsh ..."
  yum -y install zsh
  chsh -s /bin/zsh
  sh -c "$(wget -O- https://cdn.jsdelivr.net/gh/ohmyzsh/ohmyzsh/tools/install.sh)"
  echo "oh_my_zsh installed !!!"
}

disable_root_login() {
  echo "starting disable root login ..."
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak
  sudo sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
  sudo systemctl restart sshd
  echo "your sshd_config.PermitRootLogin is set to no"
}

enable_root_login() {
  echo "starting enable root login ..."
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak
  sudo sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
  sudo systemctl restart sshd
  echo "your sshd_config.PermitRootLogin is set to yes"
}

print_systeminfo() {
  echo "******************************************************"
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
  echo "******************************************************"
}

help() {
  echo -e "1) add_user\t\t4) enable_root_login\t\t7) exit"
  echo -e "2) del_user\t\t5) install_software\t\t8) help:"
  echo -e "3) disable_root_login   6) install_oh_my_zsh"
}

main() {
  print_systeminfo
  centos_funcs="add_user del_user
  disable_root_login enable_root_login
  install_software install_oh_my_zsh
  exit help"
  select centos_func in $centos_funcs:; do
    case $REPLY in
    1)
      add_user
      help
      ;;
    2)
      del_user
      help
      ;;
    3)
      disable_root_login
      help
      ;;
    4)
      enable_root_login
      help
      ;;
    5)
      install_software
      help
      ;;
    6)
      install_oh_my_zsh
      help
      ;;
    7)
      exit
      ;;
    8)
      help
      ;;
    *)
      echo "please select a true num"
      ;;
    esac
  done
}

main
