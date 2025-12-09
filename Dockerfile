FROM thecodingmachine/php:8.2-v4-apache-node16

ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV PHP_INI_MEMORY_LIMIT=512M
ENV PHP_INI_MAX_EXECUTION_TIME=600
ENV PHP_INI_MAX_INPUT_TIME=600
ENV PHP_INI_POST_MAX_SIZE=100M
ENV PHP_INI_UPLOAD_MAX_FILESIZE=100M
ENV PHP_EXTENSIONS="pdo_mysql gd intl mbstring bcmath zip curl dom opcache exif fileinfo soap"
ENV COMPOSER_ALLOW_SUPERUSER=1

USER root

COPY --chown=docker:docker . /var/www/html

WORKDIR /var/www/html

# Create required directories
RUN mkdir -p userfiles/modules userfiles/templates storage/framework/cache storage/framework/sessions storage/framework/views storage/logs config bootstrap/cache \
    && chown -R docker:docker userfiles storage config bootstrap/cache \
    && chmod -R 775 userfiles storage config bootstrap/cache

USER docker

# Install composer dependencies
RUN composer install --no-interaction --prefer-dist --no-scripts

# Generate autoload and run post-install
RUN composer dump-autoload

# Copy .env.example to .env if .env doesn't exist and generate key
RUN if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "APP_KEY=" > .env; fi

# Generate application key
RUN php artisan key:generate --force || true

# Clear and cache config
RUN php artisan config:clear || true
RUN php artisan cache:clear || true
