# Etapa 1: Build de dependencias PHP
FROM php:8.2-cli AS build

# Instala extensiones necesarias
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

# Instala Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia los archivos del proyecto
WORKDIR /var/www
COPY . .

# Instala las dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Etapa 2: Producción
FROM php:8.2-apache

# Instala extensiones necesarias también en producción
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Copia el proyecto ya construido desde la etapa anterior
COPY --from=build /var/www /var/www

# Configura Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

WORKDIR /var/www
