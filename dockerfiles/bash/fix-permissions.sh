#!/bin/sh
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/log
exec "$@"
