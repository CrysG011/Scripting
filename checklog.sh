#!/bin/bash

# Archivo de registro a monitorear
LOG_FILE="/var/log/auth.log"

# Número máximo de intentos fallidos permitidos
MAX_FAILED_ATTEMPTS=3

# Función para mostrar una notificación
function notify() {
    echo "ALERTA: Se han detectado $1 intentos fallidos de conexión desde la dirección $2"
    # notificaciones por correo electrónico, SMS, etc.
}

# Ciclo infinito para monitorear el archivo de registro
while true; do
    # Obtener las direcciones IP que han realizado intentos fallidos
    failed_ips=$(grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq)

    # Ciclo para verificar cada dirección IP
    for ip in $failed_ips; do
        # Contar el número de intentos fallidos para esta IP
        failed_count=$(grep "Failed password.*$ip" "$LOG_FILE" | wc -l)

        # Si el número de intentos fallidos es mayor que el umbral, notificar
        if [ "$failed_count" -ge "$MAX_FAILED_ATTEMPTS" ]; then
            notify "$failed_count" "$ip"
        fi
    done

    # Dormir durante un tiempo antes de volver a verificar el archivo de registro
    sleep 300  # Dormir 5 minutos
done
