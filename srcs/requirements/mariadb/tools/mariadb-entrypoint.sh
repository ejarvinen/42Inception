#!/bin/bash
set -e
echo "Running mariadb entrypoint script..."

ls -la /var/lib/mysql

# configure server to be reachable by other containers on the first run
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Installing mysql..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	mysqld --user=mysql --bootstrap <<- EOF
	FLUSH PRIVILEGES;
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
	CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
	FLUSH PRIVILEGES;
	EOF
fi

echo "Running mysql user..."
exec mysqld --user=mysql
