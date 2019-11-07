#!/bin/bash

BLUE='\033[04;01;34m'
YELLOW='\033[33m'
NC='\e[0m'
DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true

echo -e "\n ${BLUE} ## APT-GET UPDATE  ${NC} \n"
apt-get update -qq

echo -e "\n ${BLUE} Instalação do postgresql ${NC}"
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update -qq
apt install -qq postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 libpq-dev -y

echo -e "\n ${BLUE} Ajustes banco de dados ${NC}"
su -l postgres -c 'psql -U postgres -f /tmp/config/init.sql'

echo -e "\n ${BLUE} Liberar conexão remota ao postgresql ${NC}"
echo 'host all all all trust' >> /etc/postgresql/9.4/main/pg_hba.conf
echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf

echo -e "\n ${BLUE} ## Instalação dos pacotes ${NC} \n"
apt install -y --no-install-recommends \
        locales apt-utils procps \
        build-essential python-dev python-setuptools git python-pip \
        libsasl2-dev libpq-dev libjpeg-dev libfreetype6-dev \
        libxslt1-dev libpq-dev libldap2-dev libmagic-dev libxml2-dev \
        zlib1g-dev freetds-dev libxmlsec1-dev \
        postgresql-client-common postgresql-client ipython3

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

pip install --upgrade pip

echo -e '-> Reiniciando o Postgres'
systemctl restart postgresql.service

echo -e '\n\n ## Terminado o provisionamento ## \n\n'
