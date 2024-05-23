#!/usr/bin/env bash

set -e

if [ ! -d /var/www/html/vendor ];
then
  . /composer-install-dependencies.sh
fi

if [ "$(mysql -h "$DATABASE_HOST" -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" \
      -sse "select count(*) from information_schema.tables where table_schema='pimcore' and table_name='assets';")" -ne 0 ]
then
    # Only run cache clear if the database is seeded. If it is not, trying to clear the cache will cause errors.
    # init.sh will handle seeding it
    runuser -u www-data -- bin/console cache:clear
fi

. /init.sh