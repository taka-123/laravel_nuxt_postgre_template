# Laravel + Nuxt + PostgreSQL テンプレート バックエンド

このディレクトリにはLaravel + Nuxt + PostgreSQL テンプレートのバックエンド（Laravel 12.x）が含まれています。

## バックエンド技術スタック

- **フレームワーク**: Laravel 12.x
- **データベース**: PostgreSQL 17.x
- **認証**: JWT（php-open-source-saver/jwt-auth）
- **コード品質**: PHP_CodeSniffer（PSR-12）, PHPStan/Larastan
- **テスト**: PHPUnit

## セットアップ

依存関係をインストールします：

```bash
# Composer（ローカル環境）
composer install

# または Laravel Sail（Docker）を使用
./vendor/bin/sail up -d
```

## 環境設定

`.env` ファイルをセットアップします：

```bash
cp .env.example .env
php artisan key:generate
```

データベースを作成・初期化します：

```bash
php artisan migrate
php artisan db:seed
```

## 開発サーバー

開発サーバーを起動します（http://localhost:8000）：

```bash
# Laravel サーバー（ローカル環境）
php artisan serve

# または Laravel Sail（Docker）を使用
./vendor/bin/sail up -d
```

## コマンド一覧

```bash
# 開発サーバー起動
php artisan serve

# データベースマイグレーション
php artisan migrate

# テストデータ作成
php artisan db:seed

# コード品質チェック
composer lint

# 静的解析
composer analyze

# テスト実行
composer test

# キャッシュクリア
php artisan optimize:clear
```

## API エンドポイント

### 認証

- `POST /api/auth/register` - ユーザー登録
- `POST /api/auth/login` - ログイン
- `POST /api/auth/logout` - ログアウト
- `POST /api/auth/refresh` - トークンリフレッシュ
- `GET /api/auth/me` - ログイン中ユーザー情報取得

## ディレクトリ構造

```
backend/
├── app/               # アプリケーションコード
│   ├── Http/          # コントローラー、ミドルウェア等
│   │   ├── Controllers/  # APIコントローラー
│   │   └── Middleware/   # カスタムミドルウェア
│   ├── Models/        # Eloquentモデル
│   └── Providers/     # サービスプロバイダー
├── bootstrap/         # アプリケーション起動ファイル
├── config/            # 設定ファイル
├── database/          # マイグレーション、シーダー
│   ├── factories/     # モデルファクトリー
│   ├── migrations/    # データベースマイグレーション
│   └── seeders/       # データベースシーダー
├── docker/            # Docker設定ファイル
│   ├── nginx/         # Nginx設定
│   ├── php/           # PHP設定
│   └── supervisor/    # Supervisor設定
├── public/            # 公開ディレクトリ
├── resources/         # ビュー、アセット
├── routes/            # ルート定義
├── storage/           # ログ、キャッシュ等
├── tests/             # テストファイル
│   ├── Feature/       # 機能テスト
│   └── Unit/          # ユニットテスト
├── composer.json      # Composer依存関係
├── Dockerfile.fly     # Fly.io用Dockerfile
├── fly.toml          # Fly.io設定
├── phpcs.xml         # コーディング規約
└── phpstan.neon      # 静的解析設定
```

## 詳細情報

詳細については、以下を参照してください：

- [Laravel ドキュメント](https://laravel.com/docs/12.x)
- [JWT認証パッケージ](https://github.com/PHP-Open-Source-Saver/jwt-auth)
- [プロジェクト開発環境ガイド](../DEVELOPMENT.md)
