#!/bin/sh
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
NGINX_CONF="/etc/nginx/nginx.conf"

# nginx configuration
NGINX_CONFIG="
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
   worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log warn;

  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;

  gzip on;
  gzip_comp_level 6;
  gzip_min_length 256;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

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

    location ~ /\.ht {
          deny all;
    }
  }
}
"

# replace Nginx config
echo "$NGINX_CONFIG" > "$NGINX_CONF"

echo "127.0.0.1 "$DOMAIN_NAME"" >> /etc/hosts

# start Nginx in the foreground
exec nginx -g 'daemon off;'
