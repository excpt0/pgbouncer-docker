#!/bin/bash

set -e

if [ ! -f /etc/pgbouncer/pgbconf.ini ]
then
cat << EOF > /etc/pgbouncer/pgbconf.ini
[databases]
* = host=${DB_HOST} port=${DB_PORT}

[pgbouncer]
logfile = /var/log/postgresql/pgbouncer.log
pidfile = /var/run/postgresql/pgbouncer.pid
listen_addr = ${LISTEN_ADDR:-0.0.0.0}
listen_port = ${LISTEN_PORT:-6432}
unix_socket_dir = /var/run/postgresql
auth_type = any
auth_type = trust
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = session
server_reset_query = DISCARD ALL
max_client_conn = ${MAX_CLIENT_CONN:-10000}
default_pool_size = ${DEFAULT_POOL_SIZE:-400}
ignore_startup_parameters = extra_float_digits
server_idle_timeout = ${SERVER_IDLE_TIMEOUT:-240}
application_name_add_host = ${APPLICATION_NAME_ADD_HOST:-0}
EOF
fi

if [ ! -s /etc/pgbouncer/userlist.txt ]
then
        echo '"'"${DB_USER}"'" "'"${DB_PASS}"'"'  > /etc/pgbouncer/userlist.txt
fi

chown -R postgres:postgres /etc/pgbouncer
chown root:postgres /var/log/postgresql
chmod 1775 /var/log/postgresql
chmod 640 /etc/pgbouncer/userlist.txt

/usr/sbin/pgbouncer -u postgres /etc/pgbouncer/pgbconf.ini
