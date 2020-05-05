FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade
RUN apt-get install -yq mysql-server
RUN mysql_secure_installation --use-default --password=123456
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 
RUN ln -sf /dev/stdout /var/log/mysqld.err 
RUN { \
        echo "[mysqld]"; \
        echo "bind-address=0.0.0.0"; \
        echo "socket=/var/lib/mysql/mysql.sock"; \
    } > /etc/mysql/conf.d/bind_0.0.0.0.cnf
RUN { \
        echo "#!/usr/bin/env bash"; \
        echo "set -e"; \
        echo "rm -f /run/mysqld/mysqld.pid"; \
        echo "/usr/bin/mysqld_safe"; \
        echo "tail -f /empty.log"; \
    } > /usr/local/bin/entrypoint
RUN echo "" > /empty.log 
RUN chmod a+rx /usr/local/bin/entrypoint 
RUN apt-get -yq clean autoclean && apt-get -yq autoremove 
RUN rm -rf /var/lib/apt/lists/*
  
EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
