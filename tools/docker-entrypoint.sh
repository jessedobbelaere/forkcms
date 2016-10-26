#!/bin/sh

# Chown the directories used by Apache to have the correct permissions
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data ./data

# Run apache server
apache2-foreground
