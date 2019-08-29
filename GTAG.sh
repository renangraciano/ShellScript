#!/bin/bash
<< 'GTAG'
Cria um arquivo gtag.js na pasta viewer do criador de sites com um template do GTAG,
Busca pela tag HEAD no cabeçalho dos arquivos .html e adiciona a chamada do arquivo JavaScript com a UAID do Analytics.

Usage:
Informe o domínio, se for válido e o diretório viewer existir o script será executado, se não informará o erro.
GTAG

VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
RESETCOR="\033[0m"

#o Script não deve ser executado como root, se estiver como root o script sai
if [[ `whoami` == "root" ]]
then
	echo -e "$VERMELHO
	Executar logado na conta via Jailshell.
	$RESETCOR"
	exit
else
	CONTA=$(whoami)
    TEMPLATE="https://git.hostgator.com.br/renangraciano/hgscripts/raw/master/criador/template/gtag.js" 
	FILEJS="viewer/gtag.js"

	echo -e "$VERDE Você está em : $(pwd) $RESETCOR"
	echo -e "$VERMELHO Você deve estar no DOCROOT do site que deseja corrigir! $RESETCOR"

	read -p "Informe a ID de controle do analytics: " UAID
	if [ -d viewer/ ]
		then
			wget -q $TEMPLATE -O $FILEJS
			chown $CONTA. $FILEJS
			sed -i 's/GATRACKINGID/'"$UAID"'/g' $FILEJS
			BUSCAHTML="</head>"
			PATTERNHTML="<script src=\"viewer/gtag.js\"></script></head>"
			find ./ -type f -name "*.html" | xargs sed -ie "s@$BUSCAHTML@$PATTERNHTML@g"
			echo "Finalizado... "
		else
			echo -e "$VERMELHO Ocorreu um erro, certifique-se de estar executando dentro do DOCROOT correto e de o diretório viewer existir. $RESETCOR"
		fi
fi
exit