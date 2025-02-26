#!/bin/bash
set -e

# increase php memory limit
echo "memory_limit = 512M" > /etc/php83/conf.d/99-custom.ini
echo "upload_max_filesize = 512M" > /etc/php83/conf.d/99-custom.ini
echo "post_max_size = 512M" > /etc/php83/conf.d/99-custom.ini

# wait for database
until mysqladmin ping -h mariadb --silent; do
	echo "Waiting for MariaDB..."
	sleep 3
done

echo "Connection to mariadb established..."

# wordpress installation
if [ ! -f wp-config.php ]; then

	echo "Installing wordpress..."
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

    echo "WordPress setup complete!"
fi

chown -R nobody:nobody /var/www/html

echo "Finished configuration"
exec "$@"
