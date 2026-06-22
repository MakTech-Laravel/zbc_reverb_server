FROM php:8.4-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev \
    libxml2-dev libzip-dev \
    && docker-php-ext-install \
        pdo_mysql mbstring zip pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy only what Reverb needs (your full Laravel backend source)
COPY . .

# Install PHP dependencies (no dev, no scripts)
RUN composer install --no-dev --optimize-autoloader --no-scripts \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 storage bootstrap/cache

# Reverb listens on 8080
EXPOSE 8080

# Start Reverb WebSocket server
CMD ["php", "artisan", "reverb:start", "--host=0.0.0.0", "--port=8080", "--no-interaction"]