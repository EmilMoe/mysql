FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
        && echo mariadb-server mysql-server/root_password password secret | debconf-set-selections \
        && echo mariadb-server mysql-server/root_password_again password secret | debconf-set-selections \
        && apt-get install -yq mariadb-server software-properties-common \
        && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && sed -i -e 's/bind-address/# bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf \
        && /etc/init.d/mysql start && mysql -u root -psecret -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;" 
        && { \
                echo "#!/usr/bin/env bash"; \
                echo "set -e"; \
                echo "rm -f /run/mysqld/mysqld.pid"; \
                echo "exec /usr/bin/mysqld_safe \"\$@\""; \
        } > /usr/local/bin/entrypoint \
        && chmod a+rx /usr/local/bin/entrypoint \
        && apt-get -yq clean autoclean && apt-get -yq autoremove \
        && rm -rf /var/lib/apt/lists/*

EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
