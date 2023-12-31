#!/bin/bash

echo "Tarjetas de red disponibles:"
ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'

echo "Seleccione una tarjeta de red:"
read tarjeta

echo "Seleccione una opción:"
echo "1.- Dedicarle nombre"
echo "2.- Usar una lista txt para espamear redes"
read opcion

if [ $opcion -eq 1 ]; then
    echo "Ingrese el nombre para espamear:"
    read nombre
    echo "Ingrese la cantidad de redes que desea:"
    read cantidad
    for ((i=1; i<=$cantidad; i++))
    do
        canal=$(( ( RANDOM % 11 ) + 1 )) # Generar un número aleatorio entre 1 y 11
        sudo airbase-ng -e $nombre$i -c $canal $tarjeta &
        sleep 1  # Esperar 1 segundo antes de ejecutar el siguiente comando
    done
elif [ $opcion -eq 2 ]; then
    echo "Ingrese el nombre del archivo de texto con la lista de nombres:"
    read archivo
    while IFS= read -r nombre
    do
        canal=$(( ( RANDOM % 11 ) + 1 )) # Generar un número aleatorio entre 1 y 11
        sudo airbase-ng -e $nombre -c $canal $tarjeta &
        sleep 1  # Esperar 1 segundo antes de ejecutar el siguiente comando
    done < "$archivo"
else
    echo "Opción inválida. Por favor, seleccione una opción válida."
fi
