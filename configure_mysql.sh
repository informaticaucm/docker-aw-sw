#!/bin/bash
set -eo pipefail
shopt -s nullglob

# see: https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh
# Fetch value from server config
# We use mysqld --verbose --help instead of my_print_defaults because the
# latter only show values present in config files, and not server defaults
_get_config() {
  local conf="$1"; shift
  mysqld --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null | awk '$1 == "'"$conf"'" { print $2; exit }'
}

SOCKET="$(_get_config 'socket' "$@")"

mysqld --skip-networking --socket="${SOCKET}" > /dev/null 2>&1 &
pid=$!

mysql=( mysql --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" )

for i in {30..0}; do
  if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
    break
  fi
  echo '=> MySQL init process in progress...'
  sleep 1
done
if [ "$i" = 0 ]; then
  echo >&2 '=> MySQL init process failed.'
  exit 1
fi

PASS=${MYSQL_PASS:-$(pwgen -s 20 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"
echo "=> Your new admin password is $PASS "

# Recreate debian user too
DEBIAN_MYSQL_USER_NAME=$(cat /etc/mysql/debian.cnf | sed -n 's/user \+= \+\(.*\)/\1/p' | head -1)
DEBIAN_MYSQL_USER_PASSWORD=$(cat /etc/mysql/debian.cnf | sed -n 's/password \+= \+\(.*\)/\1/p' | head -1)

"${mysql[@]}" <<-EOSQL
CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION ;
-- Recreate debian maintenance mysql user
CREATE USER '$DEBIAN_MYSQL_USER_NAME'@'localhost' IDENTIFIED BY '$DEBIAN_MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$DEBIAN_MYSQL_USER_NAME'@'localhost' WITH GRANT OPTION ;
FLUSH PRIVILEGES ;
EOSQL


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

echo "Done !"
echo ""
echo ""
echo "========================================================================"

if ! kill -s TERM "$pid" || ! wait "$pid"; then
  echo >&2 'MySQL init process failed.'
  exit 1
fi
