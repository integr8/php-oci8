
ARG PHP_VERSION="7.2"

FROM php:${PHP_VERSION}-apache
LABEL maintainer="Fábio Luciano <fabio@naoimporta.com>"

ARG INSTANTCLIENT_VERSION="19.3.0.0.0"
ENV LD_LIBRARY_PATH /opt/oracle/instantclient

RUN apt-get update && apt-get install -qqy git unzip libaio1 \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && mkdir /opt/oracle && STRIPED_INSTANTCLIENT_VERSION=`echo "${INSTANTCLIENT_VERSION}" | sed -e 's/\.//g'` \
  && curl -OLJs https://download.oracle.com/otn_software/linux/instantclient/${STRIPED_INSTANTCLIENT_VERSION}/instantclient-basic-linux.x64-${INSTANTCLIENT_VERSION}dbru.zip \
  && curl -OLJs https://download.oracle.com/otn_software/linux/instantclient/${STRIPED_INSTANTCLIENT_VERSION}/instantclient-sdk-linux.x64-${INSTANTCLIENT_VERSION}dbru.zip && find . -type f -exec unzip '{}' -d /opt/oracle \; \
  && mv /opt/oracle/instantclient* /opt/oracle/instantclient \
  && echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8 && docker-php-ext-enable oci8 \
  && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient,${INSTANTCLIENT_VERSION} \
  && docker-php-ext-install pdo_oci && rm ./*.zip && rm /etc/apache2/sites-*/*.conf \
  && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && a2enmod rewrite

COPY default.conf /etc/apache2/sites-enabled/