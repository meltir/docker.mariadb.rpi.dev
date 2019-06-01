FROM alpine

ENV DB_DATA_PATH="/var/lib/mysql" \
	DB_ROOT_PASS="qwerty" \
    DB_USER="mariadb" \
    DB_PASS="qwerty" \
    DB_NAME="docker" \
	MAX_ALLOWED_PACKET="200M"

COPY entrypoint.sh /

VOLUME /var/lib/mysql


RUN apk update \
	&& apk add --no-cache mariadb mariadb-client \
	&& chmod 755 /entrypoint.sh 

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]