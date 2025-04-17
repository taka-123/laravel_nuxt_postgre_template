#!/bin/bash
set -e

# 環境変数が設定されていない場合のデフォルト値
if [ -z "$PHP_FPM_WORKERS" ]; then
    PHP_FPM_WORKERS=5
fi

# PHP-FPMの設定
echo "Configuring PHP-FPM..."
sed -i "s/pm.max_children = .*/pm.max_children = $PHP_FPM_WORKERS/" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/pm.start_servers = .*/pm.start_servers = $(($PHP_FPM_WORKERS / 2))/" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = $(($PHP_FPM_WORKERS / 2))/" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = $PHP_FPM_WORKERS/" /usr/local/etc/php-fpm.d/www.conf

# Laravel向けの前処理
cd /var/www/html

# .envファイルが存在するかどうかをチェック
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    php artisan key:generate
fi

# キャッシュのクリア
php artisan config:clear
php artisan route:clear
php artisan view:clear

# ストレージディレクトリの権限設定
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Nginxの起動
echo "Starting Nginx..."
nginx

# PHP-FPMの起動
echo "Starting PHP-FPM..."
php-fpm
