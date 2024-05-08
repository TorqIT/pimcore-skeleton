#!/usr/bin/env bash

set -e

if [ ! -d /var/www/html/vendor ];
then
  . /composer-install-dependencies.sh
fi

runuser -u www-data -- bin/console cache:clear

. /init.sh