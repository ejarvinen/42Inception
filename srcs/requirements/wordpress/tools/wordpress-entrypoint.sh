#!/bin/bash
set -e

MAX_TRIES=30
TRIES=0

while ! mysqladmin ping -h mariadb --silent; do
	TRIES=$((TRIES + 1))
	echo "Waiting for MariaDB ($TRIES/$MAX_TRIES)..."

	if [ "$TRIES" -ge "$MAX_TRIES" ]; then
		echo "MariaDB is not responding. Exiting."
		exit 1
	fi

	sleep 3
done
echo "MariaDB is ready!" 

# wordpress installation
if [ ! -f wp-config.php ] || [ ! -d wp-admin ]; then

	echo "Installing wordpress..."
	wp core download --allow-root

	wp config create \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbhost=mariadb \
		--allow-root

	wp core install \
		--url=$DOMAIN_NAME \
		--title=$WORDPRESS_TITLE \
		--admin_user=$WORDPRESS_ADMIN_USER \
		--admin_password=$WORDPRESS_ADMIN_PASSWORD \
		--admin_email=$WORDPRESS_ADMIN_EMAIL \
		--allow-root \
		--skip-email

    echo "WordPress setup complete!"
fi

#configure and optimize MySQL handling

echo "Updadting wp-config.php..."

if ! grep -q "WP_MEMORY_LIMIT" wp-config.php; then
	cat <<EOF >> wp-config.php
define('FS_METHOD', 'direct');
define('WP_ALLOW_REPAIR', true);
define('WP_MEMORY_LIMIT', '512M');
define('WP_MAX_MEMORY_LIMIT', '512M');
define('DB_HOST', 'mariadb:3306');
EOF
fi

chown -R nobody:nobody /var/www/html

echo "Finished configuration"
exec "$@"
