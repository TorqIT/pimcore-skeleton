FROM pimcore/pimcore:php8.2-v3 as base
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends autoconf make g++ unixodbc-dev cron vim supervisor netcat-traditional default-mysql-client; \
    rm -rf /var/lib/apt/lists/*; \
    usermod -u 1000 www-data; \
    groupmod -g 1000 www-data;
# We copy in the composer files and download dependencies, then in a separate set of statements below copy in the full
# source directory and run a full composer install. This will take advantage of Docker-build caching when the composer
# dependencies do not change.
COPY --chown=www-data:www-data /composer.* /var/www/html
COPY /.docker/composer-install-dependencies.sh /composer-install-dependencies.sh
RUN /composer-install-dependencies.sh
COPY --chown=www-data:www-data / /var/www/html
RUN cd /var/www/html; \
    runuser -u www-data -- php /usr/local/bin/composer install

FROM base as init
# TODO allow for custom bundles to be passed via args?
COPY /.docker/init/init.sh /init.sh
CMD [ "/init.sh" ]

FROM base as php
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends nginx; \
    rm -rf /var/lib/apt/lists/*;
# php.ini configuration
ENV PHP_MEMORY_LIMIT=4G
ENV PHP_UPLOAD_MAX_FILESIZE=20G
ENV PHP_POST_MAX_SIZE=20G
ENV PHP_MAX_EXECUTION_TIME=0
ENV PHP_MAX_INPUT_TIME=-1
COPY /.docker/php/php.ini /usr/local/etc/php/conf.d/docker-pimcore-php.ini
# php-fpm.conf configuration
ENV PHP_FPM_MAX_CHILDREN=275
ENV PHP_FPM_START_SERVERS=75
ENV PHP_FPM_MIN_SPARE_SERVERS=75
ENV PHP_FPM_MAX_SPARE_SERVERS=200
COPY /.docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
# nginx configuration
COPY /.docker/php/nginx.conf /etc/nginx/sites-available/default
COPY /.docker/php/supervisord.conf /etc/supervisor/supervisord.conf
# Build Pimcore classes and warm up the cache to improve container start-up
RUN runuser -u www-data -- /var/www/html/bin/console pimcore:build:classes; \
    runuser -u www-data -- /var/www/html/bin/console cache:warmup
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]

FROM base as supervisord
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /var/run /var/run
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /usr/sbin/cron /usr/sbin/cron
COPY --from=pimcore/pimcore:php8.2-supervisord-v3 /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY /.docker/supervisord/supervisord.conf /etc/supervisor/conf.d/pimcore.conf
RUN runuser -u www-data -- /var/www/html/bin/console pimcore:build:classes; \
    runuser -u www-data -- /var/www/html/bin/console cache:warmup
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/pimcore.conf" ]

FROM base as php-debug
COPY --from=pimcore/pimcore:php8.2-debug-v3 /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN pecl install xdebug; \
    docker-php-ext-enable xdebug;
ENV PHP_IDE_CONFIG serverName=localhost
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]