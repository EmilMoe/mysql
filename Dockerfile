FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade \
  && sudo apt-get install -yq mysql-server \
  && mysql_secure_installation --use-default --password=123456 \
  echo "" > /empty.log
  
EXPOSE 3306

ENTRYPOINT /bin/sh /cmd.sh && /etc/init.d/mysql start && tail -f /empty.log
