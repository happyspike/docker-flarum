FROM php:5-apache
RUN apt-get update
RUN bash -c 'debconf-set-selections <<< "mariadb-server mysql-server/root_password password rootpass" '
RUN bash -c 'debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password rootpass" '
RUN apt-get install -y mariadb-server mariadb-client libpng-dev zip git
RUN docker-php-ext-install mbstring pdo_mysql gd

WORKDIR /var/www
RUN php -r "readfile('https://getcomposer.org/installer');" | php
RUN mkdir flarum; cd flarum; php ../composer.phar create-project flarum/flarum . --no-interaction --stability=beta --prefer-source
ADD flarum.conf /etc/apache2/sites-enabled/
RUN chown -R www-data:www-data flarum
RUN service mysql start; mysql --password=rootpass -e 'create database flarum;'

#extensions
RUN cd flarum; php ../composer.phar require vingle/flarum-configure-smtp

EXPOSE 80
CMD service mysql start; apache2-foreground
