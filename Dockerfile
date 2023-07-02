# Use an official PHP runtime as a parent image
FROM php:8.2.0-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Give Apache access to the mounted /var/www directory
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Change apache2 document root to laravel public directory and add redirect
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo 'RedirectMatch ^/$ /cp' >> /etc/apache2/sites-available/000-default.conf 

# Restart apache to make changes take effect
RUN service apache2 restart

# Expose port 80
EXPOSE 80
