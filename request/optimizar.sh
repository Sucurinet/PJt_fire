#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "     \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "     \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}

echo -e "${cor[3]} $(fun_trans "OPTIMIZAR SERVIDOR") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -e "\033[1;37m Actualizando servicios\033[0m"
fun_bar 'apt-get update -y' 'apt-get upgrade -y'
echo -e "\033[1;37m Corrigiendo problemas de dependencias"
fun_bar 'apt-get -f install'
echo -e "\033[1;37m Removendo paquetes inútiles"
fun_bar 'apt-get autoremove -y' 'apt-get autoclean -y'
echo -e "\033[1;37m Removendo paquetes con problemas"
fun_bar 'apt-get -f remove -y' 'apt-get clean -y'
echo -e "$barra"

fun_limpram () {
sync 
echo 3 > /proc/sys/vm/drop_caches
sleep 4
sync && sysctl -w vm.drop_caches=3
sysctl -w vm.drop_caches=0
swapoff -a
swapon -a
sleep 4
}

function aguarde {
sleep 1
helice ()
{
	fun_limpram > /dev/null 2>&1 & 
	tput civis
	while [ -d /proc/$! ]
	do
		for i in / - \\ \|
		do
			sleep .1
			echo -ne "\e[1D$i"
		done
	done
	tput cnorm
}

MEM1=`free|awk '/Mem:/ {print int(100*$3/$2)}'`
echo -e "\033[1;37mMemória \033[1;32mRAM \033[1;37mAntes de Otimizacion:\033[1;36m" $MEM1% 
echo ""
sleep 1.5s
echo -e "\033[1;37m LIMPANDO MEMORIA \033[1;32mRAM \033[1;37me \033[1;32mSWAP"
fun_bar 'service ssh restart'
helice
echo -e "\033[1;32m\e[1DOk!"
}
aguarde
sleep 1.5s

MEM2=`free|awk '/Mem:/ {print int(100*$3/$2)}'`
echo ""
echo -e "\033[1;37mMemória \033[1;32mRAM \033[1;37mahora en la Otimizacion:\033[1;36m" $MEM2% 
echo ""
sleep 1.5s
echo -e "\033[1;37m ECONOMIA DE :\033[1;36m `expr $MEM1 - $MEM2`%\033[0m"
echo -e "$barra"
