#!/bin/bash

# Obtener la lista de tarjetas de red disponibles
tarjetas_disponibles=$(ls /sys/class/net)

# Mostrar las tarjetas disponibles con números de opción
echo "Seleccione la tarjeta de red:"
select tarjeta in $tarjetas_disponibles
do
    if [ -n "$tarjeta" ]; then
        echo "Ha seleccionado la tarjeta de red: $tarjeta"
        break
    else
        echo "Opción no válida. Inténtelo de nuevo."
    fi
done

# Almacenar los PID de los procesos en segundo plano
pids=()

function generar_punto_de_acceso {
    local nombre_de_red="$1"
    local canal="$2"
    
    # Crear punto de acceso falso en segundo plano
    sudo airbase-ng -e "$nombre_de_red" -c "$canal" "$tarjeta" &
    
    # Almacenar el PID del proceso actual
    pids+=($!)

    echo "Punto de acceso falso '$nombre_de_red' creado en el canal $canal."
}

echo "Seleccione una opción:"
echo "1.- Dedicarle nombre"
echo "2.- Usar una lista txt para espamear de redes"
read opcion

if [ "$opcion" == "1" ]; then
    echo "Ingrese el nombre para el punto de acceso falso:"
    read nombre

    echo "¿Cuántos puntos de acceso falsos desea crear?"
    read cantidad

    for ((i=1; i<=$cantidad; i++))
    do
        canal=$(( ( RANDOM % 11 ) + 1 )) # Generar un número aleatorio entre 1 y 11
        generar_punto_de_acceso "${nombre}${i}" "$canal"
    done

elif [ "$opcion" == "2" ]; then
    echo "Ingrese el nombre del archivo txt que contiene la lista de nombres:"
    read archivo_txt

    # Verificar si el archivo existe
    if [ -f "$archivo_txt" ]; then
        while IFS= read -r nombre
        do
            canal=$(( ( RANDOM % 11 ) + 1 )) # Generar un número aleatorio entre 1 y 11
            generar_punto_de_acceso "$nombre" "$canal"
        done < "$archivo_txt"
    else
        echo "El archivo '$archivo_txt' no existe."
        exit 1
    fi

else
    echo "Opción no válida. Saliendo."
    exit 1
fi

# Esperar a que todos los procesos en segundo plano terminen
for pid in "${pids[@]}"; do
    wait "$pid"
done

echo "Todos los puntos de acceso falsos han sido creados correctamente."
