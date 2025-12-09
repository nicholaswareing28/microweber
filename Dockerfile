FROM php:8.2-apache


RUN apt update && apt install -y --no-install-recommends \
        git \
        zip \
        curl \
        libzip-dev \
        zlib1g-dev \
        unzip \
        libonig-dev \
        graphviz \
        libsodium-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libicu-dev \
        libsqlite3-dev \
        libbz2-dev \
        libpng-dev && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg && \
    docker-php-ext-install gd && \
    { \
        echo 'memory_limit = 512M'; \
        echo 'max_execution_time = 600'; \
        echo 'max_input_time = 600'; \
        echo 'upload_max_filesize = 100M'; \
        echo 'post_max_size = 100M'; \
        echo 'expose_php = Off'; \
    } > /usr/local/etc/php/conf.d/microweber-custom.ini

RUN docker-php-ext-install pdo_mysql pdo_sqlite zip dom curl mbstring intl bcmath sodium opcache soap exif fileinfo sockets xml bz2

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY . /var/www/html

WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --prefer-dist

# Fix ownership for Apache and enable modules
RUN chown -R www-data:www-data /var/www/html && \
    a2enmod rewrite headers expires
