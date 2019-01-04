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
  gpg-agent \
  --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2 \
  && rm -rf /var/lib/apt/lists/*

#Install PHP and apache2-mod
RUN apt-get update && apt-get install -y \
  php7.2 \
  libapache2-mod-php7.2

# Install basic dependencies for PHP
RUN apt-get install -y \
  php7.2-curl \
  php7.2-mysql \
  php7.2-xml \
  php7.2-zip \
  && rm -rf /var/lib/apt/lists/*

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

#Install Phalcon PHP
ENV PHALCON_URL https://packagecloud.io/install/repositories/phalcon/stable/config_file.list?os=ubuntu&dist=bionic&source=script
ENV PHALCON_KEY_URL https://packagecloud.io/phalcon/stable/gpgkey
RUN curl -sSf $PHALCON_URL > /etc/apt/sources.list.d/phalcon_stable.list \
  && curl -L $PHALCON_KEY_URL | apt-key add -

RUN apt-get update && apt-get install php7.2-phalcon --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

#Copy Entrypoint
COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

EXPOSE 80
CMD ["/bin/bash"]