#!/bin/bash

for ((i=1; i<=20; i++))
do
    canal=$(( ( RANDOM % 11 ) + 1 )) # Generar un número aleatorio entre 1 y 11
    sudo airbase-ng -e NombreDeRedFalso${i} -c $canal wlan0 &
done
