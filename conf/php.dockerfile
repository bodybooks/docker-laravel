FROM php:8.2-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/web

WORKDIR /var/www/web

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system www
RUN adduser -G www --system -D -s /bin/sh -u ${UID} www

RUN sed -i "s/user = www-data/user = www/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = www/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# PHP 容器配置

# 官方版本默认安装扩展: 
# Core, ctype, curl
# date, dom
# fileinfo, filter, ftp
# hash
# iconv
# json
# libxml
# mbstring, mysqlnd
# openssl
# pcre, PDO, pdo_sqlite, Phar, posix
# readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard
# tokenizer
# xml, xmlreader, xmlwriter
# zlib

# bcmath, calendar, exif, gettext, sockets, dba, mysqli, pcntl, pdo_mysql, shmop, sysvmsg, sysvsem, sysvshm 扩展
RUN docker-php-ext-install -j$(nproc) bcmath calendar exif gettext \
sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm

# GD 扩展
RUN apt-get update && \
apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
rm -r /var/lib/apt/lists/* && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
docker-php-ext-install -j$(nproc) gd

# soap wddx xmlrpc tidy xsl 扩展
RUN apt-get update && \
apt-get install -y --no-install-recommends libxml2-dev libtidy-dev libxslt1-dev && \
rm -r /var/lib/apt/lists/* && \
docker-php-ext-install -j$(nproc) soap wddx xmlrpc tidy xsl

# zip 扩展
RUN apt-get update && \
apt-get install -y --no-install-recommends libzip-dev && \
rm -r /var/lib/apt/lists/* && \
docker-php-ext-install -j$(nproc) zip

# mcrypt 扩展 
RUN apt-get update && \ 
apt-get install -y --no-install-recommends libmcrypt-dev && \
rm -r /var/lib/apt/lists/* && \
pecl install mcrypt-1.0.1 && \
docker-php-ext-enable mcrypt

# imagick 扩展
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
apt-get update && \
apt-get install -y --no-install-recommends libmagickwand-dev && \
rm -rf /var/lib/apt/lists/* && \
pecl install imagick-3.4.3 && \
docker-php-ext-enable imagick

# opcache 扩展 
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

# redis 扩展 
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/refs/tags/6.0.2.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis
    
USER www

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
