#!/bin/bash
<<"EOF"
Script de Restreamento para o Facebook Pixel
Author : Renan Souza
Data : 28/02/2019
Bugs : renan.souza@endurance.com
Updates:
EOF

VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
RESETCOR="\033[0m"

#o Script não deve ser executado como root, se estiver como root o script sai
if [[ $(whoami) == "root" ]]
then
	echo -e "$VERMELHO
	Executar logado na conta via Jailshell.
	$RESETCOR"
	exit
fi

echo "Procurando PATH do Criador de Sites ..."
echo "-----------------------------------"
find ./ -type d -iname "viewer" 2> /dev/null
<<<<<<< HEAD
echo -en "\t"
echo "Copie o Path Desejado e cole abaixo ..."
echo "-----------------------------------"
read -p "Informe o PATH para aplicar o Pixel: " PATHPIXEL

if [[ -d ${PATHPIXEL} ]]
then
	#home do criador
	cd ${PATHPIXEL} && cd ..
	FILEJS="viewer/facebook-pixel.js"

#TEMPLATE
/usr/bin/tee $FILEJS << 'EOF'
=======
echo "\t"
echo "Copie o Path Desejado e cole abaixo ..."
echo "-----------------------------------"
read -p "Informe o PATH para aplicar o Pixel: " PATH

if [[ -d PATH ]]
then
	#home do criador
	cd $PATH && cd ..
	FILEJS="viewer/facebook-pixel.js"

#TEMPLATE
/usr/bin/tee -a $FILEJS << 'EOF'
>>>>>>> 7748b5bd9027873c24980b187bd9e7d180499e00
!function(f,b,e,v,n,t,s)
{if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};
if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version=’2.0′;
n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];
s.parentNode.insertBefore(t,s)}(window, document,’script’,
‘https://connect.Facebook.net/en_US/fbevents.js’);
<<<<<<< HEAD
fbq(‘init’, ‘PIXELID’);
=======
fbq(‘init’, ‘#PIXEL_ID#’);
>>>>>>> 7748b5bd9027873c24980b187bd9e7d180499e00
fbq(‘track’, ‘PageView’);
EOF
#TEMPLATE

#permissões e alteração da ID
<<<<<<< HEAD
/bin/chown $(/usr/bin/whoami). $FILEJS
read -p "Informe a ID do PIXEL: " IDPIXEL
sed -i 's/PIXELID/'"${IDPIXEL}"'/g' $FILEJS
=======
CONTA=$(whoami)
chown ${CONTA}. $FILEJS
read -p "Informe a ID do PIXEL: " IDPIXEL
sed -i 's/IDPIXEL/#PIXEL_ID#/g' $FILEJS
>>>>>>> 7748b5bd9027873c24980b187bd9e7d180499e00

#alteração no código html
BUSCAHTML="</head>"
PATTERNHTML="\
<script src=\"viewer/${FILEJS}\">\
</script><br/>\
<noscript><img height=\"1\" width=\"1\" style=\"display:none\"\
src=\"https://www.facebook.com/tr?id=${IDPIXEL}&ev=PageView&noscript=1\"/>\
</noscript>\
</head>"

find ./ -type f -name "*.html" | xargs sed -ie "s@$BUSCAHTML@$PATTERNHTML@g"
echo "Finalizado... "
else
echo -e "$VERMELHO Ocorreu um erro, verifique o PATH informado. $RESETCOR"
fi
exit