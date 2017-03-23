#!/bin/bash

mysqld > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"
echo "=> Your new admin password is $PASS "

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"
echo ""
echo ""
echo "Starting phpmyadmin configuration"



# preseed installation configuration
# - dbconfig-install true -> configure installation with dbconfig_common
# - reconfigure-webserver apache2 -> use apache2 as webserver
# - mysql/admin-pass -> mysql root user password (empty)
# - mysql/app-pass -> password for phpmyadmin to register with the database server (blank is random)
# - app-password-confirm -> confirmation for password for phpmyadmin to register with the database server
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PASS" | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-reinstall boolean true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure phpmyadmin

echo "phpmyadmin configuration completes"
echo ""
echo ""
echo "========================================================================"


mysqladmin -uroot shutdown
