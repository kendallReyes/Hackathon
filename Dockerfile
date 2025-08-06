# Etapa de construcción
FROM node:18 AS build

WORKDIR /app

# Copiamos dependencias PHP y Node
COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php && php composer.phar install --no-dev --optimize-autoloader

COPY package.json package-lock.json ./
RUN npm install --production

# Copiamos el resto de la aplicación
COPY . .

# Compilamos assets si es necesario
# RUN npm run build

# Etapa de producción
FROM php:8.2-fpm

# Instalamos extensiones requeridas
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

WORKDIR /var/www/html

# Copiamos desde el build
COPY --from=build /app /var/www/html

# Copiamos el Composer del build
COPY --from=build /app/vendor /var/www/html/vendor

# Configuraciones de Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Entrypoint para comandos extra si los necesitas
CMD ["php-fpm"]
