FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
        && apt-get install -yq mysql-server \
        && mkdir -p /var/run/mysqld \
        && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && { \
                echo "[mysqld]"; \
                echo "bind-address=0.0.0.0"; \
        } > /etc/mysql/conf.d/conf_01.cnf \
        && { \
                echo "UPDATE mysql.user SET authentication_string = PASSWORD('${MYSQL_PASSWORD}') WHERE User='root';"; \
                echo "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';"; \
                echo "DELETE FROM mysql.user WHERE User='';"; \
                echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"; \
                echo "FLUSH PRIVILEGES;"; \
        } > /mysql-first-time \
        && chmod a+rx /mysql-first-time \
        && { \
                echo "#!/usr/bin/env bash"; \
                echo "set -e"; \
                echo "if [ -n \"$MYSQL_PASSWORD\" ]; then"; \
                echo "set -- \"$@\" --init-file=/mysql-first-time"; \
                echo "else"; \
                echo "if [ -f /mysql-first-time ]; then"; \
                echo "rm /mysql-first-time"; \
                echo "fi"; \
                echo "fi"; \
                echo "rm -f /run/mysqld/mysqld.pid"; \
                echo "exec /usr/bin/mysqld_safe \"\$@\""; \
        } > /usr/local/bin/entrypoint \
        && chmod a+rx /usr/local/bin/entrypoint \
        && apt-get -yq clean autoclean && apt-get -yq autoremove \
        && rm -rf /var/lib/apt/lists/*

EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
