#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM ubuntu:18.04

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542

ENV PHPIZE_DEPS \
  apt-utils \
  autoconf \
  dpkg-dev \
  file \
  g++ \
  gcc \
  libc6-dev \
  make \
  pkg-config \
  re2c
RUN apt-get update && apt-get upgrade -y

WORKDIR /usr/local/bin

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install tzdata -y \
  && ln -fs /usr/share/zoneinfo/etc/UTC /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install -y \
  $PHPIZE_DEPS \
  ca-certificates \
  curl \
  xz-utils \
  wget \
  gpg \
  --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2 \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  php7.2 \
  php7.2-curl \
  php7.2-mysql \
  php7.2-xml \
  libapache2-mod-php7.2 \
  php7.2-json \
  php7.2-zip \
  && rm -rf /var/lib/apt/lists/*

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

#Install Phalcon PHP
ENV PHALCON_URL https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh
RUN curl -s $PHALCON_URL | bash

RUN apt-get update && apt-get install php7.2-phalcon \
  && rm -rf /var/lib/apt/lists/*

COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]