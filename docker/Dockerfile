FROM php:8.2-fpm

WORKDIR /var/www/html

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    libpq-dev \
    supervisor \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd mysqli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ComposerとNode.jsのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# Nginxの設定
COPY docker/nginx/nginx.conf /etc/nginx/sites-available/default

# PHPの設定
RUN echo "upload_max_filesize = 100M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 108M" >> /usr/local/etc/php/conf.d/uploads.ini

# 起動スクリプトと権限設定
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# アプリケーションのコピー
COPY . /var/www/html

# Composerパッケージのインストール
RUN composer install --optimize-autoloader --no-dev

# フロントエンドのビルド
RUN npm ci && npm run build

# 権限の設定
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
