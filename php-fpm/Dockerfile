FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    unzip \
    mariadb-client \
    curl

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) mysqli gd opcache zip

# Configure Opcache for production performance
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Set up WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create a wrapper for mariadb client to bypass SSL enforcement in Alpine
RUN mv /usr/bin/mariadb /usr/bin/mariadb-real \
    && printf '#!/bin/sh\nif [ "$1" = "--no-defaults" ]; then\n    shift\n    exec /usr/bin/mariadb-real --no-defaults --skip-ssl "$@"\nelse\n    exec /usr/bin/mariadb-real --skip-ssl "$@"\nfi\n' > /usr/bin/mariadb \
    && chmod +x /usr/bin/mariadb

WORKDIR /var/www/html
