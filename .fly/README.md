# Fly.io デプロイガイド

このディレクトリには、Book Management アプリケーションを Fly.io にデプロイするためのスクリプトと設定ファイルが含まれています。

## 目次

1. [概要](#概要)
2. [前提条件](#前提条件)
3. [デプロイ手順](#デプロイ手順)
4. [Managed Postgres (MPG)](#managed-postgres-mpg)
5. [トラブルシューティング](#トラブルシューティング)
6. [コマンドリファレンス](#コマンドリファレンス)

## 概要

このプロジェクトは以下のコンポーネントで構成されています：

- **バックエンド**: Laravel アプリケーション（`/backend`）
- **フロントエンド**: Nuxt.js アプリケーション（`/frontend`）
- **データベース**: Fly.io の Managed Postgres

## 前提条件

1. **Fly CLI のインストール**

   ```bash
   # macOS の場合
   brew install flyctl

   # または curl を使用する場合
   curl -L https://fly.io/install.sh | sh
   ```

2. **Fly.io アカウントの作成とログイン**
   ```bash
   fly auth signup
   # または既存アカウントでログイン
   fly auth login
   ```

## デプロイ手順

### 自動デプロイ

すべてのコンポーネント（データベース、バックエンド、フロントエンド）を一度にデプロイするには：

```bash
.fly/deploy.sh
```

### オプション

以下のオプションが利用可能です：

- `--skip-db`: データベースのデプロイをスキップ
- `--skip-backend`: バックエンドのデプロイをスキップ
- `--skip-frontend`: フロントエンドのデプロイをスキップ
- `--non-interactive`: 対話なしでデプロイ（自動的に全ての質問にデフォルト回答）

例：

```bash
.fly/deploy.sh --skip-db
```

### インタラクティブな質問への回答方法

デプロイ中に表示される質問と推奨される回答：

1. **データベースパスワード**:

   ```
   データベースパスワード:
   ```

   - 初回デプロイ時に表示されたパスワードを入力

2. **設定のコピー確認**:

   ```
   ? Would you like to copy its configuration to the new app? (y/N)
   ```

   - 推奨回答: `Yes` (入力するか Enter キーを押す)

3. **設定確認**:

   ```
   ? Do you want to tweak these settings before proceeding? (y/N)
   ```

   - 推奨回答: `No` (入力するか Enter キーを押す)

4. **.dockerignore の作成確認**:

   ```
   ? Create .dockerignore from 18 .gitignore files? (y/N)
   ```

   - 推奨回答: `Yes` (ベストプラクティスとして推奨)

## Managed Postgres (MPG)

Fly.io は現在、Managed Postgres (MPG) を推奨しています。従来の Unmanaged Postgres は非推奨となっています。

### MPG の主な特徴

- 完全マネージド型の PostgreSQL サービス
- バックアップ、高可用性、フェイルオーバーを自動管理
- セキュリティパッチとバージョンアップグレードを自動実行

### MPG コマンド

```bash
# MPG インスタンスの作成
fly mpg create --name book-management-db --region nrt

# MPG への接続
fly mpg connect book-management-db

# プロキシ接続の設定（ローカル開発用）
fly mpg proxy book-management-db

# MPG インスタンスの一覧表示
fly mpg list
```

### 既存の Unmanaged Postgres から MPG への移行

現在のプロジェクトでは Unmanaged Postgres を使用していますが、将来的には MPG への移行を検討してください。移行手順は公式ドキュメントを参照してください。

## トラブルシューティング

### データベース接続エラー

1. データベース接続情報を確認：

   ```bash
   fly status -a book-management-db
   ```

2. データベースパスワードを再設定：

   ```bash
   fly secrets set POSTGRES_PASSWORD=新しいパスワード -a book-management-db
   ```

3. バックエンドの環境変数を更新：
   ```bash
   fly secrets set DATABASE_URL="postgres://postgres:新しいパスワード@book-management-db.internal:5432/postgres" -a book-management-backend
   ```

### デプロイエラー

1. アプリケーションのログを確認：

   ```bash
   fly logs -a book-management-backend
   ```

2. アプリケーションを再起動：
   ```bash
   fly restart -a book-management-backend
   ```

## コマンドリファレンス

### アプリケーション管理

```bash
# アプリケーションの一覧表示
fly apps list

# アプリケーションの詳細情報
fly status -a アプリ名

# アプリケーションのログ表示
fly logs -a アプリ名

# アプリケーションの再起動
fly restart -a アプリ名

# アプリケーションの削除
fly apps destroy アプリ名
```

### シークレット管理

```bash
# シークレットの設定
fly secrets set キー=値 -a アプリ名

# シークレットの一覧表示
fly secrets list -a アプリ名
```

### データベース管理

```bash
# データベースの状態確認
fly status -a データベース名

# データベースへの接続
fly mpg connect データベース名

# データベースのプロキシ接続
fly mpg proxy データベース名
```

---

詳細は [Fly.io の公式ドキュメント](https://fly.io/docs/) を参照してください。
