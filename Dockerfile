# This is a convenience container for local workstation development
#
# This is a Docker Anti-Pattern.  I am putting all the services into
# one container and I am doing it knowing that this is NOT the way
# you should do it.   That's just how I roll...
#
# Breaking the law, breaking the law ...
#
# This is intended for development but also allows less experienced
# system operators to deploy to system like QNAP NAS server as one
# container, without having to understand how to connect and
# maintain separate services.
#
FROM php:7.1-apache
MAINTAINER James Stormes <jstormes@stormes.net>

# Add Tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

# Add custom init script
ADD bash_scripts/init.sh /etc/init.sh

RUN docker-php-ext-install pdo pdo_mysql mysqli \
    && a2enmod rewrite ssl \
    && apt-get update \
    && { \
       		echo "mariadb-server" mysql-server/root_password password 'naked'; \
       		echo "mariadb-server" mysql-server/root_password_again password 'naked'; \
       	} | debconf-set-selections \
    && apt-get install -y cron mariadb-server \
    && chmod +x /tini \
    && chmod +x /etc/init.sh

WORKDIR /var/www
EXPOSE 443 80 3306

# Run your init under Tini
ENTRYPOINT ["/tini", "/etc/init.sh"]
