# 書籍管理システム

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した書籍管理システムです。

## 目次

- [書籍管理システム](#書籍管理システム)
  - [目次](#目次)
  - [プロジェクト構成](#プロジェクト構成)
  - [システム構成](#システム構成)
  - [開発環境のセットアップ](#開発環境のセットアップ)
    - [前提条件](#前提条件)
    - [推奨エディタとプラグイン](#推奨エディタとプラグイン)
      - [必須拡張機能](#必須拡張機能)
    - [ポート設定](#ポート設定)
  - [Docker 環境の起動方法](#docker-環境の起動方法)
    - [重要: 同時に両方の環境を起動しないでください](#重要-同時に両方の環境を起動しないでください)
    - [正しい起動方法](#正しい起動方法)
    - [正しい停止方法](#正しい停止方法)
  - [開発サーバーの起動](#開発サーバーの起動)
    - [Docker を使用した起動（推奨）](#docker-を使用した起動推奨)
    - [個別の起動方法](#個別の起動方法)
      - [バックエンド（Laravel）の起動](#バックエンドlaravelの起動)
      - [フロントエンド（Nuxt.js）の起動](#フロントエンドnuxtjsの起動)
  - [コード品質管理とテスト](#コード品質管理とテスト)
    - [Linter と Formatter](#linter-と-formatter)
      - [バックエンド](#バックエンド)
      - [フロントエンド](#フロントエンド)
      - [開発プロセスの自動化](#開発プロセスの自動化)
    - [テスト実行](#テスト実行)
      - [バックエンド](#バックエンド-1)
      - [フロントエンド](#フロントエンド-1)
    - [テスト駆動開発のプロセス](#テスト駆動開発のプロセス)
  - [Git ワークフロー](#git-ワークフロー)
    - [ブランチ戦略](#ブランチ戦略)
    - [開発プロセス](#開発プロセス)
    - [ブランチ保護設定](#ブランチ保護設定)
  - [テストユーザー](#テストユーザー)
  - [CI/CD 環境](#cicd-環境)
    - [CI ワークフロー](#ci-ワークフロー)
    - [CD ワークフロー](#cd-ワークフロー)
    - [必要な環境変数](#必要な環境変数)
  - [本番環境（Fly.io）](#本番環境flyio)
    - [デプロイ済み環境](#デプロイ済み環境)
    - [デプロイ状況の確認](#デプロイ状況の確認)
    - [手動デプロイ方法](#手動デプロイ方法)
  - [開発者向けドキュメント](#開発者向けドキュメント)

## プロジェクト構成

```
.
├── README.md             # このファイル（プロジェクト全体の概要）
├── docs/                 # プロジェクトドキュメント
│   └── deployment-status.md  # デプロイ状況レポート
├── backend/              # Laravel バックエンド
│   ├── README.md         # バックエンド固有の情報
│   └── .fly/             # Fly.io デプロイ設定
├── frontend/             # Nuxt.js フロントエンド
│   └── README.md         # フロントエンド固有の情報
└── .github/              # GitHub関連設定
    └── workflows/        # GitHub Actions ワークフロー
        └── deploy.yml    # 自動デプロイ設定
```

## システム構成

本システムは以下のコンポーネントで構成されています：

- **フロントエンド**: Nuxt.js 3.16 + Vuetify 3.x

  - SPA (Single Page Application) として実装
  - Fly.io にデプロイ: https://book-management-frontend.fly.dev

- **バックエンド**: Laravel 12.x (PHP 8.3)

  - RESTful API として実装
  - Fly.io にデプロイ: https://book-management-backend.fly.dev

- **データベース**: PostgreSQL 16.x
  - Fly.io Managed PostgreSQL (MPG) を使用
  - 高可用性と自動バックアップを実現

## 開発環境のセットアップ

### 前提条件

- Docker Desktop がインストールされていること
- Node.js 18.0 以上がインストールされていること
- Git がインストールされていること
- Composer がインストールされていること（オプション、Docker 内で実行も可）

### 推奨エディタとプラグイン

本プロジェクトは Visual Studio Code（VSCode）または互換エディタ（Cursor, Windsurf など）での開発を推奨しています。プロジェクトには `.vscode` ディレクトリが含まれており、推奨設定と拡張機能が定義されています。

#### 必須拡張機能

プロジェクトディレクトリを VSCode で開くと、推奨拡張機能のインストールが提案されます。以下の拡張機能は開発効率と品質を向上させるために重要です：

- **ESLint** - JavaScript/TypeScript コードの静的解析
- **Prettier** - コードフォーマッター
- **Volar** - Vue 3 のシンタックスハイライトと補完
- **PHP CS Fixer** - PHP コードの自動整形
- **PHP Intelephense** - PHP の高度な補完と検証
- **Laravel Extra Intellisense** - Laravel フレームワーク用の補完機能
- **EditorConfig** - エディタの共通設定
- **YAML** - YAML ファイルの編集サポート
- **Docker** - Docker 関連ファイルの編集サポート
- **Markdown All in One** - Markdown 編集の総合支援（目次生成、ショートカット等）
- **Markdown Mermaid** - Markdown プレビューでの Mermaid 図表示サポート
- **shell-format** - シェルスクリプトのフォーマット
- **GitLens** - コード行の Git 履歴（誰がいつ変更したか）を表示
- **indent-rainbow** - インデントの深さを色付けして可視化
- **Code Spell Checker** - コード内のスペルミスをチェック

VSCode を使用していない場合は、同等の機能を持つエディタプラグインをインストールしてください。

### ポート設定

| サービス               | ポート |
| ---------------------- | ------ |
| Laravel バックエンド   | 8000   |
| Nuxt.js フロントエンド | 3000   |
| PostgreSQL             | 5432   |
| pgAdmin                | 5050   |

## Docker 環境の起動方法

本プロジェクトでは 2 つの Docker Compose 設定があります：

1. **プロジェクトルートの`docker-compose.yml`**：

   - フロントエンド、バックエンド、データベースを一括で起動
   - 開発環境全体の構築に使用

2. **`backend/docker-compose.yml`**：
   - バックエンドのみ（Laravel + PostgreSQL）を起動
   - バックエンド単体の開発に使用

### 重要: 同時に両方の環境を起動しないでください

これらの設定には同じポートを使用するサービスが含まれるため、**どちらか一方のみを起動**してください。
両方を同時に起動するとポート競合が発生します。

### 正しい起動方法

```bash
# 全体環境を起動する場合
docker compose up -d

# または、バックエンドのみを起動する場合
cd backend
docker compose up -d
```

### 正しい停止方法

```bash
# 起動したのと同じディレクトリで停止する
docker compose down
```

既存の環境をすべて停止するには：

```bash
# 既存のコンテナをすべて確認
docker ps -a

# 特定のコンテナを停止・削除
docker stop [コンテナID] && docker rm [コンテナID]
```

## 開発サーバーの起動

### Docker を使用した起動（推奨）

1. Docker Desktop を起動します
2. 以下のコマンドを実行します：

```bash
docker compose up -d --build
```

### 個別の起動方法

#### バックエンド（Laravel）の起動

```bash
cd backend
php artisan serve
```

#### フロントエンド（Nuxt.js）の起動

```bash
cd frontend
npm run dev
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

## 本番環境（Fly.io）

本プロジェクトは Fly.io にデプロイされています：

### デプロイ済み環境

- **バックエンド API**: https://book-management-backend.fly.dev
- **フロントエンド**: https://book-management-frontend.fly.dev
- **データベース**: Fly.io Managed PostgreSQL (MPG)

### デプロイ状況の確認

デプロイの現在の状態や履歴は以下の方法で確認できます：

1. **ドキュメントによる確認**:

   - [デプロイ状況レポート](./docs/deployment-status.md) に最新の状態が記録されています

2. **Fly.io ダッシュボードによる確認**:

   ```bash
   fly status -a book-management-backend
   fly status -a book-management-frontend
   ```

3. **ログの確認**:
   ```bash
   fly logs -a book-management-backend
   fly logs -a book-management-frontend
   ```

### 手動デプロイ方法

必要に応じて、以下のコマンドで手動デプロイも可能です：

```bash
# バックエンドのデプロイ
cd backend && fly deploy

# フロントエンドのデプロイ
cd frontend && fly deploy
```

## 開発者向けドキュメント

開発を進める際は、以下のドキュメントを参照してください：

- [デプロイ状況レポート](./docs/deployment-status.md) - 現在のデプロイ状況、解決済みの問題、今後のタスク
- バックエンドとフロントエンドの各 README - コンポーネント固有の情報

---

本プロジェクトは継続的に改善されています。問題や提案がある場合は、GitHub Issues に登録するか、プルリクエストを作成してください。
