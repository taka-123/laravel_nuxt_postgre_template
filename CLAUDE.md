# プロジェクト名

## プロジェクト概要

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 17.x を使用したモダンなフルスタック Web アプリケーションテンプレート。API ドリブンなアーキテクチャでフロントエンドとバックエンドを分離。

## プロジェクト構造

```
laravel_nuxt_postgre_template/
├── .claude/                 # Claude AI設定
├── .fly/                    # Fly.io デプロイ設定
├── .husky/                  # Git hooks設定
├── backend/                 # Laravel API アプリケーション
├── frontend/               # Nuxt.js フロントエンド
├── docker/                # Docker Compose設定
├── docs/                  # 技術詳細ドキュメント（デプロイ除外）
├── docker-compose.yml     # Docker Compose定義
├── setup.sh              # 初期セットアップスクリプト
├── git-flow.md           # Git Flow運用ガイド
└── README.md             # プロジェクトメイン説明
```

## アーキテクチャ

### バックエンド (Laravel API)

- **ディレクトリ**: `/backend/`
- **技術スタック**: PHP 8.3, Laravel 12.x, PostgreSQL 17.x
- **認証**: `php-open-source-saver/jwt-auth`による JWT 認証
- **API ルート**: `/backend/routes/api.php`
- **主要コントローラー**: `/backend/app/Http/Controllers/API/AuthController.php`

### フロントエンド (Nuxt.js)

- **ディレクトリ**: `/frontend/`
- **技術スタック**: Node.js 22.x+, Nuxt.js 3.16, Vue.js 3.4+, TypeScript 5.2+
- **UI フレームワーク**: Vuetify 3.x (Material Design)
- **状態管理**: Pinia
- **認証連携**: `/frontend/composables/useAuth.ts`のカスタムコンポーザブル

### 開発環境

- **Docker Compose**: Laravel, Nuxt, PostgreSQL, pgAdmin を含む完全な開発スタック
- **ローカル開発**: Docker なしで Laravel と Nuxt を個別に実行可能
- **データベース**: PostgreSQL 17 (Docker) または SQLite (ローカル開発)

## 開発規約

**NEVER**:

- パスワードや API キーをハードコーディングしない
- マイグレーションファイルを直接編集しない
- 本番環境で debug モードを有効にしない

**YOU MUST**:

- PR マージ前にコードレビューを 2 名以上から取得
- テストカバレッジ 80%以上を維持
- コミット前に lint とテストを実行

**IMPORTANT**:

- パフォーマンスへの影響を常に考慮
- TypeScript の型定義を適切に行う
- エラーハンドリングを確実に実装

## よく使うコマンド

### 環境セットアップ

```bash
# Docker環境（推奨）
docker compose up -d

# ローカル開発
cd backend && php artisan serve   # ポート8000
cd frontend && npm run dev        # ポート3000（別ターミナル）
```

### バックエンド (Laravel) - `/backend/`ディレクトリから実行

```bash
# 開発
php artisan serve                 # 開発サーバー起動
php artisan migrate              # マイグレーション実行
php artisan db:seed              # シーディング実行
php artisan make:controller      # コントローラー作成
php artisan make:job             # ジョブ作成

# テスト・品質チェック
php artisan test                 # テスト実行
./vendor/bin/phpunit            # PHPUnitテスト
./vendor/bin/pint               # Laravel Pintフォーマッター
composer analyze                # PHPStan解析
```

### フロントエンド (Nuxt) - `/frontend/`ディレクトリから実行

```bash
# 開発
npm run dev                      # 開発サーバー起動
npm run build                    # プロダクションビルド
npm run generate                 # 静的サイト生成

# テスト・品質チェック
npm run test                     # Vitestテスト実行
npm run test:coverage            # カバレッジ付きテスト
npm run lint                     # ESLintチェック
npm run lint:fix                 # ESLint自動修正
```

## 主要設定ファイル

### 環境設定

- `/backend/.env.example` - Laravel 環境変数テンプレート
- `/frontend/.env.example` - Nuxt 環境変数テンプレート
- `/docker-compose.yml` - Docker 開発環境

### パッケージ管理

- `/backend/composer.json` - Laravel 依存関係とスクリプト
- `/frontend/package.json` - Nuxt 依存関係とスクリプト
- `/package.json` - ルートレベルスクリプト

### TypeScript 設定

- `/frontend/tsconfig.json` - Nuxt 3 + Vue 3 用に最適化
- `/frontend/nuxt.config.ts` - Vuetify 統合を含む Nuxt 設定

## API 設計

### 認証エンドポイント

- `POST /api/auth/register` - ユーザー登録
- `POST /api/auth/login` - ログイン
- `POST /api/auth/logout` - ログアウト
- `GET /api/auth/me` - 現在のユーザー取得

### JWT トークンフロー

- フロントエンドの状態管理（Pinia）にトークン保存
- Authorization ヘッダーで API リクエストを認証
- コンポーザブルパターンで認証機能を提供（`useAuth.ts`, `useApi.ts`）

## データベース設定

### 開発用データベース

- **Docker**: PostgreSQL 17 コンテナ（ポート 5432）
- **ローカル**: SQLite データベース
- **管理ツール**: pgAdmin (http://localhost:5050)

### 接続情報（Docker）

- ホスト: localhost、ポート: 5432
- データベース: laravel_nuxt_template
- ユーザー名: sail、パスワード: password

## 開発ポート一覧

| サービス      | ポート | URL                   |
| ------------- | ------ | --------------------- |
| Laravel API   | 8000   | http://localhost:8000 |
| Nuxt Frontend | 3000   | http://localhost:3000 |
| PostgreSQL    | 5432   | -                     |
| pgAdmin       | 5050   | http://localhost:5050 |

## コード品質基準

### バックエンド基準

- Laravel Pint によるコーディング標準
- PHPStan 静的解析（レベル 3）
- PHPUnit によるテスト
- PHPCS による追加のコードスタイルチェック

### フロントエンド基準

- TypeScript と Vue 3 ルールを含む ESLint
- Prettier によるコードフォーマット
- Vitest によるユニットテスト
- 開発効率のため TypeScript strict モードは無効

## エラーハンドリング

- try/catch ブロックを使用し、適切なエラーログを記録
- API エラーは統一されたフォーマットで返却
- フロントエンドでは axios インターセプターでグローバルエラー処理

## 実装済み機能

- JWT 認証（登録/ログイン/ログアウト）
- ユーザープロフィール管理
- 認証状態に応じたダッシュボード表示
- Vuetify Material Design の UI コンポーネント
- レスポンシブデザインとローディング状態
- エラーハンドリング付き API 統合
