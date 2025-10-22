# Latest stable as of 2025-07-24
FROM pkpofficial/ojs:3_5_0-1

# disable sll (server is ssl terminated)
RUN apt-get update \
    && apt-get install -y --no-install-recommends libapache2-mod-xsendfile \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && a2enmod rewrite headers \
    && a2dismod ssl

# health check
COPY --chown=www-data:www-data --chmod=775 docker/health.php /var/www/html/health.php
HEALTHCHECK --interval=2s --retries=120 CMD curl --fail http://localhost/health.php || exit 1

# modified bin scripts
COPY --chown=www-data:www-data --chmod=775 docker/bin /usr/local/bin/

# default configs
COPY --chown=www-data:www-data --chmod=775 docker/php.custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY --chown=www-data:www-data --chmod=775 docker/pkp.conf /etc/apache2/conf-enabled/pkp.conf
COPY --chown=www-data:www-data --chmod=775 docker/apache.htaccess /var/www/html/.htaccess

# plugins/themes
ADD --chown=www-data:www-data --chmod=775 \
    plugins/generic/podcast-v1_0_0-0.tar.gz \
    plugins/generic \
    /var/www/html/plugins/generic/
ADD --chown=www-data:www-data --chmod=775 \
    plugins/themes/material-v3_1_0-0.tar.gz \
    plugins/themes \
    /var/www/html/plugins/themes/

# make sure permission are set correctly
RUN chmod -R 755 /var/www/html/plugins \
    && chown -R www-data:www-data /var/www/html/plugins \
    && find /var/www/html/plugins -name '*.tar.gz' -type f -delete