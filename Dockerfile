# School of Computer Engineering at Complutense University
#
# LAMP stack for student projects
#
# Forked from tutum/lamp and adapted to the needs of the School
# Original credits: Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Usage info
#  - use 'docker run ... -e MYSQL_PASS=X" to set MySQL admin password (or will be randomly generated)
#  - use 'docker run ... -e SSH_PASS=X" to set SSH root password (or will default to "root:default")

FROM ubuntu:xenial
MAINTAINER Ivan Martinez-Ortiz <imartinez@ucm.es>
ARG USE_APT_CACHE
ENV USE_APT_CACHE ${USE_APT_CACHE}
RUN ([ ! -z $USE_APT_CACHE ] && echo 'Acquire::http { Proxy "http://172.17.0.1:3142"; };' >> /etc/apt/apt.conf.d/01proxy \
    && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy) || true

ENV DEBIAN_FRONTEND noninteractive

# Install SSH server, supervisor and pwgen
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    supervisor \
    pwgen \
    && rm -rf /var/lib/apt/lists/*

# Install MySQL
RUN {\
	echo mysql-server-5.7 mysql-server/root_password password ''; \
	echo mysql-server-5.7 mysql-server/root_password_again password ''; \
    } | debconf-set-selections \
    && apt-get update && apt-get install -y --no-install-recommends \
    mysql-server-5.7 \
    && rm -fr /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld \
    && rm -rf /var/lib/apt/lists/*

# Install Apache2 + PHP + PHPMyAdmin
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 libapache2-mod-php7.0 mysql-server php7.0-mysql php-apcu php7.0-mcrypt phpmyadmin \
        && rm -rf /var/lib/apt/lists/* \
        && echo "ServerName localhost" >> /etc/apache2/apache2.conf

#
# Prepare SSH server
#

ENV SSH_PASS default
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    # SSH login fix. Otherwise user is kicked off after login
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd && chmod 0755 /var/run/sshd

#
# Prepare supervisord
#

# Copy supervisor configuration scripts
COPY supervisor/*.conf /etc/supervisor/conf.d/
COPY supervisor/*.sh /usr/local/bin/

#
# Prepare MySQL
#

ENV MYSQL_PASS default
COPY configure_mysql.sh /usr/local/bin/

RUN sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf

# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf \
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

#RUN /usr/local/bin/configure_mysql.sh

# Add volumes for MySQL 
VOLUME  [ "/var/lib/mysql" ]

#
# Prepare Apache
#

COPY apache/fix-acl.sh /usr/local/bin/
COPY apache/apache_default /etc/apache2/sites-available/000-default.conf
COPY apache/index.html /var/www/html
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
RUN a2enmod rewrite

# Add volumes for Apache2 + PHP
VOLUME  ["/var/www", "/etc/apache2", "/etc/php/" ]

#
# Add stack configuration scripts
#

COPY run.sh /usr/local/bin/

# Fix scripts permisions
RUN chmod 755 /usr/local/bin/*.sh

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 80 22
CMD ["run.sh", "-D"]
