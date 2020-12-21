# Using base ubuntu image
FROM ubuntu:20.04

LABEL Maintainer="Herlangga Sefani <herlanggasefani@gmail.com>" \
      Description="Nginx + PHP8.0-FPM Based on Ubuntu 20.04."

# Setup document root
RUN mkdir -p /var/www/app


# Base install
RUN apt update --fix-missing
RUN  DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && echo Asia/Jakarta > /etc/timezone
RUN apt install software-properties-common git zip unzip curl gnupg2 ca-certificates lsb-release libicu-dev supervisor nginx -y

# Install php8.0
RUN add-apt-repository ppa:ondrej/php
RUN apt update -y
RUN apt install -y \
      php8.0-fpm \
      php8.0-pdo \
      php8.0-mysql \
      php8.0-zip \
      php8.0-gd \
      php8.0-mbstring \
      php8.0-curl \
      php8.0-xml \
      php8.0-bcmath \
      php8.0-intl

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"
# Check if installation successfull
RUN composer --help

COPY ./entrypoint.sh ./entrypoint.sh

RUN chmod +x ./entrypoint.sh

RUN rm /etc/nginx/sites-enabled/default

COPY ./php/php.ini /etc/php/8.0/fpm/php.ini
COPY ./php/www.conf /etc/php/8.0/fpm/pool.d/www.conf
COPY ./nginx/server.conf /etc/nginx/sites-enabled/default.conf
COPY ./supervisor/config.conf /etc/supervisor/conf.d/supervisord.conf

# Starter file
COPY ./php/index.php /var/www/app/index.php


EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# # Prevent exit
# ENTRYPOINT ["./entrypoint.sh"]