FROM php:7.0-apache
MAINTAINER Fork CMS <info@fork-cms.com>

# Install MCrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt

# Install Intl
RUN apt-get update \
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl

# Install PHP extensions: GD, mbstring, mysql, pdo, zip
RUN apt-get update && apt-get install -y unzip libpng12-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring mysqli pdo pdo_mysql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Configure Apache Document Root
ENV APACHE_DOC_ROOT /var/www/html

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Bundle source code
COPY . /var/www/html/

# Install app dependencies
RUN cd /var/www/html && /usr/local/bin/composer install --optimize-autoloader --prefer-dist --no-dev --no-interaction --no-scripts

# Give apache write access to host
RUN chown -R www-data:www-data /var/www/html/

EXPOSE 80
EXPOSE 443
