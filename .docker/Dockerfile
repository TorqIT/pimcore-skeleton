FROM pimcore/pimcore:php8.2-v3 as base
# TODO arg for passing in custom Linux packages
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends autoconf make g++ unixodbc-dev cron vim supervisor netcat-traditional default-mysql-client; \
    rm -rf /var/lib/apt/lists/*; \
    usermod -u 1000 www-data; \
    groupmod -g 1000 www-data;
# TODO required until Pimcore adds this to their image...
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y librabbitmq-dev; \
    rm -rf /var/lib/apt/lists/*; \
    pecl install amqp; \
    docker-php-ext-enable amqp;
# We copy in the composer files and download dependencies, then in a separate set of statements below copy in the full
# source directory and run a full composer install. This will take advantage of Docker-build caching when the composer
# dependencies do not change.
# TODO stage/context option for custom composer files
COPY --chown=www-data:www-data /composer.* /var/www/html
COPY /.docker/composer-install-dependencies.sh /composer-install-dependencies.sh
RUN /composer-install-dependencies.sh
# TODO be more selective about what to copy into image
COPY --chown=www-data:www-data / /var/www/html
RUN cd /var/www/html; \
    runuser -u www-data -- php /usr/local/bin/composer install

FROM base as init
# TODO allow for custom bundles to be passed via args
COPY /.docker/init/init.sh /init.sh
CMD [ "/init.sh" ]

# Default sources for config files
# TODO php.ini - should probably go at base level?
FROM base as nginx-conf-src
COPY /.docker/php/nginx.conf /etc/nginx/sites-available/default
# TODO php fpm ini

FROM base as php
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends nginx; \
    rm -rf /var/lib/apt/lists/*;
# TODO what to specify as "source path" when copying from outside context?
COPY --from=nginx-conf-src /etc/nginx/sites-available/default /etc/nginx/sites-available/default
COPY /.docker/php/supervisord.conf /etc/supervisor/supervisord.conf
RUN runuser -u www-data -- /var/www/html/bin/console pimcore:build:classes; \
    runuser -u www-data -- /var/www/html/bin/console cache:warmup
CMD [ "/usr/bin/supervisord" ]

FROM base as supervisord-conf-src
COPY /.docker/supervisord/supervisord.conf /etc/supervisor/conf.d/pimcore.conf

FROM base as supervisord
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /var/run /var/run
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /usr/sbin/cron /usr/sbin/cron
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY --from=supervisord-conf-src /etc/supervisor/conf.d/pimcore.conf /etc/supervisor/conf.d/pimcore.conf
RUN runuser -u www-data -- /var/www/html/bin/console pimcore:build:classes; \
    runuser -u www-data -- /var/www/html/bin/console cache:warmup
CMD [ "/usr/bin/supervisord" ]

FROM base as php-debug
COPY --from=pimcore/pimcore:php8.2-debug-v3 /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN pecl install xdebug; \
    docker-php-ext-enable xdebug;
ENV PHP_IDE_CONFIG serverName=localhost
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]