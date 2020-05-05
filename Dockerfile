FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
    && apt-get install -yq mysql-server \
    && mysql_secure_installation --use-default --password=123456 \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && ln -sf /dev/stdout /var/log/mysqld.err \
    && { \
        echo "[mysqld]"; \
        echo "bind-address=0.0.0.0"; \
    && } > /etc/mysql/conf.d/bind_0.0.0.0.cnf \
    && { \
        echo "#!/usr/bin/env bash"; \
        echo "set -e"; \
        echo "rm -f /run/mysqld/mysqld.pid"; \
        echo "/usr/bin/mysqld_safe"; \
        echo "tail -f /empty.log"; \
    } > /usr/local/bin/entrypoint \
    && echo "" > /empty.log \
    && chmod a+rx /usr/local/bin/entrypoint \
    && apt-get -yq clean autoclean && apt-get -yq autoremove \
    && rm -rf /var/lib/apt/lists/*
  
EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
