FROM thecodingmachine/php:8.2-v4-apache-node16

ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV PHP_INI_MEMORY_LIMIT=512M
ENV PHP_INI_MAX_EXECUTION_TIME=600
ENV PHP_INI_MAX_INPUT_TIME=600
ENV PHP_INI_POST_MAX_SIZE=100M
ENV PHP_INI_UPLOAD_MAX_FILESIZE=100M
ENV PHP_EXTENSIONS="pdo_mysql gd intl mbstring bcmath zip curl dom opcache exif fileinfo soap"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY . /var/www/html

WORKDIR /var/www/html

RUN composer install --no-interaction --prefer-dist

RUN chown -R www-data:www-data /var/www/html
