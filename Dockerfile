FROM php:5.6-apache

# Install and enable PHP extensions
# https://wiki.invoiceplane.com/en/1.0/getting-started/requirements
RUN \
  apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    librecode-dev \
    libxml2-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd mcrypt mysqli recode xmlrpc

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer

# Copy InvoicePlane into public directory
COPY . /var/www/html

# Install deps using composer
RUN cd /var/www/html && COMPOSER_ALLOW_SUPERUSER=1 composer install

# Enable .htaccess, set permissions, and enable Apache mod_rewrite
RUN mv /var/www/html/htaccess /var/www/html/.htaccess \
  && chown -R www-data:www-data /var/www/html \
  && a2enmod rewrite
