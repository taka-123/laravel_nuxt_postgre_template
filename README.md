# 書籍管理システム

Laravel 12.x + Nuxt.js 3.16 + PostgreSQL 16.x を使用した書籍管理システムです。

## 開発環境のセットアップ

### 前提条件

- Docker Desktop がインストールされていること
- Node.js 18.0 以上がインストールされていること
- Git がインストールされていること
- Composer がインストールされていること（オプション、Docker 内で実行も可）

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

## テストユーザー

- メールアドレス: test@example.com
- パスワード: password

## 開発者向けドキュメント

開発を始める前に、以下のドキュメントを確認してください：

- [開発環境ガイド](./DEVELOPMENT.md) - コーディング規約、品質管理ツール、Git ワークフロー
- [詳細なセットアップ手順](./setup-procedure.md) - プロジェクト環境構築の詳細手順
- [Git ワークフロー](./docs/git-workflow.md) - ブランチ戦略とコミットメッセージ規約

## 本番環境へのデプロイ

本番環境へのデプロイは、AWSのECSを使用して自動化されています。

### ECSデプロイの前提条件

1. AWS ECSクラスター、サービス、およびタスク定義が作成されていること
2. Amazon ECRリポジトリが作成されていること
3. 必要なIAMロールとポリシーが設定されていること
4. GitHub Actions用のシークレットが設定されていること

### GitHub Secretsの設定

以下のシークレット値をGitHubリポジトリの設定で追加してください：

- `AWS_ACCESS_KEY_ID` - AWSアクセスキーID
- `AWS_SECRET_ACCESS_KEY` - AWSシークレットアクセスキー
- `AWS_REGION` - AWSリージョン
- `ECR_REPOSITORY_BACKEND` - バックエンド用ECRリポジトリ名
- `ECR_REPOSITORY_FRONTEND` - フロントエンド用ECRリポジトリ名
- `BACKEND_SERVICE_NAME` - バックエンドECSサービス名
- `FRONTEND_SERVICE_NAME` - フロントエンドECSサービス名
- `ECS_CLUSTER` - ECSクラスター名
- `DB_HOST` - データベースホスト
- `DB_DATABASE` - データベース名
- `DB_USERNAME` - データベースユーザー
- `PRODUCTION_API_URL` - 本番APIのパブリックURL
- `PRODUCTION_INTERNAL_API_URL` - ECS内部でのAPI通信用URL

### デプロイフロー

1. `main`ブランチにプッシュまたはマージすると、GitHub Actionsが起動します
2. テストが実行され、問題がなければデプロイが開始されます
3. Dockerイメージがビルドされ、Amazon ECRにプッシュされます
4. 新しいECSタスク定義が作成され、サービスが更新されます
5. アプリケーションが本番環境にデプロイされます

詳細なECS設定については、`.aws/`ディレクトリのファイルを参照してください。
