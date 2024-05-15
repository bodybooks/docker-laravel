FROM php:8.2-fpm

RUN mkdir -p /var/www/web

WORKDIR /var/www/web

# RUN sed -i "s/user = www-data/user = www/g" /usr/local/etc/php-fpm.d/www.conf
# RUN sed -i "s/group = www-data/group = www/g" /usr/local/etc/php-fpm.d/www.conf
# RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

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

# mysql 扩展
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli

# redis 扩展 
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/refs/tags/6.0.2.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# gd 扩展
RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

# zip 扩展
RUN apt update && apt install -y --no-install-recommends libzip-dev && rm -r /var/lib/apt/lists/* && docker-php-ext-install -j$(nproc) zip

# opcache 扩展 
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
