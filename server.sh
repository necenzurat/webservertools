#!/bin/bash
function check_root() {
	if [ $(id -u) -ne 0 ]
	then
		echo "Y U NO root???" 2>&1
		exit 1
	fi
}
check_root

function do_new_host() {
read -p "Enter the name of the server (example.com)? " servername
echo "generating config file for" $servername;
echo "Generated file /etc/nginx/conf.d/$servername.conf"

cat > /etc/nginx/conf.d/$servername.conf <<END
server {
	# listen for ipv4, Todo: ipv6?
    listen 80; 

    server_name $servername www.$servername;
    
    access_log /home/$servername/logs/access.log;
    error_log /home/$servername/logs/error.log;
    root /home/$servername/public;
    server_tokens off;
    add_header Served-From \$server_addr;

    # Disable .htaccess and other hidden files
    location  /. {
        return 404;
    }

    # uncomment this for index.php to be the router
    try_files \$uri \$uri/ /index.php?q=\$uri&\$args;

    default_type text/html;

    index index.html index.php;
	
	# the php part
    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED \$document_root\$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

	# no favicon.ico in logs
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
 
 	# no robots.txt in logs
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }    
}
END

cat > /etc/logrotate.d/$servername <<END
/home/$servername/logs/*.log {
        daily
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        create 640 nginx adm
        sharedscripts
        postrotate
                [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
        endscript
}
END


# make home dir folder
mkdir /home/$servername
echo "Generated /home/$servername";

# make logs folder
mkdir /home/$servername/logs 
echo "Generated /home/$servername/logs";

# make public folder
mkdir /home/$servername/public
echo "Generated /home/$servername/public";


service nginx restart

}


while true; do
    read -p "Do you wish add a new host? " yn
    case $yn in
        [Yy]* ) do_new_host; break;;
        [Nn]* ) exit;;
        	* ) echo "Please answer yes or no.";;
    esac
done
