FROM alpine:3.20.6
RUN apk update && apk add --no-cache \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-curl \
	php83-dom \
	php83-mbstring \
	php83-openssl \
	php83-xml \
	php83-phar \
	php83-session \
	php83-gd \
	mariadb-client \
	wget \
	bash \
	ca-certificates
RUN mkdir -p /var/www/html && \
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh
WORKDIR /var/www/html
RUN echo "memory_limit = 512M" > /etc/php83/conf.d/99-custom.ini
RUN echo "upload_max_filesize = 512M" >> /etc/php83/conf.d/99-custom.ini
RUN echo "post_max_size = 512M" >> /etc/php83/conf.d/99-custom.ini
RUN echo "max_execution_time = 300" >> /etc/php83/conf.d/99-custom.ini
RUN echo "max_input_time = 300" >> /etc/php83/conf.d/99-custom.ini
EXPOSE 9000
ENTRYPOINT [ "/usr/local/bin/wordpress-entrypoint.sh" ]
CMD ["/usr/sbin/php-fpm83", "-F"]
