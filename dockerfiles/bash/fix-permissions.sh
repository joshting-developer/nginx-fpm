#!/bin/sh

WEB_ROOT="/var/www/html"
EXCLUDE_DIR="volumes"

find "$WEB_ROOT" -path "$WEB_ROOT/$EXCLUDE_DIR" -prune -o -exec chown www-data:www-data {} \;

chown -R www-data:www-data /var/log
exec "$@"
