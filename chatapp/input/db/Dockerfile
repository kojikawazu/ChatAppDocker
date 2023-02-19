FROM mysql:8.0.29

ENV MYSQL_ROOT_PASSWORD=root \
    MYSQL_DATABASE=chat_database \
    MYSQL_USER=admin \
    MYSQL_PASSWORD=root

ADD ./files/*.sql /docker-entrypoint-initdb.d/.
