FROM php:7.0-apache
MAINTAINER Fork CMS <info@fork-cms.com>

# Install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libmcrypt-dev libicu-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache mcrypt intl mbstring pdo pdo_mysql zip

# Set recommended PHP.ini settings
# See https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache Document Root
ENV APACHE_DOC_ROOT /var/www/html

# Bundle source code
COPY . /var/www/html/

# Install composer and install the app dependencies
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN cd /var/www/html && /usr/local/bin/composer install --optimize-autoloader --prefer-dist --no-dev --no-interaction --no-scripts

# Give apache write access to host
RUN chown -R www-data:www-data /var/www/html/
