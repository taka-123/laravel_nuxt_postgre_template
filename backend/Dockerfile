FROM ubuntu:22.04

LABEL maintainer="Taylor Otwell"

ARG WWWGROUP
ARG NODE_VERSION=22
ARG POSTGRES_VERSION=16

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www/html

ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone

# Install base packages including those needed for adding repositories
RUN apt-get update &&
    apt-get install -y --no-install-recommends gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin software-properties-common &&
    apt-get clean &&
    rm -rf /var/lib/apt/lists/*

# Add Repositories (PHP, Node.js, Yarn, PostgreSQL)
RUN add-apt-repository ppa:ondrej/php -y &&
    curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - &&
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn.gpg >/dev/null &&
    echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg &&
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" >/etc/apt/sources.list.d/pgdg.list

# Install CORE PHP Packages ONLY
RUN apt-get update &&
    apt-get install -y --no-install-recommends \
        php8.3-common php8.3-cli php8.3-fpm &&
    apt-get install -f -y &&
    dpkg --configure -a

# Install PHP Extensions (non-problematic), Node, Yarn, DB clients
RUN apt-get update &&
    apt-get install -y --no-install-recommends \
        php8.3-sqlite3 php8.3-gd php8.3-imagick \
        php8.3-imap php8.3-mysql php8.3-mbstring \
        php8.3-bcmath php8.3-soap \
        php8.3-intl php8.3-readline php8.3-ldap \
        php8.3-msgpack php8.3-igbinary php8.3-redis \
        php8.3-memcached \
        php8.3-opcache \
        nodejs \
        yarn \
        mysql-client \
        postgresql-client-$POSTGRES_VERSION &&
    apt-get install -f -y &&
    dpkg --configure -a

# Install php8.3-zip separately
RUN apt-get update && apt-get install -y --no-install-recommends php8.3-zip && apt-get install -f -y && dpkg --configure -a

# Install php8.3-xml separately
RUN apt-get update && apt-get install -y --no-install-recommends php8.3-xml && apt-get install -f -y && dpkg --configure -a

# Install php8.3-pgsql separately
RUN apt-get update && apt-get install -y --no-install-recommends php8.3-pgsql && apt-get install -f -y && dpkg --configure -a

# Install php8.3-curl separately
RUN apt-get update && apt-get install -y --no-install-recommends php8.3-curl && apt-get install -f -y && dpkg --configure -a

# Install php8.3-swoole separately
RUN apt-get update && apt-get install -y --no-install-recommends php8.3-swoole && apt-get install -f -y && dpkg --configure -a

# Install Composer and Global npm packages
RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer &&
    npm install -g npm

# Final Cleanup
RUN apt-get -y autoremove &&
    apt-get clean &&
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.3

# Create PHP-FPM runtime directory
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY start-container /usr/local/bin/start-container
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php/php.ini /etc/php/8.3/cli/conf.d/99-sail.ini
COPY docker/php-fpm/www.conf /etc/php/8.3/fpm/pool.d/www.conf
RUN chmod +x /usr/local/bin/start-container

EXPOSE 8000

ENTRYPOINT ["start-container"]
