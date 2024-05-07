#!/usr/bin/env bash
echo Installing Composer packages...
# Use --no-scripts so that we simply download and install packages, then at a later point we will run the scripts to fully install Pimcore
cd /var/www/html && runuser -u www-data -- php -d memory_limit=-1 -d xdebug.remote_enable=0 /usr/local/bin/composer install --prefer-dist --no-scripts