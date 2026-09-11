# syntax=docker/dockerfile:1
#
# JPBook application image: FrankenPHP (PHP 8.3) + Laravel Octane + Node (for Vite).
# A single image is reused for the web (Octane) and queue (Horizon) services.

FROM dunglas/frankenphp:1-php8.3-bookworm AS base

LABEL org.opencontainers.image.title="jpbook-app"

# --- System packages & PHP extensions ----------------------------------------
# install-php-extensions ships with the dunglas/frankenphp image.
RUN install-php-extensions \
        pdo_pgsql \
        pgsql \
        intl \
        zip \
        gd \
        bcmath \
        opcache \
        pcntl \
        redis \
    && apt-get update \
    && apt-get install -y --no-install-recommends git unzip libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Composer (copied from the official image).
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Node 22 + npm (copied from the official node image) for building front-end assets.
COPY --from=node:22-bookworm-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:22-bookworm-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# PHP configuration tuned for Octane (opcache + JIT).
COPY docker/php/php.ini /usr/local/etc/php/conf.d/zz-jpbook.ini

# FrankenPHP needs the CAP_NET_BIND_SERVICE capability dropped for non-root ports;
# we run Octane on :8000 so the default www-data user is sufficient.
WORKDIR /app

# In development the source is bind-mounted over /app (see docker-compose.yml),
# so we do not COPY the application here. For a production build, add:
#   COPY . /app
#   RUN composer install --no-dev --optimize-autoloader && npm ci && npm run build

EXPOSE 8000

# Default command is overridden per-service in docker-compose.yml.
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000"]
