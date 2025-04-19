#!/bin/sh
set -e

# 環境変数が設定されていない場合のデフォルト値
: "${APP_ENV:=production}"
: "${PHP_MEMORY_LIMIT:=256M}"
: "${PHP_MAX_EXECUTION_TIME:=60}"

# PHP設定を環境変数から上書き
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/custom.ini
sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" /usr/local/etc/php/conf.d/custom.ini

# .envファイルが存在するか確認し、APP_KEY等の環境変数を設定
if [ ! -f .env ]; then
    echo "Creating .env file"
    cp .env.example .env
    php artisan key:generate
fi

# 本番環境特有の処理
if [ "$APP_ENV" = "production" ]; then
    echo "Running production environment setup..."

    # キャッシュをクリア
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear

    # キャッシュを作成
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache

    # ストレージディレクトリのパーミッション確認
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache

    # マイグレーション実行（--force は本番環境でのマイグレーション実行を強制）
    php artisan migrate --force
fi

# PHP-FPMを開始（バックグラウンドで実行）
echo "Starting PHP-FPM..."
php-fpm -D

# Nginxを開始（フォアグラウンドで実行）
echo "Starting Nginx..."
exec nginx -g "daemon off;"
