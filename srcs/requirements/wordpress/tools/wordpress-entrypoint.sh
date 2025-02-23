#!/bin/bash
set -e

# increase php memory limit
echo "memory_limit = 512M" > /etc/php83/conf.d/99-custom.ini

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

	# Install and activate the Twenty Twenty-Four theme
    echo "Installing and activating Twenty Twenty-Four..."
    wp theme install twentytwentyfour --activate --allow-root

    # Install and activate plugins for guest posting
    echo "Installing necessary plugins..."
    wp plugin install user-submitted-posts --activate --allow-root  # Enables guest post submissions
    wp plugin install disable-comments --activate --allow-root  # Ensures proper comment settings
    wp plugin install wp-user-avatar --activate --allow-root  # Allows avatars for guest posts
    wp plugin install classic-editor --activate --allow-root  # Better compatibility with older themes

    # Configure WordPress settings for guest posting
    echo "Configuring WordPress settings..."

    # Allow comments from anyone
    wp option update comment_registration 0 --allow-root
    wp option update comment_moderation 0 --allow-root
    wp option update comment_whitelist 0 --allow-root
    wp option update default_comment_status open --allow-root
    wp option update show_avatars 1 --allow-root

    # Set homepage to latest posts
    wp option update show_on_front posts --allow-root

    # Configure user-submitted posts plugin settings
    wp option update usp_name_required 0 --allow-root  # No need for a name
    wp option update usp_email_required 0 --allow-root  # No need for an email
    wp option update usp_show_author 1 --allow-root  # Show guest author name
    wp option update usp_status pending --allow-root  # Guest posts need approval
    wp option update usp_form_position top --allow-root  # Show form above posts

    echo "WordPress setup complete!"
fi

echo "Finished configuration"
exec "$@"
