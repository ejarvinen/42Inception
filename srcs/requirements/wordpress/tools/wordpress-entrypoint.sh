#!/bin/bash
set -e

# wait for database
until mysql -h $MYSQL_DATABASE -u $MYSQL_USER -p $MYSQL_PASSWORD -e "SELECT 1"; do
	echo "Waiting for MariaDB..."
	sleep 3
done

# wordpress installation
if [ ! -f wp-config.php ]; then
	wp core download --allow-root

	wp config create \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbhost=$MYSQL_DATABASE \
		--allow-root

	wp core install \
		--url=$DOMAIN_NAME \
		--title=$WORDPRESS_TITLE \
		--admin_user=$WORDPRESS_ADMIN_USER \
		--admin_password=$WORDPRESS_ADMIN_PASSWORD \
		--admin_email=$WORDPRESS_ADMIN_EMAIL \
		--allow-root
fi

exec "$@"
