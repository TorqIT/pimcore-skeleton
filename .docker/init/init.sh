#!/usr/bin/env bash

set -e

echo "Database host is $DATABASE_HOST"

# TODO extra condition to make extra-sure this doesn't run in non-local envs
if [ "$(mysql -h "$DATABASE_HOST" -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" \
      -sse "select count(*) from information_schema.tables where table_schema='pimcore' and table_name='assets';")" -eq 0 ]
then
  echo "Database is empty, so doing a fresh install to seed the database..."
  runuser -u www-data -- vendor/bin/pimcore-install --skip-database-config
fi

echo Installing bundles...
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreApplicationLoggerBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreCustomReportsBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreDataHubBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreDataImporterBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreGlossaryBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreSeoBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreSimpleBackendSearchBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreStaticRoutesBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreTinymceBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreUuidBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreXliffBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreWordExportBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreWebToPrintBundle
#runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install ElementsProcessManagerBundle
# TODO use env var as list of extra bundles to install

echo Running migration...
runuser -u www-data -- /var/www/html/bin/console doctrine:migrations:migrate -n

echo Rebuilding classes...
runuser -u www-data -- /var/www/html/bin/console pimcore:deployment:classes-rebuild -c -d -n

echo Generating roles...
# TODO role creator

echo Generating folders...
# TODO folder creator