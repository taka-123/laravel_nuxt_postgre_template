# Fly.io 初回セットアップガイド

このガイドでは、Laravel + Nuxt.js テンプレートを Fly.io にデプロイするための初回セットアップ手順を説明します。

## 前提条件

- Git リポジトリがセットアップ済み
- Docker がローカルにインストール済み
- GitHub アカウントの準備

## 1. Fly.io CLI のインストール

### macOS / Linux

```bash
curl -L https://fly.io/install.sh | sh
```

### Windows (PowerShell)

```powershell
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

### パッケージマネージャーを使用

```bash
# Homebrew (macOS)
brew install flyctl

# npm
npm install -g @flydotio/flyctl
```

## 2. Fly.io アカウントへのログイン

```bash
fly auth login
```

ブラウザが開き、Fly.io アカウントにログインします。

## 3. API Token の取得

GitHub Actions で使用するための API Token を作成します。

```bash
fly tokens create
```

出力されたトークンをコピーして保存しておきます。

## 4. GitHub Secrets の設定

リポジトリの GitHub Secrets に以下の環境変数を追加します：

1. GitHub リポジトリページで **Settings** → **Secrets and variables** → **Actions** に移動
2. **New repository secret** をクリック
3. 以下の値を設定：

| Name | Value |
|------|-------|
| `FLY_API_TOKEN` | 手順3で取得した API Token |

## 5. アプリケーション名の設定

### 5.1 fly.toml の更新

以下のファイルでアプリ名を変更します：

**backend/fly.toml**
```toml
app = 'your-unique-backend-name'  # 任意のユニークな名前に変更
```

**frontend/fly.toml**
```toml
app = 'your-unique-frontend-name'  # 任意のユニークな名前に変更
```

### 5.2 フロントエンドの設定更新

**frontend/Dockerfile.fly** の環境変数も更新：
```dockerfile
ENV BROWSER_API_BASE_URL=${BROWSER_API_BASE_URL:-https://your-unique-backend-name.fly.dev/api}
ENV SERVER_API_BASE_URL=${SERVER_API_BASE_URL:-https://your-unique-backend-name.fly.dev/api}
```

## 6. 必要な環境変数一覧

### バックエンド (Laravel)

Fly.io にデプロイ時に設定が必要な環境変数：

```bash
# データベース設定（fly secrets set で設定）
fly secrets set DB_CONNECTION=pgsql -a your-unique-backend-name
fly secrets set DB_HOST=your-postgres-hostname -a your-unique-backend-name
fly secrets set DB_PORT=5432 -a your-unique-backend-name
fly secrets set DB_DATABASE=your-database-name -a your-unique-backend-name
fly secrets set DB_USERNAME=your-username -a your-unique-backend-name
fly secrets set DB_PASSWORD=your-password -a your-unique-backend-name

# Laravel設定
fly secrets set APP_KEY=base64:your-app-key -a your-unique-backend-name
fly secrets set APP_ENV=production -a your-unique-backend-name
fly secrets set APP_DEBUG=false -a your-unique-backend-name

# JWT設定
fly secrets set JWT_SECRET=your-jwt-secret -a your-unique-backend-name
```

### フロントエンド (Nuxt.js)

ビルド時に設定される環境変数：

```bash
# API接続設定（Dockerfile.flyで設定済み）
BROWSER_API_BASE_URL=https://your-unique-backend-name.fly.dev/api
SERVER_API_BASE_URL=https://your-unique-backend-name.fly.dev/api
```

## 7. PostgreSQL データベースの作成

```bash
# PostgreSQL インスタンスを作成
fly postgres create --name your-postgres-app-name

# データベースを作成
fly postgres connect -a your-postgres-app-name
# psql 内で実行:
# CREATE DATABASE your_database_name;
# \q でexit
```

## 8. 初回デプロイ

### 8.1 バックエンドのデプロイ

```bash
cd backend
fly deploy
```

### 8.2 フロントエンドのデプロイ

```bash
cd frontend
fly deploy
```

## 9. GitHub Actions の自動デプロイ

`.github/workflows/deploy.yml` が既に設定されているため、main ブランチにプッシュすると自動デプロイが実行されます。

## 10. デプロイ後の確認

### アプリケーションの確認

```bash
# バックエンドの状態確認
fly status -a your-unique-backend-name

# フロントエンドの状態確認
fly status -a your-unique-frontend-name

# ログの確認
fly logs -a your-unique-backend-name
fly logs -a your-unique-frontend-name
```

### ブラウザでアクセス

- フロントエンド: https://your-unique-frontend-name.fly.dev
- バックエンド API: https://your-unique-backend-name.fly.dev/api

## トラブルシューティング

### よくある問題

1. **アプリ名の重複エラー**
   ```
   Error: The app name "your-app-name" is already taken
   ```
   → 他のユニークな名前を選択してください

2. **データベース接続エラー**
   ```
   SQLSTATE[08006] [7] could not connect to server
   ```
   → データベースの環境変数設定を確認してください

3. **JWT シークレットエラー**
   ```
   JWT secret not found
   ```
   → `fly secrets set JWT_SECRET=...` でシークレットを設定してください

### ログの確認方法

```bash
# リアルタイムログの監視
fly logs -a your-app-name

# 過去のログを確認
fly logs -a your-app-name --since 1h
```

## 参考リンク

- [Fly.io 公式ドキュメント](https://fly.io/docs/)
- [Fly.io Postgres ガイド](https://fly.io/docs/postgres/)
- [GitHub Actions 公式ドキュメント](https://docs.github.com/ja/actions)