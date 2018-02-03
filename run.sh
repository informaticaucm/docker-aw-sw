#!/bin/bash

#PHP
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/7.2/apache2/php.ini

#SSH server
echo "root:${SSH_PASS}" | chpasswd

#MySQL
VOLUME_HOME="/var/lib/mysql"

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."

    echo 'Initializing database'
    mysqld --initialize-insecure
    echo 'Database initialized'

    echo "=> Done!"  
    /usr/local/bin/configure_mysql.sh
else
    echo "=> Using an existing volume of MySQL"
fi

/usr/local/bin/configure_phpmyadmin.sh

exec supervisord -n -c /etc/supervisor/supervisord.conf
