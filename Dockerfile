FROM php:8.4-cli

RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev \
    libxml2-dev libzip-dev \
    && docker-php-ext-install \
        pdo_mysql mbstring zip pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 8080

# Write .env from Docker environment variables, then start Reverb
CMD sh -c '\
  printenv | grep -E "^(APP_|DB_|CACHE_|REVERB_|LOG_|FRONTEND_)" | \
  sed "s/=\(.*\)/=\1/" > /var/www/.env && \
  php artisan config:clear && \
  php artisan reverb:start --host=0.0.0.0 --port=8080 --no-interaction\
'