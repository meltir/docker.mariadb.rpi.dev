#!/bin/sh

#set -x


mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ -d $DB_DATA_PATH/mysql ]; then
	echo "[i] MySQL directory already present, skipping creation"
	chown -R mysql:mysql $DB_DATA_PATH
else
	echo "[i] MySQL data directory not found, creating initial DBs"

	chown -R mysql:mysql $DB_DATA_PATH

	mysql_install_db --datadir=$DB_DATA_PATH --user=mysql > /proc/self/fd/1

	
	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$DB_ROOT_PASS' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by '$DB_ROOT_PASS' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
DROP DATABASE test;
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON \`$DB_NAME\`.* to '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
EOF


	/usr/bin/mysqld --datadir=$DB_DATA_PATH --user=mysql --bootstrap < $tfile
#	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
	rm -f $tfile
	
fi
exec /usr/bin/mysqld --datadir=$DB_DATA_PATH --port=3306 --skip-networking=0 --user=mysql --console
