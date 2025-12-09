FROM thecodingmachine/php:8.2-v4-apache-node16

ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV PHP_INI_MEMORY_LIMIT=1G
ENV PHP_INI_MAX_EXECUTION_TIME=600
ENV PHP_INI_MAX_INPUT_TIME=600
ENV PHP_INI_POST_MAX_SIZE=100M
ENV PHP_INI_UPLOAD_MAX_FILESIZE=100M
ENV PHP_INI_OUTPUT_BUFFERING=4096
ENV PHP_INI_OPCACHE__ENABLE=1
ENV PHP_INI_OPCACHE__MEMORY_CONSUMPTION=256
ENV PHP_INI_OPCACHE__INTERNED_STRINGS_BUFFER=16
ENV PHP_INI_OPCACHE__MAX_ACCELERATED_FILES=10000
ENV PHP_INI_OPCACHE__VALIDATE_TIMESTAMPS=0
ENV APACHE_RUN_USER=docker
ENV APACHE_RUN_GROUP=docker
ENV PHP_EXTENSIONS="pdo_mysql gd intl mbstring bcmath zip curl dom opcache exif fileinfo soap"
ENV COMPOSER_ALLOW_SUPERUSER=1

USER root

COPY --chown=docker:docker . /var/www/html

WORKDIR /var/www/html

# Create required directories
RUN mkdir -p userfiles/modules userfiles/templates storage/framework/cache storage/framework/sessions storage/framework/views storage/logs config bootstrap/cache \
    && chown -R docker:docker userfiles storage config bootstrap/cache \
    && chmod -R 775 userfiles storage config bootstrap/cache

# Make startup script executable
RUN chmod +x /var/www/html/docker-entrypoint-mw.sh

USER docker

# Install composer dependencies
RUN composer install --no-interaction --prefer-dist --no-scripts

# Generate autoload
RUN composer dump-autoload

# Use thecodingmachine startup command mechanism
ENV STARTUP_COMMAND_1="bash /var/www/html/docker-entrypoint-mw.sh"
