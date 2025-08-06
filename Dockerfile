# ----------------------------
# Etapa 1: Composer + Node build
# ----------------------------
FROM php:8.2-fpm-alpine AS build

# Instala dependencias del sistema
RUN apk add --no-cache \
    bash \
    git \
    curl \
    libpng \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    icu-dev \
    nodejs \
    npm

# Instala extensiones de PHP necesarias para Laravel
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath xml intl

# Instala Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Define directorio de trabajo
WORKDIR /var/www

# Copia todos los archivos
COPY . .

# Instala dependencias PHP y Node
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# Cacha configuración
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# ----------------------------
# Etapa 2: Imagen final
# ----------------------------
FROM php:8.2-fpm-alpine

# Instala dependencias del sistema
RUN apk add --no-cache \
    bash \
    libpng \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    icu-dev \
    mysql-client

# Instala extensiones PHP
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath xml intl

# Define directorio de trabajo
WORKDIR /var/www

# Copia el código ya compilado desde la etapa anterior
COPY --from=build /var/www /var/www

# Puerto por defecto para FPM (no expuesto en Railway)
EXPOSE 9000

# Comando por defecto
CMD ["php-fpm"]
