FROM canvouch/ubuntu2004

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_ALLOW_XDEBUG=1
ENV COMPOSER_DISABLE_XDEBUG_WARN=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV PHP_VERSION="8.0"
ENV NVM_VERSION="0.35.1"
ENV NODE_VERSION="14"
ENV UBUNTU_NAME="focal"
ENV NVM_DIR="/root/.nvm"
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN echo "deb http://ppa.launchpad.net/ondrej/apache2/ubuntu ${UBUNTU_NAME} main" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${UBUNTU_NAME} main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C

RUN apt-get update

RUN apt-get install --assume-yes --no-install-recommends --no-install-suggests \
    apache2 \
    libapache2-mod-php${PHP_VERSION} \
    pdftk \
    php-geoip \
    php-pear \
    php-yaml \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-msgpack \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-pdo-pgsql \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-yaml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-redis 

RUN mkdir -p /usr/local/etc/php/conf.d
RUN mkdir -p /usr/local/lib/php/extensions
RUN yes | pecl install xdebug >/dev/null 2>&1
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN apt-get purge --assume-yes --auto-remove \
    --option APT::AutoRemove::RecommendsImportant=false \
    --option APT::AutoRemove::SuggestsImportant=false
RUN rm -rf /var/lib/apt/lists/*

RUN curl -LS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

###########
## install node/npm/NVM
###########
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

SHELL ["/bin/bash", "-c"] 

#COPY etc/apache2 /etc/apache2
#COPY etc/php /etc/php/${PHP_VERSION}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

RUN chown root:root /usr/local/bin/*
RUN chmod 755 /usr/local/bin/*

STOPSIGNAL SIGWINCH

CMD ["apache2", "-DFOREGROUND"]

