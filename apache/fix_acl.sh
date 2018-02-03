#!/bin/bash
find /var/www/html -type d -exec chmod 770 {} \;
find /var/www/html -type f -exec chmod 660 {} \;
chown -R www-data: /var/www/html
