#!/bin/bash
<< 'IpRotate'
Script criado por Luciano R - Suporte HostGator Brasil
28/04/2018
Array com a lista de ip's
Update no array para que não seja necessário adicionar IPS
IpRotate

iplist=($(ip a | awk '/eth0/,/inet6/' | awk '{print $2}'|grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"))
#Selecionar um ip aletório
ipfinal=${iplist[$RANDOM % ${#iplist[@]}]}
#Ip atual da configuração do exim
ipatual=`cat /etc/mailips | cut -d : -f2  | sed 's/\ //g'`
#Verificacao de ip atual X IP novo
     if [ $ipfinal = $ipatual ] ; then
    #echo "IP's iguais";
    #echo "Gerando novo IP";
    #sleep 1
#Gerando um novo IP caso o primeito IP gerado seja igual ao IP atual
        while [ $ipfinal = $ipatual ] ; do
            ipfinal=${iplist[$RANDOM % ${#iplist[@]}]}
        done
        echo "*: $ipfinal" > /etc/mailips;
        echo "`date` IP alterado de $ipatual para $ipfinal" >> /opt/exim/change_log;
   else
        echo "*: $ipfinal" > /etc/mailips;
        echo "`date` IP alterado de $ipatual para $ipfinal" >> /opt/exim/change_log;
   fi
#Corrigindo mailhelo
  if      [ $ipfinal = "162.144.134.1" ] ; then
         echo "*: mail1.virtuabrasil.com" > /etc/mailhelo;
   elif    [ $ipfinal = "142.4.19.134" ] ; then
         echo "*: mail2.virtuabrasil.com" > /etc/mailhelo;
   elif    [ $ipfinal = "162.214.3.227" ] ; then
        echo "*: mail3.virtuabrasil.com" > /etc/mailhelo;
  else
        echo "*: mail4.virtuabrasil.com" > /etc/mailhelo;
  fi
#reload no exim
/etc/init.d/exim reload > /dev/null 2> /opt/exim/error_log;