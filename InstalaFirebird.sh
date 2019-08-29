#!/bin/bash
<< 'FIREBIRD'
Autor: Renan Souza <renan.souza@endurance.com>
Contributors: 
Creation: 27/03/2019 
Update: 27/03/2019

Funcionality: Install firebird and compile PHP for use with Interbase.

BUGS: Relate for <renan.souza@endurance.com> 
FIREBIRD

#Versões estáveis
PHP54="http://us1.php.net/get/php-5.4.40.tar.gz/from/this/mirror"
PHP55="http://us1.php.net/get/php-5.5.38.tar.gz/from/this/mirror"
PHP56="http://us1.php.net/get/php-5.6.40.tar.gz/from/this/mirror"
PHP70="http://us1.php.net/get/php-7.0.0.tar.gz/from/this/mirror"
PHP71="http://us1.php.net/get/php-7.1.27.tar.gz/from/this/mirror"
PHP72="http://us1.php.net/get/php-7.2.16.tar.gz/from/this/mirror"
PHP73="http://us1.php.net/get/php-7.3.3.tar.gz/from/this/mirror"

if [[ ! $(hostname) =~ ^"br" ]] || [[ $(hostname) =~ ^"srv" ]] \
	|| [[ $(hostname) =~ ^"vega" ]] || [[ $(hostname) =~ ^"polaris" ]] ||\
	 [[ $(hostname) =~ ^"canopus" ]]

	then
	
			if [[ $(yum install -y epel-release && yum install -y firebird-superclassic firebird-devel) ]]
				then
				/etc/init.d/firebird-superclassic start && chkconfig --level 345 firebird-superclassic on
			fi

tempdir="/root/tmp/"

			if [[ -d $tempdir ]]
				then
				cd $tempdir
				else
				mkdir $tempdir && cd $tempdir
			fi

	#obter as versões do php
			for phpver in \
				$(ls -1 /opt/cpanel/|grep ea-php|sed 's/ea-php//g'|cut -d/ -f1)
			do
				case $phpver in
					54)
						wget -O php54.tar.gz $PHP54
						tar -xvzf php54.tar.gz && cd php-5.4.40/ext/interbase/
						/opt/cpanel/ea-php54/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php54/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php54/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php54/root/etc/php.d/interbase.ini 
					;;
					55)
						wget -O php55.tar.gz $PHP55
						tar -xvzf php55.tar.gz && cd php-5.5.38/ext/interbase/
						/opt/cpanel/ea-php55/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php55/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php55/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php55/root/etc/php.d/interbase.ini 
					;;
					56)
						wget -O php56.tar.gz $PHP56
						tar -xvzf php56.tar.gz && cd php-5.6.40/ext/interbase/
						/opt/cpanel/ea-php56/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php56/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php56/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php56/root/etc/php.d/interbase.ini 
					;;
					70)
						wget -O php70.tar.gz $PHP70
						tar -xvzf php70.tar.gz && cd php-7.0.0/ext/interbase/
						/opt/cpanel/ea-php70/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php70/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php70/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php70/root/etc/php.d/interbase.ini 
					;;
					71)
						wget -O php71.tar.gz $PHP71
						tar -xvzf php71.tar.gz && cd php-7.1.27/ext/interbase/
						/opt/cpanel/ea-php71/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php71/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php71/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php71/root/etc/php.d/interbase.ini 
					;;
					72)
						wget -O php72.tar.gz $PHP72
						tar -xvzf php72.tar.gz && cd php-7.2.16/ext/interbase/
						/opt/cpanel/ea-php72/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php72/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php72/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php72/root/etc/php.d/interbase.ini 
					;;
					73)
						wget -O php73.tar.gz $PHP73
						tar -xvzf php73.tar.gz && cd php-7.3.3/ext/interbase/
						/opt/cpanel/ea-php73/root/usr/bin/phpize && ./configure --with-interbase=/etc/firebird --with-php-config=/opt/cpanel/ea-php73/root/usr/bin/php-config
						make && cp modules/interbase.so /opt/cpanel/ea-php73/root/usr/lib64/php/modules/
						echo "extension=interbase.so" >  /opt/cpanel/ea-php73/root/etc/php.d/interbase.ini 
					;;
				esac
			done

else
	echo "$VERMELHO Você deve executar este script em um servidor dedicado ou em uma VPS, nunca em um ambiente compartilhado! $RESETCOR"
	exit
fi
