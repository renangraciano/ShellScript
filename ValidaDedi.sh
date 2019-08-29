#!/bin/bash
<< 'VALIDADEDI'
Autor: Renan Souza <renan.souza@endurance.com>
Contribuitors: Renan Souza, 
Functions: Services status, Load Usage, Memory Consumption, Mail Auth Validator,
Update: 17/12/2018
Bugs: Report for <renan.souza@endurance.com>


VALIDADEDI
#Script com funções úteis para a validação de curto prazo
echo -en "Status dos serviços: "
txtgrn='\e[1;32m';txtrst='\e[0m';
echo -e "${txtgrn}Server Uptime :${txtrst}$(uptime)";
echo -e "${txtgrn}Apache Uptime :${txtrst}$(service httpd fullstatus 2> /dev/null | grep uptime | cut -d':' -f2)";
echo -e "${txtgrn}MySQL Uptime  : ${txtrst}$(mysqladmin version 2> /dev/null | grep Uptime | cut -f4)";
echo -e "${txtgrn}Exim Status   : ${txtrst}$(/etc/init.d/exim status 2> /dev/null )";
echo -e "${txtgrn}pure-ftpd     : ${txtrst}$(/etc/init.d/pure-ftpd status 2> /dev/null | grep pure-ftpd)";
echo -e "${txtgrn}sshd status   : ${txtrst}$(/etc/init.d/sshd status 2> /dev/null | grep openssh)";
echo -e "${txtgrn}cPanel status : ${txtrst}$(/etc/init.d/cpanel status 2> /dev/null | grep cpsrvd)";
echo -e "${txtgrn}named status  : ${txtrst}$(/etc/init.d/named status 2> /dev/null | grep server)"


highload() { 
	echo -en "::::: Load do dia ::::: \n"

	echo -ne "\n Dia com dois digitos: " && read DIA
	echo -ne "\n Mês com dois digitos: " && read MES

	DAY=$(date -d "$1" +$MES/$DIA) ; 
	sys-snap ${DAY} | awk '!/proc_rstate/{ 
		if ( $2 > 100 ) { 
			print $1"\t\033[1;91m"$2"\033[0m" } 
		else if ( $2 > 75 ) { 
			print $1"\t\033[0;31m"$2"\033[0m" } 
		else if ( $2 > 50 ) { 
			print $1"\t\033[0;93m"$2"\033[0m" } 
		else if ( $2 > 10 ) { 
			print $1"\t\033[0;33m"$2"\033[0m" } 
		else if ( $2 > 1 ) { print $1"\t"$2 } }'  
		} 
		

		snappy() {
		read -p "Informe a hora de maior load ex 05:35:  " HORA

			snt="$HORA"; 
			bb='\e[1;34m';bc='\e[1;36m';bw='\e[1;37m';co='\e[0m'; 
			echo -en $bc;  
			sys-snap -C $DAY $snt|head -n3; 
			echo -e "${bw}Top SQL${co}"; 
			sys-snap -C --sql $DAY $snt|awk '/Query/ {print $4}'|sort|uniq -c|sort -gr|column -t; 
			echo -en $bc; 
			sys-snap $DAY $snt|awk '/bin.php/ {pct=pct+$3;pmt=pmt+$4} END {print "Total PHP statistics:  CPU %: "pct" | Mem %: "pmt }'; 
			echo -en $co; 
			echo -e "${bb}Top PHP Users${co}"; 
			sys-snap -C $DAY $snt|awk '/bin.php/ {puc[$1]=puc[$1]+1;pucp[$1]=pucp[$1]+$3;pum[$1]=pum[$1]+$4} END {for(key in puc) {   print puc[key]" "key"\t-> CPU %: "pucp[key]" | Mem %: "pum[key]}}'|sort -nrk1|column -t; 
			echo -e "${bw}Top PHP Scripts${co}"; 
			sys-snap -C $DAY $snt|awk '/bin.php/ {psc[$NF]=psc[$NF]+1;pscp[$NF]=pscp[$NF]+$3;psm[$NF]=psm[$NF]+$4}  END {for(key in psc) { print psc[key]"  " key"\t-> CPU %: "pscp[key]" | Mem %: "psm[key]}}'|sort -nrk1|column -t ; 
			echo -e "${bb}Is Exim Hung?${co}"; 
			sys-snap -C $DAY $snt|grep \_./usr/sbin/exim|awk '{print $14}'|sort|uniq -c|column -t; 
			echo -ne "${bw}Webmail processes? (Note: Right now its only squirrelmail and roundcube): ";
			sys-snap $DAY $snt|egrep '3rdparty/squirrelmail|3rdparty/roundcube'|wc -l;
			echo -ne ${co}; 
			echo -e "${bb}Connections to the Server:${co}";
			sys-snap -C -a $DAY $snt|awk '{print $3}'|sort -n|cut -d: -f1|egrep '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}$'|grep -v 0.0.0.0|uniq -c|sort -rn; }; 


			
func_menu(){
echo -en "
| LOAD DO DIA - 1 |
| STATUS HORA - 2 |
" 
read resp_menu

case "$resp_menu" in
	1"")
	highload
	func_menu
;;
	2)
	snappy
	func_menu
;;
	*)
	echo "opção inválida..."
	exit
	;;
esac
}
func_menu