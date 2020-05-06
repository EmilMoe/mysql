FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
        && echo "mariadb-server mysql-server/root_password password $MYSQL_PASSWORD" | debconf-set-selections \
        && echo "mariadb-server mysql-server/root_password_again password $MYSQL_PASSWORD" | debconf-set-selections \
        && apt-get install -yq mariadb-server software-properties-common \
        && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && sed -i -e 's/bind-address/# bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf \
        && { \
                echo "#!/usr/bin/env bash"; \
                echo "set -e"; \
                echo "if [[ -z \"$MYSQL_PASSWORD\" ]]; then"; \
                echo "/etc/init.d/mysql start"; \
                echo "mysql -u root -p${MYSQL_PASSWORD}  -e \"GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;\""; \
                echo "/etc/init.d/mysql stop"; \
                echo "fi"; \
                echo "rm -f /run/mysqld/mysqld.pid"; \
                echo "exec /usr/bin/mysqld_safe \"\$@\""; \
        } > /usr/local/bin/entrypoint \
        && chmod a+rx /usr/local/bin/entrypoint \
        && apt-get -yq clean autoclean && apt-get -yq autoremove \
        && rm -rf /var/lib/apt/lists/*

EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
