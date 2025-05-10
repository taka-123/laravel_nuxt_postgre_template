#!/bin/sh
set -e

# 環境変数が設定されていない場合のデフォルト値
: "${APP_ENV:=production}"
: "${PHP_MEMORY_LIMIT:=256M}"
: "${PHP_MAX_EXECUTION_TIME:=60}"

# PHP設定を環境変数から上書き
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/custom.ini
sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" /usr/local/etc/php/conf.d/custom.ini

# Fly.io環境変数からLaravelの環境変数を設定
if [ -n "$DATABASE_URL" ]; then
    echo "Using DATABASE_URL from environment: $DATABASE_URL"

    # DATABASE_URLからDB接続情報を解析（BusyBox互換の方法で）
    # postgres://user:password@host:port/database
    DB_CONNECTION=pgsql

    # URLをスラッシュで分割
    PROTOCOL_AND_AUTH=${DATABASE_URL%%/*}
    HOST_AND_PATH=${DATABASE_URL#*//}

    # ユーザー名とパスワードを抽出
    AUTH=${HOST_AND_PATH%%@*}
    DB_USER=${AUTH%%:*}
    DB_PASSWORD=${AUTH#*:}

    # ホスト、ポート、データベース名を抽出
    HOST_PORT_DB=${HOST_AND_PATH#*@}
    HOST_PORT=${HOST_PORT_DB%%/*}
    DB_HOST=${HOST_PORT%%:*}
    DB_PORT=${HOST_PORT#*:}
    DB_DATABASE=${HOST_PORT_DB#*/}

    # クエリパラメータがあれば削除
    DB_DATABASE=${DB_DATABASE%%\?*}

    echo "Extracted database connection info:"
    echo "DB_CONNECTION=$DB_CONNECTION"
    echo "DB_HOST=$DB_HOST"
    echo "DB_PORT=$DB_PORT"
    echo "DB_DATABASE=$DB_DATABASE"
    echo "DB_USERNAME=$DB_USER"

    # 環境変数を設定
    export DB_CONNECTION=$DB_CONNECTION
    export DB_HOST=$DB_HOST
    export DB_PORT=$DB_PORT
    export DB_DATABASE=$DB_DATABASE
    export DB_USERNAME=$DB_USER
    export DB_PASSWORD=$DB_PASSWORD
else
    echo "WARNING: DATABASE_URL environment variable is not set"
fi

# .envファイルが存在するか確認し、APP_KEY等の環境変数を設定
if [ ! -f .env ]; then
    echo "Creating .env file for Fly.io"
    cp .env.example .env

    # APP_KEYが設定されていない場合は生成
    if [ -z "$APP_KEY" ]; then
        php artisan key:generate --show
        # 生成されたキーを取得して環境変数に設定
        export APP_KEY=$(grep APP_KEY .env | cut -d '=' -f2)
    fi
fi

# 本番環境特有の処理
if [ "$APP_ENV" = "production" ]; then
    echo "Running production environment setup for Fly.io..."

    # 重要: ストレージディレクトリの準備（最初に実行）
    echo "Preparing storage directories..."
    mkdir -p storage/framework/views
    mkdir -p storage/framework/cache
    mkdir -p storage/framework/sessions
    mkdir -p bootstrap/cache

    # 重要: すべてのキャッシュをクリア（最初のステップ）
    echo "Clearing all caches..."
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    # view:clearはエラーが出るため、手動でクリア
    if [ -d "storage/framework/views" ]; then
        echo "Manually clearing view cache..."
        rm -rf storage/framework/views/*
    else
        echo "Views directory not found, skipping view cache clear"
    fi

    # ストレージディレクトリのパーミッション確認（先に実行）
    echo "Setting storage permissions..."
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache

    # データベース接続の確認（シンプルな方法）
    echo "Checking database connection..."
    php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'Database connection successful.'; } catch (\Exception \$e) { echo 'Database connection failed: ' . \$e->getMessage(); }" || {
        echo "Warning: Database connection check failed. Will try to continue anyway."
    }

    # キャッシュテーブルを直接作成（最優先）
    echo "Creating cache table directly with SQL..."
    php artisan tinker --execute="try {
        if (Schema::hasTable('cache')) {
            echo 'Cache table already exists.';
        } else {
            Schema::create('cache', function(\Illuminate\Database\Schema\Blueprint \$table) {
                \$table->string('key')->primary();
                \$table->text('value');
                \$table->integer('expiration');
            });
            echo 'Cache table created successfully.';
        }
    } catch(\Exception \$e) {
        echo 'Error creating cache table: ' . \$e->getMessage();
    }" || {
        echo "Warning: Failed to create cache table with tinker. Will try another method."
        # tinkerが失敗した場合、PDOを使って直接接続を試みる
        php -r "try {
            \$dsn = 'pgsql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_DATABASE}';
            \$pdo = new PDO(\$dsn, '${DB_USERNAME}', '${DB_PASSWORD}');
            \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            \$sql = 'CREATE TABLE IF NOT EXISTS cache (key VARCHAR(255) NOT NULL, value TEXT NOT NULL, expiration INTEGER NOT NULL, PRIMARY KEY (key))';
            \$pdo->exec(\$sql);
            echo 'Cache table created successfully using PDO.';
        } catch (PDOException \$e) {
            echo 'Database connection failed: ' . \$e->getMessage();
        }" || echo "Failed to create cache table with PDO as well."
    }

    # マイグレーション実行（--force は本番環境でのマイグレーション実行を強制）
    echo "Running database migrations with fresh..."
    php artisan migrate:fresh --force || {
        echo "Warning: Fresh migration failed. Trying regular migration..."
        php artisan migrate --force || {
            echo "Warning: Migration failed. But we already created the cache table directly."
        }
    }

    # 最後にキャッシュを再生成（マイグレーション後）
    echo "Regenerating caches after migrations..."

    # キャッシュテーブルの存在確認
    echo "Verifying cache table exists..."
    php artisan tinker --execute="try { echo DB::table('cache')->count() >= 0 ? 'Cache table exists and is accessible.' : 'Cache table exists but might be empty.'; } catch (\Exception \$e) { echo 'Cache table check failed: ' . \$e->getMessage(); }" || {
        echo "Warning: Cache table verification failed."
    }

    # キャッシュを作成（エラーを無視）
    echo "Creating cache files..."
    php artisan config:cache || echo "Warning: config:cache failed"
    php artisan route:cache || echo "Warning: route:cache failed"
    php artisan view:cache || echo "Warning: view:cache failed"

    # ストレージディレクトリのパーミッション確認
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache
fi

# PHP-FPMを開始（バックグラウンドで実行）
echo "Starting PHP-FPM..."
php-fpm -D

# Nginxを開始（フォアグラウンドで実行）
echo "Starting Nginx on port 8080..."
exec nginx -g "daemon off;"
