FROM mysql:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -yq upgrade \
    echo "[mysql]" > /etc/mysql/conf.d/disable_binary_log.cnf \
    echo "disable_log_bin" >> /etc/mysql/conf.d/disable_binary_log.cnf

EXPOSE 3306 33060

CMD ["--default-authentication-plugin=mysql_native_password"]
