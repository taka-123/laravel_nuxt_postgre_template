# 書籍管理システム

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した書籍管理システムです。

## 目次

- [プロジェクト構成](#プロジェクト構成)
- [開発環境のセットアップ](#開発環境のセットアップ)
- [開発サーバーの起動](#開発サーバーの起動)
- [マイグレーションとシーディング](#マイグレーションとシーディング)
- [コード品質管理とテスト](#コード品質管理とテスト)
- [デプロイフロー](#デプロイフロー)
- [環境構成](#環境構成fly-io)
- [トラブルシューティング](#トラブルシューティング)

## プロジェクト構成

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

## 開発環境のセットアップ

### 前提条件

- Docker と Docker Compose がインストールされていること
- Node.js 20.x 以上
- PHP 8.3 以上（ローカルで直接実行する場合）

### 自動セットアップ（推奨）

プロジェクトルートディレクトリで以下のコマンドを実行するだけで環境構築が完了します：

```bash
./setup.sh
```

このスクリプトは以下の処理を自動的に行います：
- 必要な環境変数ファイルの作成
- Docker コンテナのビルドと起動
- 依存パッケージのインストール
- データベースのマイグレーションとシーディング

### 手動セットアップ

1. 環境変数ファイルを作成

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

2. Docker 環境を起動

```bash
docker-compose up -d
```

3. バックエンドの依存パッケージをインストール

```bash
docker-compose exec backend composer install
```

4. フロントエンドの依存パッケージをインストール

```bash
docker-compose exec frontend npm install
```

## 開発サーバーの起動

### Docker を使用した起動（推奨）

Docker 環境を起動すると、自動的に開発サーバーも起動します：

```bash
# プロジェクトルートディレクトリで実行
docker-compose up -d
```

以下の URL でアクセスできます：

- バックエンド API: http://localhost:8000
- フロントエンド: http://localhost:3000
- pgAdmin（DB 管理）: http://localhost:5050（ユーザー名: admin@example.com、パスワード: admin）

### 個別の起動方法

#### バックエンド（Laravel）の起動

```bash
# Docker 内で実行する場合
docker-compose exec backend php artisan serve --host=0.0.0.0

# ローカルで直接実行する場合
cd backend
php artisan serve
```

#### フロントエンド（Nuxt.js）の起動

```bash
# Docker 内で実行する場合
docker-compose exec frontend npm run dev

# ローカルで直接実行する場合
cd frontend
npm run dev
```

## マイグレーションとシーディング

### Docker 環境でのマイグレーション実行

```bash
# マイグレーションの実行
docker-compose exec backend php artisan migrate

# シーディングの実行
docker-compose exec backend php artisan db:seed

# マイグレーションとシーディングを一度に実行
docker-compose exec backend php artisan migrate:fresh --seed
```

### ステージング環境でのマイグレーション実行

```bash
# ステージング環境へのマイグレーション
fly ssh console -a book-management-backend-staging -C "php artisan migrate"

# ステージング環境へのシーディング
fly ssh console -a book-management-backend-staging -C "php artisan db:seed"
```

### 本番環境でのマイグレーション実行

```bash
# 本番環境へのマイグレーション（注意: 慎重に実行してください）
fly ssh console -a book-management-backend -C "php artisan migrate"
```

## コード品質管理とテスト

### Linter と Formatter

本プロジェクトでは以下の Linter と Formatter を使用しています：

#### バックエンド

- **PHP_CodeSniffer (PSR-12)** - コーディング規約チェック
- **PHPStan/Larastan** - 静的解析
- **PHP-CS-Fixer** - コードスタイル自動修正

コマンドラインで実行：

```bash
cd backend
composer lint    # PHPCSによるコード規約チェック
composer analyze # PHPStanによる静的解析
./vendor/bin/php-cs-fixer fix # コードスタイル自動修正
```

#### フロントエンド

- **ESLint** - コード品質チェック
- **Prettier** - コードフォーマッター

コマンドラインで実行：

```bash
cd frontend
npm run lint     # リントチェック
npm run lint:fix # リントとフォーマット修正
```

#### 開発プロセスの自動化

本プロジェクトでは、コード品質を維持するために以下の自動化が設定されています：

- **Git Hooks（Husky）** - コミット前にコード品質チェックを自動実行
- **lint-staged** - 変更されたファイルのみをリントして効率化

コミット前には以下が自動実行されます：

1. フロントエンド: 変更された JavaScript/TypeScript ファイルの ESLint と Prettier チェック
2. バックエンド: 変更された PHP ファイルの PHP-CS-Fixer と PHPCS チェック

**自動フォーマット**: VSCode (または互換エディタ) を使用している場合、ファイル保存時に自動フォーマットが適用されます。プロジェクトには`.vscode/settings.json`があらかじめ設定されており、保存時に以下のファイル形式が自動的にフォーマットされます：

- JavaScript/TypeScript/Vue (Prettier)
- PHP (PHP CS Fixer)
- HTML/CSS/SCSS (Prettier)
- JSON/YAML (Prettier/YAML)
- Markdown (Prettier)
- Dockerfile (Docker)
- シェルスクリプト/dotenv (Shell Format)

### テスト実行

#### バックエンド

```bash
cd backend
php artisan test                 # すべてのテストを実行
php artisan test --filter=UserTest  # 特定のテストクラスのみ実行
```

#### フロントエンド

```bash
cd frontend
npm run test           # すべてのテストを実行
npm run test:watch     # ファイル変更を監視して自動テスト実行
npm run test:coverage  # テストカバレッジレポートを生成
```

### テスト駆動開発のプロセス

本プロジェクトでは、以下のテストプロセスを推奨しています：

1. **機能開発前にテストを作成**（TDDアプローチ）
   - 新機能の要件をテストとして記述
   - 期待される動作を明確にしてから実装を開始

2. **実装中にテストを実行**
   - `npm run test:watch` や `php artisan test --filter=` を使用して必要なテストのみを実行
   - 実装が進むにつれてテストが通るように調整

3. **プルリクエスト作成前の確認**
   - すべてのテストが通ることを確認
   - カバレッジレポートを確認し、必要に応じてテストを追加

4. **CI パイプラインによる自動チェック**
   - プルリクエスト時に自動的にすべてのテストが実行される
   - テストが失敗するとマージがブロックされる

このプロセスにより、コードの品質と信頼性を維持しながら、開発速度を落とさないバランスの取れたテスト環境を実現しています。

## Git ワークフロー

本プロジェクトでは以下のようなシンプルな Git ワークフローを採用しています：

### ブランチ戦略

- **`main`**: 本番環境用のブランチ。常に安定した状態を維持する。
- **`develop`**: （オプション）開発環境用のブランチ。検証環境がある場合に使用。

### 開発プロセス

1. **機能開発・バグ修正**:

   - 新機能開発は `feature/機能名` ブランチ（例：`feature/barcode-generator`）
   - バグ修正は `fix/修正内容` ブランチ（例：`fix/login-error`）
   - 基本的に`main`から分岐し、プルリクエスト後に`main`へマージ

2. **コミットメッセージ規約**:

   ```
   タイプ: 簡潔な説明

   詳細な説明（オプション）

   関連する問題やPR（オプション）
   ```

   **タイプ例:**

   - `feat`: 新機能
   - `fix`: バグ修正
   - `docs`: ドキュメント変更
   - `style`: フォーマットの変更
   - `refactor`: リファクタリング
   - `test`: テスト関連の変更
   - `chore`: その他の変更

### ブランチ保護設定

コードの品質を確保するため、GitHub上で以下のブランチ保護設定を行っています：

1. **GitHubリポジトリの設定方法**:
   - リポジトリの「Settings」→「Branches」→「Branch protection rules」→「Add rule」
   - 「Branch name pattern」に `main` を指定

2. **有効化すべき保護設定**:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
     - 「Status checks that are required」で以下を選択:
       - backend-tests
       - frontend-build
       - security-check
   - ✅ Require branches to be up to date before merging

これにより、以下の保護が有効になります：

- テストが失敗したプルリクエストはマージできない
- 直接`main`ブランチへのプッシュが禁止される
- プルリクエストが最新の`main`ブランチの変更を取り込んでいることが必要

## テストユーザー

- メールアドレス: test@example.com
- パスワード: password

## CI/CD 環境

プロジェクトには以下の CI/CD 設定が含まれています：

### CI ワークフロー (`.github/workflows/ci.yml`)

継続的インテグレーション（CI）は以下のイベントで自動的に実行されます：

- `main`および`develop`ブランチへのプッシュ
- すべてのプルリクエストの作成と更新

実行される主なプロセス：

1. **コード品質チェック**：
   - フロントエンド: ESLint, Prettier
   - バックエンド: PHP_CodeSniffer, PHPStan/Larastan
2. **自動テスト**：
   - フロントエンド: Vitest
   - バックエンド: PHPUnit
3. **依存パッケージの脆弱性スキャン**：
   - npm audit (フロントエンド)
   - composer audit (バックエンド)

### CD ワークフロー (`.github/workflows/deploy.yml`)

継続的デプロイ（CD）は以下のイベントで自動的に実行されます：

- `main`ブランチへのプッシュ
- GitHub Actionsの「Actions」タブからの手動実行

実行される主なプロセス：

1. **コードのチェックアウト**
2. **Fly.io CLI のセットアップ**
3. **バックエンドのデプロイ** (`flyctl deploy --remote-only`)
4. **フロントエンドのデプロイ** (`flyctl deploy --remote-only`)

### 必要な環境変数

GitHub リポジトリの Secrets に以下の値を設定する必要があります：

- `FLY_API_TOKEN`: Fly.io の API トークン

## 環境構成（Fly.io）

### デプロイ済み環境

現在、以下の環境が Fly.io にデプロイされています：

| アプリケーション名                   | 種類               | メモリサイズ | URL                                              |
| ---------------------------------- | ------------------ | ---------- | ------------------------------------------------ |
| book-management-frontend           | フロントエンド         | 256MB       | https://book-management-frontend.fly.dev         |
| book-management-backend            | バックエンド           | 512MB       | https://book-management-backend.fly.dev          |
| book-management-db-mpg             | データベース           | 256MB       | 内部アクセスのみ                                 |
| book-management-frontend-staging   | ステージングフロントエンド | 256MB       | https://book-management-frontend-staging.fly.dev |
| book-management-backend-staging    | ステージングバックエンド   | 512MB       | https://book-management-backend-staging.fly.dev  |
| book-management-db-staging         | ステージングデータベース   | 256MB       | 内部アクセスのみ                                 |

**注意**: バックエンドアプリケーションはマイグレーション実行時に 512MB のメモリが必要です。フロントエンドは 256MB で充分です。

### コスト最適化設定

すべてのアプリケーションはコスト削減のために以下の設定がされています：

- `auto_stop_machines = true` - アクセスがないと自動的に停止
- `auto_start_machines = true` - アクセスがあると自動的に起動
- `min_machines_running = 0` - 常時稼働するマシンの最小数ゼロ

これにより、使用していない時間の課金を最小限に抑えられます。

### デプロイ状況の確認

各環境の状況は以下のコマンドで確認できます：

1. **アプリケーション一覧の確認**:
   ```bash
   fly apps list
   ```

2. **特定アプリケーションの状況確認**:
   ```bash
   fly status -a book-management-backend
   ```

3. **ログの確認**:
   ```bash
   fly logs -a book-management-backend
{{ ... }}

# フロントエンドのデプロイ
cd frontend && fly deploy
```

## デプロイフロー

プロジェクトは GitHub Actions を使用した CI/CD パイプラインで自動デプロイされます：

1. `main` ブランチへのマージでステージング環境に自動デプロイ
2. ステージング環境でのテストが成功すると本番環境に自動デプロイ

## トラブルシューティング

### 共有メモリ不足エラー

マイグレーション実行時に以下のエラーが発生する場合：

```
Could not create shared memory segment: No space left on device
```

**解決方法**:
1. バックエンドアプリケーションのメモリを 512MB に増やす
2. `php.ini` の共有メモリ設定を確認する

### データベース接続エラー

データベース接続に関するエラーが発生した場合：

**確認事項**:
1. 環境変数の設定が正しいか確認
   ```bash
   fly ssh console -a book-management-backend -C "printenv | grep DB_"
   ```

2. データベースサーバーが起動しているか確認
   ```bash
   fly status -a book-management-db-mpg
   ```

3. データベース接続をテスト
   ```bash
   fly ssh console -a book-management-backend -C "php artisan db:monitor"
   ```

### アプリケーションが起動しない場合

アプリケーションが起動しない場合は、手動で起動してみてください：

```bash
fly machine start -a book-management-backend
fly machine start -a book-management-frontend
```

## 開発者向けドキュメント

開発を進める際は、以下のドキュメントを参照してください：

- [デプロイ状況レポート](./docs/deployment-status.md) - 現在のデプロイ状況、解決済みの問題、今後のタスク

---

本プロジェクトは継続的に改善されています。問題や提案がある場合は、GitHub Issues に登録するか、プルリクエストを作成してください。
