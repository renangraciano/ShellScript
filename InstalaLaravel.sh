#!/bin/bash

<< 'InstalaLaravel'
Instalação do Laravel
InstalaLaravel.sh - Instala o Laravel em uma conta cPanel

Instruções

Logue-se na conta via JailShell SSH e execute o comando abaixo

# bash <(curl -ks https://git.hostgator.com.br/renangraciano/hgscripts/raw/master/InstalaLaravel.sh)
# Após a primeira execução, para novos projetos utilize apenas:
# composer create-project laravel/laravel --prefer-dist $NOMEPROJETO


Autor : Renan Souza <renan.souza@endurance.com>
Contribuitors: Renan Souza

Funções Adicionadas
Valida a execução, suporte ea3 e ea4

Bugs reporte para renan.souza@endurance.com
InstalaLaravel

VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
RESETCOR="\033[0m"

#disallow root exec
if [[ `whoami` == "root" ]]
then
	echo -e "$VERMELHO Você não pode executar este script como root !!! $RESETCOR"
	exit
else

#if exists backup, if not create
if [[ -e .bashrc ]]
then
cp -p .bashrc{,BKPHG}
else 
touch .bashrc
fi

#insert php bin and composer aliases in user .bashrc
if [[ -e `stat /opt/php56/bin/php > /dev/null` ]] 
then
echo "alias php='/opt/php56/bin/php'" >> .bashrc
echo "alias composer='/home/"$(whoami)"/public_html/composer.phar'" >> .bashrc
else
echo "alias php='/opt/cpanel/ea-php56/root/usr/bin/php'" >> .bashrc
echo "alias composer='/home/"$(whoami)"/public_html/composer.phar'" >> .bashrc
fi

source .bashrc && cd public_html/

curl -sS https://getcomposer.org/installer | php

read -p "Informe o nome que deseja para o projeto ou deixe em branco:  " NOMEPROJETO

if [[ -z $NOMEPROJETO ]]
then 
	echo "Não foi informado o nome do projeto, criando o projeto hglaravel"
	NOMEPROJETO="hglaravel"
fi

composer create-project laravel/laravel --prefer-dist $NOMEPROJETO

echo "Instalação finalizada......."
echo -e "Acesse \n seudominio.com.br/$NOMEPROJETO/public/"
fi