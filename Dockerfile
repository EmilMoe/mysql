FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
  && apt-get install -yq mysql-server \
  && mysql_secure_installation --use-default --password=123456 \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && ln -sf /dev/stdout /var/log/mysqld.err \
  && systemctl disable mysql \
  && { \
      echo "#!/usr/bin/env bash"; \
      echo "set -e"; \
      echo "rm -f /run/mysqld/mysqld.pid"; \
      echo "service mysql start"; \
      echo "tail -f /dev/stdout"; \
  } > /usr/local/bin/entrypoint \
  && chmod a+rx /usr/local/bin/entrypoint \
  && apt-get -yq clean autoclean && apt-get -yq autoremove \
  && rm -rf /var/lib/apt/lists/*
  
EXPOSE 3306/tcp

ENTRYPOINT ["entrypoint"]
