# Laravel + Nuxt + PostgreSQL テンプレート利用ガイド

このドキュメントでは、Laravel + Nuxt + PostgreSQL テンプレートの詳細な使い方と、カスタマイズ方法について説明します。

## テンプレートの概要

このテンプレートは、Laravel 12.x、Nuxt.js 3.16、PostgreSQL 16.x を使用したモダンなウェブアプリケーション開発のための基盤を提供します。フロントエンドとバックエンドを分離した API 駆動型のアーキテクチャを採用し、認証機能、CRUD 操作、テスト環境、CI/CD 設定など、プロジェクト開始に必要な基本機能が整っています。

### 含まれる機能

- **認証システム**: JWT（JSON Web Token）を使用したトークンベースの認証
- **サンプル CRUD 機能**: 投稿（Posts）とコメント（Comments）の基本的な CRUD 操作
- **ユーザー管理**: 基本的なユーザー登録・ログイン・プロフィール管理
- **テスト環境**: PHPUnit（バックエンド）と Vitest（フロントエンド）によるテスト環境
- **Docker 環境**: Docker Compose による開発環境のコンテナ化
- **CI/CD**: GitHub Actions を使用した自動テストとデプロイ設定
- **デプロイ設定**: Fly.io と AWS ECS へのデプロイ設定

## プロジェクト構造

```
/
├── backend/          # Laravel アプリケーション
├── frontend/         # Nuxt.js アプリケーション
├── docker/           # Docker 関連ファイル
├── docs/             # プロジェクトドキュメント
├── .github/          # GitHub Actions ワークフロー
├── .aws/             # AWS インフラストラクチャスクリプト
└── setup.sh          # 初期セットアップスクリプト
```

### バックエンド（Laravel）の構造

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── API/         # APIコントローラー
│   │   └── Middleware/      # ミドルウェア
│   ├── Models/              # データモデル
│   └── Services/            # サービスクラス
├── database/
│   ├── migrations/          # マイグレーションファイル
│   └── seeders/             # シーダーファイル
├── routes/
│   └── api.php              # APIルート定義
└── tests/                   # テストファイル
```

### フロントエンド（Nuxt.js）の構造

```
frontend/
├── components/              # 再利用可能なコンポーネント
├── layouts/                 # レイアウトコンポーネント
├── pages/                   # ページコンポーネント
├── plugins/                 # Nuxtプラグイン
├── stores/                  # Piniaストア
└── test/                    # テストファイル
```

## 開始方法

### 1. リポジトリのクローン

```bash
git clone <リポジトリURL> <プロジェクト名>
cd <プロジェクト名>
```

### 2. プロジェクト名のカスタマイズ

以下のファイルでプロジェクト名と説明を変更します：

- `package.json`
- `backend/composer.json`
- `frontend/package.json`
- `README.md`
- `docker-compose.yml`
- `.github/workflows/*.yml`
- `.aws/scripts/*.sh`

### 3. 開発環境のセットアップ

自動セットアップスクリプトを実行します：

```bash
./setup.sh
```

または、手動でセットアップする場合：

```bash
# 環境変数ファイルのコピー
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# Dockerコンテナの起動
docker-compose up -d

# バックエンドの依存関係インストール
docker-compose exec backend composer install

# マイグレーションとシーディング
docker-compose exec backend php artisan migrate --seed

# フロントエンドの依存関係インストール
docker-compose exec frontend yarn install
```

### 4. アプリケーションへのアクセス

- バックエンド API: http://localhost:8000
- フロントエンド: http://localhost:3000
- pgAdmin（DB 管理）: http://localhost:5050（ユーザー名: admin@example.com、パスワード: admin）

## カスタマイズガイド

### 新しいモデルと CRUD 機能の追加

1. **バックエンド側の実装**

   ```bash
   # マイグレーションファイルの作成
   docker-compose exec backend php artisan make:migration create_your_models_table

   # モデルの作成
   docker-compose exec backend php artisan make:model YourModel

   # コントローラーの作成
   docker-compose exec backend php artisan make:controller API/YourModelController --api
   ```

2. **フロントエンド側の実装**

   - `frontend/pages/your-models/` ディレクトリを作成
   - 一覧表示、詳細表示、作成、編集用のページを作成
   - 必要に応じて Pinia ストアを追加

### 認証機能のカスタマイズ

認証機能は `backend/app/Http/Controllers/API/AuthController.php` で実装されています。ユーザーモデルやログイン要件をカスタマイズする場合は、このファイルを編集してください。

### デプロイ設定のカスタマイズ

#### Fly.io へのデプロイ

`fly.toml` と `fly.staging.toml` ファイルでデプロイ設定をカスタマイズできます。

#### AWS ECS へのデプロイ

`.aws/` ディレクトリ内の CloudFormation テンプレートとデプロイスクリプトをカスタマイズします。

## テスト

### バックエンドテスト

```bash
docker-compose exec backend php artisan test
```

### フロントエンドテスト

```bash
docker-compose exec frontend yarn test
```

## セキュリティに関する注意

- 本番環境では、必ず強力なパスワードを使用してください
- `.env` ファイルはバージョン管理に含めないでください
- AWS デプロイ時は、デプロイスクリプトで使用されるダミーパスワードを本番環境で変更してください
- 定期的に依存パッケージを更新して、セキュリティ脆弱性を防止してください

## トラブルシューティング

一般的な問題と解決方法については、README の[トラブルシューティング](#トラブルシューティング)セクションを参照してください。

## 貢献

プロジェクトへの貢献は大歓迎です。バグ報告、機能リクエスト、プルリクエストなど、どんな形の貢献でも歓迎します。

---

このテンプレートが皆様のプロジェクト開発の助けになれば幸いです。質問や提案がある場合は、お気軽に Issue を作成してください。
