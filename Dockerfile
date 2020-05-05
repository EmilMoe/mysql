FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Copenhagen

RUN apt-get update && apt-get -yq upgrade
RUN apt-get install -yq mysql-server
RUN { \
        echo "[mysql]"; \
        echo "password=123456"; \
} > passwordfile
RUN mysql_secure_installation --use-default --defaults-file=passwordfile

#RUN echo "[mysql]\npassword=123456" > passwordfile && /bin/sh -c mysql_secure_installation --use-default --defaults-file=passwordfile
#RUN mysql_secure_installation --use-default --password=123456

#RUN { \
#        echo "UPDATE mysql.user SET authentication_string = PASSWORD('123456') WHERE User='root';"; \
#        echo "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';"; \
#        echo "DELETE FROM mysql.user WHERE User='';"; \
#        echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"; \
#        echo "FLUSH PRIVILEGES;"; \
#} > mysql.sql

#RUN mysql --user=root < mysql.sql

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
