#!/usr/bin/env bash

set -e

# TODO extra condition to make extra-sure this doesn't run in non-local envs
if [ "$(mysql -h "$DATABASE_HOST" -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" \
      -sse "select count(*) from information_schema.tables where table_schema='pimcore' and table_name='assets';")" -eq 0 ]
then
  echo "Database is empty, so doing a fresh install to seed the database..."
  runuser -u www-data -- vendor/bin/pimcore-install --skip-database-config --no-interaction
fi

echo Installing bundles...
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreAdminBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreApplicationLoggerBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreCustomReportsBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreGlossaryBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreSeoBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreSimpleBackendSearchBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreStaticRoutesBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreTinymceBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreUuidBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreXliffBundle --fail-without-error
runuser -u www-data -- /var/www/html/bin/console pimcore:bundle:install PimcoreWordExportBundle --fail-without-error

echo Running migration...
runuser -u www-data -- /var/www/html/bin/console doctrine:migrations:migrate -n

echo Rebuilding classes...
runuser -u www-data -- /var/www/html/bin/console pimcore:deployment:classes-rebuild -c -d -n

echo Generating roles...
runuser -u www-data -- /var/www/html/bin/console torq:generate-roles

echo Creating folders...
runuser -u www-data -- /var/www/html/bin/console torq:folder-creator
