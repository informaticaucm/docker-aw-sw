# School of Computer Engineering at Complutense University
#
# LAMP stack for student projects
#
# Forked from tutum/lamp and adapted to the needs of the School
# Original credits: Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Usage info
#  - use 'docker run ... -e MYSQL_PASS=X" to set MySQL admin password (or will be randomly generated)
#  - use 'docker run ... -e SSH_PASS=X" to set SSH root password (or will default to "root:default")

FROM ubuntu:14.04
MAINTAINER Pablo Moreno Ger / Iván Martínez Ortiz <pablom@ucm.es / imartinez@ucm.es >

ENV DEBIAN_FRONTEND noninteractive
ENV SSH_PASS default


# Allow running MySQL during image building
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Install basic packages
RUN apt-get update && \
    apt-get -y install supervisor apache2 libapache2-mod-php5 mysql-server php5-mysqlnd pwgen php-apc php5-mcrypt openssh-server phpmyadmin && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
  apt-get clean


# Add supervisor configuration scripts
ADD supervisor/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisor/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisor/supervisord-sshd.conf /etc/supervisor/conf.d/supervisord-sshd.conf
ADD supervisor/start-apache2.sh /start-apache2.sh
ADD supervisor/start-mysqld.sh /start-mysqld.sh
ADD supervisor/start-sshd.sh /start-sshd.sh


# Add stack configuration scripts
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD configure_mysql.sh /configure_mysql.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh


# Prepare MySQL
RUN rm -rf /var/lib/mysql/*

# Prepare Apache
ADD apache/apache_default /etc/apache2/sites-available/000-default.conf
ADD apache/index.html /var/www/html
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
RUN a2enmod rewrite


# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]


ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 80 22
CMD ["/run.sh", "-D"]










