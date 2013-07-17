#!/bin/bash
function check_root() {
	if [ $(id -u) -ne 0 ]
	then
	    echo "Y U NO root???" 2>&1
	    exit 1
	fi
}
check_root

# remove apache2
apt-get autoremove --purge apache2*

#backports
cat > /etc/apt/sources.list.d/backports.sources.list <<END
deb http://ftp.ro.debian.org/debian/ wheezy-backports main contrib non-free
END

#nignx
cat > /etc/apt/sources.list.d/nginx.sources.list <<END
deb http://nginx.org/packages/debian/ wheezy nginx
deb-src http://nginx.org/packages/debian/ wheezy nginx
END
wget -q http://nginx.org/keys/nginx_signing.key -O - | apt-key add -

#percona
cat > /etc/apt/sources.list.d/percona.sources.list <<END
deb http://repo.percona.com/apt wheezy main
deb-src http://repo.percona.com/apt wheezy main
END
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

#update and remove apache
apt-get update && apt-get dist-upgrade
~
#install nginx and others

apt-get install nginx percona-server-server-5.5 percona-server-client-5.5

# optional
# apt-get install memcached


# php shits
apt-get install php5 php5-cli php5-common php5-curl php5-dev php5-gd php5-curl libcurl4-openssl-dev php5-mcrypt php5-fpm build-essential php5-memcached

service mysql start
service nginx start
service php5-fpm start
