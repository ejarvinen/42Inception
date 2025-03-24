FROM alpine:3.20.6
RUN apk update && apk add --no-cache nginx openssl curl
RUN mkdir -p /etc/nginx/ssl
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
