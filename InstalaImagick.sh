#!/bin/bash
<< 'Instalador_ImageMagick'
Desenvolvido e mantido por Renan Souza <renan.souza@endurance.com>

Realiza a instalação do ImageMagick para todas as versões do PHP habilitadas no servidor,

Ultimo Update: 17/02/2019

Bugs:
Relate para  <renan.souza@endurance.com> 
Instalador_ImageMagick

echo -en "Informações adicionais\n
Esta instalação deve ser realizada por um L em ambientes dedicados ou VPS\n
Deseja Prosseguir com a Instalação do ImageMagick? (S/N):"

#confirmação de execução
read resp_imagick;
case $resp_imagick in
		's' | 'S' )
		echo -en "Tudo bem, continuando ..."
		yum -y install ImageMagick-devel ImageMagick-c++-devel ImageMagick-perl

		for phpver in $(ls -1 /opt/cpanel/ |grep ea-php | sed 's/ea-php//g') ; do printf "\autodetect" | \
		/opt/cpanel/ea-php$phpver/root/usr/bin/pecl install imagick; echo 'extension=imagick.so' >> /opt/cpanel/\
		ea-php$phpver/root/etc/php.d/imagick.ini;done
		echo "Caso ocorram erros acima os mesmos se dão devido a versões inexistentes do PHP em /opt/cpanel verifique."
		echo "Reiniciando os serviços e finalizando a instalação."
		/scripts/restartsrv_httpd;/scripts/restartsrv_apache_php_fpm
		echo "Tudo OK, Checando a instalação.";
		/usr/bin/convert --version;
		for phpver in $(ls -1 /opt/cpanel/ |grep ea-php | sed 's/ea-php//g') ; do echo "PHP $phpver" ; \
		/opt/cpanel/ea-php$phpver/root/usr/bin/php -m |grep imagick;done
		echo "Instalação finalizada, saindo."
exit;

		;;
		
		'n' | 'N' )
		echo -en "Abortarei a missão ..."
		;;
esac