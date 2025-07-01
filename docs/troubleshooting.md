# トラブルシューティング

## TypeScript 言語サービスのクラッシュ

VSCode で問題が発生した場合：

1. VSCode を再起動する
2. コマンドパレット（Cmd+Shift+P）から「TypeScript: Restart TS Server」を実行する
3. `.vscode/settings.json` の設定を確認する

## Docker 環境の問題

Docker 環境で問題が発生した場合：

```bash
# コンテナとボリュームを完全に削除してリセット
docker compose down -v

# イメージを再ビルド
docker compose build --no-cache

# 再起動
docker compose up -d
```

## データベース接続エラー

### PostgreSQL接続が失敗する場合

```bash
# Dockerコンテナの状態確認
docker compose ps

# PostgreSQLコンテナのログ確認
docker compose logs postgres

# 環境変数の確認
cat backend/.env | grep DB_
```

### マイグレーションエラー

```bash
# マイグレーションファイルの確認
php artisan migrate:status

# ロールバック
php artisan migrate:rollback

# 再実行
php artisan migrate
```

## Node.js / npm の問題

### パッケージインストールエラー

```bash
# node_modulesを削除して再インストール
rm -rf frontend/node_modules
cd frontend && npm install

# キャッシュクリア
npm cache clean --force
```

### Nuxtビルドエラー

```bash
# .nuxtディレクトリを削除
rm -rf frontend/.nuxt

# 再ビルド
cd frontend && npm run build
```

## JWT認証の問題

### トークンエラー

```bash
# JWT秘密鍵の再生成
cd backend
php artisan jwt:secret --force

# キャッシュクリア
php artisan cache:clear
php artisan config:clear
```

## パフォーマンスの問題

### 開発サーバーが遅い場合

```bash
# Laravel
php artisan optimize:clear

# Nuxt
cd frontend
npm run dev -- --host 0.0.0.0  # ホストバインドの変更
```

### メモリ不足エラー

```bash
# PHPメモリ制限の確認と調整
php -i | grep memory_limit

# Nodeメモリ制限の調整
export NODE_OPTIONS="--max-old-space-size=4096"
```

## 権限の問題

### Laravelストレージ権限

```bash
cd backend
sudo chown -R www-data:www-data storage/
sudo chmod -R 775 storage/
```

### Docker権限エラー

```bash
# Dockerグループに追加
sudo usermod -aG docker $USER

# ログアウト・ログインが必要
```

## 開発環境固有の問題

### ポートが使用中

```bash
# ポート使用状況の確認
lsof -i :3000  # Nuxt
lsof -i :8000  # Laravel
lsof -i :5432  # PostgreSQL

# プロセス終了
kill -9 <PID>
```

### ホットリロードが効かない

```bash
# Nuxt設定確認
# nuxt.config.ts で vite.server.watch.usePolling: true を設定

# Laravel設定確認
# mix が正しく設定されているか確認
```

## よくある設定ミス

### 環境変数の設定漏れ

```bash
# 必要な環境変数の確認
cd backend && cp .env.example .env
cd frontend && cp .env.example .env

# Laravel APP_KEY生成
cd backend && php artisan key:generate
```

### CORS設定

```bash
# Laravel CORS設定確認
# config/cors.php の設定を確認
# 'allowed_origins' にフロントエンドのURLが含まれているか
```

## ログの確認方法

### Laravel

```bash
# エラーログ確認
tail -f backend/storage/logs/laravel.log

# デバッグ情報
# .envでAPP_DEBUG=trueに設定
```

### Nuxt

```bash
# ブラウザの開発者ツールでコンソールエラーを確認
# ネットワークタブでAPI通信を確認
```

### Docker

```bash
# 各サービスのログ確認
docker compose logs app      # Laravel
docker compose logs nuxt     # Nuxt
docker compose logs postgres # PostgreSQL
```