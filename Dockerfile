FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade
RUN apt-get install -yq mysql-server
RUN mkdir -p /var/run/mysqld

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN ln -sf /dev/stdout /var/log/mysqld.err
RUN { \
        echo "[mysqld]"; \
        echo "bind-address=0.0.0.0"; \
    } > /etc/mysql/conf.d/conf_01.cnf

RUN { \
        echo "UPDATE mysql.user SET authentication_string = PASSWORD('123456') WHERE User='root';"; \
        echo "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';"; \
        echo "DELETE FROM mysql.user WHERE User='';"; \
        echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"; \
        echo "FLUSH PRIVILEGES;"; \
        } > /mysql-first-time
        
RUN chmod a+rx /mysql-first-time

RUN { \
        echo "#!/usr/bin/env bash"; \
        echo "set -e"; \
        echo "if [ -f /mysql-first-time ]; then"; \
        echo "./mysql-first-time"; \
        echo "rm /mysql-first-time"; \
        echo "fi"; \
        echo "rm -f /run/mysqld/mysqld.pid"; \
        echo "/usr/bin/mysqld_safe"; \
        echo "tail -f /dev/stdout"; \
    } > /usr/local/bin/entrypoint
    
RUN chmod a+rx /usr/local/bin/entrypoint
RUN apt-get -yq clean autoclean && apt-get -yq autoremove
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
