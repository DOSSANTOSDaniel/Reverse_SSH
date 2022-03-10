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
#--------------------------------------------------#
set -e

### Global variables ###
declare ip_remote       # Remote host
declare user_remote     # Remote user

declare port_remote     # Port tunnel
readonly port_forward='2211' # Port forward 2211 >> 22

declare pid_rssh        # PID

### Main ###
clear

cat << "EOF"
 ____     __         __               __  _     
|  _ \   / /         \ \             / / | |    
| |_) | / /_____ _____\ \_____ _____/ /  | |    
|  _ <  \ \_____|_____/ /_____|_____\ \  | |___ 
|_| \_\  \_\         /_/             \_\ |_____|
                                                
EOF

if ! command -v 'ssh' > /dev/null
then
  echo "Le client SSH n'est pas installé"
  exit 1
fi

while [ -z "$ip_remote" ]
do
  read -r -p $'\n IP de la machine distante : ' ip_remote
done

while [ -z "$user_remote" ]
do
  read -r -p $'\n Utilisateur sur la machine distante : ' user_remote
done

while [ -z "$port_remote" ]
do
  read -r -p $'\n Port de connexion en écoute sur la machine distante : ' port_remote
done

echo -e "\n Start RSSH ... \n"

ssh -f -N -T -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -o 'StrictHostKeyChecking=no' -R ${port_forward}:localhost:22 -p $port_remote ${user_remote}@${ip_remote}    
readonly pid_rssh="$(pidof -x ssh)"

echo -e "\n Pour se connecter : ssh -p $port_forward <USER>@127.0.0.1"
echo -e "\n Pour arrêter le tunnel : kill $pid_rssh \n"
