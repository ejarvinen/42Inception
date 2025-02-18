#!/bin/bash
set -e

# check if DOMAIN_NAME is set
if [ -z "$DOMAIN_NAME" ]; then
	echo "DOMAIN_NAME is not set!"
	exit 1
fi

# define paths
CERT_DIR="/etc/nginx/ssl"
CERT_FILE="$CERT_DIR/emansoor.crt"
KEY_FILE="$CERT_DIR/emansoor.key"
NGINX_CONF="/etc/nginx/http.d/default.conf"

# create SSL certificate
openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
  -out "$CERT_FILE" \
  -keyout "$KEY_FILE" \
  -subj "/CN=$DOMAIN_NAME" \
  >/dev/null 2>&1

# nginx configuration
NGINX_CONFIG="
server {
  listen 443 ssl;
  http2 on;
  listen [::]:443 ssl;
  server_name $DOMAIN_NAME;

  ssl_certificate $CERT_FILE;
  ssl_certificate_key $KEY_FILE;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

  root /var/www/html;
  index index.php index.html index.htm;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ [^/]\.php(/|\$) {
    try_files \$fastcgi_script_name =404;
    fastcgi_pass wordpress:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_param PATH_INFO \$fastcgi_path_info;
    fastcgi_split_path_info ^(.+\.php)(/.*)\$;
    include fastcgi_params;
  }
}
"

# append or replace Nginx config
echo "$NGINX_CONFIG" > "$NGINX_CONF"

# start Nginx in the foreground
exec nginx -g 'daemon off;'
