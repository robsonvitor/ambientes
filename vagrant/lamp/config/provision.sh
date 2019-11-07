#!/bin/bash

BLUE='\033[04;01;34m'
YELLOW='\033[33m'
NC='\e[0m'
DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true

echo -e "\n ${BLUE} ## APT-GET UPDATE  ${NC} \n"
apt-get update -qq

echo -e "\n ${BLUE} ## Configurações do MySQL e PHPMyAdmin \n"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

echo -e "\n ${BLUE} ## Instalação dos pacotes ${NC} \n"
apt-get install -yqq apache2 apache2-utils php5 php5-cli php5-ldap \
                     php5-mcrypt php5-mysql phpmyadmin php-tcpdf \
                     mysql-server-5.5 mysql-client-5.5 vim bash-completion

echo -e "\n ${BLUE} ## Permitindo conexão remota ao MySQL ${NC} \n"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
mysql -uroot -proot -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root' with GRANT OPTION; FLUSH PRIVILEGES;"

echo -e "\n ${BLUE} ## Configuração de locales ${NC}"
echo 'pt_BR.UTF-8 UTF-8' > /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo 'America/Sao_Paulo' > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo -e "\n ${BLUE} ## habilitando bash_completion ${NC} \n"
cat <<EOF >> /etc/bash.bashrc
# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF

echo -e "\n ${BLUE} ## Configurações Apache e PHP ${NC} \n"

echo -e '-> Criando VirtualHost'
rm -rf /etc/apache2/sites-enabled/*

# VH_APP='app'
# VH_HOST_URL='app.dev'
# VH_EMAIL_ADMIN='robsonvitorm@gmail.com'
# VH_DOCUMENT_ROOT='/var/www/html/app'
#
# touch /etc/apache2/sites-enabled/${VH_APP}.conf
# cat <<EOF > /etc/apache2/sites-enabled/${VH_APP}.conf
# <VirtualHost *:80>
# 	ServerName ${VH_HOST_URL}
# 	ServerAlias ${VH_HOST_URL}
# 	ServerAdmin ${VH_EMAIL_ADMIN}
# 	DocumentRoot ${VH_DOCUMENT_ROOT}
# 	ErrorLog \${APACHE_LOG_DIR}/error.log
# 	CustomLog \${APACHE_LOG_DIR}/access.log combined
# </VirtualHost>
# EOF

echo -e '-> Apache override'
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e '-> upload_max_filesize do php.ini'
sed -i "s/upload_max_filesize = 8M/upload_max_filesize = 100M/g" /etc/php5/apache2/php.ini

echo -e '-> post_max_size do php.ini'
sed -i "s/post_max_size = 8M/post_max_size = 100M/g" /etc/php5/apache2/php.ini

echo -e '-> habilitando módulo rewrite do apache'
a2enmod rewrite

echo -e '-> Reiniciando o apache'
systemctl restart apache2.service

echo -e '-> Reiniciando o MySQL'
systemctl restart mysql.service

echo -e '\n\n ## Terminado o provisionamento ## \n\n'
