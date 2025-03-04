FROM alpine:3.20
RUN apk update && apk add --no-cache nginx openssl curl
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/emansoor.key \
	-out /etc/nginx/ssl/emansoor.crt \
	-subj "/CN=${DOMAIN_NAME:-localhost}"
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
