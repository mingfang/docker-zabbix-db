FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Nginx
RUN apt-get install -y nginx

#MySQL
#RUN wget -O - "http://pgp.mit.edu/pks/lookup?op=get&search=0x8C718D3B5072E1F5" | apt-key add - && \
#    echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.5" > /etc/apt/sources.list.d/mysql.list && \
#    apt-get update
RUN apt-get install -y mysql-server && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

#PHP-FPM
RUN apt-get install -y php5-fpm php5-mysql
RUN sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php5/fpm/php.ini

#SQL Buddy
RUN mkdir -p /var/www && \
    cd /var/www && \
    wget https://github.com/calvinlough/sqlbuddy/raw/gh-pages/sqlbuddy.zip && \
    unzip sqlbuddy.zip && \
    rm sqlbuddy.zip 

#Adminer
RUN mkdir -p /var/www/adminer && \
    cd /var/www/adminer && \
    wget https://downloads.sourceforge.net/adminer/adminer-4.2.2-mysql-en.php -O index.php

#phpAdmin
RUN mkdir -p /var/www && \
    cd /var/www && \
    wget -O - https://files.phpmyadmin.net/phpMyAdmin/4.5.4.1/phpMyAdmin-4.5.4.1-english.tar.gz | tar zx && \
    mv phpMyAdmin* phpmyadmin

RUN wget -O - http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Release%20Candidates/3.0.0rc1/zabbix-3.0.0rc1.tar.gz | tar zx

#configuration
COPY index.html /var/www/
COPY config.inc.php /var/www/phpmyadmin/
COPY nginx.conf /etc/nginx/

#Add runit services
COPY sv /etc/service 

COPY mysql.ddl /
COPY preparedb.sh /
RUN /preparedb.sh
