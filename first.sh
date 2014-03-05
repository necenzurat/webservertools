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

# backports
cat > /etc/apt/sources.list.d/backports.sources.list <<END
deb http://ftp.ro.debian.org/debian/ wheezy-backports main contrib non-free
END

# nginx
cat > /etc/apt/sources.list.d/nginx.sources.list <<END
deb http://nginx.org/packages/debian/ wheezy nginx
deb-src http://nginx.org/packages/debian/ wheezy nginx
END
wget -q http://nginx.org/keys/nginx_signing.key -O - | apt-key add -

# percona (todo selection)
# cat > /etc/apt/sources.list.d/percona.sources.list <<END
# deb http://repo.percona.com/apt wheezy main
# deb-src http://repo.percona.com/apt wheezy main
# END
# apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

# MariaDB
# cat > /etc/apt/sources.list.d/mariadb.sources.list <<END
# # MariaDB 10.0 repository list - created 2013-07-21 18:25 UTC
# # http://mariadb.org/mariadb/repositories/
# deb http://mariadb.mirror.nucleus.be//repo/10.0/debian wheezy main
# deb-src http://mariadb.mirror.nucleus.be//repo/10.0/debian wheezy main
# END
# apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db


# upgrade the system
apt-get update && apt-get -y dist-upgrade

# install nginx and others

# web server
# database
# dev depdendecies
# php5 SAPI
# php5 extensions

apt-get -y install \
	nginx \
	# percona-server-server percona-server-client \
	# mariadb-client mariadb-server mariadb-client mariadb-server mariadb-server-core mariadb-client-core \
	mysql-server
	build-essential php5-dev libcurl4-openssl-dev \
	php5-fpm php5-cli \
	php5-curl php5-gd php5-mcrypt php5-memcached \


/etc/init.d/mysql start
/etc/init.d/nginx start
/etc/init.d/php5-fpm start
